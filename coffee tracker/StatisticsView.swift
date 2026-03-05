import SwiftUI
import SwiftData
import Charts

// MARK: - Period Enum

enum StatPeriod: String, CaseIterable, Identifiable {
    case week  = "Week"
    case month = "Month"
    case year  = "Year"
    var id: String { rawValue }
}

// MARK: - StatisticsView

struct StatisticsView: View {

    @Query(sort: \CoffeeEntry.date, order: .reverse) private var allEntries: [CoffeeEntry]

    @State private var selectedPeriod: StatPeriod = .week

    // MARK: - Filtered entries for the selected period

    private var periodStart: Date {
        let cal = Calendar.current
        switch selectedPeriod {
        case .week:
            return cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: .now))!
        case .month:
            return cal.date(byAdding: .month, value: -1, to: cal.startOfDay(for: .now))!
        case .year:
            return cal.date(byAdding: .year, value: -1, to: cal.startOfDay(for: .now))!
        }
    }

    private var filteredEntries: [CoffeeEntry] {
        allEntries.filter { $0.date >= periodStart }
    }

    // MARK: - Aggregated stats

    private var totalCups: Int { filteredEntries.count }

    private var totalCaffeine: Int {
        filteredEntries.reduce(0) { $0 + $1.caffeine }
    }

    private var totalSpend: Double {
        filteredEntries.reduce(0) { $0 + ($1.price ?? 0) }
    }

    /// Average caffeine per day that has at least one entry.
    private var averageCaffeine: Int {
        let cal = Calendar.current
        let uniqueDays = Set(filteredEntries.map { cal.startOfDay(for: $0.date) })
        guard !uniqueDays.isEmpty else { return 0 }
        return totalCaffeine / uniqueDays.count
    }

    // MARK: - Chart data (caffeine per day)

    private struct DailyCaffeine: Identifiable {
        let id = UUID()
        let date: Date
        let caffeine: Int
    }

    private var dailyCaffeineData: [DailyCaffeine] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            cal.startOfDay(for: entry.date)
        }
        return grouped
            .map { DailyCaffeine(date: $0.key, caffeine: $0.value.reduce(0) { $0 + $1.caffeine }) }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if allEntries.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Statistics")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Data Yet", systemImage: "chart.bar.fill")
        } description: {
            Text("No data yet. Start tracking to see your stats!")
        }
    }

    // MARK: - Main Content

    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                periodPicker
                summaryGrid
                chartCard
            }
            .padding()
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(StatPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Summary Grid

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14),
                            GridItem(.flexible(), spacing: 14)], spacing: 14) {
            StatCard(title: "Total Cups", value: "\(totalCups)", icon: "cup.and.saucer.fill")
            StatCard(title: "Total Spend", value: String(format: "€%.2f", totalSpend), icon: "creditcard.fill")
            StatCard(title: "Total Caffeine", value: "\(totalCaffeine) mg", icon: "bolt.fill")
            StatCard(title: "Daily Avg", value: "\(averageCaffeine) mg", icon: "chart.line.uptrend.xyaxis")
        }
    }

    // MARK: - Chart

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Consumption History")
                .font(.headline)

            if dailyCaffeineData.isEmpty {
                Text("No entries in this period.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                Chart(dailyCaffeineData) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Caffeine", item.caffeine)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appGreen.opacity(0.7), Color.appGreen],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                }
                .chartYAxisLabel("mg")
                .chartXAxis {
                    AxisMarks(values: .stride(by: chartStride)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: chartDateFormat)
                    }
                }
                .frame(height: 220)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }

    // MARK: - Chart axis helpers

    private var chartStride: Calendar.Component {
        switch selectedPeriod {
        case .week:  return .day
        case .month: return .weekOfYear
        case .year:  return .month
        }
    }

    private var chartDateFormat: Date.FormatStyle {
        switch selectedPeriod {
        case .week:  return .dateTime.weekday(.abbreviated)
        case .month: return .dateTime.day().month(.abbreviated)
        case .year:  return .dateTime.month(.abbreviated)
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.appGreen)

            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color.appGreen)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}

// MARK: - Preview

#Preview {
    StatisticsView()
        .modelContainer(for: CoffeeEntry.self, inMemory: true)
}
