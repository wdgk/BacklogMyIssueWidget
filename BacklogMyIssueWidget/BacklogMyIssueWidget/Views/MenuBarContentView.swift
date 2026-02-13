import SwiftUI

struct MenuBarContentView: View {
    @Bindable var viewModel: IssueListViewModel
    var onToggleWidget: () -> Void
    var isWidgetVisible: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(isWidgetVisible ? "Hide Widget" : "Show Widget") {
                onToggleWidget()
            }
            .keyboardShortcut("w")

            Button("Refresh Now") {
                viewModel.refresh()
            }
            .keyboardShortcut("r")

            Divider()

            if let time = viewModel.lastUpdatedFormatted {
                Text("Last updated: \(time)")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Text("\(viewModel.issueCount) issues")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(4)
    }
}
