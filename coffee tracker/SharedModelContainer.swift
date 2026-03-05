import Foundation
import SwiftData

/// Shared ModelContainer that uses the App Group container so both the main app
/// and the WidgetKit extension can read/write the same SwiftData store.
///
/// ## Setup Required in Xcode
/// 1. Enable "App Groups" capability for **both** the main app target and the
///    widget extension target.
/// 2. Use the **same** App Group identifier in both (e.g. `group.com.yourteam.coffeetracker`).
/// 3. Replace the placeholder below with your actual App Group identifier.
enum SharedModelContainer {

    /// The App Group identifier shared between the app and widget.
    /// ⚠️ Replace this with your actual App Group ID from Xcode.
    static let appGroupID = "group.com.ronchik.coffee-tracker"

    /// A shared `ModelContainer` that persists to the App Group directory.
    static let container: ModelContainer = {
        let schema = Schema([CoffeeEntry.self])
        let config = ModelConfiguration(
            "CoffeeTracker",
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }()

    /// URL pointing to the SwiftData store inside the App Group container.
    private static var storeURL: URL {
        guard let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            fatalError("App Group '\(appGroupID)' not configured. Add it in Xcode → Signing & Capabilities.")
        }
        return url.appending(path: "CoffeeTracker.store")
    }
}
