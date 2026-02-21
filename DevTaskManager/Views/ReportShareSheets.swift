//
//  ReportShareSheets.swift
//  DevTaskManager
//
//  Created by Assistant on 2/20/26.
//

import SwiftUI

// MARK: - Text/CSV Share Sheet

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

// MARK: - PDF Share Sheet

struct PDFShareSheet: UIViewControllerRepresentable
{
    let pdfData: Data
    
    func makeUIViewController(context: Context) -> UIActivityViewController
    {
        // Create temporary file with timestamp
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("DevTaskManager_Report_\(Date().timeIntervalSince1970).pdf")
        
        do {
            try pdfData.write(to: tempURL)
            let controller = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            // Cleanup after sharing
            controller.completionWithItemsHandler = { _, _, _, _ in
                try? FileManager.default.removeItem(at: tempURL)
            }
            
            return controller
        } catch {
            // Fallback to sharing data directly if file creation fails
            return UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        }
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context)
    {
    }
}
