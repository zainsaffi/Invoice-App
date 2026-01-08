import { NextRequest, NextResponse } from "next/server";
import { query, queryOne, UserRow } from "@/db";
import { v4 as uuid } from "uuid";
import bcrypt from "bcryptjs";
import { z } from "zod";
import {
  checkRateLimit,
  rateLimitResponse,
  getClientIp,
  validationErrorResponse,
} from "@/lib/security";

const registerSchema = z.object({
  email: z
    .string()
    .min(1, "Email is required")
    .email("Invalid email format")
    .max(255, "Email too long")
    .toLowerCase()
    .trim(),
  password: z
    .string()
    .min(8, "Password must be at least 8 characters")
    .max(100, "Password too long")
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
      "Password must contain at least one uppercase letter, one lowercase letter, and one number"
    ),
  name: z
    .string()
    .min(1, "Name is required")
    .max(255, "Name too long")
    .trim(),
});

export async function POST(request: NextRequest) {
  try {
    // Rate limiting - stricter for registration
    const ip = getClientIp(request);
    const rateLimit = await checkRateLimit(`register:${ip}`, 5, 60 * 60 * 1000); // 5 per hour

    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    const body = await request.json();

    // Validate input
    const validation = registerSchema.safeParse(body);
    if (!validation.success) {
      const errors = validation.error.issues.map((e) => e.message).join(", ");
      return validationErrorResponse(errors);
    }

    const { email, password, name } = validation.data;

    // Check if user already exists
    const existingUser = await queryOne<UserRow>(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );

    if (existingUser) {
      return NextResponse.json(
        { error: "An account with this email already exists" },
        { status: 409 }
      );
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const userId = uuid();
    const now = new Date();
    await query(
      `INSERT INTO users (id, email, password, name, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, $6)`,
      [userId, email, hashedPassword, name, now, now]
    );

    // Fetch created user (excluding password)
    const user = await queryOne<Pick<UserRow, 'id' | 'email' | 'name' | 'created_at'>>(
      "SELECT id, email, name, created_at FROM users WHERE id = $1",
      [userId]
    );

    return NextResponse.json(
      {
        message: "Account created successfully",
        user: user ? {
          id: user.id,
          email: user.email,
          name: user.name,
          createdAt: user.created_at,
        } : null,
      },
      { status: 201 }
    );
  } catch (error) {
    console.error("Registration error:", error);
    return NextResponse.json(
      { error: "Failed to create account" },
      { status: 500 }
    );
  }
}
