//
//  PDFReportGenerator.swift
//  DevTaskManager
//
//  Created by Assistant on 2/20/26.
//

import Foundation
import PDFKit
import SwiftUI
import Charts

/// PDF Report Generator - Creates professional PDF reports with charts and formatted data
class PDFReportGenerator
{
    // MARK: - PDF Generation
    
    /// Generate a comprehensive PDF report from DevTaskManagerReport
    static func generatePDF(from report: DevTaskManagerReport) -> Data?
    {
        let pdfMetaData = [
            kCGPDFContextCreator: "DevTaskManager",
            kCGPDFContextAuthor: "DevTaskManager App",
            kCGPDFContextTitle: "DevTaskManager Report - \(report.generatedDate.formatted(date: .abbreviated, time: .omitted))"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // US Letter size: 8.5 x 11 inches = 612 x 792 points
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            var currentY: CGFloat = 60
            var pageNumber = 0
            
            // Page 1: Cover Page & Summary
            context.beginPage()
            pageNumber += 1
            currentY = drawCoverPage(context: context, pageRect: pageRect, report: report)
            // Note: Footer will be added in a second pass
            
            // Page 2: Projects Summary & Chart
            context.beginPage()
            pageNumber += 1
            currentY = 60
            currentY = drawSectionHeader(context: context, pageRect: pageRect, title: "Projects Overview", y: currentY)
            currentY = drawProjectsSummary(context: context, pageRect: pageRect, summary: report.projectsSummary, startY: currentY)
            
            // Projects chart
            if let chartImage = renderProjectCompletionChart(projects: report.detailedProjects) {
                currentY += 20
                currentY = drawImage(context: context, pageRect: pageRect, image: chartImage, y: currentY, maxHeight: 250)
            }
            
            // Page 3: Users Summary & Chart
            context.beginPage()
            pageNumber += 1
            currentY = 60
            currentY = drawSectionHeader(context: context, pageRect: pageRect, title: "Users Overview", y: currentY)
            currentY = drawUsersSummary(context: context, pageRect: pageRect, summary: report.usersSummary, startY: currentY)
            
            // Users chart
            if let chartImage = renderUserProductivityChart(users: report.detailedUsers) {
                currentY += 20
                currentY = drawImage(context: context, pageRect: pageRect, image: chartImage, y: currentY, maxHeight: 250)
            }
            
            // Page 4: Tasks Summary & Charts
            context.beginPage()
            pageNumber += 1
            currentY = 60
            currentY = drawSectionHeader(context: context, pageRect: pageRect, title: "Tasks Overview", y: currentY)
            currentY = drawTasksSummary(context: context, pageRect: pageRect, summary: report.tasksSummary, startY: currentY)
            
            // Task status chart
            if let chartImage = renderTaskStatusChart(summary: report.tasksSummary) {
                currentY += 20
                if currentY + 200 > pageHeight - 60 {
                    context.beginPage()
                    pageNumber += 1
                    currentY = 60
                }
                currentY = drawImage(context: context, pageRect: pageRect, image: chartImage, y: currentY, maxHeight: 200)
            }
            
            // Page 5+: Detailed Projects
            if !report.detailedProjects.isEmpty {
                context.beginPage()
                pageNumber += 1
                currentY = 60
                currentY = drawSectionHeader(context: context, pageRect: pageRect, title: "Detailed Project Reports", y: currentY)
                
                for project in report.detailedProjects {
                    if currentY + 100 > pageHeight - 60 {
                        context.beginPage()
                        pageNumber += 1
                        currentY = 60
                    }
                    currentY = drawProjectDetail(context: context, pageRect: pageRect, project: project, startY: currentY)
                }
            }
            
            // Detailed Users
            if !report.detailedUsers.isEmpty {
                context.beginPage()
                pageNumber += 1
                currentY = 60
                currentY = drawSectionHeader(context: context, pageRect: pageRect, title: "Detailed User Reports", y: currentY)
                
                for user in report.detailedUsers {
                    if currentY + 100 > pageHeight - 60 {
                        context.beginPage()
                        pageNumber += 1
                        currentY = 60
                    }
                    currentY = drawUserDetail(context: context, pageRect: pageRect, user: user, startY: currentY)
                }
            }
            
            // Note: Page numbers/footers are not added in this implementation
            // UIGraphicsPDFRenderer doesn't support adding content to previously rendered pages
            // If page numbers are needed, they should be added during page creation or use a different PDF library
        }
        
        return data
    }
    
    // MARK: - Cover Page
    
