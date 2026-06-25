#if os(iOS)
import SwiftUI
import RakaatCore

/// Layar Hasil: ringkasan sesi selesai (jenis shalat, rakaat, validasi).
public struct ResultView: View {
    public let session: RakaatSession
    @Environment(\.dismiss) private var dismiss

    public init(session: RakaatSession) { self.session = session }

    public var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: session.isValid ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(session.isValid ? Theme.green : Theme.warn)

                Text("Shalat Selesai").font(.headline).foregroundStyle(Theme.ink)

                Text(session.prayer.displayName)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.green)
                Text("\(session.rakaat) Rakaat")
                    .font(.title3).foregroundStyle(Theme.ink)

                if session.violations.isEmpty {
                    Label("Gerakan tertib", systemImage: "checkmark")
                        .foregroundStyle(Theme.green)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(session.violations, id: \.self) { note in
                            Label(note, systemImage: "exclamationmark.circle")
                                .font(.subheadline)
                                .foregroundStyle(Theme.warn)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))
                }

                Text("Alat bantu hitung, bukan penentu sah/batal shalat.")
                    .font(.caption).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()
                Button("Selesai") { dismiss() }
                    .font(.headline)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Theme.green, in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.white)
            }
            .padding(28)
        }
    }
}
#endif
