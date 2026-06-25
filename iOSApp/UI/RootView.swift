#if os(iOS)
import SwiftUI

/// Tab utama + gerbang onboarding.
public struct RootView: View {
    @AppStorage("onboarded") private var onboarded = false

    public init() {}

    public var body: some View {
        if !onboarded {
            OnboardingView { onboarded = true }
        } else {
            TabView {
                NavigationStack { ScanHomeView() }
                    .tabItem { Label("Shalat", systemImage: "figure.stand") }
                NavigationStack { HistoryView() }
                    .tabItem { Label("Riwayat", systemImage: "list.bullet") }
                NavigationStack { StatisticsView() }
                    .tabItem { Label("Statistik", systemImage: "chart.bar") }
                NavigationStack { SettingsView() }
                    .tabItem { Label("Atur", systemImage: "gearshape") }
            }
            .tint(Theme.green)
        }
    }
}
#endif
