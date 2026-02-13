import AppKit

final class FloatingPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )

        level = .floating
        hidesOnDeactivate = false
        isMovableByWindowBackground = true
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

        isReleasedWhenClosed = false
    }

    // Allow the panel to become key to support scrolling and interaction
    override var canBecomeKey: Bool { true }

    // Prevent the panel from becoming main window
    override var canBecomeMain: Bool { false }
}
