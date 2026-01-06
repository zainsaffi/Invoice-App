import { NextRequest, NextResponse } from "next/server";
import { prisma } from "./prisma";
import { auth } from "./auth";

// Rate limiting configuration
const RATE_LIMIT_WINDOW_MS = 60 * 1000; // 1 minute
const RATE_LIMIT_MAX_REQUESTS = 60; // 60 requests per minute

// Get client IP from request
export function getClientIp(request: NextRequest): string {
  const forwarded = request.headers.get("x-forwarded-for");
  const realIp = request.headers.get("x-real-ip");

  if (forwarded) {
    return forwarded.split(",")[0].trim();
  }

  if (realIp) {
    return realIp;
  }

  return "unknown";
}

// Rate limiting check
export async function checkRateLimit(
  key: string,
  maxRequests: number = RATE_LIMIT_MAX_REQUESTS,
  windowMs: number = RATE_LIMIT_WINDOW_MS
): Promise<{ allowed: boolean; remaining: number; resetAt: Date }> {
  const now = new Date();
  const windowStart = new Date(now.getTime() - windowMs);

  try {
    // Find or create rate limit record
    let rateLimit = await prisma.rateLimit.findUnique({
      where: { key },
    });

    if (!rateLimit || rateLimit.windowStart < windowStart) {
      // Create new window
      rateLimit = await prisma.rateLimit.upsert({
        where: { key },
        update: { count: 1, windowStart: now },
        create: { key, count: 1, windowStart: now },
      });

      return {
        allowed: true,
        remaining: maxRequests - 1,
        resetAt: new Date(now.getTime() + windowMs),
      };
    }

    // Check if limit exceeded
    if (rateLimit.count >= maxRequests) {
      return {
        allowed: false,
        remaining: 0,
        resetAt: new Date(rateLimit.windowStart.getTime() + windowMs),
      };
    }

    // Increment counter
    await prisma.rateLimit.update({
      where: { key },
      data: { count: { increment: 1 } },
    });

    return {
      allowed: true,
      remaining: maxRequests - rateLimit.count - 1,
      resetAt: new Date(rateLimit.windowStart.getTime() + windowMs),
    };
  } catch (error) {
    // On error, allow the request but log
    console.error("Rate limit check error:", error);
    return {
      allowed: true,
      remaining: maxRequests,
      resetAt: new Date(now.getTime() + windowMs),
    };
  }
}

// Rate limit middleware response
export function rateLimitResponse(resetAt: Date): NextResponse {
  return NextResponse.json(
    { error: "Too many requests. Please try again later." },
    {
      status: 429,
      headers: {
        "Retry-After": Math.ceil((resetAt.getTime() - Date.now()) / 1000).toString(),
        "X-RateLimit-Reset": resetAt.toISOString(),
      },
    }
  );
}

// CSRF token validation
export function validateCsrfToken(request: NextRequest): boolean {
  // For API routes, we check the Origin/Referer headers
  const origin = request.headers.get("origin");
  const referer = request.headers.get("referer");
  const host = request.headers.get("host");

  // Allow requests without Origin (same-origin requests)
  if (!origin && !referer) {
    return true;
  }

  // Check if origin matches host
  if (origin) {
    try {
      const originUrl = new URL(origin);
      if (originUrl.host === host) {
        return true;
      }
    } catch {
      return false;
    }
  }

  // Check referer as fallback
  if (referer) {
    try {
      const refererUrl = new URL(referer);
      if (refererUrl.host === host) {
        return true;
      }
    } catch {
      return false;
    }
  }

  return false;
}

// Unauthorized response
export function unauthorizedResponse(): NextResponse {
  return NextResponse.json(
    { error: "Unauthorized. Please log in." },
    { status: 401 }
  );
}

// Forbidden response
export function forbiddenResponse(): NextResponse {
  return NextResponse.json(
    { error: "Forbidden. You do not have access to this resource." },
    { status: 403 }
  );
}

// Validation error response
export function validationErrorResponse(error: string): NextResponse {
  return NextResponse.json({ error }, { status: 400 });
}

// Audit logging
export async function logAudit(
  userId: string,
  action: string,
  entity: string,
  entityId: string | null,
  details: Record<string, unknown> | null,
  request: NextRequest
): Promise<void> {
  try {
    await prisma.auditLog.create({
      data: {
        userId,
        action,
        entity,
        entityId,
        details: details ? JSON.stringify(details) : null,
        ipAddress: getClientIp(request),
        userAgent: request.headers.get("user-agent") || null,
      },
    });
  } catch (error) {
    // Don't fail the request if audit logging fails
    console.error("Audit logging error:", error);
  }
}

// Check if user owns the invoice
export async function checkInvoiceOwnership(
  invoiceId: string,
  userId: string
): Promise<boolean> {
  const invoice = await prisma.invoice.findFirst({
    where: {
      id: invoiceId,
      userId: userId,
    },
  });
  return !!invoice;
}

// File type validation using magic bytes
const FILE_SIGNATURES: Record<string, number[][]> = {
  "image/jpeg": [[0xff, 0xd8, 0xff]],
  "image/png": [[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]],
  "image/gif": [
    [0x47, 0x49, 0x46, 0x38, 0x37, 0x61],
    [0x47, 0x49, 0x46, 0x38, 0x39, 0x61],
  ],
  "image/webp": [[0x52, 0x49, 0x46, 0x46]], // RIFF header (WebP starts with RIFF)
  "application/pdf": [[0x25, 0x50, 0x44, 0x46]], // %PDF
};

export function validateFileType(
  buffer: Buffer,
  declaredMimeType: string
): boolean {
  const signatures = FILE_SIGNATURES[declaredMimeType];
  if (!signatures) {
    return false;
  }

  return signatures.some((signature) => {
    for (let i = 0; i < signature.length; i++) {
      if (buffer[i] !== signature[i]) {
        return false;
      }
    }
    return true;
  });
}

// Allowed file extensions
const ALLOWED_EXTENSIONS = [".jpg", ".jpeg", ".png", ".gif", ".webp", ".pdf"];

export function validateFileExtension(filename: string): boolean {
  const ext = filename.toLowerCase().split(".").pop();
  return ext ? ALLOWED_EXTENSIONS.includes(`.${ext}`) : false;
}

// Sanitize filename
export function sanitizeFilename(filename: string): string {
  // Remove path separators and null bytes
  return filename
    .replace(/[/\\]/g, "")
    .replace(/\0/g, "")
    .replace(/\.\./g, "")
    .substring(0, 255);
}

// Max file size (10MB)
export const MAX_FILE_SIZE = 10 * 1024 * 1024;
