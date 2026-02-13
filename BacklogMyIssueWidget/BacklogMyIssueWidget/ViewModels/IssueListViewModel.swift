import Foundation
import AppKit
import Observation

@Observable
final class IssueListViewModel {
    var issues: [BacklogIssue] = []
    var isLoading = false
    var errorMessage: String?
    var lastUpdated: Date?

    private let apiClient = BacklogAPIClient()
    private var refreshTimer: Timer?
    private var myUserId: Int?

    var issueCount: Int { issues.count }

    var lastUpdatedFormatted: String? {
        guard let lastUpdated else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: lastUpdated)
    }

    func startAutoRefresh() {
        refresh()
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Constants.refreshIntervalSeconds, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func refresh() {
        Task { @MainActor in
            await fetchIssues()
        }
    }

    @MainActor
    private func fetchIssues() async {
        guard let spaceURL = UserDefaults.standard.string(forKey: Constants.spaceURLKey),
              let apiKey = KeychainService.loadAPIKey(),
              !spaceURL.isEmpty, !apiKey.isEmpty else {
            errorMessage = BacklogAPIClient.APIError.missingCredentials.errorDescription
            issues = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Fetch user ID if not cached
            if myUserId == nil {
                let user = try await apiClient.fetchMyself(spaceURL: spaceURL, apiKey: apiKey)
                myUserId = user.id
            }

            guard let userId = myUserId else { return }

            let fetchedIssues = try await apiClient.fetchMyIssues(
                spaceURL: spaceURL,
                apiKey: apiKey,
                assigneeId: userId
            )
            issues = Self.sortByDueDate(fetchedIssues)
            lastUpdated = Date()
            errorMessage = nil
        } catch let error as BacklogAPIClient.APIError {
            errorMessage = error.errorDescription
            if case .unauthorized = error {
                myUserId = nil
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func openIssue(_ issue: BacklogIssue) {
        guard let spaceURL = UserDefaults.standard.string(forKey: Constants.spaceURLKey) else { return }
        var space = spaceURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if !space.hasPrefix("http://") && !space.hasPrefix("https://") {
            space = "https://\(space)"
        }
        while space.hasSuffix("/") {
            space.removeLast()
        }

        guard let url = URL(string: "\(space)/view/\(issue.issueKey)") else { return }
        NSWorkspace.shared.open(url)
    }

    func clearUserCache() {
        myUserId = nil
    }

    /// Sort: overdue first (oldest due date top), then upcoming (nearest due date top), then no due date last.
    private static func sortByDueDate(_ issues: [BacklogIssue]) -> [BacklogIssue] {
        let now = Calendar.current.startOfDay(for: Date())
        return issues.sorted { a, b in
            let dateA = a.dueDateParsed
            let dateB = b.dueDateParsed

            // Issues with due dates come before those without
            switch (dateA, dateB) {
            case (.none, .none): return false
            case (.some, .none): return true
            case (.none, .some): return false
            case let (.some(da), .some(db)):
                let overdueA = da < now
                let overdueB = db < now
                // Both overdue or both not overdue → earlier due date first
                if overdueA == overdueB { return da < db }
                // Overdue comes first
                return overdueA
            }
        }
    }
}