    private static func drawCoverPage(context: UIGraphicsPDFRendererContext, pageRect: CGRect, report: DevTaskManagerReport) -> CGFloat
    {
        var currentY: CGFloat = 150
        
        // Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36, weight: .bold),
            .foregroundColor: UIColor.systemBlue
        ]
        let title = "DevTaskManager"
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: (pageRect.width - titleSize.width) / 2, y: currentY, width: titleSize.width, height: titleSize.height)
        title.draw(in: titleRect, withAttributes: titleAttributes)
        currentY += titleSize.height + 20
        
        // Subtitle
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ]
        let subtitle = "Comprehensive Report"
        let subtitleSize = subtitle.size(withAttributes: subtitleAttributes)
        let subtitleRect = CGRect(x: (pageRect.width - subtitleSize.width) / 2, y: currentY, width: subtitleSize.width, height: subtitleSize.height)
        subtitle.draw(in: subtitleRect, withAttributes: subtitleAttributes)
        currentY += subtitleSize.height + 60
        
        // Date
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.gray
        ]
        let dateText = "Generated: \(report.generatedDate.formatted(date: .long, time: .shortened))"
        let dateSize = dateText.size(withAttributes: dateAttributes)
        let dateRect = CGRect(x: (pageRect.width - dateSize.width) / 2, y: currentY, width: dateSize.width, height: dateSize.height)
        dateText.draw(in: dateRect, withAttributes: dateAttributes)
        currentY += dateSize.height + 80
        
        // Summary statistics boxes
        let boxWidth: CGFloat = 150
        let boxHeight: CGFloat = 100
        let spacing: CGFloat = 30
        let startX = (pageRect.width - (boxWidth * 3 + spacing * 2)) / 2
        
        // Projects box
        drawStatBox(
            context: context,
            rect: CGRect(x: startX, y: currentY, width: boxWidth, height: boxHeight),
            title: "Projects",
            value: "\(report.projectsSummary.totalProjects)",
            color: UIColor.systemBlue
        )
        
        // Users box
        drawStatBox(
            context: context,
            rect: CGRect(x: startX + boxWidth + spacing, y: currentY, width: boxWidth, height: boxHeight),
            title: "Users",
            value: "\(report.usersSummary.totalUsers)",
            color: UIColor.systemPurple
        )
        
        // Tasks box
        drawStatBox(
            context: context,
            rect: CGRect(x: startX + (boxWidth + spacing) * 2, y: currentY, width: boxWidth, height: boxHeight),
            title: "Tasks",
            value: "\(report.tasksSummary.totalTasks)",
            color: UIColor.systemOrange
        )
        
        currentY += boxHeight + 60
        
        // Quick stats
        currentY = drawKeyMetrics(context: context, pageRect: pageRect, report: report, startY: currentY)
        
        return currentY
    }
    
    private static func drawStatBox(context: UIGraphicsPDFRendererContext, rect: CGRect, title: String, value: String, color: UIColor)
    {
        let cgContext = context.cgContext
        
        // Draw background with shadow
        cgContext.saveGState()
        cgContext.setShadow(offset: CGSize(width: 0, height: 2), blur: 4, color: UIColor.black.withAlphaComponent(0.1).cgColor)
        cgContext.setFillColor(color.withAlphaComponent(0.1).cgColor)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 12)
        path.fill()
        cgContext.restoreGState()
        
        // Draw border
        cgContext.setStrokeColor(color.cgColor)
        cgContext.setLineWidth(2)
        path.stroke()
        
        // Draw value
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
            .foregroundColor: color
        ]
        let valueSize = value.size(withAttributes: valueAttributes)
        let valueRect = CGRect(x: rect.minX + (rect.width - valueSize.width) / 2, y: rect.minY + 20, width: valueSize.width, height: valueSize.height)
        value.draw(in: valueRect, withAttributes: valueAttributes)
        
        // Draw title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ]
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: rect.minX + (rect.width - titleSize.width) / 2, y: rect.maxY - 30, width: titleSize.width, height: titleSize.height)
        title.draw(in: titleRect, withAttributes: titleAttributes)
    }
    
    private static func drawKeyMetrics(context: UIGraphicsPDFRendererContext, pageRect: CGRect, report: DevTaskManagerReport, startY: CGFloat) -> CGFloat
    {
        var currentY = startY
        let margin: CGFloat = 80
        let lineHeight: CGFloat = 24
        
        let metricsAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]
        
        let metrics = [
            "✓ Completed Tasks: \(report.tasksSummary.completedTasks)",
            "⏳ In Progress Tasks: \(report.tasksSummary.inProgressTasks)",
            "○ Unassigned Tasks: \(report.tasksSummary.unassignedTasks)",
            "📊 Completion Rate: \(String(format: "%.1f%%", report.tasksSummary.totalTasks > 0 ? Double(report.tasksSummary.completedTasks) / Double(report.tasksSummary.totalTasks) * 100 : 0))",
            "🎯 Completed This Week: \(report.tasksSummary.completedThisWeek)",
            "📅 Completed This Month: \(report.tasksSummary.completedThisMonth)"
        ]
        
        for metric in metrics {
            let rect = CGRect(x: margin, y: currentY, width: pageRect.width - margin * 2, height: lineHeight)
            metric.draw(in: rect, withAttributes: metricsAttributes)
            currentY += lineHeight
        }
        
        return currentY + 20
    }
    
    // MARK: - Section Drawing
    
    private static func drawSectionHeader(context: UIGraphicsPDFRendererContext, pageRect: CGRect, title: String, y: CGFloat) -> CGFloat
    {
        let margin: CGFloat = 60
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.systemBlue
        ]
        
        let rect = CGRect(x: margin, y: y, width: pageRect.width - margin * 2, height: 30)
        title.draw(in: rect, withAttributes: headerAttributes)
        
        // Draw underline
        let cgContext = context.cgContext
        cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
        cgContext.setLineWidth(2)
        cgContext.move(to: CGPoint(x: margin, y: y + 32))
        cgContext.addLine(to: CGPoint(x: pageRect.width - margin, y: y + 32))
        cgContext.strokePath()
        
        return y + 50
    }
    
    private static func drawProjectsSummary(context: UIGraphicsPDFRendererContext, pageRect: CGRect, summary: ProjectsSummary, startY: CGFloat) -> CGFloat
    {
        var currentY = startY
        let margin: CGFloat = 60
        let lineHeight: CGFloat = 22
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        
        let data = [
            ("Total Projects:", "\(summary.totalProjects)"),
            ("Projects with Tasks:", "\(summary.projectsWithTasks)"),
            ("Projects without Tasks:", "\(summary.projectsWithoutTasks)"),
            ("Total Tasks Across Projects:", "\(summary.totalTasksAcrossProjects)"),
            ("Average Tasks per Project:", String(format: "%.1f", summary.averageTasksPerProject))
        ]
        
        for (label, value) in data {
            let labelRect = CGRect(x: margin, y: currentY, width: 300, height: lineHeight)
            label.draw(in: labelRect, withAttributes: labelAttributes)
            
            let valueRect = CGRect(x: margin + 310, y: currentY, width: 200, height: lineHeight)
            value.draw(in: valueRect, withAttributes: valueAttributes)
            
            currentY += lineHeight
        }
        
        return currentY + 20
    }
    
    private static func drawUsersSummary(context: UIGraphicsPDFRendererContext, pageRect: CGRect, summary: UsersSummary, startY: CGFloat) -> CGFloat
    {
        var currentY = startY
        let margin: CGFloat = 60
        let lineHeight: CGFloat = 22
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        
        let data = [
            ("Total Users:", "\(summary.totalUsers)"),
            ("Users with Tasks:", "\(summary.usersWithTasks)"),
            ("Users without Tasks:", "\(summary.usersWithoutTasks)"),
            ("Total Tasks Assigned:", "\(summary.totalTasksAssigned)"),
            ("Average Tasks per User:", String(format: "%.1f", summary.averageTasksPerUser)),
            ("Most Active User:", summary.mostActiveUser ?? "N/A"),
            ("Most Active User Tasks:", "\(summary.mostActiveUserTaskCount)")
        ]
        
        for (label, value) in data {
            let labelRect = CGRect(x: margin, y: currentY, width: 300, height: lineHeight)
            label.draw(in: labelRect, withAttributes: labelAttributes)
            
            let valueRect = CGRect(x: margin + 310, y: currentY, width: 200, height: lineHeight)
            value.draw(in: valueRect, withAttributes: valueAttributes)
            
            currentY += lineHeight
        }
        
        return currentY + 20
    }
    
    private static func drawTasksSummary(context: UIGraphicsPDFRendererContext, pageRect: CGRect, summary: TasksSummary, startY: CGFloat) -> CGFloat
    {
        var currentY = startY
        let margin: CGFloat = 60
        let lineHeight: CGFloat = 22
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        
        let data = [
            ("Total Tasks:", "\(summary.totalTasks)"),
            ("Unassigned:", "\(summary.unassignedTasks)"),
            ("In Progress:", "\(summary.inProgressTasks)"),
            ("Completed:", "\(summary.completedTasks)"),
            ("Deferred:", "\(summary.deferredTasks)"),
            ("Completed This Week:", "\(summary.completedThisWeek)"),
            ("Completed This Month:", "\(summary.completedThisMonth)")
        ]
        
        for (label, value) in data {
            let labelRect = CGRect(x: margin, y: currentY, width: 300, height: lineHeight)
            label.draw(in: labelRect, withAttributes: labelAttributes)
            
            let valueRect = CGRect(x: margin + 310, y: currentY, width: 200, height: lineHeight)
            value.draw(in: valueRect, withAttributes: valueAttributes)
            
            currentY += lineHeight
        }
        
        return currentY + 20
    }
    
    private static func drawProjectDetail(context: UIGraphicsPDFRendererContext, pageRect: CGRect, project: ProjectReport, startY: CGFloat) -> CGFloat
    {
        var currentY = startY
        let margin: CGFloat = 60
        
        // Draw box
        let boxHeight: CGFloat = 90
        let boxRect = CGRect(x: margin, y: currentY, width: pageRect.width - margin * 2, height: boxHeight)
        
        let cgContext = context.cgContext
        cgContext.setFillColor(UIColor.systemBlue.withAlphaComponent(0.05).cgColor)
        let path = UIBezierPath(roundedRect: boxRect, cornerRadius: 8)
        path.fill()
        
        cgContext.setStrokeColor(UIColor.systemBlue.withAlphaComponent(0.3).cgColor)
        cgContext.setLineWidth(1)
        path.stroke()
        
        // Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        let titleRect = CGRect(x: margin + 10, y: currentY + 10, width: boxRect.width - 20, height: 20)
        project.title.draw(in: titleRect, withAttributes: titleAttributes)
        
        // Details
        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]
        
        let details = "Created: \(project.dateCreated.formatted(date: .abbreviated, time: .omitted)) | Tasks: \(project.taskCount) | ✓ \(project.completedTaskCount) | ⏳ \(project.inProgressTaskCount) | ○ \(project.unassignedTaskCount)"
        let detailRect = CGRect(x: margin + 10, y: currentY + 35, width: boxRect.width - 20, height: 40)
        details.draw(in: detailRect, withAttributes: detailAttributes)
        
        return currentY + boxHeight + 10
    }
    
    private static func drawUserDetail(context: UIGraphicsPDFRendererContext, pageRect: CGRect, user: UserReport, startY: CGFloat) -> CGFloat
    {
        var currentY = startY
        let margin: CGFloat = 60
        
        // Draw box
        let boxHeight: CGFloat = 90
        let boxRect = CGRect(x: margin, y: currentY, width: pageRect.width - margin * 2, height: boxHeight)
        
        let cgContext = context.cgContext
        cgContext.setFillColor(UIColor.systemPurple.withAlphaComponent(0.05).cgColor)
        let path = UIBezierPath(roundedRect: boxRect, cornerRadius: 8)
        path.fill()
        
        cgContext.setStrokeColor(UIColor.systemPurple.withAlphaComponent(0.3).cgColor)
        cgContext.setLineWidth(1)
        path.stroke()
        
        // Name
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        let nameRect = CGRect(x: margin + 10, y: currentY + 10, width: boxRect.width - 20, height: 20)
        user.name.draw(in: nameRect, withAttributes: nameAttributes)
        
        // Roles
        let roleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: UIColor.systemPurple
        ]
        let roleRect = CGRect(x: margin + 10, y: currentY + 32, width: boxRect.width - 20, height: 15)
        user.roles.joined(separator: ", ").draw(in: roleRect, withAttributes: roleAttributes)
        
        // Details
        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]
        
        let details = "Joined: \(user.dateCreated.formatted(date: .abbreviated, time: .omitted)) | Tasks: \(user.totalTasksAssigned) | ✓ \(user.completedTasks) | ⏳ \(user.inProgressTasks)"
        let detailRect = CGRect(x: margin + 10, y: currentY + 50, width: boxRect.width - 20, height: 30)
        details.draw(in: detailRect, withAttributes: detailAttributes)
        
        return currentY + boxHeight + 10
    }
    
    // MARK: - Footer (Not currently used - UIGraphicsPDFRenderer limitation)
    // UIGraphicsPDFRenderer doesn't support adding content to previously rendered pages
    // To add page numbers, you would need to calculate total pages first or use PDFKit post-processing
    
    /*
    private static func drawFooter(context: UIGraphicsPDFRendererContext, pageRect: CGRect, pageNumber: Int, totalPages: Int)
    {
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor.gray
        ]
        
        let footerText = "DevTaskManager Report - Page \(pageNumber) of \(totalPages)"
        let footerSize = footerText.size(withAttributes: footerAttributes)
        let footerRect = CGRect(
            x: (pageRect.width - footerSize.width) / 2,
            y: pageRect.height - 40,
            width: footerSize.width,
            height: footerSize.height
        )
        footerText.draw(in: footerRect, withAttributes: footerAttributes)
    }
    */
    
    private static func drawImage(context: UIGraphicsPDFRendererContext, pageRect: CGRect, image: UIImage, y: CGFloat, maxHeight: CGFloat) -> CGFloat
    {
        let margin: CGFloat = 60
        let maxWidth = pageRect.width - margin * 2
        
        let aspectRatio = image.size.width / image.size.height
        var imageWidth = maxWidth
        var imageHeight = imageWidth / aspectRatio
        
        if imageHeight > maxHeight {
            imageHeight = maxHeight
            imageWidth = imageHeight * aspectRatio
        }
        
        let x = margin + (maxWidth - imageWidth) / 2
        let imageRect = CGRect(x: x, y: y, width: imageWidth, height: imageHeight)
        image.draw(in: imageRect)
        
        return y + imageHeight + 10
    }
    
    // MARK: - Chart Rendering
    
    @MainActor
    static func renderTaskStatusChart(summary: TasksSummary) -> UIImage?
    {
        let chartView = TaskStatusChartView(summary: summary)
        let renderer = ImageRenderer(content: chartView)
        renderer.scale = 3.0 // High resolution
        return renderer.uiImage
    }
    
    @MainActor
    static func renderProjectCompletionChart(projects: [ProjectReport]) -> UIImage?
    {
        let topProjects = Array(projects.prefix(10))
        let chartView = ProjectCompletionChartView(projects: topProjects)
        let renderer = ImageRenderer(content: chartView)
        renderer.scale = 3.0
        return renderer.uiImage
    }
    
    @MainActor
    static func renderUserProductivityChart(users: [UserReport]) -> UIImage?
    {
        let topUsers = Array(users.sorted { $0.totalTasksAssigned > $1.totalTasksAssigned }.prefix(10))
        let chartView = UserProductivityChartView(users: topUsers)
        let renderer = ImageRenderer(content: chartView)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

// MARK: - Chart Views for Rendering

struct TaskStatusChartView: View
{
    let summary: TasksSummary
    
    var body: some View
    {
        Chart {
            BarMark(
                x: .value("Count", summary.completedTasks),
                y: .value("Status", "Completed")
            )
            .foregroundStyle(.green.gradient)
            
            BarMark(
                x: .value("Count", summary.inProgressTasks),
                y: .value("Status", "In Progress")
            )
            .foregroundStyle(.blue.gradient)
            
            BarMark(
                x: .value("Count", summary.unassignedTasks),
                y: .value("Status", "Unassigned")
            )
            .foregroundStyle(.orange.gradient)
            
            if summary.deferredTasks > 0 {
                BarMark(
                    x: .value("Count", summary.deferredTasks),
                    y: .value("Status", "Deferred")
                )
                .foregroundStyle(.gray.gradient)
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(width: 500, height: 250)
        .padding()
        .background(Color.white)
    }
}

struct ProjectCompletionChartView: View
{
    let projects: [ProjectReport]
    
    var body: some View
    {
        Chart(projects) { project in
            BarMark(
                x: .value("Completion", project.taskCount > 0 ? Double(project.completedTaskCount) / Double(project.taskCount) * 100 : 0),
                y: .value("Project", project.title)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        .chartXScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let project = projects.first(where: { $0.title == value.as(String.self) }) {
                        Text(project.title)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
        }
        .frame(width: 500, height: CGFloat(projects.count * 40 + 100))
        .padding()
        .background(Color.white)
    }
}

struct UserProductivityChartView: View
{
    let users: [UserReport]
    
    var body: some View
    {
        Chart(users) { user in
            BarMark(
                x: .value("Tasks", user.totalTasksAssigned),
                y: .value("User", user.name)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.purple, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let user = users.first(where: { $0.name == value.as(String.self) }) {
                        Text(user.name)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
        }
        .frame(width: 500, height: CGFloat(users.count * 40 + 100))
        .padding()
        .background(Color.white)
    }
}
