#if os(iOS)
import SwiftUI

/// Layar 2: pilih mode deteksi + panduan posisi, lalu mulai sesi (LiveView).
public struct ScanHomeView: View {
    @State private var scanning = false
    @State private var mode: DetectionMode = .camera

    public init() {}

    public var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 18) {
                Text("Pilih mode").font(.title2.weight(.bold)).foregroundStyle(Theme.ink)

                modePicker

                ZStack {
                    RoundedRectangle(cornerRadius: 22).fill(Theme.green.opacity(0.12))
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Theme.greenSoft, style: StrokeStyle(lineWidth: 2, dash: [7]))
                        .padding(16)
                    Text(mode == .camera ? "🧍" : "📱").font(.system(size: 56))
                }
                .frame(height: 200)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(instructions, id: \.self) { bullet($0) }
                }
                Spacer()
                Button("Mulai") { scanning = true }
                    .buttonStyle(FilledButton())
            }
            .padding(28)
        }
        .fullScreenCover(isPresented: $scanning) { LiveView(mode: mode) }
    }

    private var modePicker: some View {
        Picker("Mode", selection: $mode) {
            Text("Kamera").tag(DetectionMode.camera)
            Text("Sajadah (sensor)").tag(DetectionMode.proximity)
        }
        .pickerStyle(.segmented)
    }

    private var instructions: [String] {
        switch mode {
        case .camera:
            return [
                "Taruh HP di tripod, menyamping (profil) ±2 m.",
                "Seluruh badan masuk frame saat berdiri & sujud.",
                "Cahaya cukup.",
            ]
        case .proximity:
            return [
                "Taruh HP di sajadah, layar menghadap ATAS.",
                "Letakkan di titik DAHI mendarat saat sujud — JANGAN di bawah dagu.",
                "Ujung atas HP (sensor dekat speaker) menghadap ke arah kepala.",
                "Cocok untuk tempat sempit. Tidak butuh kamera & tidak merekam.",
            ]
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle().fill(Theme.green).frame(width: 6, height: 6).padding(.top, 7)
            Text(text).font(.subheadline).foregroundStyle(Theme.ink)
        }
    }
}
#endif
