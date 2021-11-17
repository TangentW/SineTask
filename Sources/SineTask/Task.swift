//
//  Task.swift
//  SineTask
//
//  Created by Tangent on 2021/11/15.
//

public final class Task<Input, Output> {
    
    public typealias Work = (Input) throws -> Output
    
    public init(priority: Priority = .default, work: @escaping Work) {
        self.work = work
        self.priority = priority
    }
    
    internal let work: Work

    @usableFromInline
    internal private(set) var priority: Priority
    
    @usableFromInline
    internal private(set) var dependencies: Set<Task> = []
}

public extension Task {

    @inlinable
    @discardableResult
    func set(priority: Priority) -> Self {
        self.priority = priority
        return self
    }
    
    @inlinable
    @discardableResult
    func depend(on dependency: Task) -> Self {
        dependencies.insert(dependency)
        return self
    }

    @inlinable
    func remove(dependency: Task) {
        dependencies.remove(dependency)
    }
}

public extension Task {
    
    static func run<T>(
        tasks: Set<Task>,
        with input: Input,
        reduceInto initialResult: T,
        _ updateAccumulatingResult: (inout T, Output) throws -> Void
    ) -> Result<T, TaskError> {
        expandThenTopologicalSort(tasks: tasks).flatMap {
            $0.run(input, into: initialResult, updateAccumulatingResult)
        }
    }

    static func runWithThrowing<T>(
        tasks: Set<Task>,
        with input: Input,
        reduceInto initialResult: T,
        _ updateAccumulatingResult: (inout T, Output) throws -> Void
    ) throws -> T {
        try run(tasks: tasks, with: input, reduceInto: initialResult, updateAccumulatingResult).get()
    }

    func run<T>(
        _ input: Input,
        into initialResult: T,
        _ updateAccumulatingResult: (inout T, Output) throws -> Void
    ) -> Result<T, TaskError> {
        Task.run(tasks: [self], with: input, reduceInto: initialResult, updateAccumulatingResult)
    }
    
    func runWithThrowing<T>(
        _ input: Input,
        into initialResult: T,
        _ updateAccumulatingResult: (inout T, Output) throws -> Void
    ) throws -> T {
        try run(input, into: initialResult, updateAccumulatingResult).get()
    }
}

public extension Task where Output == () {
    
    static func run(
        tasks: Set<Task>,
        with input: Input
    ) -> Result<(), TaskError> {
        run(tasks: tasks, with: input, reduceInto: ()) { _, _ in }
    }

    static func runWithThrowing(
        tasks: Set<Task>,
        with input: Input
    ) throws {
        try run(tasks: tasks, with: input).get()
    }

    func run(_ input: Input) -> Result<(), TaskError> {
        run(input, into: ()) { _, _ in }
    }
    
    func runWithThrowing(_ input: Input) throws {
        try run(input).get()
    }
}

public extension Task where Input == (), Output == () {
    
    static func run(tasks: Set<Task>) -> Result<(), TaskError> {
        run(tasks: tasks, with: ())
    }

    static func runWithThrowing(tasks: Set<Task>) throws {
        try run(tasks: tasks).get()
    }

    func run() -> Result<(), TaskError> {
        run((), into: ()) { _, _ in }
    }
    
    func runWithThrowing() throws {
        try run().get()
    }
}

// MARK: - Hashable

extension Task: Equatable, Hashable {
    
    public static func == (lhs: Task, rhs: Task) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}

// MARK: - Tools

private extension Sequence {
    
    func run<Input, Output, T>(
        _ input: Input,
        into initialResult: T,
        _ updateAccumulatingResult: (inout T, Output) throws -> Void
    ) -> Result<T, TaskError> where Element == Task<Input, Output> {
        Result {
            try reduce(into: initialResult) { result, task in
                let output = try task.work(input)
                try updateAccumulatingResult(&result, output)
            }
        }.mapError(TaskError.internal)
    }
}
