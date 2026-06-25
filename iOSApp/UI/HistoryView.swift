#if os(iOS)
import SwiftUI
import RakaatCore

/// Layar 5: daftar sesi shalat lampau.
public struct HistoryView: View {
    @ObservedObject private var store = SessionStore.shared

    public init() {}

    private static let fmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.dateFormat = "d MMM · HH:mm"
        return f
    }()

    public var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()
            if store.sessions.isEmpty {
                ContentUnavailable("Belum ada riwayat", "Sesi shalat akan muncul di sini.")
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(store.sessions) { s in
                            row(s)
                            Divider().background(Theme.line)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .navigationTitle("Riwayat")
    }

    private func row(_ s: RakaatSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(s.prayer.displayName).font(.headline).foregroundStyle(Theme.ink)
                Text(Self.fmt.string(from: s.timestamp))
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(s.rakaat)").font(.title3.weight(.bold)).foregroundStyle(Theme.ink)
            Image(systemName: s.isValid ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(s.isValid ? Theme.green : Theme.warn)
        }
        .padding(.vertical, 14)
    }
}

/// Tiny empty-state helper (avoids iOS 17 ContentUnavailableView dependency).
struct ContentUnavailable: View {
    let title: String, message: String
    init(_ title: String, _ message: String) { self.title = title; self.message = message }
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.stars").font(.largeTitle).foregroundStyle(Theme.greenSoft)
            Text(title).font(.headline).foregroundStyle(Theme.ink)
            Text(message).font(.subheadline).foregroundStyle(.secondary)
        }
    }
}
#endif
