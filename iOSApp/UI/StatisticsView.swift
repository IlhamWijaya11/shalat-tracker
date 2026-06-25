#if os(iOS)
import SwiftUI
import RakaatCore

/// Layar 7: ringkasan mingguan dari riwayat sesi.
public struct StatisticsView: View {
    @ObservedObject private var store = SessionStore.shared

    public init() {}

    private var weekSessions: [RakaatSession] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return store.sessions.filter { $0.timestamp >= weekAgo }
    }

    private var tidyPercent: Int {
        let week = weekSessions
        guard !week.isEmpty else { return 0 }
        let valid = week.filter(\.isValid).count
        return Int(Double(valid) / Double(week.count) * 100)
    }

    private var activeDays: Int {
        Set(weekSessions.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
    }

    /// Count of sessions per weekday (Mon...Sun) for the bar chart.
    private var perDay: [Int] {
        var counts = Array(repeating: 0, count: 7)
        for s in weekSessions {
            let wd = Calendar.current.component(.weekday, from: s.timestamp) // 1=Sun
            counts[(wd + 5) % 7] += 1 // shift so 0=Mon
        }
        return counts
    }

    public var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    stat("\(weekSessions.count)", "Shalat")
                    stat("\(tidyPercent)%", "Tertib")
                    stat("\(activeDays)", "Hari aktif")
                }
                chart
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Statistik")
    }

    private func stat(_ num: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(num).font(.system(size: 26, weight: .heavy, design: .rounded)).foregroundStyle(Theme.green)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.line))
    }

    private var chart: some View {
        let counts = perDay
        let maxVal = max(counts.max() ?? 1, 1)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Konsistensi harian").font(.caption).foregroundStyle(.secondary)
            HStack(alignment: .bottom, spacing: 7) {
                ForEach(counts.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Theme.greenSoft)
                        .frame(height: 90 * CGFloat(counts[i]) / CGFloat(maxVal) + 4)
                        .frame(maxWidth: .infinity)
                }
            }
            HStack {
                ForEach(["S","S","R","K","J","S","M"], id: \.self) { d in
                    Text(d).font(.system(size: 10)).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.line))
    }
}
#endif
