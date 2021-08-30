//
// Reactions App
//

import Foundation

/// Provides the current date.
///
/// Used to inject different dates for testing
public protocol DateProvider {
    func now() -> Date
}

extension DateProvider {

    /// Returns true if at least `days` have passed since `date`.
    public func daysPassed(since date: Date, days: Int) -> Bool {
        date.distance(to: now()) >= days.seconds
    }
}

private extension Int {
    // converts int value from days to seconds
    var seconds: TimeInterval {
        TimeInterval(self * 86400)
    }
}

public class CurrentDateProvider: DateProvider {
    public init() { }

    public func now() -> Date {
        Date()
    }
}

/// Returns the date at a faster rate, since the moment of the first initialisation
public class FastDateProvider: DateProvider {

    public static let shared = FastDateProvider(initialDate: Date())

    private init(initialDate: Date) {
        self.initialDate = initialDate
        printDaysForever()
    }

    // How many real seconds elapse per day which elapses in the returned date
    private let secondsPerDay: TimeInterval = 2
    private let initialDate: Date

    public func now() -> Date {
        let currentDate = Date()
        let realtimeSecondsElapsed = initialDate.distance(to: currentDate)
        let desiredDaysElapsed = realtimeSecondsElapsed / secondsPerDay
        let desiredSecondsElapsed = desiredDaysElapsed * 86400
        return initialDate.advanced(by: desiredSecondsElapsed)
    }

    private func printDaysForever() {
        let secondsElapsed = Date().distance(to: now())
        let daysElapsed = secondsElapsed / 86400
        print("Days: \(Int(daysElapsed))")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.printDaysForever()
        }
    }
}
