//
//  Priority.swift
//  SineTask
//
//  Created by Tangent on 2021/11/15.
//

public struct Priority {
    
    public static let `default` = middle
    
    public static let high = Priority(rawValue: 1000)
    public static let middle = Priority(rawValue: 500)
    public static let low = Priority(rawValue: 0)
    
    public var rawValue: Int
    
    public init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension Priority: RawRepresentable, Equatable, Hashable {
    
    public init(rawValue: Int) {
        self.init(rawValue)
    }
}

extension Priority: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Priority: Comparable {
    
    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
