// Almost solves Day 8 part 2 (needs python post-processing)
// Run from the command line as follows:
// $ swift 8b.swift 8.input | python3 8.py
// [answer]

// Here I take advantage of the specifics of the input data
// So it doesn't really work on the example :(

// Each ghost eventually starts going in cycles
// In my input data each ghost has only one position with Z on such the cycle
// And the cycles are of such a shape that calculating the LCM (least common multiple) is enough
// I use python because it has built-in LCM function

import Foundation
import RegexBuilder

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)

struct Node {
    let name: String
    let left: String
    let right: String
}

let nodeRegex = #/(?<name>\S{3}) = \((?<left>\S{3}), (?<right>\S{3})\)/#

func parseNodes(s: Substring) -> Dictionary<String, Node> {
    var ans = [String: Node]()
    for match in s.matches(of: nodeRegex) {
        let (_, name, left, right) = match.output
        ans[String(name)] = Node(name: String(name), left: String(left), right: String(right))
    }
    return ans
}

let dataRegex = Regex {
    Capture {
        #/[RL]+/#
    } transform: { Array($0).map{String($0)} }
    "\n\n"
    Capture (
        OneOrMore {
            nodeRegex
            "\n"
        }
    , transform: parseNodes)
}

let (_, directions, nodes) = rawData.wholeMatch(of: dataRegex)!.output

func getNext(for pos: String, direction: String) -> String {
    assert(direction == "L" || direction == "R")
    if direction == "L" {
        return nodes[pos]!.left
    } else {
        return nodes[pos]!.right
    }
}

func move(from: String, steps: Int, instructionsOffset: Int = 0) -> String {
    var stepCount = 0
    var pos = from
    while stepCount < steps {
        let instructionsPos = (instructionsOffset + stepCount) % directions.count
        pos = getNext(for: pos, direction: directions[instructionsPos])
        stepCount += 1
    }  
    return pos 
}

struct Cycle {
    let offset: Int
    let length: Int
    var z: [Int] = []
}

let startNodes = nodes.keys.filter({$0.hasSuffix("A")})
let endNodes = nodes.keys.filter({$0.hasSuffix("Z")})

// print("instruction length:", directions.count, "number of nodes:", nodes.count)
// print(startNodes.count, "start nodes:", startNodes)
// print(endNodes.count, "end nodes:", endNodes)

var cycles = [String: Cycle]()
for node in startNodes {
    var history = Array(repeating: Array<String>(), count: directions.count)
    var pos = node
    var stepCount = 0
    while !history[stepCount % directions.count].contains(pos) {
        history[stepCount % directions.count].append(pos)
        let currentDirection = directions[stepCount % directions.count]
        // print(pos, currentDirection, terminator: " -> ")

        pos = getNext(for: pos, direction: currentDirection)
        stepCount += 1
    }
    let nCircles = history[stepCount % directions.count].firstIndex(of: pos)!
    let offset = nCircles * directions.count + stepCount % directions.count
    let length = (history[stepCount % directions.count].count - nCircles) * directions.count
    cycles[node] = Cycle(offset: offset, length: length)
    // print("pos:", pos, "nCircles:", nCircles, "offset:", offset, "length:", length)
    // print(history)
    assert(move(from: node, steps: offset+length) == move(from: node, steps: offset+length*2))
    assert(move(from: node, steps: offset+length*2) == move(from: node, steps: offset+length*3))
}

for node in startNodes {
    var pos = node
    var stepCount = 0
    while stepCount < cycles[node]!.offset + cycles[node]!.length {
        if pos.hasSuffix("Z") {
            cycles[node]!.z.append(stepCount - cycles[node]!.offset)
        }
        let currentDirection = directions[stepCount % directions.count]
        pos = getNext(for: pos, direction: currentDirection)
        stepCount += 1
    }
}

for node in startNodes {
    for zOffset in cycles[node]!.z {
        let pos1 = move(from: node, steps: cycles[node]!.offset + zOffset)
        assert(pos1.hasSuffix("Z"))
        let pos2 = move(from: node, steps: cycles[node]!.offset + zOffset + cycles[node]!.length)
        assert(pos1 == pos2)
    }
}

// for (node, cycle) in cycles {
//     print("\(node): offset = \(cycle.offset), length = \(cycle.length), z = \(cycle.z)")
// }

// Printing cycle lengths for post-processing in python
for (_, cycle) in cycles {
    print(cycle.length, terminator: " ")
}
print()