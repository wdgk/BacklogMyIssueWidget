import Foundation

enum Constants {
    static let keychainAPIKeyAccount = "backlog_api_key"
    static let keychainService = "com.backlog.myissuewidget"

    static let spaceURLKey = "backlog_space_url"
    static let windowFrameXKey = "window_frame_x"
    static let windowFrameYKey = "window_frame_y"
    static let widgetVisibleKey = "widget_visible"

    static let refreshIntervalSeconds: TimeInterval = 3600 // 1 hour

    static let panelWidth: CGFloat = 320
    static let panelHeight: CGFloat = 480
    static let panelCornerRadius: CGFloat = 12

    static let maxIssueCount = 100
}
