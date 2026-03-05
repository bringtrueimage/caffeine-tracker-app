import SwiftUI

struct SettingsView: View {

    // MARK: - Persisted Preferences

    @AppStorage("dailyCaffeineLimit") private var dailyCaffeineLimit: Double = 400.0
    @AppStorage("preferredCurrency")  private var preferredCurrency: String = "USD"
    @AppStorage("userName")           private var userName: String = "Coffee Lover"

    // MARK: - Currency Options

    private let currencies: [(code: String, symbol: String)] = [
        ("USD", "$"),
        ("EUR", "€"),
        ("GBP", "£"),
        ("RUB", "₽")
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                caffeineGoalSection
                localizationSection
                profileSection
                aboutSection
            }
            .tint(Color.appGreen)
            .navigationTitle("Settings")
        }
    }

    // MARK: - Caffeine Goal

    private var caffeineGoalSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Daily Limit")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(dailyCaffeineLimit)) mg")
                        .font(.title3.bold())
                        .foregroundStyle(Color.appGreen)
                }

                Slider(value: $dailyCaffeineLimit, in: 0...1000, step: 25)
                    .tint(Color.appGreen)

                Label("Health experts recommend a limit of 400 mg per day.",
                      systemImage: "heart.text.square")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Caffeine Goal")
        }
    }

    // MARK: - Localization

    private var localizationSection: some View {
        Section {
            Picker("Currency", selection: $preferredCurrency) {
                ForEach(currencies, id: \.code) { currency in
                    Text("\(currency.code) (\(currency.symbol))").tag(currency.code)
                }
            }
        } header: {
            Text("Localization")
        }
    }

    // MARK: - Profile

    private var profileSection: some View {
        Section {
            HStack {
                Label("Name", systemImage: "person.fill")
                    .font(.subheadline)
                Spacer()
                TextField("Your name", text: $userName)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 180)
            }
        } header: {
            Text("Profile")
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "cup.and.saucer.fill")
                    .font(.subheadline)
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.appGreen)
                    Text("Coffee Tracker")
                        .font(.caption.weight(.semibold))
                    Text("Made with ☕ and ❤️")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        } header: {
            Text("About")
        }
    }
}

#Preview {
    SettingsView()
}
