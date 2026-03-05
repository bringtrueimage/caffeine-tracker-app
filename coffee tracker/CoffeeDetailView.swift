import SwiftUI
import SwiftData

struct CoffeeDetailView: View {

    @Bindable var entry: CoffeeEntry

    var body: some View {
        List {
            // ── Header ────────────────────────────────
            Section {
                VStack(spacing: 8) {
                    Image(systemName: entry.temperature == "Iced" ? "snowflake.circle.fill" : "cup.and.saucer.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(entry.temperature == "Iced" ? .blue : .brown)

                    Text(entry.coffeeType)
                        .font(.title2.bold())

                    if let name = entry.name, !name.isEmpty {
                        Text(name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            // ── Details ───────────────────────────────
            Section("Details") {
                DetailRow(icon: "calendar", label: "Date", value: entry.date.formatted(date: .long, time: .shortened))
                DetailRow(icon: entry.temperature == "Iced" ? "snowflake" : "flame.fill",
                          label: "Temperature", value: entry.temperature)
                DetailRow(icon: "ruler", label: "Size", value: entry.size)
                DetailRow(icon: "house.fill", label: "Homemade", value: entry.isHomemade ? "Yes" : "No")
            }

            // ── Nutrition ─────────────────────────────
            Section("Nutrition") {
                DetailRow(icon: "bolt.fill", label: "Caffeine", value: "\(entry.caffeine) mg")
                DetailRow(icon: "cube.fill", label: "Sugar", value: "\(entry.sugar) g")
            }

            // ── Price ─────────────────────────────────
            if let price = entry.price {
                Section("Price") {
                    DetailRow(icon: "creditcard", label: "Cost", value: String(format: "%.2f", price))
                }
            }

            // ── Note ──────────────────────────────────
            if let note = entry.note, !note.isEmpty {
                Section("Note") {
                    Text(note)
                        .font(.body)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Detail Row

private struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        CoffeeDetailView(
            entry: CoffeeEntry(
                name: "Morning ritual",
                coffeeType: "Flat White",
                size: "Large",
                caffeine: 120,
                sugar: 5,
                price: 4.50,
                note: "From the new café around the corner 🫶"
            )
        )
    }
    .modelContainer(for: CoffeeEntry.self, inMemory: true)
}
