import SwiftUI
import SwiftData

struct AddCoffeeView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form State

    @State private var name: String = ""
    @State private var coffeeType: String = "Espresso"
    @State private var size: String = "Medium"
    @State private var temperature: String = "Hot"
    @State private var caffeine: Double = 80
    @State private var sugar: Double = 0
    @State private var isHomemade: Bool = false
    @State private var price: String = ""
    @State private var note: String = ""
    @State private var date: Date = .now

    // MARK: - Options

    private let coffeeTypes: [(name: String, icon: String)] = [
        ("Espresso",    "cup.and.saucer.fill"),
        ("Latte",       "mug.fill"),
        ("Flat White",  "cup.and.saucer"),
        ("Cappuccino",  "cup.and.saucer.fill"),
        ("Americano",   "drop.fill"),
        ("Mocha",       "mug.fill"),
        ("Macchiato",   "cup.and.saucer"),
        ("Cold Brew",   "snowflake"),
        ("Drip Coffee", "drop.fill"),
        ("Other",       "ellipsis.circle")
    ]
    private let sizes = ["Small", "Medium", "Large"]
    private let temperatures = ["Hot", "Iced"]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    coffeeTypeCard
                    sizeCard
                    temperatureCard
                    slidersCard
                    extrasCard
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .navigationTitle("New Coffee")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .bold()
                        .foregroundStyle(Color.appGreen)
                }
            }
        }
    }

    // MARK: - 1 · Coffee Type

    private var coffeeTypeCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Coffee Type")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(coffeeTypes, id: \.name) { item in
                            let isSelected = coffeeType == item.name
                            VStack(spacing: 6) {
                                Image(systemName: item.icon)
                                    .font(.title2)
                                    .frame(width: 52, height: 52)
                                    .background(isSelected ? Color.appGreen : Color(UIColor.tertiarySystemFill))
                                    .foregroundStyle(isSelected ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                Text(item.name)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .foregroundStyle(isSelected ? Color.appGreen : .secondary)
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    coffeeType = item.name
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 2 · Size

    private var sizeCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Size")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    ForEach(sizes, id: \.self) { s in
                        let isSelected = size == s
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { size = s }
                        } label: {
                            Text(s)
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isSelected ? Color.appGreen : Color(UIColor.tertiarySystemFill))
                                .foregroundStyle(isSelected ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - 3 · Temperature

    private var temperatureCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Temperature")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    ForEach(temperatures, id: \.self) { t in
                        let isSelected = temperature == t
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { temperature = t }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: t == "Iced" ? "snowflake" : "flame.fill")
                                Text(t)
                            }
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isSelected ? Color.appGreen : Color(UIColor.tertiarySystemFill))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - 4 · Sliders

    private var slidersCard: some View {
        CardContainer {
            VStack(spacing: 20) {
                // Caffeine slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Caffeine", systemImage: "bolt.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(caffeine)) mg")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.appGreen)
                    }
                    Slider(value: $caffeine, in: 0...600, step: 10)
                        .tint(Color.appGreen)
                }

                Divider()

                // Sugar slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Sugar", systemImage: "cube.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(sugar)) g")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.appGreen)
                    }
                    Slider(value: $sugar, in: 0...100, step: 1)
                        .tint(Color.appGreen)
                }
            }
        }
    }

    // MARK: - 5 · Extras

    private var extrasCard: some View {
        CardContainer {
            VStack(spacing: 14) {
                // Homemade toggle
                HStack {
                    Label("Homemade", systemImage: "house.fill")
                        .font(.subheadline)
                    Spacer()
                    Toggle("", isOn: $isHomemade)
                        .labelsHidden()
                        .tint(Color.appGreen)
                }

                Divider()

                // Price
                HStack {
                    Label("Price", systemImage: "creditcard")
                        .font(.subheadline)
                    Spacer()
                    TextField("0.00", text: $price)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }

                Divider()

                // Name
                HStack {
                    Label("Name", systemImage: "pencil")
                        .font(.subheadline)
                    Spacer()
                    TextField("Optional", text: $name)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 160)
                }

                Divider()

                // Date
                DatePicker(
                    selection: $date,
                    label: {
                        Label("Date & Time", systemImage: "calendar")
                            .font(.subheadline)
                    }
                )
                .tint(Color.appGreen)

                Divider()

                // Note
                VStack(alignment: .leading, spacing: 6) {
                    Label("Note", systemImage: "note.text")
                        .font(.subheadline)
                    TextField("Add a note…", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(10)
                        .background(Color(UIColor.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }

    // MARK: - Save

    private func saveEntry() {
        let entry = CoffeeEntry(
            date: date,
            name: name.isEmpty ? nil : name,
            isHomemade: isHomemade,
            coffeeType: coffeeType,
            size: size,
            temperature: temperature,
            caffeine: Int(caffeine),
            sugar: Int(sugar),
            price: Double(price),
            note: note.isEmpty ? nil : note
        )
        modelContext.insert(entry)
        dismiss()
    }
}

// MARK: - Card Container

/// Reusable white card wrapper with padding, rounded corners, and shadow.
private struct CardContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }
}

// MARK: - Preview

#Preview {
    AddCoffeeView()
        .modelContainer(for: CoffeeEntry.self, inMemory: true)
}
