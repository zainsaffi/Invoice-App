"use client";

import { useState, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Sidebar from "@/components/Sidebar";
import TripLegsEditor from "@/components/TripLegsEditor";
import { InvoiceFormData, InvoiceItem, ItemTemplate, ServiceTemplate, TripLeg, ServiceType, TravelSubtype, Customer, INVOICE_STATUSES, SERVICE_TYPES, TRAVEL_SUBTYPES } from "@/types/invoice";
import { ArrowLeft, Plus, Trash2, ChevronDown, Check, Package, Plane, Utensils, Car, Users } from "lucide-react";

interface ItemSaveFlags {
  saveTitle: boolean;
  saveDescription: boolean;
}

// Default templates - always available
const DEFAULT_TITLE_TEMPLATES: ItemTemplate[] = [
  { id: 'default-1', type: 'title', content: 'CJ - PIC - Day Rate', usageCount: 10, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
  { id: 'default-2', type: 'title', content: 'Travel', usageCount: 5, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
  { id: 'default-3', type: 'title', content: 'Meals', usageCount: 5, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
];

const DEFAULT_DESCRIPTION_TEMPLATES: ItemTemplate[] = [
  { id: 'default-desc-1', type: 'description', content: 'Pilot:\nTrip Dates:\nItinerary:\nLead Passenger:', usageCount: 10, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
];

const DEFAULT_PAYMENT_INSTRUCTIONS = `Jordan Hardison / Sosocial.media
Phone: 772-323-5828
Email: jordanahardison@gmail.com
Mailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982

Bank Info:
Company Name: AIO.Church
Bank Name: Coastal Community Bank
ACH/Routing: 125109019
Account #: 8751-0692-4355`;

export default function NewInvoicePage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState<InvoiceFormData>({
    clientName: "",
    clientEmail: "",
    clientBusinessName: "",
    clientAddress: "",
    items: [{ title: "", description: "", quantity: 1, unitPrice: 0, serviceType: 'standard' }],
    tax: 0,
    dueDate: "",
    paymentInstructions: DEFAULT_PAYMENT_INSTRUCTIONS,
    status: "due",
  });

  // Template state - initialize with defaults
  const [titleTemplates, setTitleTemplates] = useState<ItemTemplate[]>(DEFAULT_TITLE_TEMPLATES);
  const [descriptionTemplates, setDescriptionTemplates] = useState<ItemTemplate[]>(DEFAULT_DESCRIPTION_TEMPLATES);
  const [serviceTemplates, setServiceTemplates] = useState<ServiceTemplate[]>([]);
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [selectedCustomerId, setSelectedCustomerId] = useState<string>("");
  const [itemSaveFlags, setItemSaveFlags] = useState<ItemSaveFlags[]>([{ saveTitle: false, saveDescription: false }]);
  const [openDropdown, setOpenDropdown] = useState<{ index: number; type: 'title' | 'description' | 'service' | 'customer' } | null>(null);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Fetch templates and customers on mount
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [titlesRes, descriptionsRes, servicesRes, customersRes] = await Promise.all([
          fetch('/api/item-templates?type=title'),
          fetch('/api/item-templates?type=description'),
          fetch('/api/service-templates'),
          fetch('/api/customers'),
        ]);
        if (titlesRes.ok) {
          const titles = await titlesRes.json();
          // Filter out any templates that look like descriptions (contain newlines or are too long)
          const validTitles = titles.filter((t: ItemTemplate) =>
            !t.content.includes('\n') && t.content.length <= 100
          );
          // Start with defaults first, then add user's saved templates
          const allTitles = [...DEFAULT_TITLE_TEMPLATES];
          validTitles.forEach((t: ItemTemplate) => {
            if (!allTitles.some((dt) => dt.content === t.content)) {
              allTitles.push(t);
            }
          });
          setTitleTemplates(allTitles);
        }
        if (descriptionsRes.ok) {
          const descriptions = await descriptionsRes.json();
          // Start with defaults first, then add user's saved templates
          const allDescs = [...DEFAULT_DESCRIPTION_TEMPLATES];
          descriptions.forEach((d: ItemTemplate) => {
            if (!allDescs.some((dd) => dd.content === d.content)) {
              allDescs.push(d);
            }
          });
          setDescriptionTemplates(allDescs);
        }
        if (servicesRes.ok) {
          const services = await servicesRes.json();
          setServiceTemplates(services);
        }
        if (customersRes.ok) {
          const customersData = await customersRes.json();
          setCustomers(customersData);
        }
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };
    fetchData();
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
  }, [formData.items.length, itemSaveFlags]);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === "tax" ? parseFloat(value) || 0 : value,
    }));
  };

  const handleSelectCustomer = (customer: Customer) => {
    setSelectedCustomerId(customer.id);
    setFormData((prev) => ({
      ...prev,
      clientName: customer.name,
      clientEmail: customer.email,
      clientBusinessName: customer.businessName || "",
      clientAddress: customer.address || "",
      customerId: customer.id,
    }));
    setOpenDropdown(null);
  };

  const clearCustomerSelection = () => {
    setSelectedCustomerId("");
    setFormData((prev) => ({
      ...prev,
      clientName: "",
      clientEmail: "",
      clientBusinessName: "",
      clientAddress: "",
      customerId: undefined,
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
      items: [...prev.items, { title: "", description: "", quantity: 1, unitPrice: 0, serviceType: 'standard' }],
    }));
    setItemSaveFlags((prev) => [...prev, { saveTitle: false, saveDescription: false }]);
  };

  const addFromServiceTemplate = async (template: ServiceTemplate) => {
    // Increment usage count
    fetch(`/api/service-templates?id=${template.id}`, { method: 'PATCH' }).catch(() => {});

    const newItem: InvoiceItem = {
      title: template.name,
      description: template.description,
      quantity: 1,
      unitPrice: template.defaultPrice,
      serviceType: template.serviceType as ServiceType,
      travelSubtype: template.travelSubtype as TravelSubtype | undefined,
      legs: template.serviceType === 'trip' ? [] : undefined,
    };
    setFormData((prev) => ({
      ...prev,
      items: [...prev.items, newItem],
    }));
    setItemSaveFlags((prev) => [...prev, { saveTitle: false, saveDescription: false }]);
    setOpenDropdown(null);
  };

  const updateItemLegs = (index: number, legs: TripLeg[]) => {
    const newItems = [...formData.items];
    newItems[index] = { ...newItems[index], legs };
    setFormData((prev) => ({ ...prev, items: newItems }));
  };

  const updateItemServiceType = (index: number, serviceType: ServiceType) => {
    const newItems = [...formData.items];
    newItems[index] = {
      ...newItems[index],
      serviceType,
      travelSubtype: serviceType === 'travel' ? 'other' : undefined,
      legs: serviceType === 'trip' ? [] : undefined,
    };
    setFormData((prev) => ({ ...prev, items: newItems }));
  };

  const updateItemTravelSubtype = (index: number, travelSubtype: TravelSubtype) => {
    const newItems = [...formData.items];
    newItems[index] = { ...newItems[index], travelSubtype };
    setFormData((prev) => ({ ...prev, items: newItems }));
  };

  const getServiceIcon = (type: ServiceType) => {
    switch (type) {
      case 'trip': return <Plane className="w-4 h-4" />;
      case 'meals': return <Utensils className="w-4 h-4" />;
      case 'travel': return <Car className="w-4 h-4" />;
      default: return <Package className="w-4 h-4" />;
    }
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
    <div className="flex min-h-screen bg-gray-100">
      <Sidebar />
      <main className="flex-1 ml-64">
        <div className="max-w-5xl mx-auto p-8">
          {/* Header */}
          <div className="flex items-center justify-between mb-8">
            <div className="flex items-center gap-4">
              <Link
                href="/"
                className="p-2 text-gray-500 hover:text-gray-700 hover:bg-white rounded-lg transition-all"
              >
                <ArrowLeft className="w-5 h-5" />
              </Link>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">New Invoice</h1>
                <p className="text-sm text-gray-500">Create a new invoice for your client</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Link
                href="/"
                className="px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-800 hover:bg-gray-200 rounded-lg transition-all"
              >
                Cancel
              </Link>
              <button
                type="submit"
                form="invoice-form"
                disabled={isLoading}
                className="px-6 py-2 bg-indigo-600 text-white text-sm font-medium rounded-lg hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-sm"
              >
                {isLoading ? "Creating..." : "Create Invoice"}
              </button>
            </div>
          </div>

          <form id="invoice-form" onSubmit={handleSubmit} className="space-y-6">
            {/* Client & Invoice Info - Two Column */}
            <div className="grid grid-cols-2 gap-6">
              {/* Client Details */}
              <div className="bg-white rounded-xl border border-gray-200 p-6">
                <div className="flex items-center justify-between mb-4">
                  <h2 className="text-sm font-semibold text-gray-900 uppercase tracking-wide">Client Details</h2>
                  {customers.length > 0 && (
                    <div className="relative">
                      <button
                        type="button"
                        onClick={() => setOpenDropdown(
                          openDropdown?.type === 'customer' ? null : { index: -1, type: 'customer' }
                        )}
                        className="flex items-center gap-2 text-xs font-medium text-indigo-600 hover:text-indigo-700"
                      >
                        <Users className="w-3.5 h-3.5" />
                        {selectedCustomerId ? 'Change Customer' : 'Select Existing'}
                        <ChevronDown className="w-3 h-3" />
                      </button>
                      {openDropdown?.type === 'customer' && (
                        <div className="absolute z-50 right-0 mt-1 w-72 bg-white border border-gray-200 rounded-lg shadow-xl overflow-hidden">
                          <div className="px-3 py-2 bg-gray-50 border-b border-gray-200">
                            <span className="text-xs font-medium text-gray-500 uppercase">Select Customer</span>
                          </div>
                          <div className="max-h-64 overflow-y-auto">
                            {selectedCustomerId && (
                              <button
                                type="button"
                                onClick={clearCustomerSelection}
                                className="w-full px-3 py-2.5 text-left text-sm text-gray-500 hover:bg-gray-50 border-b border-gray-100"
                              >
                                Clear selection (new customer)
                              </button>
                            )}
                            {customers.map((customer) => (
                              <button
                                key={customer.id}
                                type="button"
                                onClick={() => handleSelectCustomer(customer)}
                                className="w-full px-3 py-2.5 text-left hover:bg-indigo-50 transition-colors"
                              >
                                <div className="flex items-center justify-between">
                                  <div>
                                    <div className="text-sm font-medium text-gray-900">{customer.name}</div>
                                    <div className="text-xs text-gray-500">{customer.email}</div>
                                    {customer.businessName && (
                                      <div className="text-xs text-gray-400">{customer.businessName}</div>
                                    )}
                                  </div>
                                  {selectedCustomerId === customer.id && (
                                    <Check className="w-4 h-4 text-indigo-600" />
                                  )}
                                </div>
                              </button>
                            ))}
                          </div>
                        </div>
                      )}
                    </div>
                  )}
                </div>
                <div className="space-y-4">
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1.5">
                        Name <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="text"
                        name="clientName"
                        value={formData.clientName}
                        onChange={handleChange}
                        required
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                        placeholder="John Doe"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1.5">
                        Email <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="email"
                        name="clientEmail"
                        value={formData.clientEmail}
                        onChange={handleChange}
                        required
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                        placeholder="john@example.com"
                      />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1.5">
                      Business Name
                    </label>
                    <input
                      type="text"
                      name="clientBusinessName"
                      value={formData.clientBusinessName}
                      onChange={handleChange}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                      placeholder="Company Inc."
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1.5">
                      Address
                    </label>
                    <textarea
                      name="clientAddress"
                      value={formData.clientAddress}
                      onChange={handleChange}
                      rows={2}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm resize-none"
                      placeholder="123 Main St, City, State 12345"
                    />
                  </div>
                </div>
              </div>

              {/* Invoice Details */}
              <div className="bg-white rounded-xl border border-gray-200 p-6">
                <h2 className="text-sm font-semibold text-gray-900 uppercase tracking-wide mb-4">Invoice Details</h2>
                <div className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1.5">
                        Due Date
                      </label>
                      <input
                        type="date"
                        name="dueDate"
                        value={formData.dueDate}
                        onChange={handleChange}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1.5">
                        Status
                      </label>
                      <select
                        name="status"
                        value={formData.status || "due"}
                        onChange={handleChange}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm bg-white"
                      >
                        {INVOICE_STATUSES.map((status) => (
                          <option key={status.value} value={status.value}>
                            {status.label}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1.5">
                      Payment Instructions
                    </label>
                    <textarea
                      name="paymentInstructions"
                      value={formData.paymentInstructions || ""}
                      onChange={handleChange}
                      rows={3}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm resize-none"
                      placeholder="Bank transfer to Account #123456789"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Line Items */}
            <div className="bg-white rounded-xl border border-gray-200">
              <div className="px-6 py-4 border-b border-gray-200 bg-gray-50 rounded-t-xl">
                <h2 className="text-sm font-semibold text-gray-900 uppercase tracking-wide">Line Items</h2>
              </div>

              <div className="divide-y divide-gray-100">
                {formData.items.map((item, index) => (
                  <div key={index} className="p-6" ref={openDropdown?.index === index ? dropdownRef : undefined}>
                    <div className="flex gap-6">
                      {/* Left: Title & Description */}
                      <div className="flex-1 space-y-3">
                        {/* Title with Template Dropdown */}
                        <div>
                          <div className="flex items-center justify-between mb-1.5">
                            <label className="text-sm font-medium text-gray-700">
                              Title <span className="text-red-500">*</span>
                            </label>
                            <button
                              type="button"
                              onClick={() => setOpenDropdown(
                                openDropdown?.index === index && openDropdown?.type === 'title'
                                  ? null
                                  : { index, type: 'title' }
                              )}
                              className="text-xs text-indigo-600 hover:text-indigo-700 font-medium flex items-center gap-1"
                            >
                              Use template <ChevronDown className="w-3 h-3" />
                            </button>
                          </div>
                          <div className="relative">
                            <input
                              type="text"
                              value={item.title}
                              onChange={(e) => handleItemChange(index, "title", e.target.value)}
                              required
                              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                              placeholder="e.g., CJ - PIC - Day Rate"
                            />
                            {/* Title Dropdown */}
                            {openDropdown?.index === index && openDropdown?.type === 'title' && (
                              <div className="absolute z-50 left-0 right-0 mt-1 bg-white border border-gray-200 rounded-lg shadow-xl overflow-hidden">
                                <div className="px-3 py-2 bg-gray-50 border-b border-gray-200">
                                  <span className="text-xs font-medium text-gray-500 uppercase">Select a title</span>
                                </div>
                                <div className="max-h-48 overflow-y-auto">
                                  {titleTemplates.map((template) => (
                                    <button
                                      key={template.id}
                                      type="button"
                                      onClick={() => selectTemplate(index, 'title', template.content)}
                                      className="w-full px-3 py-2.5 text-left text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-700 flex items-center justify-between transition-colors"
                                    >
                                      <span>{template.content}</span>
                                      {item.title === template.content && (
                                        <Check className="w-4 h-4 text-indigo-600" />
                                      )}
                                    </button>
                                  ))}
                                </div>
                              </div>
                            )}
                          </div>
                          <label className="flex items-center gap-2 mt-2 cursor-pointer">
                            <input
                              type="checkbox"
                              checked={itemSaveFlags[index]?.saveTitle || false}
                              onChange={() => toggleSaveFlag(index, 'saveTitle')}
                              className="w-4 h-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                            />
                            <span className="text-xs text-gray-500">Save as template</span>
                          </label>
                        </div>

                        {/* Description with Template Dropdown */}
                        <div>
                          <div className="flex items-center justify-between mb-1.5">
                            <label className="text-sm font-medium text-gray-700">Description</label>
                            <button
                              type="button"
                              onClick={() => setOpenDropdown(
                                openDropdown?.index === index && openDropdown?.type === 'description'
                                  ? null
                                  : { index, type: 'description' }
                              )}
                              className="text-xs text-indigo-600 hover:text-indigo-700 font-medium flex items-center gap-1"
                            >
                              Use template <ChevronDown className="w-3 h-3" />
                            </button>
                          </div>
                          <div className="relative">
                            <textarea
                              value={item.description}
                              onChange={(e) => handleItemChange(index, "description", e.target.value)}
                              rows={3}
                              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm resize-none"
                              placeholder="Pilot:&#10;Trip Dates:&#10;Itinerary:&#10;Lead Passenger:"
                            />
                            {/* Description Dropdown */}
                            {openDropdown?.index === index && openDropdown?.type === 'description' && (
                              <div className="absolute z-50 left-0 right-0 mt-1 bg-white border border-gray-200 rounded-lg shadow-xl overflow-hidden">
                                <div className="px-3 py-2 bg-gray-50 border-b border-gray-200">
                                  <span className="text-xs font-medium text-gray-500 uppercase">Select a description</span>
                                </div>
                                <div className="max-h-60 overflow-y-auto">
                                  {descriptionTemplates.map((template) => (
                                    <button
                                      key={template.id}
                                      type="button"
                                      onClick={() => selectTemplate(index, 'description', template.content)}
                                      className="w-full px-3 py-3 text-left text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-700 transition-colors border-b border-gray-100 last:border-0"
                                    >
                                      <pre className="whitespace-pre-wrap font-sans text-xs">{template.content}</pre>
                                    </button>
                                  ))}
                                </div>
                              </div>
                            )}
                          </div>
                          <label className="flex items-center gap-2 mt-2 cursor-pointer">
                            <input
                              type="checkbox"
                              checked={itemSaveFlags[index]?.saveDescription || false}
                              onChange={() => toggleSaveFlag(index, 'saveDescription')}
                              className="w-4 h-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                            />
                            <span className="text-xs text-gray-500">Save as template</span>
                          </label>
                        </div>
                      </div>

                      {/* Right: Qty, Price, Total */}
                      <div className="w-72 flex flex-col justify-between">
                        <div className="grid grid-cols-3 gap-3">
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1.5">Qty</label>
                            <input
                              type="number"
                              min="0.01"
                              step="0.01"
                              value={item.quantity}
                              onChange={(e) => handleItemChange(index, "quantity", e.target.value)}
                              required
                              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm text-center"
                            />
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1.5">Price</label>
                            <div className="relative">
                              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">$</span>
                              <input
                                type="number"
                                min="0"
                                step="0.01"
                                value={item.unitPrice}
                                onChange={(e) => handleItemChange(index, "unitPrice", e.target.value)}
                                required
                                className="w-full pl-7 pr-2 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                              />
                            </div>
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1.5">Total</label>
                            <div className="px-3 py-2 bg-gray-100 border border-gray-200 rounded-lg text-sm font-semibold text-gray-900 text-center">
                              ${(item.quantity * item.unitPrice).toFixed(2)}
                            </div>
                          </div>
                        </div>

                        {/* Delete Button */}
                        <div className="flex justify-end mt-4">
                          <button
                            type="button"
                            onClick={() => removeItem(index)}
                            disabled={formData.items.length === 1}
                            className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-30 disabled:cursor-not-allowed disabled:hover:bg-transparent disabled:hover:text-gray-400"
                            title="Remove item"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    </div>

                    {/* Service Type & Travel Subtype */}
                    <div className="mt-4 flex items-center gap-4 pt-4 border-t border-gray-100">
                      <div className="flex items-center gap-2">
                        <label className="text-xs font-medium text-gray-500">Type:</label>
                        <select
                          value={item.serviceType || 'standard'}
                          onChange={(e) => updateItemServiceType(index, e.target.value as ServiceType)}
                          className="px-2 py-1 text-xs border border-gray-200 rounded-lg bg-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                        >
                          {SERVICE_TYPES.map((type) => (
                            <option key={type.value} value={type.value}>{type.label}</option>
                          ))}
                        </select>
                      </div>

                      {item.serviceType === 'travel' && (
                        <div className="flex items-center gap-2">
                          <label className="text-xs font-medium text-gray-500">Subtype:</label>
                          <select
                            value={item.travelSubtype || 'other'}
                            onChange={(e) => updateItemTravelSubtype(index, e.target.value as TravelSubtype)}
                            className="px-2 py-1 text-xs border border-gray-200 rounded-lg bg-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                          >
                            {TRAVEL_SUBTYPES.map((type) => (
                              <option key={type.value} value={type.value}>{type.label}</option>
                            ))}
                          </select>
                        </div>
                      )}
                    </div>

                    {/* Trip Legs Editor */}
                    {item.serviceType === 'trip' && (
                      <div className="mt-4">
                        <TripLegsEditor
                          legs={item.legs || []}
                          onChange={(legs) => updateItemLegs(index, legs)}
                        />
                      </div>
                    )}
                  </div>
                ))}
              </div>

              {/* Add Item Button */}
              <div className="px-6 py-4 bg-gray-50 border-t border-gray-200 flex items-center gap-3">
                <button
                  type="button"
                  onClick={addItem}
                  className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-indigo-600 hover:text-indigo-700 hover:bg-indigo-50 rounded-lg transition-colors"
                >
                  <Plus className="w-4 h-4" />
                  Add Line Item
                </button>

                {/* Quick Add Service Dropdown */}
                {serviceTemplates.length > 0 && (
                  <div className="relative">
                    <button
                      type="button"
                      onClick={() => setOpenDropdown(
                        openDropdown?.type === 'service' ? null : { index: -1, type: 'service' }
                      )}
                      className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-green-600 hover:text-green-700 hover:bg-green-50 rounded-lg transition-colors"
                    >
                      <Package className="w-4 h-4" />
                      Quick Add Service
                      <ChevronDown className="w-3 h-3" />
                    </button>
                    {openDropdown?.type === 'service' && (
                      <div className="absolute z-50 left-0 mt-1 w-72 bg-white border border-gray-200 rounded-lg shadow-xl overflow-hidden">
                        <div className="px-3 py-2 bg-gray-50 border-b border-gray-200">
                          <span className="text-xs font-medium text-gray-500 uppercase">Service Templates</span>
                        </div>
                        <div className="max-h-60 overflow-y-auto">
                          {serviceTemplates.map((template) => (
                            <button
                              key={template.id}
                              type="button"
                              onClick={() => addFromServiceTemplate(template)}
                              className="w-full px-3 py-2.5 text-left text-sm hover:bg-indigo-50 hover:text-indigo-700 flex items-center gap-3 transition-colors border-b border-gray-100 last:border-0"
                            >
                              <span className={`p-1.5 rounded ${
                                template.serviceType === 'trip' ? 'bg-blue-100 text-blue-600' :
                                template.serviceType === 'meals' ? 'bg-orange-100 text-orange-600' :
                                template.serviceType === 'travel' ? 'bg-green-100 text-green-600' :
                                'bg-gray-100 text-gray-600'
                              }`}>
                                {getServiceIcon(template.serviceType as ServiceType)}
                              </span>
                              <div className="flex-1 min-w-0">
                                <div className="font-medium text-gray-900 truncate">{template.name}</div>
                                <div className="text-xs text-gray-500">${template.defaultPrice.toFixed(2)}</div>
                              </div>
                            </button>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>

            {/* Summary */}
            <div className="bg-white rounded-xl border border-gray-200 p-6">
              <div className="flex justify-end">
                <div className="w-72 space-y-3">
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">Subtotal</span>
                    <span className="font-medium text-gray-900">${calculateSubtotal().toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between items-center text-sm">
                    <span className="text-gray-500">Tax</span>
                    <div className="relative w-28">
                      <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">$</span>
                      <input
                        type="number"
                        name="tax"
                        min="0"
                        step="0.01"
                        value={formData.tax}
                        onChange={handleChange}
                        className="w-full pl-7 pr-2 py-1.5 border border-gray-300 rounded-lg text-sm text-right focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                      />
                    </div>
                  </div>
                  <div className="pt-3 border-t border-gray-200">
                    <div className="flex justify-between items-center">
                      <span className="text-base font-semibold text-gray-900">Total</span>
                      <span className="text-2xl font-bold text-gray-900">${calculateTotal().toFixed(2)}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </form>
        </div>
      </main>
    </div>
  );
}
