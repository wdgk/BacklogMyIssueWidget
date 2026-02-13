import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    var onSave: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.system(size: 16, weight: .semibold))

            VStack(alignment: .leading, spacing: 8) {
                Text("Space URL")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                TextField("myspace.backlog.com", text: $viewModel.spaceURL)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                SecureField("Enter your API key", text: $viewModel.apiKey)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundStyle(.red)
            }

            if viewModel.isSaved {
                Text("Settings saved!")
                    .font(.system(size: 11))
                    .foregroundStyle(.green)
            }

            Button("Save") {
                viewModel.save()
                if viewModel.isSaved {
                    onSave?()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
        .frame(width: 300)
        .onAppear {
            viewModel.load()
        }
    }
}
