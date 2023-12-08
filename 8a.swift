// Solves Day 8 part 1
// Run from the command line as follows:
// $ swift 8a.swift 8-1.example
// ...[some debug data]...
// answer: 2

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
    } transform: { Array($0) }
    "\n\n"
    Capture (
        OneOrMore {
            nodeRegex
            "\n"
        }
    , transform: parseNodes)
}

let (_, directions, nodes) = rawData.wholeMatch(of: dataRegex)!.output
print("==directions==")
print(directions)
print()
print("==nodes==")
print(nodes)

var stepCount = 0
var currentNode = "AAA"
while currentNode != "ZZZ" {
    let currentDirection = directions[stepCount % directions.count]
    if currentDirection == "L" {
        currentNode = nodes[currentNode]!.left
    } else {
        currentNode = nodes[currentNode]!.right
    }
    stepCount += 1
}

print("answer:", stepCount)