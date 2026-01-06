import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { writeFile, mkdir, unlink } from "fs/promises";
import path from "path";
import { v4 as uuidv4 } from "uuid";
import { auth } from "@/lib/auth";
import { uuidSchema } from "@/lib/validations";
import {
  checkRateLimit,
  rateLimitResponse,
  unauthorizedResponse,
  forbiddenResponse,
  validationErrorResponse,
  validateCsrfToken,
  logAudit,
  checkInvoiceOwnership,
  validateFileType,
  validateFileExtension,
  sanitizeFilename,
  MAX_FILE_SIZE,
} from "@/lib/security";

// Allowed MIME types
const ALLOWED_MIME_TYPES = [
  "image/jpeg",
  "image/png",
  "image/gif",
  "image/webp",
  "application/pdf",
];

// Extension to MIME type mapping
const EXTENSION_MIME_MAP: Record<string, string> = {
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".png": "image/png",
  ".gif": "image/gif",
  ".webp": "image/webp",
  ".pdf": "application/pdf",
};

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    // Authentication check
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    // CSRF validation
    if (!validateCsrfToken(request)) {
      return NextResponse.json(
        { error: "Invalid request origin" },
        { status: 403 }
      );
    }

    const { id } = await params;

    // Validate ID format
    const idValidation = uuidSchema.safeParse(id);
    if (!idValidation.success) {
      return validationErrorResponse("Invalid invoice ID format");
    }

    // Rate limiting - stricter for file uploads
    const rateLimit = await checkRateLimit(`receipt:upload:${session.user.id}`, 20);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Authorization: check ownership
    const isOwner = await checkInvoiceOwnership(id, session.user.id);
    if (!isOwner) {
      return forbiddenResponse();
    }

    const formData = await request.formData();
    const file = formData.get("file") as File;

    if (!file) {
      return validationErrorResponse("No file provided");
    }

    // Validate file size
    if (file.size > MAX_FILE_SIZE) {
      return validationErrorResponse(
        `File size must be less than ${MAX_FILE_SIZE / (1024 * 1024)}MB`
      );
    }

    if (file.size === 0) {
      return validationErrorResponse("File is empty");
    }

    // Sanitize filename
    const sanitizedFilename = sanitizeFilename(file.name);
    if (!sanitizedFilename) {
      return validationErrorResponse("Invalid filename");
    }

    // Validate file extension
    if (!validateFileExtension(sanitizedFilename)) {
      return validationErrorResponse(
        "Invalid file type. Allowed: JPEG, PNG, GIF, WebP, PDF"
      );
    }

    // Get file extension and expected MIME type
    const fileExtension = path.extname(sanitizedFilename).toLowerCase();
    const expectedMimeType = EXTENSION_MIME_MAP[fileExtension];

    // Validate declared MIME type
    if (!ALLOWED_MIME_TYPES.includes(file.type)) {
      return validationErrorResponse(
        "Invalid file type. Allowed: JPEG, PNG, GIF, WebP, PDF"
      );
    }

    // Read file bytes
    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);

    // Validate file content matches declared type (magic bytes check)
    if (!validateFileType(buffer, file.type)) {
      return validationErrorResponse(
        "File content does not match declared type"
      );
    }

    // Also verify MIME type matches extension
    if (expectedMimeType && expectedMimeType !== file.type) {
      return validationErrorResponse(
        "File extension does not match file type"
      );
    }

    // Create secure upload directory using user ID to prevent enumeration
    const uploadDir = path.join(
      process.cwd(),
      "uploads", // Note: NOT in public folder
      session.user.id,
      id
    );
    await mkdir(uploadDir, { recursive: true });

    // Generate unique filename with validated extension
    const uniqueFilename = `${uuidv4()}${fileExtension}`;
    const filepath = path.join(uploadDir, uniqueFilename);

    // Write file
    await writeFile(filepath, buffer);

    // Store relative path for serving through API
    const receipt = await prisma.receipt.create({
      data: {
        filename: sanitizedFilename,
        filepath: `/api/receipts/${session.user.id}/${id}/${uniqueFilename}`,
        mimeType: file.type,
        size: file.size,
        invoiceId: id,
      },
    });

    // Audit log
    await logAudit(
      session.user.id,
      "create",
      "receipt",
      receipt.id,
      { filename: sanitizedFilename, size: file.size, invoiceId: id },
      request
    );

    return NextResponse.json(receipt, { status: 201 });
  } catch (error) {
    console.error("Error uploading receipt:", error);
    return NextResponse.json(
      { error: "Failed to upload receipt" },
      { status: 500 }
    );
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    // Authentication check
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    // CSRF validation
    if (!validateCsrfToken(request)) {
      return NextResponse.json(
        { error: "Invalid request origin" },
        { status: 403 }
      );
    }

    const { id } = await params;

    // Validate invoice ID format
    const idValidation = uuidSchema.safeParse(id);
    if (!idValidation.success) {
      return validationErrorResponse("Invalid invoice ID format");
    }

    const { searchParams } = new URL(request.url);
    const receiptId = searchParams.get("receiptId");

    if (!receiptId) {
      return validationErrorResponse("Receipt ID required");
    }

    // Validate receipt ID format
    const receiptIdValidation = uuidSchema.safeParse(receiptId);
    if (!receiptIdValidation.success) {
      return validationErrorResponse("Invalid receipt ID format");
    }

    // Rate limiting
    const rateLimit = await checkRateLimit(`receipt:delete:${session.user.id}`, 30);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Authorization: check invoice ownership
    const isOwner = await checkInvoiceOwnership(id, session.user.id);
    if (!isOwner) {
      return forbiddenResponse();
    }

    // Find receipt and verify it belongs to this invoice
    const receipt = await prisma.receipt.findFirst({
      where: {
        id: receiptId,
        invoiceId: id,
      },
    });

    if (!receipt) {
      return NextResponse.json({ error: "Receipt not found" }, { status: 404 });
    }

    // Delete file from disk
    try {
      // Extract actual file path from stored path
      const pathParts = receipt.filepath.split("/");
      const filename = pathParts[pathParts.length - 1];
      const actualPath = path.join(
        process.cwd(),
        "uploads",
        session.user.id,
        id,
        filename
      );
      await unlink(actualPath);
    } catch (fileError) {
      // Log but don't fail if file doesn't exist
      console.error("Error deleting file from disk:", fileError);
    }

    // Delete database record
    await prisma.receipt.delete({
      where: { id: receiptId },
    });

    // Audit log
    await logAudit(
      session.user.id,
      "delete",
      "receipt",
      receiptId,
      { invoiceId: id },
      request
    );

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Error deleting receipt:", error);
    return NextResponse.json(
      { error: "Failed to delete receipt" },
      { status: 500 }
    );
  }
}
