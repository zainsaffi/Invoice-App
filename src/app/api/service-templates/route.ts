import { NextRequest, NextResponse } from "next/server";
import { query, queryMany, queryOne, ServiceTemplateRow, toServiceTemplate } from "@/db";
import { auth } from "@/lib/auth";
import { serviceTemplateSchema, uuidSchema } from "@/lib/validations";
import {
  checkRateLimit,
  rateLimitResponse,
  unauthorizedResponse,
  validationErrorResponse,
} from "@/lib/security";
import { v4 as uuidv4 } from "uuid";

// GET - List user's service templates
export async function GET(request: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    const { searchParams } = new URL(request.url);
    const serviceType = searchParams.get("type"); // 'trip', 'meals', 'travel', 'standard'

    let sql = `
      SELECT * FROM service_templates
      WHERE user_id = $1
    `;
    const params: unknown[] = [session.user.id];

    if (serviceType && ["trip", "meals", "travel", "standard"].includes(serviceType)) {
      sql += ` AND service_type = $2`;
      params.push(serviceType);
    }

    sql += ` ORDER BY usage_count DESC, created_at DESC`;

    const rows = await queryMany<ServiceTemplateRow>(sql, params);
    const templates = rows.map(toServiceTemplate);

    return NextResponse.json(templates);
  } catch (error) {
    console.error("Error fetching service templates:", error);
    return NextResponse.json(
      { error: "Failed to fetch service templates" },
      { status: 500 }
    );
  }
}

// POST - Create a new service template
export async function POST(request: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    // Rate limiting
    const rateLimit = await checkRateLimit(`service-template:create:${session.user.id}`, 50);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    const body = await request.json();
    const validation = serviceTemplateSchema.safeParse(body);

    if (!validation.success) {
      return validationErrorResponse(
        validation.error.issues.map((e) => e.message).join(", ")
      );
    }

    const { name, description, serviceType, defaultPrice, travelSubtype } = validation.data;

    // Create new template
    const id = uuidv4();
    await query(
      `INSERT INTO service_templates (id, user_id, name, description, service_type, default_price, travel_subtype, usage_count, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, 0, NOW(), NOW())`,
      [id, session.user.id, name, description, serviceType, defaultPrice, travelSubtype || null]
    );

    const row = await queryOne<ServiceTemplateRow>(
      `SELECT * FROM service_templates WHERE id = $1`,
      [id]
    );

    return NextResponse.json(row ? toServiceTemplate(row) : { id, name, description, serviceType, defaultPrice, travelSubtype, usageCount: 0 }, { status: 201 });
  } catch (error) {
    console.error("Error creating service template:", error);
    return NextResponse.json(
      { error: "Failed to create service template" },
      { status: 500 }
    );
  }
}

// PUT - Update a service template
export async function PUT(request: NextRequest) {
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

    // Verify ownership
    const existing = await queryOne<ServiceTemplateRow>(
      `SELECT * FROM service_templates WHERE id = $1 AND user_id = $2`,
      [templateId, session.user.id]
    );

    if (!existing) {
      return NextResponse.json({ error: "Template not found" }, { status: 404 });
    }

    const body = await request.json();
    const validation = serviceTemplateSchema.safeParse(body);

    if (!validation.success) {
      return validationErrorResponse(
        validation.error.issues.map((e) => e.message).join(", ")
      );
    }

    const { name, description, serviceType, defaultPrice, travelSubtype } = validation.data;

    await query(
      `UPDATE service_templates
       SET name = $1, description = $2, service_type = $3, default_price = $4, travel_subtype = $5, updated_at = NOW()
       WHERE id = $6`,
      [name, description, serviceType, defaultPrice, travelSubtype || null, templateId]
    );

    const row = await queryOne<ServiceTemplateRow>(
      `SELECT * FROM service_templates WHERE id = $1`,
      [templateId]
    );

    return NextResponse.json(row ? toServiceTemplate(row) : toServiceTemplate(existing));
  } catch (error) {
    console.error("Error updating service template:", error);
    return NextResponse.json(
      { error: "Failed to update service template" },
      { status: 500 }
    );
  }
}

// DELETE - Delete a service template
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
    const template = await queryOne<ServiceTemplateRow>(
      `SELECT * FROM service_templates WHERE id = $1 AND user_id = $2`,
      [templateId, session.user.id]
    );

    if (!template) {
      return NextResponse.json({ error: "Template not found" }, { status: 404 });
    }

    await query(`DELETE FROM service_templates WHERE id = $1`, [templateId]);

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Error deleting service template:", error);
    return NextResponse.json(
      { error: "Failed to delete service template" },
      { status: 500 }
    );
  }
}

// PATCH - Increment usage count (called when a template is used)
export async function PATCH(request: NextRequest) {
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

    // Verify ownership
    const template = await queryOne<ServiceTemplateRow>(
      `SELECT * FROM service_templates WHERE id = $1 AND user_id = $2`,
      [templateId, session.user.id]
    );

    if (!template) {
      return NextResponse.json({ error: "Template not found" }, { status: 404 });
    }

    await query(
      `UPDATE service_templates SET usage_count = usage_count + 1, updated_at = NOW() WHERE id = $1`,
      [templateId]
    );

    const row = await queryOne<ServiceTemplateRow>(
      `SELECT * FROM service_templates WHERE id = $1`,
      [templateId]
    );

    return NextResponse.json(row ? toServiceTemplate(row) : toServiceTemplate(template));
  } catch (error) {
    console.error("Error incrementing usage count:", error);
    return NextResponse.json(
      { error: "Failed to update template" },
      { status: 500 }
    );
  }
}
