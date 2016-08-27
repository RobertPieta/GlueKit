//
//  ReplacingIfEmpty.swift
//  GlueKit
//
//  Created by Károly Lőrentey on 2016-08-26.
//  Copyright © 2016. Károly Lőrentey. All rights reserved.
//

import Foundation

extension ObservableArrayType {
    public func replacingIfEmpty(with array: [Element]) -> ObservableArray<Element> {
        return EmptySubstitutedObservableArray(inner: self, substitution: array).observableArray
    }
}

private class EmptySubstitutedObservableArray<Element, Inner: ObservableArrayType>: ObservableArrayType
where Inner.Element == Element {

    let inner: Inner
    let substitution: [Element]

    init(inner: Inner, substitution: [Element]) {
        self.inner = inner
        self.substitution = substitution
    }

    private static func process(_ change: ArrayChange<Element>, substitution: [Element]) -> ArrayChange<Element>? {
        if change.isEmpty {
            return nil
        }
        if change.finalCount == 0 {
            return ArrayChange(initialCount: change.initialCount,
                               modification: .replaceRange(0 ..< change.initialCount, with: substitution))
        }
        else if change.initialCount == 0 {
            var c = ArrayChange<Element>(initialCount: substitution.count)
            c.addModification(.replaceRange(0 ..< substitution.count, with: []))
            c.merge(with: change)
            return c
        }
        else {
            return change
        }
    }

    var isBuffered: Bool {
        return inner.isBuffered
    }

    var count: Int {
        return inner.isEmpty ? substitution.count : inner.count
    }

    var value: [Element] {
        return inner.isEmpty ? substitution : inner.value
    }

    subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        return inner.isEmpty ? substitution[bounds] : inner[bounds]
    }

    subscript(index: Int) -> Element {
        return inner.isEmpty ? substitution[index] : inner[index]
    }

    var futureChanges: Source<ArrayChange<Element>> {
        return inner.futureChanges.flatMap { change in
            EmptySubstitutedObservableArray.process(change, substitution: self.substitution)
        }
    }
}
