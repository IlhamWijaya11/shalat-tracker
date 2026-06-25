#if os(iOS)
import SwiftUI

/// Layar 6: pengaturan lokasi, ambang validasi, mode gelap, sensitivitas.
public struct SettingsView: View {
    @AppStorage("useAutoLocation") private var autoLocation = true
    @AppStorage("city") private var city = "Jakarta"
    @AppStorage("tumaninahThreshold") private var tumaninah = 1.0
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("sensitivity") private var sensitivity = "Sedang"

    public init() {}

    public var body: some View {
        Form {
            Section("Waktu Shalat") {
                Toggle("Lokasi otomatis", isOn: $autoLocation)
                if !autoLocation {
                    Picker("Kota", selection: $city) {
                        ForEach(["Jakarta","Bandung","Surabaya","Medan","Makassar"], id: \.self, content: Text.init)
                    }
                }
            }
            Section("Deteksi") {
                HStack {
                    Text("Ambang tuma'ninah")
                    Spacer()
                    Text("\(tumaninah, specifier: "%.1f") dtk").foregroundStyle(.secondary)
                }
                Slider(value: $tumaninah, in: 0.5...2.0, step: 0.1)
                Picker("Sensitivitas", selection: $sensitivity) {
                    ForEach(["Rendah","Sedang","Tinggi"], id: \.self, content: Text.init)
                }
            }
            Section("Tampilan") {
                Toggle("Mode gelap", isOn: $darkMode)
            }
            Section {
                Text("Semua data tersimpan di HP. Tidak ada video, tidak ada server.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Pengaturan")
        .tint(Theme.green)
    }
}
#endif
