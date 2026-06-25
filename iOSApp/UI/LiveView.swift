#if os(iOS)
import SwiftUI
import RakaatCore

/// Layar Live: sumber deteksi (kamera / sensor) + label posisi + counter rakaat.
public struct LiveView: View {
    @StateObject private var vm = PrayerScanViewModel()
    private let mode: DetectionMode

    public init(mode: DetectionMode = .camera) {
        self.mode = mode
    }

    public var body: some View {
        ZStack {
            background

            VStack {
                privacyBadge
                Spacer()
                postureLabel
                rakaatCounter
                stopButton
            }
            .padding(24)
        }
        .onAppear { vm.start(mode: mode) }
        .onDisappear { vm.stop() }
        .fullScreenCover(item: $vm.finishedSession) { session in
            ResultView(session: session)
        }
    }

    @ViewBuilder
    private var background: some View {
        switch mode {
        case .camera:
            CameraPreview(session: vm.captureSession).ignoresSafeArea()
        case .proximity:
            Theme.ink.ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: vm.sujudActive ? "hand.raised.fill" : "iphone.gen3")
                    .font(.system(size: 64))
                    .foregroundStyle(vm.sujudActive ? Theme.green : .white.opacity(0.5))
                Text(vm.sujudActive ? "Sujud terdeteksi" : "Menunggu sujud…")
                    .font(.headline).foregroundStyle(.white.opacity(0.85))
                Text("HP di sajadah, di titik dahi.")
                    .font(.footnote).foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    private var privacyBadge: some View {
        Label(mode == .camera ? "Tidak merekam — diproses di HP" : "Sensor jarak — tanpa kamera",
              systemImage: "lock.shield")
            .font(.footnote.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(.black.opacity(0.45), in: Capsule())
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var postureLabel: some View {
        Text(vm.posture.labelID)
            .font(.title2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18).padding(.vertical, 8)
            .background(Theme.green.opacity(0.85), in: Capsule())
    }

    private var rakaatCounter: some View {
        VStack(spacing: 2) {
            Text("\(vm.rakaatCount)")
                .font(.system(size: 88, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Rakaat")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.vertical, 12)
    }

    private var stopButton: some View {
        Button {
            vm.stop()
        } label: {
            Text("Selesai")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.cream, in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(Theme.ink)
        }
    }
}
#endif
