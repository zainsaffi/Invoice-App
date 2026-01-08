"use client";

import { useState, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Sidebar from "@/components/Sidebar";
import { InvoiceFormData, ItemTemplate } from "@/types/invoice";
import { ArrowLeft, Plus, Trash2, User, FileText, Package, CreditCard, ChevronDown, Save } from "lucide-react";

interface ItemSaveFlags {
  saveTitle: boolean;
  saveDescription: boolean;
}

export default function NewInvoicePage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState<InvoiceFormData>({
    clientName: "",
    clientEmail: "",
    clientBusinessName: "",
    clientAddress: "",
    description: "",
    items: [{ title: "", description: "", quantity: 1, unitPrice: 0 }],
    tax: 0,
    dueDate: "",
    paymentInstructions: "",
  });

  // Template state
  const [titleTemplates, setTitleTemplates] = useState<ItemTemplate[]>([]);
  const [descriptionTemplates, setDescriptionTemplates] = useState<ItemTemplate[]>([]);
  const [itemSaveFlags, setItemSaveFlags] = useState<ItemSaveFlags[]>([{ saveTitle: false, saveDescription: false }]);
  const [openDropdown, setOpenDropdown] = useState<{ index: number; type: 'title' | 'description' } | null>(null);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Fetch templates on mount
  useEffect(() => {
    const fetchTemplates = async () => {
      try {
        const [titlesRes, descriptionsRes] = await Promise.all([
          fetch('/api/item-templates?type=title'),
          fetch('/api/item-templates?type=description'),
        ]);
        if (titlesRes.ok) {
          const titles = await titlesRes.json();
          setTitleTemplates(titles);
        }
        if (descriptionsRes.ok) {
          const descriptions = await descriptionsRes.json();
          setDescriptionTemplates(descriptions);
        }
      } catch (error) {
        console.error('Error fetching templates:', error);
      }
    };
    fetchTemplates();
  }, []);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setOpenDropdown(null);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Initialize save flags when items change
  useEffect(() => {
    if (formData.items.length !== itemSaveFlags.length) {
      setItemSaveFlags(formData.items.map((_, i) =>
        itemSaveFlags[i] || { saveTitle: false, saveDescription: false }
      ));
    }
  }, [formData.items.length]);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === "tax" ? parseFloat(value) || 0 : value,
    }));
  };

  const handleItemChange = (
    index: number,
    field: string,
    value: string | number
  ) => {
    const newItems = [...formData.items];
    newItems[index] = {
      ...newItems[index],
      [field]:
        field === "quantity" || field === "unitPrice"
          ? parseFloat(value as string) || 0
          : value,
    };
    setFormData((prev) => ({ ...prev, items: newItems }));
  };

  const addItem = () => {
    setFormData((prev) => ({
      ...prev,
      items: [...prev.items, { title: "", description: "", quantity: 1, unitPrice: 0 }],
    }));
    setItemSaveFlags((prev) => [...prev, { saveTitle: false, saveDescription: false }]);
  };

  const removeItem = (index: number) => {
    if (formData.items.length > 1) {
      setFormData((prev) => ({
        ...prev,
        items: prev.items.filter((_, i) => i !== index),
      }));
      setItemSaveFlags((prev) => prev.filter((_, i) => i !== index));
    }
  };

  const toggleSaveFlag = (index: number, field: 'saveTitle' | 'saveDescription') => {
    setItemSaveFlags((prev) => {
      const newFlags = [...prev];
      newFlags[index] = { ...newFlags[index], [field]: !newFlags[index][field] };
      return newFlags;
    });
  };

  const selectTemplate = (index: number, type: 'title' | 'description', content: string) => {
    handleItemChange(index, type, content);
    setOpenDropdown(null);
  };

  const calculateSubtotal = () => {
    return formData.items.reduce(
      (sum, item) => sum + item.quantity * item.unitPrice,
      0
    );
  };

  const calculateTotal = () => {
    return calculateSubtotal() + formData.tax;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    // Save templates for items with "Save for future use" checked
    const savePromises: Promise<Response>[] = [];
    formData.items.forEach((item, index) => {
      const flags = itemSaveFlags[index];
      if (flags?.saveTitle && item.title.trim()) {
        savePromises.push(
          fetch('/api/item-templates', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ type: 'title', content: item.title.trim() }),
          })
        );
      }
      if (flags?.saveDescription && item.description.trim()) {
        savePromises.push(
          fetch('/api/item-templates', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ type: 'description', content: item.description.trim() }),
          })
        );
      }
    });

    // Save templates in parallel (don't block invoice submission)
    if (savePromises.length > 0) {
      Promise.all(savePromises).catch((err) => console.error('Error saving templates:', err));
    }

    try {
      const response = await fetch("/api/invoices", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      if (response.ok) {
        const invoice = await response.json();
        router.push(`/invoices/${invoice.id}`);
      } else {
        alert("Failed to create invoice");
      }
    } catch (error) {
      console.error("Error creating invoice:", error);
      alert("Failed to create invoice");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 ml-64">
        <div className="p-8">
          {/* Header */}
          <div className="flex items-center gap-4 mb-8">
            <Link
              href="/"
              className="p-2 text-gray-400 hover:text-gray-600 hover:bg-white rounded-lg transition-colors border border-transparent hover:border-gray-200 hover:shadow-sm"
            >
              <ArrowLeft className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Create Invoice</h1>
              <p className="text-gray-500 mt-0.5">Fill in the details to create a new invoice</p>
            </div>
          </div>

          <form onSubmit={handleSubmit}>
            <div className="grid grid-cols-3 gap-8">
              {/* Main Form */}
              <div className="col-span-2 space-y-6">
                {/* Client Details */}
                <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                      <User className="w-5 h-5 text-blue-600" />
                    </div>
                    <div>
                      <h2 className="text-lg font-semibold text-gray-900">Client Details</h2>
                      <p className="text-sm text-gray-500">Who is this invoice for?</p>
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Client Name <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="text"
                        name="clientName"
                        value={formData.clientName}
                        onChange={handleChange}
                        required
                        className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent focus:bg-white text-sm transition-all"
                        placeholder="Enter client name"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Client Email <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="email"
                        name="clientEmail"
                        value={formData.clientEmail}
                        onChange={handleChange}
                        required
                        className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent focus:bg-white text-sm transition-all"
                        placeholder="email@example.com"
                      />
                    </div>
                    <div className="col-span-2">
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Business Name
                      </label>
                      <input
                        type="text"
                        name="clientBusinessName"
                        value={formData.clientBusinessName}
                        onChange={handleChange}
                        className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent focus:bg-white text-sm transition-all"
                        placeholder="Enter client's business name"
                      />
                    </div>
                    <div className="col-span-2">
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Address
                      </label>
                      <textarea
                        name="clientAddress"
                        value={formData.clientAddress}
                        onChange={handleChange}
                        rows={2}
                        className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent focus:bg-white text-sm resize-none transition-all"
                        placeholder="Enter client address"
                      />
                    </div>
                  </div>
                </div>

                {/* Invoice Details */}
                <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-10 h-10 bg-purple-100 rounded-xl flex items-center justify-center">
                      <FileText className="w-5 h-5 text-purple-600" />
                    </div>
                    <div>
                      <h2 className="text-lg font-semibold text-gray-900">Invoice Details</h2>
                      <p className="text-sm text-gray-500">Description and due date</p>
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="col-span-2">
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Description <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="text"
                        name="description"
                        value={formData.description}
                        onChange={handleChange}
                        required
                        className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent focus:bg-white text-sm transition-all"
                        placeholder="Invoice description"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Due Date
                      </label>
                      <input
                        type="date"
                        name="dueDate"
                        value={formData.dueDate}
                        onChange={handleChange}
                        className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent focus:bg-white text-sm transition-all"
                      />
                    </div>
                  </div>
                </div>

                {/* Line Items */}
                <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-10 h-10 bg-emerald-100 rounded-xl flex items-center justify-center">
                      <Package className="w-5 h-5 text-emerald-600" />
                    </div>
                    <div>
                      <h2 className="text-lg font-semibold text-gray-900">Line Items</h2>
                      <p className="text-sm text-gray-500">Add products or services</p>
                    </div>
                  </div>

                  {/* Table Header */}
                  <div className="grid grid-cols-12 gap-4 mb-3 text-xs font-semibold text-gray-500 uppercase tracking-wide px-2">
                    <div className="col-span-6">Item Details</div>
                    <div className="col-span-2">Qty</div>
                    <div className="col-span-1">Price</div>
                    <div className="col-span-2">Total</div>
                    <div className="col-span-1"></div>
                  </div>

                  {/* Items */}
                  <div className="space-y-3">
                    {formData.items.map((item, index) => (
                      <div key={index} className="p-4 bg-gray-50 rounded-xl border border-gray-100">
                        <div className="grid grid-cols-12 gap-4">
                          {/* Title and Description */}
                          <div className="col-span-12 md:col-span-6 space-y-3" ref={openDropdown?.index === index ? dropdownRef : undefined}>
                            {/* Title Field */}
                            <div>
                              <label className="text-xs font-medium text-gray-500 mb-1 block">
                                Title <span className="text-red-500">*</span>
                              </label>
                              <div className="relative">
                                <input
                                  type="text"
                                  value={item.title}
                                  onChange={(e) => handleItemChange(index, "title", e.target.value)}
                                  required
                                  className="w-full px-3 py-2 pr-10 bg-white border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                                  placeholder="e.g., Flight Charter"
                                />
                                {titleTemplates.length > 0 && (
                                  <button
                                    type="button"
                                    onClick={() => setOpenDropdown(
                                      openDropdown?.index === index && openDropdown?.type === 'title'
                                        ? null
                                        : { index, type: 'title' }
                                    )}
                                    className="absolute right-2 top-1/2 -translate-y-1/2 w-6 h-6 flex items-center justify-center text-gray-400 hover:text-gray-600"
                                  >
                                    <ChevronDown className="w-4 h-4" />
                                  </button>
                                )}
                                {/* Title Dropdown */}
                                {openDropdown?.index === index && openDropdown?.type === 'title' && titleTemplates.length > 0 && (
                                  <div className="absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-48 overflow-y-auto">
                                    {titleTemplates.map((template) => (
                                      <button
                                        key={template.id}
                                        type="button"
                                        onClick={() => selectTemplate(index, 'title', template.content)}
                                        className="w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-100 flex justify-between items-center"
                                      >
                                        <span className="truncate">{template.content}</span>
                                        <span className="text-xs text-gray-400 ml-2">({template.usageCount})</span>
                                      </button>
                                    ))}
                                  </div>
                                )}
                              </div>
                              {/* Save Title Checkbox */}
                              <label className="flex items-center gap-2 mt-1.5 cursor-pointer">
                                <input
                                  type="checkbox"
                                  checked={itemSaveFlags[index]?.saveTitle || false}
                                  onChange={() => toggleSaveFlag(index, 'saveTitle')}
                                  className="w-3.5 h-3.5 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                                />
                                <span className="text-xs text-gray-500 flex items-center gap-1">
                                  <Save className="w-3 h-3" />
                                  Save title for future use
                                </span>
                              </label>
                            </div>

                            {/* Description Field */}
                            <div>
                              <label className="text-xs font-medium text-gray-500 mb-1 block">
                                Description
                              </label>
                              <div className="relative">
                                <textarea
                                  value={item.description}
                                  onChange={(e) => handleItemChange(index, "description", e.target.value)}
                                  rows={3}
                                  className="w-full px-3 py-2 pr-10 bg-white border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm resize-none"
                                  placeholder="Detailed description (optional)"
                                />
                                {descriptionTemplates.length > 0 && (
                                  <button
                                    type="button"
                                    onClick={() => setOpenDropdown(
                                      openDropdown?.index === index && openDropdown?.type === 'description'
                                        ? null
                                        : { index, type: 'description' }
                                    )}
                                    className="absolute right-2 top-2.5 w-6 h-6 flex items-center justify-center text-gray-400 hover:text-gray-600"
                                  >
                                    <ChevronDown className="w-4 h-4" />
                                  </button>
                                )}
                                {/* Description Dropdown */}
                                {openDropdown?.index === index && openDropdown?.type === 'description' && descriptionTemplates.length > 0 && (
                                  <div className="absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-48 overflow-y-auto">
                                    {descriptionTemplates.map((template) => (
                                      <button
                                        key={template.id}
                                        type="button"
                                        onClick={() => selectTemplate(index, 'description', template.content)}
                                        className="w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-100"
                                      >
                                        <div className="flex justify-between items-start">
                                          <span className="whitespace-pre-wrap text-xs">{template.content.length > 100 ? template.content.substring(0, 100) + '...' : template.content}</span>
                                          <span className="text-xs text-gray-400 ml-2 flex-shrink-0">({template.usageCount})</span>
                                        </div>
                                      </button>
                                    ))}
                                  </div>
                                )}
                              </div>
                              {/* Save Description Checkbox */}
                              <label className="flex items-center gap-2 mt-1.5 cursor-pointer">
                                <input
                                  type="checkbox"
                                  checked={itemSaveFlags[index]?.saveDescription || false}
                                  onChange={() => toggleSaveFlag(index, 'saveDescription')}
                                  className="w-3.5 h-3.5 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                                />
                                <span className="text-xs text-gray-500 flex items-center gap-1">
                                  <Save className="w-3 h-3" />
                                  Save description for future use
                                </span>
                              </label>
                            </div>
                          </div>

                          {/* Quantity, Price, Total, Delete */}
                          <div className="col-span-12 md:col-span-6">
                            <div className="grid grid-cols-12 gap-4 items-start">
                              <div className="col-span-4 md:col-span-4">
                                <label className="text-xs font-medium text-gray-500 mb-1 block">
                                  Qty
                                </label>
                                <input
                                  type="number"
                                  min="1"
                                  value={item.quantity}
                                  onChange={(e) => handleItemChange(index, "quantity", e.target.value)}
                                  required
                                  className="w-full px-3 py-2 bg-white border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                                />
                              </div>
                              <div className="col-span-4 md:col-span-3">
                                <label className="text-xs font-medium text-gray-500 mb-1 block">
                                  Price
                                </label>
                                <div className="relative">
                                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">$</span>
                                  <input
                                    type="number"
                                    min="0"
                                    step="0.01"
                                    value={item.unitPrice}
                                    onChange={(e) => handleItemChange(index, "unitPrice", e.target.value)}
                                    required
                                    className="w-full pl-7 pr-2 py-2 bg-white border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                                  />
                                </div>
                              </div>
                              <div className="col-span-3 md:col-span-4">
                                <label className="text-xs font-medium text-gray-500 mb-1 block">
                                  Total
                                </label>
                                <div className="px-3 py-2 bg-white border border-gray-200 rounded-lg text-sm font-medium text-gray-900">
                                  ${(item.quantity * item.unitPrice).toFixed(2)}
                                </div>
                              </div>
                              <div className="col-span-1 flex justify-center items-end pb-2">
                                <button
                                  type="button"
                                  onClick={() => removeItem(index)}
                                  disabled={formData.items.length === 1}
                                  className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-30 disabled:cursor-not-allowed"
                                >
                                  <Trash2 className="w-4 h-4" />
                                </button>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>

                  <button
                    type="button"
                    onClick={addItem}
                    className="mt-4 flex items-center gap-2 px-4 py-2.5 text-sm font-medium text-indigo-600 hover:text-indigo-700 hover:bg-indigo-50 rounded-lg transition-colors"
                  >
                    <Plus className="w-4 h-4" />
                    Add Line Item
                  </button>
                </div>

                {/* Payment Instructions */}
                <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-10 h-10 bg-orange-100 rounded-xl flex items-center justify-center">
                      <CreditCard className="w-5 h-5 text-orange-600" />
                    </div>
                    <div>
                      <h2 className="text-lg font-semibold text-gray-900">Payment Instructions</h2>
                      <p className="text-sm text-gray-500">How should the client pay?</p>
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Instructions
                    </label>
                    <textarea
                      name="paymentInstructions"
                      value={formData.paymentInstructions || ""}
                      onChange={handleChange}
                      rows={4}
                      className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent focus:bg-white text-sm resize-none transition-all"
                      placeholder="e.g., Please pay via bank transfer to Account #123456789 at ABC Bank. Reference: Your invoice number."
                    />
                    <p className="text-xs text-gray-400 mt-2">
                      These instructions will appear on the invoice and in emails sent to the client.
                    </p>
                  </div>
                </div>
              </div>

              {/* Summary Sidebar */}
              <div className="col-span-1">
                <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm sticky top-8">
                  <h2 className="text-lg font-semibold text-gray-900 mb-6">Summary</h2>

                  <div className="space-y-4 text-sm">
                    <div className="flex justify-between">
                      <span className="text-gray-500">Subtotal</span>
                      <span className="font-medium text-gray-900">${calculateSubtotal().toFixed(2)}</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-gray-500">Tax</span>
                      <div className="relative">
                        <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">$</span>
                        <input
                          type="number"
                          name="tax"
                          min="0"
                          step="0.01"
                          value={formData.tax}
                          onChange={handleChange}
                          className="w-24 pl-7 pr-2 py-1.5 bg-gray-50 border border-gray-200 rounded-lg text-right text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white"
                        />
                      </div>
                    </div>
                    <div className="pt-4 border-t border-gray-200">
                      <div className="flex justify-between">
                        <span className="font-semibold text-gray-900">Total</span>
                        <span className="text-2xl font-bold text-gray-900">
                          ${calculateTotal().toFixed(2)}
                        </span>
                      </div>
                    </div>
                  </div>

                  <button
                    type="submit"
                    disabled={isLoading}
                    className="mt-8 w-full px-4 py-3 bg-indigo-600 text-white text-sm font-medium rounded-xl hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors shadow-lg shadow-indigo-500/25"
                  >
                    {isLoading ? (
                      <span className="flex items-center justify-center gap-2">
                        <svg className="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
                          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                        </svg>
                        Creating...
                      </span>
                    ) : (
                      "Create Invoice"
                    )}
                  </button>

                  <Link
                    href="/"
                    className="mt-3 block w-full px-4 py-3 text-center text-gray-700 text-sm font-medium rounded-xl hover:bg-gray-50 border border-gray-200 transition-colors"
                  >
                    Cancel
                  </Link>
                </div>
              </div>
            </div>
          </form>
        </div>
      </main>
    </div>
  );
}
