import Foundation
import SwiftData

@Model
final class CoffeeEntry {

    // MARK: - Properties

    var id: UUID
    var date: Date
    var name: String?
    var isHomemade: Bool
    var coffeeType: String
    var size: String
    var temperature: String
    var caffeine: Int
    var sugar: Int
    var price: Double?
    var note: String?

    // MARK: - Initializer

    /// Creates a new CoffeeEntry with sensible defaults.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - date: When the coffee was consumed. Defaults to now.
    ///   - name: Optional display name (e.g., "Morning pick-me-up").
    ///   - isHomemade: Whether the coffee was made at home. Defaults to `false`.
    ///   - coffeeType: The type of coffee (e.g., "Espresso", "Latte", "Flat White"). Defaults to `"Espresso"`.
    ///   - size: Cup size (e.g., "Small", "Medium", "Large"). Defaults to `"Medium"`.
    ///   - temperature: Serving temperature (e.g., "Hot", "Iced"). Defaults to `"Hot"`.
    ///   - caffeine: Caffeine content in milligrams. Defaults to `80`.
    ///   - sugar: Sugar content in grams. Defaults to `0`.
    ///   - price: Optional price in the user's local currency.
    ///   - note: Optional free-text note about the drink.
    init(
        id: UUID = UUID(),
        date: Date = .now,
        name: String? = nil,
        isHomemade: Bool = false,
        coffeeType: String = "Espresso",
        size: String = "Medium",
        temperature: String = "Hot",
        caffeine: Int = 80,
        sugar: Int = 0,
        price: Double? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.date = date
        self.name = name
        self.isHomemade = isHomemade
        self.coffeeType = coffeeType
        self.size = size
        self.temperature = temperature
        self.caffeine = caffeine
        self.sugar = sugar
        self.price = price
        self.note = note
    }
}
