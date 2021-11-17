//
//  BinaryHeap.swift
//  SineTask
//
//  Created by Tangent on 2021/11/14.
//

internal struct BinaryHeap<Element> {
    
    internal typealias Compare = (Element, Element) -> Bool
    
    internal init(compare: @escaping Compare) {
        self.compare = compare
    }
    
    private let compare: Compare
    private var inner: [Element] = []
}

internal extension BinaryHeap {
    
    var isEmpty: Bool {
        inner.isEmpty
    }
    
    mutating func push(_ element: Element) {
        inner.append(element)
        siftUp(from: inner.count - 1)
    }
    
    mutating func pop() -> Element? {
        guard !isEmpty else { return nil }
        inner.swapAt(0, inner.count - 1)
        defer { siftDown(from: 0) }
        return inner.removeLast()
    }
}

private extension BinaryHeap {
    
    mutating func siftUp(from index: Int) {
        var index = index
        while let parent = parentIndex(of: index), topIndex(index, parent) == index {
            inner.swapAt(index, parent)
            index = parent
        }
    }
    
    mutating func siftDown(from index: Int) {
        var index = index
        while let targetIndex = targetIndex(index: index), targetIndex != index {
            inner.swapAt(index, targetIndex)
            index = targetIndex
        }
        
        func targetIndex(index: Int) -> Int? {
            switch childrenIndices(of: index) {
            case let (left?, right?):
                return topIndex(topIndex(left, right), index)
            case (let child?, nil), (nil, let child?):
                return topIndex(child, index)
            default:
                return nil
            }
        }
    }
    
    func childrenIndices(of parentIndex: Int) -> (left: Int?, right: Int?) {
        (
            validate(index: 2 * parentIndex + 1),
            validate(index: 2 * parentIndex + 2)
        )
    }
    
    func parentIndex(of childIndex: Int) -> Int? {
        childIndex != 0 ? validate(index: (childIndex - 1) / 2) : nil
    }
    
    func validate(index: Int) -> Int? {
        (0..<inner.count).contains(index) ? index : nil
    }

    func topIndex(_ left: Int, _ right: Int) -> Int {
        compare(inner[left], inner[right]) ? left : right
    }
}
