/// An ordered collection of `Changeset` as staged set of changes in the sectioned collection.
///
/// The order is representing the stages of changesets.
///
/// We know that there are combination of changes that crash when applied simultaneously
/// in batch-updates of UI such as UITableView or UICollectionView.
/// The `StagedChangeset` created from the two collection is split at the minimal stages
/// that can be perform batch-updates with no crashes.
///
/// Example for calculating differences between the two linear collections.
///
///     extension String: Differentiable {}
///
///     let source = ["A", "B", "C"]
///     let target = ["B", "C", "D"]
///
///     let changeset = StagedChangeset(source: source, target: target)
///     print(changeset.isEmpty)  // prints "false"
///
/// Example for calculating differences between the two sectioned collections.
///
///     let source = [
///         Section(model: "A", elements: ["😉"]),
///     ]
///     let target = [
///         Section(model: "A", elements: ["😉, 😺"]),
///         Section(model: "B", elements: ["😪"])
///     ]
///
///     let changeset = StagedChangeset(source: sectionedSource, target: sectionedTarget)
///     print(changeset.isEmpty)  // prints "false"
public struct StagedChangeset<Collection: Swift.Collection> {
    private var changesets: ContiguousArray<Changeset<Collection>>

    /// Creates a new `StagedChangeset`.
    ///
    /// - Parameters:
    ///   - changesets: The collection of `Changeset`.
    public init<C: Swift.Collection>(_ changesets: C) where C.Element == Changeset<Collection> {
        self.changesets = ContiguousArray(changesets)
    }
}

extension StagedChangeset: RandomAccessCollection, RangeReplaceableCollection, MutableCollection {
    public init() {
        self.init([])
    }

    public var startIndex: Int {
        return changesets.startIndex
    }

    public var endIndex: Int {
        return changesets.endIndex
    }

    public func index(after i: Int) -> Int {
        return changesets.index(after: i)
    }

    public subscript(position: Int) -> Changeset<Collection> {
        get { return changesets[position] }
        set { changesets[position] = newValue }
    }

    public mutating func replaceSubrange<C: Swift.Collection, R: RangeExpression>(_ subrange: R, with newElements: C) where C.Element == Changeset<Collection>, R.Bound == Int {
        changesets.replaceSubrange(subrange, with: newElements)
    }
}

extension StagedChangeset: Equatable where Collection: Equatable {
    public static func == (lhs: StagedChangeset, rhs: StagedChangeset) -> Bool {
        return lhs.changesets == rhs.changesets
    }
}

extension StagedChangeset: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Changeset<Collection>...) {
        self.init(elements)
    }
}

extension StagedChangeset: CustomDebugStringConvertible {
    public var debugDescription: String {
        guard !isEmpty else { return "[]" }

        return "[\n\(map { "    \($0.debugDescription.split(separator: "\n").joined(separator: "\n    "))" }.joined(separator: ",\n"))\n]"
    }
}
