import SwiftUI

struct IssueListView: View {
    @Bindable var viewModel: IssueListViewModel
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("My Issues")
                    .font(.system(size: 14, weight: .bold))

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.5)
                        .frame(width: 16, height: 16)
                }

                Spacer()

                Button {
                    viewModel.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .help("Refresh")

                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Divider()

            // Content
            if showSettings {
                SettingsView {
                    showSettings = false
                    viewModel.clearUserCache()
                    viewModel.refresh()
                }
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 28))
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if error.contains("Settings") {
                        Button("Open Settings") {
                            showSettings = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.issues.isEmpty && !viewModel.isLoading {
                EmptyStateView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(viewModel.issues) { issue in
                            IssueRowView(issue: issue)
                                .onTapGesture {
                                    viewModel.openIssue(issue)
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Footer
            if !showSettings {
                Divider()
                HStack {
                    Text("\(viewModel.issueCount) issues")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                    Spacer()
                    if let time = viewModel.lastUpdatedFormatted {
                        Text("Updated \(time)")
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
            }
        }
        .frame(width: Constants.panelWidth, height: Constants.panelHeight)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.panelCornerRadius))
    }
}
