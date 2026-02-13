import SwiftUI

struct StatusBadgeView: View {
    let status: BacklogStatus

    private var badgeColor: Color {
        if let hex = status.color {
            return Color(hex: hex)
        }
        switch status.id {
        case 1: return .green   // Open
        case 2: return .blue    // In Progress
        case 3: return .orange  // Resolved
        case 4: return .gray    // Closed
        default: return .secondary
        }
    }

    var body: some View {
        Text(status.name)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(badgeColor, in: Capsule())
    }
}
