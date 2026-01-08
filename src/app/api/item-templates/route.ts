import { NextRequest, NextResponse } from "next/server";
import { query, queryMany, queryOne, ItemTemplateRow, toItemTemplate } from "@/db";
import { auth } from "@/lib/auth";
import { itemTemplateSchema, uuidSchema } from "@/lib/validations";
import {
  checkRateLimit,
  rateLimitResponse,
  unauthorizedResponse,
  validationErrorResponse,
} from "@/lib/security";
import { v4 as uuidv4 } from "uuid";

// GET - List user's item templates
export async function GET(request: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    const { searchParams } = new URL(request.url);
    const type = searchParams.get("type"); // 'title' or 'description'

    let sql = `
      SELECT * FROM item_templates
      WHERE user_id = $1
    `;
    const params: unknown[] = [session.user.id];

    if (type && (type === "title" || type === "description")) {
      sql += ` AND type = $2`;
      params.push(type);
    }

    sql += ` ORDER BY usage_count DESC, created_at DESC`;

    const rows = await queryMany<ItemTemplateRow>(sql, params);
    const templates = rows.map(toItemTemplate);

    return NextResponse.json(templates);
  } catch (error) {
    console.error("Error fetching item templates:", error);
    return NextResponse.json(
      { error: "Failed to fetch item templates" },
      { status: 500 }
    );
  }
}

// POST - Create a new item template
export async function POST(request: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    // Rate limiting
    const rateLimit = await checkRateLimit(`item-template:create:${session.user.id}`, 50);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    const body = await request.json();
    const validation = itemTemplateSchema.safeParse(body);

    if (!validation.success) {
      return validationErrorResponse(
        validation.error.issues.map((e) => e.message).join(", ")
      );
    }

    const { type, content } = validation.data;

    // Check if template already exists for this user
    const existing = await queryOne<ItemTemplateRow>(
      `SELECT * FROM item_templates WHERE user_id = $1 AND type = $2 AND content = $3`,
      [session.user.id, type, content]
    );

    if (existing) {
      // Increment usage count instead of creating duplicate
      await query(
        `UPDATE item_templates SET usage_count = usage_count + 1, updated_at = NOW() WHERE id = $1`,
        [existing.id]
      );
      const updated = await queryOne<ItemTemplateRow>(
        `SELECT * FROM item_templates WHERE id = $1`,
        [existing.id]
      );
      return NextResponse.json(updated ? toItemTemplate(updated) : toItemTemplate(existing));
    }

    // Create new template
    const id = uuidv4();
    await query(
      `INSERT INTO item_templates (id, user_id, type, content, usage_count, created_at, updated_at)
       VALUES ($1, $2, $3, $4, 1, NOW(), NOW())`,
      [id, session.user.id, type, content]
    );

    const row = await queryOne<ItemTemplateRow>(
      `SELECT * FROM item_templates WHERE id = $1`,
      [id]
    );

    return NextResponse.json(row ? toItemTemplate(row) : { id, type, content, usageCount: 1 }, { status: 201 });
  } catch (error) {
    console.error("Error creating item template:", error);
    return NextResponse.json(
      { error: "Failed to create item template" },
      { status: 500 }
    );
  }
}

// DELETE - Delete an item template
export async function DELETE(request: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    const { searchParams } = new URL(request.url);
    const templateId = searchParams.get("id");

    if (!templateId) {
      return validationErrorResponse("Template ID is required");
    }

    const idValidation = uuidSchema.safeParse(templateId);
    if (!idValidation.success) {
      return validationErrorResponse("Invalid template ID format");
    }

    // Verify ownership before deleting
    const template = await queryOne<ItemTemplateRow>(
      `SELECT * FROM item_templates WHERE id = $1 AND user_id = $2`,
      [templateId, session.user.id]
    );

    if (!template) {
      return NextResponse.json({ error: "Template not found" }, { status: 404 });
    }

    await query(`DELETE FROM item_templates WHERE id = $1`, [templateId]);

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Error deleting item template:", error);
    return NextResponse.json(
      { error: "Failed to delete item template" },
      { status: 500 }
    );
  }
}
