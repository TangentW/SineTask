# Sine Task

轻量型**依赖性任务**调度执行器。

## 简介

`Sine Task` 能够调度执行具有**依赖性**的任务。所谓`依赖性`的任务，就是多个任务之间存在多对多的依赖关系。`Sine Task` 能够根据任务的`优先级`和`依赖关系`按序调度执行任务。

`Sine Task` 的实现基于了`堆排序`以及图的`拓扑排序`算法。

## 使用

### 构建任务

`Sine Task` 中的任务被抽象为 `Task` 类，这是一个泛型类，具有两个泛型参数，分别代表任务的输入值类型已经输出结果类型：

```Swift
... class Task<Input, Output> ...
```

我们使用构造器构造 `Task` 实例时，需要传入任务的执行闭包以及优先级参数（默认可不传）。在后续我们也可以通过 `set(priority:)` 方法设置任务优先级：

```Swift
// 构造器传入优先级 `priority`
let task = Task<Int, Int>(priority: .low) { 2 * $0 }

// 通过 Setter 设置优先级
let task2 = Task<Int, Int> { 3 * $0 }
    .set(priority: .high)
```

### 任务依赖

通过 `depend(on:)` 方法，我们可以为 `Task` 指定依赖。在执行任务时，`Task` 所有的依赖都被保证先比其更早执行，而后当所有依赖执行完毕后，`Task` 本身才开始执行。

```Swift
let task = Task<Int, Int> { 2 * $0 }
let task2 = Task<Int, Int> { 3 * $0 }

// 为任务设置多个依赖
let task3 = Task<Int, Int> { 4 * $0 }
    .depend(on: task)
    .depend(on: task2)
```

### 执行任务

定义好任务以及依赖后，我们需要在某个时期执行它：

```Swift
let task = Task<Int, Int> { 2 * $0 }
let task2 = Task<Int, Int> { 3 * $0 }
    .set(priority: .high)
let task3 = Task<Int, Int> { 4 * $0 }
    .depend(on: task)
    .depend(on: task2)

let result = task3.run(2, into: "") {
    $0 += "\($1)"
}

// .success(648)
print(result)
```

如上所示，调用 `Task` 的 `run(_:into:_:)` 方法即可运行任务，其中第一个参数为任务的输入值，输入值不仅会传入到 `Task` 本身的执行中，还会递归传入给其所有依赖及子依赖执行里面。第二及第三个参数为 `reduce` 参数，多个任务执行完毕后产出多个结果，我们通过 `reduce` 的形式合并这些结果到统一的值里。

### 依赖环检测

若多个任务存在依赖环，任务的执行则无从下手，因为这是不合逻辑的操作。 `Sine Task` 存在依赖环检测，当使用 `run(_:into:_:)` 执行任务时，返回值类型为 `Result`，若任务存在依赖环，返回值则为`Result.failure(TaskError.dependencyCycleError)`。若我们想通过 Swift 的 `Try-Catch`机制捕获错误，则可以使用 `run(_:into:_:)` 的变体版本：`runWithThrowing(_:into:_:)`。

## Demo

接下来将展示 `Sine Task` 的一个小 Demo。

假设我们需要对若干大学课程重新进行温习巩固，每个课程的学习都有依赖关系：

| 课程 | 依赖 | 优先级 |
| :---: | :----: | :----: |
| 高等数学 | N/A | 高 |
| 程序设计基础 | N/A | 普通 |
| 离散数学 | 高等数学、程序设计基础 | 普通 |
| 数据结构 | 程序设计基础、离散数学 | 普通 |

我们必须按序先把基础课程学习完毕，再学习依赖到基础课程的其他课程。

通过使用 `SineTask`，我们则可以用以下的方式组织课程及依赖关系，并进行学习：

```Swift
typealias Student = String
typealias Course = Task<Student, String>

let advancedMathematics = Course { "\($0) 学习高等数学" }
    .set(priority: .high)

let programmingFoundations = Course { "\($0) 学习程序设计基础" }

let discreteMathematics = Course { "\($0) 学习离散数学" }
    .depend(on: advancedMathematics)
    .depend(on: programmingFoundations)

let dataStructure = Course { "\($0) 学习数据结构" }
    .depend(on: programmingFoundations)
    .depend(on: discreteMathematics)

let result = dataStructure.run("Tangent", into: "") { $0 += "\($1), " }

// .success("Tangent 学习高等数学, Tangent 学习程序设计基础, Tangent 学习离散数学, Tangent 学习数据结构")
print(result)
```

