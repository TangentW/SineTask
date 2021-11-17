//
//  Task+Graph.swift
//  SineTask
//
//  Created by Tangent on 2021/11/16.
//

// MARK: - Sort

internal extension Task {
     
    static func expandThenTopologicalSort(tasks: Set<Task>) -> Result<[Task], TaskError> {
        // Expand
        var nodes: [Task: Node] = [:]
        func expand(_ task: Task) -> Node {
            if let node = nodes[task] { return node }
            
            let node = Node(task)
            node.indegree = node.task.dependencies.count
            nodes[task] = node
            
            for dep in node.task.dependencies {
                let depNode = expand(dep)
                depNode.successors.append(node)
            }
            return node
        }
        for task in tasks {
            _ = expand(task)
        }
        
        // Topological Sort
        var result: [Task] = []
        var heap = nodes.values.lazy
            .filter { $0.indegree == 0 }
            .reduce(into: BinaryHeap(compare: Node.priorityCompare)) {
                $0.push($1)
            }
        while let node = heap.pop() {
            result.append(node.task)
            for successor in node.successors {
                successor.indegree -= 1
                if successor.indegree == 0 {
                    heap.push(successor)
                }
            }
        }
        
        return result.count == nodes.count ? .success(result) : .failure(.dependencyCycleError)
    }
}

// MARK: - Node

private extension Task {
    
    final class Node {
        
        let task: Task
        var indegree: Int = 0
        var successors: [Node] = []
        
        init(_ task: Task) {
            self.task = task
        }
        
        static func priorityCompare(lhs: Node, rhs: Node) -> Bool {
            lhs.task.priority > rhs.task.priority
        }
    }
}
