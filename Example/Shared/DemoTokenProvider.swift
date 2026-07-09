import Foundation

/// DEMO-ONLY token minting. In production your BACKEND calls Infobip `POST /webrtc/1/token`
/// and returns the token to the app — the API key must never ship inside the app.
///
/// The key is provided at runtime so it stays OUT of source control. Set it either way:
///   • Scheme ▸ Run ▸ Arguments ▸ Environment Variables: `INFOBIP_API_KEY = <your key>`, or
///   • add a git-ignored `Secrets.plist` to the app target with a string key `INFOBIP_API_KEY`.
enum DemoTokenProvider {

    private static let baseURL = URL(string: "https://api.infobip.com")!
    private static let tokenTimeToLive = 8 * 60 * 60

    private static var apiKey: String? {
        if let env = ProcessInfo.processInfo.environment["INFOBIP_API_KEY"], !env.isEmpty {
            return env
        }
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let dict = NSDictionary(contentsOf: url),
           let key = dict["INFOBIP_API_KEY"] as? String, !key.isEmpty {
            return key
        }
        return nil
    }

    private struct TokenRequest: Encodable {
        let identity: String
        let displayName: String
        let timeToLive: Int
    }
    private struct TokenResponse: Decodable {
        let token: String
    }

    static func token(identity: String, displayName: String) async throws -> String {
        guard let apiKey = apiKey else {
            throw NSError(domain: "DemoTokenProvider", code: 2, userInfo: [
                NSLocalizedDescriptionKey:
                    "Missing INFOBIP_API_KEY. Set it as a scheme environment variable or in a git-ignored Secrets.plist. In production, mint the token on your backend instead."
            ])
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("webrtc/1/token"))
        request.httpMethod = "POST"
        request.setValue("App \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            TokenRequest(identity: identity, displayName: displayName, timeToLive: tokenTimeToLive)
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "DemoTokenProvider", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Token request failed"])
        }
        return try JSONDecoder().decode(TokenResponse.self, from: data).token
    }
}
