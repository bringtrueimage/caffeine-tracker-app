import SwiftUI
import SwiftData

// MARK: - TrackerView (Dashboard)

struct TrackerView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CoffeeEntry.date, order: .reverse) private var entries: [CoffeeEntry]

    @State private var showingAddSheet = false
    @State private var displayedMonth = Date.now

    @AppStorage("dailyCaffeineLimit") private var dailyCaffeineLimit: Double = 400.0

    // MARK: - Computed

    /// Set of calendar days (start-of-day) that contain at least one entry.
    private var daysWithCoffee: Set<Date> {
        let calendar = Calendar.current
        return Set(entries.map { calendar.startOfDay(for: $0.date) })
    }

    /// Total caffeine consumed today (mg).
    private var todayCaffeine: Int {
        let calendar = Calendar.current
        return entries
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.caffeine }
    }

    private var maxCaffeine: Int { Int(dailyCaffeineLimit) }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    calendarCard
                    addButton
                    caffeineCard
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Tracker ☕")
            .sheet(isPresented: $showingAddSheet) {
                AddCoffeeView()
            }
        }
    }

    // MARK: - 1 · Calendar Card

    private var calendarCard: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button { shiftMonth(by: -1) } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                }

                Spacer()

                Text(displayedMonth, format: .dateTime.month(.wide).year())
                    .font(.headline)

                Spacer()

                Button { shiftMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(.primary)

            // Weekday headers
            let weekdays = Calendar.current.veryShortWeekdaySymbols
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            // Day cells
            let days = calendarDays(for: displayedMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { date in
                    if let date {
                        DayCellView(
                            date: date,
                            isToday: Calendar.current.isDateInToday(date),
                            hasCoffee: daysWithCoffee.contains(date)
                        )
                    } else {
                        Text("")
                            .frame(height: 36)
                    }
                }
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }

    // MARK: - 2 · Add Button

    private var addButton: some View {
        Button {
            showingAddSheet = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add a Cup")
                    .fontWeight(.bold)
            }
            .font(.title3)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.appGreen)
            .cornerRadius(15)
        }
        .shadow(color: Color.appGreen.opacity(0.35), radius: 10, y: 6)
    }

    // MARK: - 3 · Today Caffeine Card

    private var caffeineCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color.appGreen)
                Text("Today's Caffeine")
                    .font(.headline)
            }

            // Large number
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(todayCaffeine)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(todayCaffeine > maxCaffeine ? .red : Color.appGreen)
                Text("/ \(maxCaffeine) mg")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: min(Double(todayCaffeine), Double(maxCaffeine)),
                         total: Double(maxCaffeine))
                .tint(todayCaffeine > maxCaffeine ? .red : Color.appGreen)
                .scaleEffect(y: 2, anchor: .center)
                .clipShape(Capsule())

            if todayCaffeine == 0 {
                Text("You haven't had any coffee yet today.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } else if todayCaffeine > maxCaffeine {
                Text("You've exceeded the recommended daily limit!")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }

    // MARK: - Helpers

    private func shiftMonth(by value: Int) {
        withAnimation(.easeInOut(duration: 0.25)) {
            displayedMonth = Calendar.current.date(
                byAdding: .month, value: value, to: displayedMonth
            ) ?? displayedMonth
        }
    }

    /// Returns an array of optional `Date`s representing the grid cells for a month.
    /// `nil` entries are leading blanks before the 1st.
    private func calendarDays(for referenceDate: Date) -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: referenceDate)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: referenceDate))!
        let weekdayOffset = (calendar.component(.weekday, from: firstOfMonth) - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: weekdayOffset)

        for day in range {
            if let date = calendar.date(bySetting: .day, value: day, of: firstOfMonth) {
                cells.append(calendar.startOfDay(for: date))
            }
        }
        return cells
    }
}

// MARK: - Day Cell

private struct DayCellView: View {
    let date: Date
    let isToday: Bool
    let hasCoffee: Bool

    var body: some View {
        VStack(spacing: 3) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.subheadline.weight(isToday ? .bold : .regular))
                .foregroundStyle(isToday ? .white : .primary)
                .frame(width: 32, height: 32)
                .background {
                    if isToday {
                        Circle().fill(Color.appGreen)
                    }
                }

            Circle()
                .fill(hasCoffee ? Color.appGreen : .clear)
                .frame(width: 5, height: 5)
        }
        .frame(height: 42)
    }
}

// MARK: - Preview

#Preview {
    TrackerView()
        .modelContainer(for: CoffeeEntry.self, inMemory: true)
}
