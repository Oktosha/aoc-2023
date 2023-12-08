// Solves Day 8 part 2
// Run from the command line as follows:
// $ swift 8a.swift 8-3.example
// answer: 6

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
}

let startNodes = nodes.keys.filter({$0.hasSuffix("A")})
var cycles = [String: Cycle]()
for node in startNodes {
    var history = Array(repeating: Array<String>(), count: directions.count)
    var pos = node
    var stepCount = 0
    while !history[stepCount % directions.count].contains(pos) {
        history[stepCount % directions.count].append(pos)
        let currentDirection = directions[stepCount % directions.count]
        print(pos, currentDirection, terminator: " -> ")

        pos = getNext(for: pos, direction: currentDirection)
        stepCount += 1
    }
    let nCircles = history[stepCount % directions.count].firstIndex(of: pos)!
    let offset = nCircles * directions.count + stepCount % directions.count
    let length = (history[stepCount % directions.count].count - nCircles) * directions.count
    cycles[node] = Cycle(offset: offset, length: length)
    print("pos:", pos, "nCircles:", nCircles, "offset:", offset, "length:", length)
    print(history)
    assert(move(from: node, steps: offset+length) == move(from: node, steps: offset+length*2))
}
print(cycles)
