import SwiftUI
import SwiftData

enum AppTab: String {
    case tracker
    case statistics
    case settings
}

struct ContentView: View {

    @State private var selectedTab: AppTab = .tracker

    var body: some View {
        TabView(selection: $selectedTab) {
            TrackerView()
                .tabItem {
                    Label("Tracker", systemImage: "cup.and.saucer.fill")
                }
                .tag(AppTab.tracker)

            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(AppTab.statistics)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(.appGreen)
        .onOpenURL { url in
            // Deep link: coffeetracker://tracker
            if url.host == "tracker" {
                selectedTab = .tracker
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CoffeeEntry.self, inMemory: true)
}
