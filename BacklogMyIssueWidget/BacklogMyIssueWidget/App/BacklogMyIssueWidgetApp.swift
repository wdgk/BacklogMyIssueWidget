import SwiftUI

@main
struct BacklogMyIssueWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Backlog My Issues", systemImage: "list.bullet.rectangle") {
            MenuBarContentView(
                viewModel: appDelegate.viewModel,
                onToggleWidget: { appDelegate.toggleWidget() },
                isWidgetVisible: appDelegate.isWidgetVisible
            )
        }
    }
}
