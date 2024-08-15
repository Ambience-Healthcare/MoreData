import CoreData
import MoreData
import SwiftUI

/// Filters which specify particular entities to fetch
public enum StatementFilter: Filtering {

    /// Look up subtext
    case contains(String)

    /// relation to particular individual
    case toldBy(Person)
    case toldTo(Person)

    /// compound predicate
    case all([StatementFilter])
    case noElements

    public var predicate: NSPredicate? {
        switch self {

        case .contains(let query):
            return NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Statement.content), query)

        case .toldBy(let person):
            return NSPredicate(format: "%K == %@", #keyPath(Statement.by), person)

        case .toldTo(let person):
            return NSPredicate(format: "%@ IN %K", person, #keyPath(Statement.to))

        case .all(let filters):
            return NSCompoundPredicate(andPredicateWithSubpredicates: filters.compactMap(\.predicate))

        case .noElements:
            return NSPredicate(format: "%K == %@", #keyPath(Statement.statementID), "bogus")
        }
    }

    /// Helper for cases where you don't have person records indexed
    static func toldBy(_ personID: String, in people: FetchedResults<Person>) -> StatementFilter {
        guard let person = people.first(where: { $0.personID == personID }) else {
            return .noElements
        }
        return .toldBy(person)
    }
}
