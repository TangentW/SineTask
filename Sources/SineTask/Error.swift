//
//  Error.swift
//  SineTask
//
//  Created by Tangent on 2021/11/16.
//

public enum TaskError {
    
    case dependencyCycleError
    case `internal`(Error)
}

extension TaskError: Error { }

extension TaskError: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .dependencyCycleError:
            return "dependency cycle"
        case .internal(let err):
            return "internal: \(err)"
        }
    }
}
