import { prisma } from "@/lib/prisma";
import InvoiceTable from "@/components/InvoiceTable";
import Sidebar from "@/components/Sidebar";
import Link from "next/link";
import { Plus } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function InvoicesPage() {
  const invoices = await prisma.invoice.findMany({
    include: {
      items: true,
      receipts: true,
    },
    orderBy: {
      createdAt: "desc",
    },
  });

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 ml-64">
        <div className="p-8">
          {/* Header */}
          <div className="flex items-center justify-between mb-8">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Invoices</h1>
              <p className="text-gray-500 mt-1">Manage and track all your invoices</p>
            </div>
            <Link
              href="/invoices/new"
              className="flex items-center gap-2 px-4 py-2.5 bg-indigo-600 text-white text-sm font-medium rounded-xl hover:bg-indigo-700 transition-colors shadow-lg shadow-indigo-500/25"
            >
              <Plus className="w-4 h-4" />
              New Invoice
            </Link>
          </div>

          {/* Invoice Table */}
          <InvoiceTable invoices={invoices} />
        </div>
      </main>
    </div>
  );
}
