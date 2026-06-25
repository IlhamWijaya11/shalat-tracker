#if os(iOS)
import Foundation
import RakaatCore

/// Persists `RakaatSession` summaries to a local JSON file. This is the **only**
/// thing the app writes to disk — small structured data, never video or frames.
public final class SessionStore: ObservableObject {
    public static let shared = SessionStore()

    @Published public private(set) var sessions: [RakaatSession] = []

    private let url: URL

    public init(filename: String = "sessions.json") {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.url = dir.appendingPathComponent(filename)
        load()
    }

    public func add(_ session: RakaatSession) {
        sessions.insert(session, at: 0)
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([RakaatSession].self, from: data) else { return }
        sessions = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
#endif
