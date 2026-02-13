import Foundation

actor BacklogAPIClient {
    enum APIError: LocalizedError {
        case invalidURL
        case unauthorized
        case rateLimited
        case httpError(Int)
        case networkError(Error)
        case decodingError(Error)
        case missingCredentials

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .unauthorized:
                return "Invalid API key. Please check your settings."
            case .rateLimited:
                return "Rate limited. Please wait a moment."
            case .httpError(let code):
                return "HTTP error: \(code)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .decodingError(let error):
                return "Data error: \(error.localizedDescription)"
            case .missingCredentials:
                return "Please configure your Backlog space URL and API key in Settings."
            }
        }
    }

    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    func fetchMyself(spaceURL: String, apiKey: String) async throws -> BacklogUser {
        let url = try buildURL(spaceURL: spaceURL, path: "/api/v2/users/myself", queryItems: [
            URLQueryItem(name: "apiKey", value: apiKey),
        ])
        return try await request(url: url)
    }

    func fetchMyIssues(spaceURL: String, apiKey: String, assigneeId: Int) async throws -> [BacklogIssue] {
        let url = try buildURL(spaceURL: spaceURL, path: "/api/v2/issues", queryItems: [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "assigneeId[]", value: String(assigneeId)),
            URLQueryItem(name: "statusId[]", value: "1"), // Open
            URLQueryItem(name: "statusId[]", value: "2"), // In Progress
            URLQueryItem(name: "statusId[]", value: "3"), // Resolved
            URLQueryItem(name: "sort", value: "dueDate"),
            URLQueryItem(name: "order", value: "asc"),
            URLQueryItem(name: "count", value: String(Constants.maxIssueCount)),
        ])
        return try await request(url: url)
    }

    private func buildURL(spaceURL: String, path: String, queryItems: [URLQueryItem]) throws -> URL {
        var space = spaceURL.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove trailing slash
        while space.hasSuffix("/") {
            space.removeLast()
        }
        // Add https:// if missing
        if !space.hasPrefix("http://") && !space.hasPrefix("https://") {
            space = "https://\(space)"
        }

        guard var components = URLComponents(string: space + path) else {
            throw APIError.invalidURL
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.invalidURL
        }
        return url
    }

    private func request<T: Decodable>(url: URL) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidURL
        }

        switch httpResponse.statusCode {
        case 200..<300:
            break
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimited
        default:
            throw APIError.httpError(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
