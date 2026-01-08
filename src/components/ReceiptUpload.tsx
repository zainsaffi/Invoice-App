"use client";

import { useState, useRef, useEffect } from "react";
import { createPortal } from "react-dom";
import { Upload, X, FileText, Download, Paperclip, Image, Tag } from "lucide-react";
import { Receipt, AttachmentType, ATTACHMENT_TYPES, getAttachmentTypeLabel } from "@/types/invoice";

interface ReceiptUploadProps {
  invoiceId: string;
  receipts: Receipt[];
  onUpload: () => void;
}

export default function ReceiptUpload({
  invoiceId,
  receipts,
  onUpload,
}: ReceiptUploadProps) {
  const [isUploading, setIsUploading] = useState(false);
  const [isDragging, setIsDragging] = useState(false);
  const [selectedType, setSelectedType] = useState<AttachmentType>('receipt');
  const [pendingFile, setPendingFile] = useState<File | null>(null);
  const [showTypeSelector, setShowTypeSelector] = useState(false);
  const [mounted, setMounted] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // For portal rendering
  useEffect(() => {
    setMounted(true);
  }, []);

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    console.log("File selected:", file?.name);
    if (!file) return;
    // Show type selector modal
    console.log("Setting showTypeSelector to true");
    setPendingFile(file);
    setShowTypeSelector(true);
  };

  const uploadFile = async (file: File, attachmentType: AttachmentType) => {
    setIsUploading(true);
    const formData = new FormData();
    formData.append("file", file);
    formData.append("attachmentType", attachmentType);

    try {
      const response = await fetch(`/api/invoices/${invoiceId}/receipts`, {
        method: "POST",
        body: formData,
      });

      if (response.ok) {
        onUpload();
      } else {
        alert("Failed to upload file");
      }
    } catch (error) {
      console.error("Error uploading file:", error);
      alert("Failed to upload file");
    } finally {
      setIsUploading(false);
      setShowTypeSelector(false);
      setPendingFile(null);
      setSelectedType('receipt');
      if (fileInputRef.current) {
        fileInputRef.current.value = "";
      }
    }
  };

  const handleConfirmUpload = () => {
    if (pendingFile) {
      uploadFile(pendingFile, selectedType);
    }
  };

  const handleCancelUpload = () => {
    setShowTypeSelector(false);
    setPendingFile(null);
    setSelectedType('receipt');
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  const handleDrop = async (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    const file = e.dataTransfer.files?.[0];
    if (file) {
      // Show type selector modal
      setPendingFile(file);
      setShowTypeSelector(true);
    }
  };

  const handleDelete = async (receiptId: string) => {
    if (!confirm("Are you sure you want to delete this receipt?")) return;

    try {
      const response = await fetch(
        `/api/invoices/${invoiceId}/receipts?receiptId=${receiptId}`,
        {
          method: "DELETE",
        }
      );

      if (response.ok) {
        onUpload();
      } else {
        alert("Failed to delete receipt");
      }
    } catch (error) {
      console.error("Error deleting receipt:", error);
      alert("Failed to delete receipt");
    }
  };

  const formatFileSize = (bytes: number) => {
    if (bytes < 1024) return bytes + " B";
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB";
    return (bytes / (1024 * 1024)).toFixed(1) + " MB";
  };

  const getFileIcon = (mimeType: string) => {
    if (mimeType.startsWith("image/")) {
      return <Image className="w-5 h-5 text-purple-500" />;
    }
    return <FileText className="w-5 h-5 text-blue-500" />;
  };

  return (
    <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden">
      <div className="px-6 py-4 border-b border-slate-200 bg-slate-50">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-purple-100 rounded-xl flex items-center justify-center">
            <Paperclip className="w-5 h-5 text-purple-600" />
          </div>
          <div>
            <h2 className="font-semibold text-slate-900">Attachments</h2>
            <p className="text-sm text-slate-500">
              {receipts.length} file{receipts.length !== 1 ? "s" : ""} attached
            </p>
          </div>
        </div>
      </div>

      <div className="p-6">
        {/* Upload Area */}
        <label
          className={`flex flex-col items-center justify-center w-full py-8 border-2 border-dashed rounded-xl cursor-pointer transition-all ${
            isDragging
              ? "border-blue-400 bg-blue-50"
              : "border-slate-200 hover:border-blue-300 hover:bg-slate-50"
          }`}
          onDragOver={(e) => {
            e.preventDefault();
            setIsDragging(true);
          }}
          onDragLeave={() => setIsDragging(false)}
          onDrop={handleDrop}
        >
          <div className="flex flex-col items-center">
            {isUploading ? (
              <>
                <svg
                  className="animate-spin w-8 h-8 text-blue-500 mb-3"
                  fill="none"
                  viewBox="0 0 24 24"
                >
                  <circle
                    className="opacity-25"
                    cx="12"
                    cy="12"
                    r="10"
                    stroke="currentColor"
                    strokeWidth="4"
                  />
                  <path
                    className="opacity-75"
                    fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                  />
                </svg>
                <p className="text-sm font-medium text-slate-700">Uploading...</p>
              </>
            ) : (
              <>
                <div className="w-12 h-12 bg-slate-100 rounded-xl flex items-center justify-center mb-3">
                  <Upload className="w-6 h-6 text-slate-400" />
                </div>
                <p className="text-sm font-medium text-slate-700 mb-1">
                  Drop files here or click to upload
                </p>
                <p className="text-xs text-slate-400">
                  PDF, PNG, JPG up to 10MB
                </p>
              </>
            )}
          </div>
          <input
            ref={fileInputRef}
            type="file"
            className="hidden"
            accept=".pdf,.png,.jpg,.jpeg"
            onChange={handleFileChange}
            disabled={isUploading}
          />
        </label>

        {/* Files List */}
        {receipts.length > 0 && (
          <div className="mt-4 space-y-2">
            {receipts.map((receipt) => (
              <div
                key={receipt.id}
                className="flex items-center justify-between p-3 bg-slate-50 rounded-xl border border-slate-100 group hover:bg-slate-100 transition-colors"
              >
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center border border-slate-200 flex-shrink-0">
                    {getFileIcon(receipt.mimeType)}
                  </div>
                  <div className="min-w-0">
                    <p className="text-sm font-medium text-slate-900 truncate">
                      {receipt.filename}
                    </p>
                    <div className="flex items-center gap-2">
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 bg-indigo-50 text-indigo-600 text-xs font-medium rounded-full">
                        <Tag className="w-3 h-3" />
                        {getAttachmentTypeLabel(receipt.attachmentType)}
                      </span>
                      <span className="text-xs text-slate-400">
                        {formatFileSize(receipt.size)}
                      </span>
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <a
                    href={receipt.filepath}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="w-8 h-8 flex items-center justify-center rounded-lg text-slate-500 hover:text-blue-600 hover:bg-blue-50 transition-colors"
                  >
                    <Download className="w-4 h-4" />
                  </a>
                  <button
                    onClick={() => handleDelete(receipt.id)}
                    className="w-8 h-8 flex items-center justify-center rounded-lg text-slate-500 hover:text-red-600 hover:bg-red-50 transition-colors"
                  >
                    <X className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {receipts.length === 0 && (
          <p className="text-sm text-slate-400 text-center mt-4">
            No files attached yet
          </p>
        )}
      </div>

      {/* Type Selector Modal - rendered via portal */}
      {mounted && showTypeSelector && pendingFile && createPortal(
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center" style={{ zIndex: 9999 }}>
          <div className="bg-white rounded-2xl shadow-xl max-w-md w-full mx-4 overflow-hidden">
            <div className="px-6 py-4 border-b border-slate-200 bg-slate-50">
              <h3 className="font-semibold text-slate-900">Select Attachment Type</h3>
              <p className="text-sm text-slate-500 mt-1">
                Choose a category for &quot;{pendingFile.name}&quot;
              </p>
            </div>
            <div className="p-6">
              <div className="space-y-2">
                {ATTACHMENT_TYPES.map((type) => (
                  <label
                    key={type.value}
                    className={`flex items-center gap-3 p-3 rounded-xl border cursor-pointer transition-all ${
                      selectedType === type.value
                        ? "border-indigo-500 bg-indigo-50"
                        : "border-slate-200 hover:border-slate-300 hover:bg-slate-50"
                    }`}
                  >
                    <input
                      type="radio"
                      name="attachmentType"
                      value={type.value}
                      checked={selectedType === type.value}
                      onChange={(e) => setSelectedType(e.target.value as AttachmentType)}
                      className="w-4 h-4 text-indigo-600"
                    />
                    <span className={`text-sm font-medium ${
                      selectedType === type.value ? "text-indigo-700" : "text-slate-700"
                    }`}>
                      {type.label}
                    </span>
                  </label>
                ))}
              </div>
              <div className="flex gap-3 mt-6">
                <button
                  onClick={handleCancelUpload}
                  className="flex-1 px-4 py-2.5 border border-slate-300 text-slate-700 rounded-xl hover:bg-slate-50 transition-colors font-medium"
                >
                  Cancel
                </button>
                <button
                  onClick={handleConfirmUpload}
                  disabled={isUploading}
                  className="flex-1 px-4 py-2.5 bg-indigo-600 text-white rounded-xl hover:bg-indigo-700 transition-colors font-medium disabled:opacity-50"
                >
                  {isUploading ? "Uploading..." : "Upload"}
                </button>
              </div>
            </div>
          </div>
        </div>,
        document.body
      )}
    </div>
  );
}
