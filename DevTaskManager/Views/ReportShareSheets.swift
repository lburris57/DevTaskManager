//
//  ReportShareSheets.swift
//  DevTaskManager
//
//  Created by Assistant on 2/20/26.
//

import SwiftUI
import UniformTypeIdentifiers

#if canImport(UIKit)
    import UIKit

    // MARK: - Text/CSV Share Sheet (iOS)

    struct ReportShareSheet: UIViewControllerRepresentable
    {
        let items: [Any]

        func makeUIViewController(context: Context) -> UIActivityViewController
        {
            UIActivityViewController(activityItems: items, applicationActivities: nil)
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context)
        {
        }
    }

    // MARK: - PDF Share Sheet (iOS)

    struct PDFShareSheet: UIViewControllerRepresentable
    {
        let pdfData: Data

        func makeUIViewController(context: Context) -> UIActivityViewController
        {
            // Create temporary file with timestamp
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("DevTaskManager_Report_\(Date().timeIntervalSince1970).pdf")

            do
            {
                try pdfData.write(to: tempURL)
                let controller = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)

                // Cleanup after sharing
                controller.completionWithItemsHandler = { _, _, _, _ in
                    try? FileManager.default.removeItem(at: tempURL)
                }

                return controller
            }
            catch
            {
                // Fallback to sharing data directly if file creation fails
                return UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
            }
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context)
        {
        }
    }

#elseif canImport(AppKit)
    import AppKit

    // MARK: - Text/CSV Share Sheet (macOS)

    struct ReportShareSheet: View
    {
        let items: [Any]
        
        @Environment(\.dismiss) private var dismiss

        var body: some View
        {
            VStack(spacing: 20)
            {
                Text("Export Report")
                    .font(.headline)

                HStack(spacing: 12)
                {
                    Button("Save to File")
                    {
                        saveToFile()
                    }
                    .keyboardShortcut(.defaultAction)

                    Button("Copy to Clipboard")
                    {
                        copyToClipboard()
                    }

                    Button("Cancel")
                    {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
            .padding()
            .frame(width: 400)
        }

        private func saveToFile()
        {
            let panel = NSSavePanel()
            
            panel.allowedContentTypes = [.plainText, .commaSeparatedText]
            panel.nameFieldStringValue = "DevTaskManager_Report_\(Date().timeIntervalSince1970).txt"

            panel.begin
            {
                response in
                
                if response == .OK, let url = panel.url, let text = items.first as? String
                {
                    try? text.write(to: url, atomically: true, encoding: .utf8)
                }
                
                dismiss()
            }
        }

        private func copyToClipboard()
        {
            if let text = items.first as? String
            {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(text, forType: .string)
            }
            
            dismiss()
        }
    }

    // MARK: - PDF Share Sheet (macOS)

    struct PDFShareSheet: View
    {
        let pdfData: Data
        
        @Environment(\.dismiss) private var dismiss

        var body: some View
        {
            VStack(spacing: 20)
            {
                Text("Export PDF Report")
                    .font(.headline)

                HStack(spacing: 12)
                {
                    Button("Save to File")
                    {
                        saveToFile()
                    }
                    .keyboardShortcut(.defaultAction)

                    Button("Cancel")
                    {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
            .padding()
            .frame(width: 400)
        }

        private func saveToFile()
        {
            let panel = NSSavePanel()
            
            panel.allowedContentTypes = [.pdf]
            panel.nameFieldStringValue = "DevTaskManager_Report_\(Date().timeIntervalSince1970).pdf"

            panel.begin
            {
                response in
                
                if response == .OK, let url = panel.url
                {
                    try? pdfData.write(to: url)
                }
                
                dismiss()
            }
        }
    }

#endif
