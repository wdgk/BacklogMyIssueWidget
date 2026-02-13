import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: FloatingPanel?
    let viewModel = IssueListViewModel()

    var isWidgetVisible: Bool {
        panel?.isVisible ?? false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        createPanel()
        viewModel.startAutoRefresh()
    }

    func applicationWillTerminate(_ notification: Notification) {
        viewModel.stopAutoRefresh()
    }

    func toggleWidget() {
        guard let panel else { return }
        if panel.isVisible {
            panel.orderOut(nil)
            UserDefaults.standard.set(false, forKey: Constants.widgetVisibleKey)
        } else {
            panel.orderFront(nil)
            UserDefaults.standard.set(true, forKey: Constants.widgetVisibleKey)
        }
    }

    private func createPanel() {
        let x = UserDefaults.standard.object(forKey: Constants.windowFrameXKey) as? CGFloat
        let y = UserDefaults.standard.object(forKey: Constants.windowFrameYKey) as? CGFloat

        let screenFrame = NSScreen.main?.visibleFrame ?? .zero
        let defaultX = screenFrame.maxX - Constants.panelWidth - 20
        let defaultY = screenFrame.maxY - Constants.panelHeight - 20

        let origin = CGPoint(x: x ?? defaultX, y: y ?? defaultY)
        let size = CGSize(width: Constants.panelWidth, height: Constants.panelHeight)
        let contentRect = NSRect(origin: origin, size: size)

        let panel = FloatingPanel(contentRect: contentRect)

        let hostingView = NSHostingView(rootView: IssueListView(viewModel: viewModel))
        hostingView.layer?.cornerRadius = Constants.panelCornerRadius
        hostingView.layer?.masksToBounds = true
        panel.contentView = hostingView

        self.panel = panel

        // Observe window move to persist position
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidMove),
            name: NSWindow.didMoveNotification,
            object: panel
        )

        // Show if previously visible (default: true on first launch)
        let shouldShow = UserDefaults.standard.object(forKey: Constants.widgetVisibleKey) as? Bool ?? true
        if shouldShow {
            panel.orderFront(nil)
        }
    }

    @objc private func windowDidMove(_ notification: Notification) {
        guard let panel else { return }
        let frame = panel.frame
        UserDefaults.standard.set(frame.origin.x, forKey: Constants.windowFrameXKey)
        UserDefaults.standard.set(frame.origin.y, forKey: Constants.windowFrameYKey)
    }
}
