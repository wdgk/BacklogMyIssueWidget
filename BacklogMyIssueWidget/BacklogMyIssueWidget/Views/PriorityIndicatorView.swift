import SwiftUI

struct PriorityIndicatorView: View {
    let priority: BacklogPriority?

    private var color: Color {
        guard let priority else { return .gray }
        switch priority.id {
        case 2: return .red       // High
        case 3: return .orange    // Medium
        case 4: return .blue      // Low
        default: return .gray
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 4)
    }
}
