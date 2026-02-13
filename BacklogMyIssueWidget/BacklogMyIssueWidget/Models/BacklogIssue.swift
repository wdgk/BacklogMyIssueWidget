import Foundation

struct BacklogIssue: Codable, Identifiable {
    let id: Int
    let issueKey: String
    let summary: String
    let status: BacklogStatus
    let priority: BacklogPriority?
    let issueType: BacklogIssueType
    let dueDate: String?
    let assignee: BacklogUser?
    let createdUser: BacklogUser?
    let created: String?
    let updated: String?

    var dueDateFormatted: String? {
        guard let dueDate else { return nil }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        inputFormatter.timeZone = TimeZone(identifier: "UTC")

        guard let date = inputFormatter.date(from: dueDate) else {
            // Try date-only format
            inputFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = inputFormatter.date(from: dueDate) else { return nil }
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "M/d"
            return outputFormatter.string(from: date)
        }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "M/d"
        return outputFormatter.string(from: date)
    }

    var dueDateParsed: Date? {
        guard let dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        if let date = formatter.date(from: dueDate) { return date }
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dueDate)
    }

    var isOverdue: Bool {
        guard let date = dueDateParsed else { return false }
        return date < Calendar.current.startOfDay(for: Date())
    }
}

struct BacklogStatus: Codable, Identifiable {
    let id: Int
    let name: String
    let color: String?
}

struct BacklogPriority: Codable, Identifiable {
    let id: Int
    let name: String
}

struct BacklogIssueType: Codable, Identifiable {
    let id: Int
    let name: String
    let color: String?
}
