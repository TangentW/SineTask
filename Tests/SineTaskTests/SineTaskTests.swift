import XCTest
@testable import SineTask

final class SineTaskTests: XCTestCase {
    
    func testBinaryHeap() {
        // Min-heap
        var heap: BinaryHeap<Int> = .init { $0 < $1 }
        
        XCTAssertEqual(heap.pop(), nil)
        
        heap.push(233)
        XCTAssertEqual(heap.pop(), 233)
        XCTAssertEqual(heap.pop(), nil)
        
        heap.push(1)
        heap.push(3)
        heap.push(2)
        heap.push(5)
        heap.push(4)
        heap.push(0)
        
        XCTAssertEqual(heap.pop(), 0)
        XCTAssertEqual(heap.pop(), 1)
        XCTAssertEqual(heap.pop(), 2)
        XCTAssertEqual(heap.pop(), 3)
        XCTAssertEqual(heap.pop(), 4)
        XCTAssertEqual(heap.pop(), 5)
        XCTAssertEqual(heap.pop(), nil)
    }
    
    func testDependencyCycleSmall() {
        typealias Task = SineTask.Task<(), ()>

        let a = Task { }
        let b = Task { }
        a.depend(on: b)
        b.depend(on: a)
        
        if case .failure(TaskError.dependencyCycleError) = a.run() { } else {
            XCTFail("expect dependency cycle error")
        }
        a.remove(dependency: b)
    }
    
    func testDependencyCycleLarge() {
        typealias Task = SineTask.Task<(), ()>

        let a = Task { }
        let b = Task { }
        let c = Task { }
        let d = Task { }
        
        a.depend(on: b)
        b.depend(on: c)
        c.depend(on: d)
        d.depend(on: a)

        if case .failure(TaskError.dependencyCycleError) = a.run() { } else {
            XCTFail("expect dependency cycle error")
        }
        
        d.remove(dependency: a)
        if case .failure(TaskError.dependencyCycleError) = a.run() {
            XCTFail()
        }
    }
    
    func testTask() {
        typealias Task = SineTask.Task<(), String>

        let a = Task { "A" }
            .set(priority: .high)

        let b = Task { "B" }

        let c = Task { "C" }
            .depend(on: a)
            .depend(on: b)

        let d = Task { "D" }
            .depend(on: b)
            .depend(on: c)

        let result = try? d.run((), into: "") { $0 += $1 }.get()
        XCTAssertEqual(result, "ABCD")

        a.set(priority: .low)
        let result2 = try? d.run((), into: "") { $0 += $1 }.get()
        XCTAssertEqual(result2, "BACD")
    }
}
