#if os(iOS)
import SwiftUI
import AVFoundation
import CoreLocation

/// Layar 1: jelasin privasi + minta izin kamera & lokasi.
public struct OnboardingView: View {
    public var onDone: () -> Void
    @StateObject private var loc = LocationPermission()

    public init(onDone: @escaping () -> Void) { self.onDone = onDone }

    public var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()
            VStack(spacing: 18) {
                Spacer()
                Text("🤲").font(.system(size: 60))
                Text("Hitung rakaat,\ntanpa direkam")
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.ink)
                Text("Kamera mendeteksi gerakan shalat di HP-mu. Tidak ada video disimpan — semua diproses di perangkat, offline.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                Label("On-device · tanpa server", systemImage: "lock.shield")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Theme.green, in: Capsule())
                Spacer()
                Button("Izinkan Kamera") {
                    AVCaptureDevice.requestAccess(for: .video) { _ in }
                }
                .buttonStyle(FilledButton())
                Button("Izinkan Lokasi (waktu shalat)") { loc.request() }
                    .buttonStyle(FilledButton(light: true))
                Button("Lanjut") { onDone() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.green)
                    .padding(.top, 4)
            }
            .padding(28)
        }
    }
}

/// Thin CLLocationManager wrapper just to trigger the when-in-use prompt.
final class LocationPermission: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    override init() { super.init(); manager.delegate = self }
    func request() { manager.requestWhenInUseAuthorization() }
}

struct FilledButton: ButtonStyle {
    var light = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(light ? Color.white : Theme.green,
                        in: RoundedRectangle(cornerRadius: 16))
            .foregroundStyle(light ? Theme.ink : .white)
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.line, lineWidth: light ? 1 : 0))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

extension Theme { static let line = Color(red: 0.89, green: 0.88, blue: 0.83) }
#endif
