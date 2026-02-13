import SwiftUI

struct IssueRowView: View {
    let issue: BacklogIssue
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            PriorityIndicatorView(priority: issue.priority)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(issue.issueKey)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary)

                    StatusBadgeView(status: issue.status)

                    Spacer()

                    if let dueDate = issue.dueDateFormatted {
                        Text(dueDate)
                            .font(.system(size: 10))
                            .foregroundStyle(issue.isOverdue ? .red : .secondary)
                    }
                }

                Text(issue.summary)
                    .font(.system(size: 12))
                    .lineLimit(2)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.primary.opacity(0.06) : Color.clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .contentShape(Rectangle())
    }
}
