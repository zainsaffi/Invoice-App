"use client";

import { useState, useEffect } from "react";
import Sidebar from "@/components/Sidebar";
import { Building2, CreditCard, Bell, Shield, Save, Banknote, CheckCircle, AlertCircle } from "lucide-react";

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState("business");
  const [isSaving, setIsSaving] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [saveMessage, setSaveMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);
  const [formData, setFormData] = useState({
    businessName: "",
    businessEmail: "",
    businessPhone: "",
    businessAddress: "",
    taxId: "",
    currency: "USD",
    invoicePrefix: "INV",
    defaultDueDays: "30",
    // Payment details
    bankName: "",
    accountName: "",
    accountNumber: "",
    routingNumber: "",
    iban: "",
    paypalEmail: "",
    paymentNotes: "",
    // Notifications
    emailNotifications: true,
    paymentReminders: true,
  });

  // Fetch user settings on load
  useEffect(() => {
    const fetchSettings = async () => {
      try {
        const response = await fetch("/api/settings");
        if (response.ok) {
          const data = await response.json();
          setFormData((prev) => ({
            ...prev,
            ...data,
            defaultDueDays: String(data.defaultDueDays || 30),
          }));
        }
      } catch (error) {
        console.error("Failed to fetch settings:", error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchSettings();
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? (e.target as HTMLInputElement).checked : value,
    }));
  };

  const handleSave = async () => {
    setIsSaving(true);
    setSaveMessage(null);

    try {
      const response = await fetch("/api/settings", {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...formData,
          defaultDueDays: parseInt(formData.defaultDueDays) || 30,
        }),
      });

      if (response.ok) {
        setSaveMessage({ type: "success", text: "Settings saved successfully!" });
      } else {
        const data = await response.json();
        setSaveMessage({ type: "error", text: data.error || "Failed to save settings" });
      }
    } catch {
      setSaveMessage({ type: "error", text: "An error occurred while saving" });
    } finally {
      setIsSaving(false);
      // Clear message after 3 seconds
      setTimeout(() => setSaveMessage(null), 3000);
    }
  };

  const tabs = [
    { id: "business", label: "Business Info", icon: Building2 },
    { id: "payment", label: "Payment Details", icon: Banknote },
    { id: "invoicing", label: "Invoicing", icon: CreditCard },
    { id: "notifications", label: "Notifications", icon: Bell },
    { id: "security", label: "Security", icon: Shield },
  ];

  if (isLoading) {
    return (
      <div className="flex min-h-screen bg-gray-50">
        <Sidebar />
        <main className="flex-1 ml-64 flex items-center justify-center">
          <div className="animate-spin w-8 h-8 border-4 border-indigo-600 border-t-transparent rounded-full" />
        </main>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 ml-64">
        <div className="p-8">
          {/* Header */}
          <div className="mb-8">
            <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
            <p className="text-gray-500 mt-1">Manage your account and preferences</p>
          </div>

          <div className="flex gap-8">
            {/* Settings Navigation */}
            <div className="w-64 flex-shrink-0">
              <nav className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                {tabs.map((tab) => (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`w-full flex items-center gap-3 px-4 py-3 text-sm font-medium transition-colors ${
                      activeTab === tab.id
                        ? "bg-indigo-50 text-indigo-600 border-l-2 border-indigo-600"
                        : "text-gray-600 hover:bg-gray-50"
                    }`}
                  >
                    <tab.icon className="w-5 h-5" />
                    {tab.label}
                  </button>
                ))}
              </nav>
            </div>

            {/* Settings Content */}
            <div className="flex-1">
              <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
                {activeTab === "business" && (
                  <div className="p-6">
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                        <Building2 className="w-5 h-5 text-blue-600" />
                      </div>
                      <div>
                        <h2 className="text-lg font-semibold text-gray-900">Business Information</h2>
                        <p className="text-sm text-gray-500">Your company details for invoices</p>
                      </div>
                    </div>

                    <div className="space-y-6">
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            Business Name
                          </label>
                          <input
                            type="text"
                            name="businessName"
                            value={formData.businessName}
                            onChange={handleChange}
                            className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            Business Email
                          </label>
                          <input
                            type="email"
                            name="businessEmail"
                            value={formData.businessEmail}
                            onChange={handleChange}
                            className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                          />
                        </div>
                      </div>

                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            Phone Number
                          </label>
                          <input
                            type="tel"
                            name="businessPhone"
                            value={formData.businessPhone}
                            onChange={handleChange}
                            placeholder="+1 (555) 000-0000"
                            className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            Tax ID / VAT Number
                          </label>
                          <input
                            type="text"
                            name="taxId"
                            value={formData.taxId}
                            onChange={handleChange}
                            placeholder="Optional"
                            className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                          />
                        </div>
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                          Business Address
                        </label>
                        <textarea
                          name="businessAddress"
                          value={formData.businessAddress}
                          onChange={handleChange}
                          rows={3}
                          placeholder="Enter your business address"
                          className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm resize-none"
                        />
                      </div>
                    </div>
                  </div>
                )}

                {activeTab === "payment" && (
                  <div className="p-6">
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 bg-green-100 rounded-xl flex items-center justify-center">
                        <Banknote className="w-5 h-5 text-green-600" />
                      </div>
                      <div>
                        <h2 className="text-lg font-semibold text-gray-900">Payment Details</h2>
                        <p className="text-sm text-gray-500">Bank details displayed on your invoices for client payments</p>
                      </div>
                    </div>

                    <div className="space-y-6">
                      {/* Bank Transfer Section */}
                      <div className="border border-gray-200 rounded-xl p-4">
                        <h3 className="text-sm font-semibold text-gray-700 mb-4">Bank Transfer Details</h3>
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                              Bank Name
                            </label>
                            <input
                              type="text"
                              name="bankName"
                              value={formData.bankName}
                              onChange={handleChange}
                              placeholder="e.g., Chase Bank"
                              className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                            />
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                              Account Holder Name
                            </label>
                            <input
                              type="text"
                              name="accountName"
                              value={formData.accountName}
                              onChange={handleChange}
                              placeholder="Name on account"
                              className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                            />
                          </div>
                        </div>

                        <div className="grid grid-cols-2 gap-4 mt-4">
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                              Account Number
                            </label>
                            <input
                              type="text"
                              name="accountNumber"
                              value={formData.accountNumber}
                              onChange={handleChange}
                              placeholder="Bank account number"
                              className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                            />
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                              Routing / SWIFT / Sort Code
                            </label>
                            <input
                              type="text"
                              name="routingNumber"
                              value={formData.routingNumber}
                              onChange={handleChange}
                              placeholder="Routing number"
                              className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                            />
                          </div>
                        </div>

                        <div className="mt-4">
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            IBAN (International)
                          </label>
                          <input
                            type="text"
                            name="iban"
                            value={formData.iban}
                            onChange={handleChange}
                            placeholder="e.g., GB82 WEST 1234 5698 7654 32"
                            className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                          />
                        </div>
                      </div>

                      {/* PayPal Section */}
                      <div className="border border-gray-200 rounded-xl p-4">
                        <h3 className="text-sm font-semibold text-gray-700 mb-4">PayPal</h3>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            PayPal Email
                          </label>
                          <input
                            type="email"
                            name="paypalEmail"
                            value={formData.paypalEmail}
                            onChange={handleChange}
                            placeholder="payments@yourcompany.com"
                            className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                          />
                        </div>
                      </div>

                      {/* Additional Notes */}
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                          Additional Payment Instructions
                        </label>
                        <textarea
                          name="paymentNotes"
                          value={formData.paymentNotes}
                          onChange={handleChange}
                          rows={3}
                          placeholder="e.g., Please use invoice number as payment reference"
                          className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm resize-none"
                        />
                      </div>
                    </div>
                  </div>
                )}

                {activeTab === "invoicing" && (
                  <div className="p-6">
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 bg-emerald-100 rounded-xl flex items-center justify-center">
                        <CreditCard className="w-5 h-5 text-emerald-600" />
                      </div>
                      <div>
                        <h2 className="text-lg font-semibold text-gray-900">Invoicing Settings</h2>
                        <p className="text-sm text-gray-500">Customize your invoice defaults</p>
                      </div>
                    </div>

                    <div className="space-y-6">
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            Currency
                          </label>
                          <select
                            name="currency"
                            value={formData.currency}
                            onChange={handleChange}
                            className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                          >
                            <option value="USD">USD - US Dollar</option>
                            <option value="EUR">EUR - Euro</option>
                            <option value="GBP">GBP - British Pound</option>
                            <option value="CAD">CAD - Canadian Dollar</option>
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            Invoice Number Prefix
                          </label>
                          <input
                            type="text"
                            name="invoicePrefix"
                            value={formData.invoicePrefix}
                            onChange={handleChange}
                            className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                          />
                        </div>
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                          Default Payment Terms (Days)
                        </label>
                        <input
                          type="number"
                          name="defaultDueDays"
                          value={formData.defaultDueDays}
                          onChange={handleChange}
                          min="1"
                          className="w-32 px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:bg-white text-sm"
                        />
                      </div>
                    </div>
                  </div>
                )}

                {activeTab === "notifications" && (
                  <div className="p-6">
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 bg-purple-100 rounded-xl flex items-center justify-center">
                        <Bell className="w-5 h-5 text-purple-600" />
                      </div>
                      <div>
                        <h2 className="text-lg font-semibold text-gray-900">Notification Preferences</h2>
                        <p className="text-sm text-gray-500">Manage your email notifications</p>
                      </div>
                    </div>

                    <div className="space-y-4">
                      <label className="flex items-center justify-between p-4 bg-gray-50 rounded-xl">
                        <div>
                          <p className="text-sm font-medium text-gray-900">Email Notifications</p>
                          <p className="text-xs text-gray-500">Receive email updates about your invoices</p>
                        </div>
                        <input
                          type="checkbox"
                          name="emailNotifications"
                          checked={formData.emailNotifications}
                          onChange={handleChange}
                          className="w-5 h-5 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                        />
                      </label>

                      <label className="flex items-center justify-between p-4 bg-gray-50 rounded-xl">
                        <div>
                          <p className="text-sm font-medium text-gray-900">Payment Reminders</p>
                          <p className="text-xs text-gray-500">Send automatic payment reminders to clients</p>
                        </div>
                        <input
                          type="checkbox"
                          name="paymentReminders"
                          checked={formData.paymentReminders}
                          onChange={handleChange}
                          className="w-5 h-5 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                        />
                      </label>
                    </div>
                  </div>
                )}

                {activeTab === "security" && (
                  <div className="p-6">
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 bg-red-100 rounded-xl flex items-center justify-center">
                        <Shield className="w-5 h-5 text-red-600" />
                      </div>
                      <div>
                        <h2 className="text-lg font-semibold text-gray-900">Security Settings</h2>
                        <p className="text-sm text-gray-500">Manage your account security</p>
                      </div>
                    </div>

                    <div className="space-y-4">
                      <div className="p-4 bg-gray-50 rounded-xl">
                        <div className="flex items-center justify-between">
                          <div>
                            <p className="text-sm font-medium text-gray-900">Change Password</p>
                            <p className="text-xs text-gray-500">Update your account password</p>
                          </div>
                          <button className="px-4 py-2 text-sm font-medium text-indigo-600 hover:bg-indigo-50 rounded-lg transition-colors">
                            Update
                          </button>
                        </div>
                      </div>

                      <div className="p-4 bg-gray-50 rounded-xl">
                        <div className="flex items-center justify-between">
                          <div>
                            <p className="text-sm font-medium text-gray-900">Two-Factor Authentication</p>
                            <p className="text-xs text-gray-500">Add an extra layer of security</p>
                          </div>
                          <button className="px-4 py-2 text-sm font-medium text-indigo-600 hover:bg-indigo-50 rounded-lg transition-colors">
                            Enable
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                )}

                {/* Save Button */}
                <div className="px-6 py-4 border-t border-gray-200 flex items-center justify-between">
                  {saveMessage && (
                    <div className={`flex items-center gap-2 text-sm ${saveMessage.type === "success" ? "text-green-600" : "text-red-600"}`}>
                      {saveMessage.type === "success" ? (
                        <CheckCircle className="w-4 h-4" />
                      ) : (
                        <AlertCircle className="w-4 h-4" />
                      )}
                      {saveMessage.text}
                    </div>
                  )}
                  <button
                    onClick={handleSave}
                    disabled={isSaving}
                    className="flex items-center gap-2 px-6 py-2.5 bg-indigo-600 text-white text-sm font-medium rounded-xl hover:bg-indigo-700 disabled:opacity-50 transition-colors shadow-lg shadow-indigo-500/25"
                  >
                    {isSaving ? (
                      <>
                        <svg className="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
                          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                        </svg>
                        Saving...
                      </>
                    ) : (
                      <>
                        <Save className="w-4 h-4" />
                        Save Changes
                      </>
                    )}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
