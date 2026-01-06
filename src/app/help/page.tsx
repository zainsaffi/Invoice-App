import Sidebar from "@/components/Sidebar";
import { HelpCircle, Book, MessageCircle, Mail, ExternalLink } from "lucide-react";
import Link from "next/link";

export default function HelpPage() {
  const faqs = [
    {
      question: "How do I create an invoice?",
      answer: "Click the 'New Invoice' button in the sidebar or on the dashboard. Fill in the client details, add line items, and click 'Create Invoice'.",
    },
    {
      question: "How do I send an invoice to a client?",
      answer: "Open an invoice and click the 'Send Invoice' button. The invoice will be emailed to the client's email address.",
    },
    {
      question: "How do I mark an invoice as paid?",
      answer: "Open the invoice and click the 'Mark Paid' button. You can also specify the payment method used.",
    },
    {
      question: "Can I attach receipts to invoices?",
      answer: "Yes! Open an invoice and scroll to the Attachments section. You can upload PDFs, images, and other documents.",
    },
  ];

  const resources = [
    {
      title: "Getting Started Guide",
      description: "Learn the basics of creating and managing invoices",
      icon: Book,
      href: "#",
    },
    {
      title: "Contact Support",
      description: "Get help from our support team",
      icon: MessageCircle,
      href: "#",
    },
    {
      title: "Email Us",
      description: "support@invoiceapp.com",
      icon: Mail,
      href: "mailto:support@invoiceapp.com",
    },
  ];

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 ml-64">
        <div className="p-8">
          {/* Header */}
          <div className="mb-8">
            <h1 className="text-2xl font-bold text-gray-900">Help & Support</h1>
            <p className="text-gray-500 mt-1">Get answers to common questions</p>
          </div>

          <div className="grid grid-cols-3 gap-8">
            {/* FAQs */}
            <div className="col-span-2">
              <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
                <div className="px-6 py-4 border-b border-gray-200">
                  <h2 className="text-lg font-semibold text-gray-900">Frequently Asked Questions</h2>
                </div>
                <div className="divide-y divide-gray-200">
                  {faqs.map((faq, index) => (
                    <div key={index} className="p-6">
                      <h3 className="text-sm font-semibold text-gray-900 mb-2">{faq.question}</h3>
                      <p className="text-sm text-gray-600">{faq.answer}</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Resources */}
            <div className="col-span-1 space-y-6">
              <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
                <div className="px-6 py-4 border-b border-gray-200">
                  <h2 className="text-lg font-semibold text-gray-900">Resources</h2>
                </div>
                <div className="p-4 space-y-2">
                  {resources.map((resource, index) => (
                    <Link
                      key={index}
                      href={resource.href}
                      className="flex items-start gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors group"
                    >
                      <div className="w-10 h-10 bg-indigo-100 rounded-xl flex items-center justify-center flex-shrink-0">
                        <resource.icon className="w-5 h-5 text-indigo-600" />
                      </div>
                      <div className="flex-1">
                        <p className="text-sm font-medium text-gray-900 group-hover:text-indigo-600 transition-colors">
                          {resource.title}
                        </p>
                        <p className="text-xs text-gray-500">{resource.description}</p>
                      </div>
                      <ExternalLink className="w-4 h-4 text-gray-400 opacity-0 group-hover:opacity-100 transition-opacity" />
                    </Link>
                  ))}
                </div>
              </div>

              <div className="bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl p-6 text-white shadow-lg">
                <HelpCircle className="w-8 h-8 mb-4 opacity-80" />
                <h3 className="font-semibold mb-2">Need more help?</h3>
                <p className="text-sm opacity-80 mb-4">
                  Our support team is available Monday to Friday, 9am - 5pm EST.
                </p>
                <button className="w-full px-4 py-2.5 bg-white text-indigo-600 text-sm font-medium rounded-lg hover:bg-gray-100 transition-colors">
                  Contact Support
                </button>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
