import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var spaceURL: String = ""
    var apiKey: String = ""
    var isSaved = false
    var errorMessage: String?

    func load() {
        spaceURL = UserDefaults.standard.string(forKey: Constants.spaceURLKey) ?? ""
        apiKey = KeychainService.loadAPIKey() ?? ""
        isSaved = false
        errorMessage = nil
    }

    func save() {
        let trimmedURL = spaceURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedURL.isEmpty else {
            errorMessage = "Space URL is required."
            return
        }
        guard !trimmedKey.isEmpty else {
            errorMessage = "API Key is required."
            return
        }

        UserDefaults.standard.set(trimmedURL, forKey: Constants.spaceURLKey)
        let saved = KeychainService.save(apiKey: trimmedKey)

        if saved {
            isSaved = true
            errorMessage = nil
        } else {
            errorMessage = "Failed to save API key to Keychain."
        }
    }
}
