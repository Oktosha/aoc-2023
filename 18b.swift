// Solves Day 18 both parts
// Run from the command line as follows
// (second arg is A for first part, B for second part):
// $ swift 18b.swift 18.example A
// 

import Foundation
import RegexBuilder

enum Direction: String {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
}

struct Step {
    var dir: Direction
    var len: Int
}

struct Position {
    var row: Int
    var col: Int
}

func parseA(rawData: String) -> [Step] {
    var plan = [Step]()
    let stepRegex = Regex {
        Capture {
            #/[UDLR]/#
        } transform: { 
            Direction(rawValue: String($0))!
        }
        " "
        Capture {
            #/\d+/#
        } transform: {
            Int($0)!
        }
        " (#"
        #/[0-9a-f]{6}/#
        ")"
    }
    for match in rawData.matches(of: stepRegex) {
        let (_, direction, length) = match.output
        plan.append(Step(dir: direction, len: length))
    }
    return plan
}

func parseB(rawData: String) -> [Step] {
    var plan = [Step]()
    let stepRegex = Regex {
        #/[UDLR]/#
        " "
        #/\d+/#
        " (#"
        Capture {
        #/[0-9a-f]{5}/#
        } transform: { 
            Int($0, radix: 16)!
        }
        Capture {
            #/\d/#
        } transform: {
            switch($0) {
                case "0":
                    return Direction.right
                case "1":
                    return Direction.down
                case "2":
                    return Direction.left
                case "3":
                    return Direction.up
                default:
                    print("Unexpected code \($0) for direction")
                    exit(1)
            }
        }
        ")"
    }
    for match in rawData.matches(of: stepRegex) {
        let (_, length, direction) = match.output
        plan.append(Step(dir: direction, len: length))
    }
    return plan
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile).trimmingCharacters(in: .newlines)
let dataVariant = CommandLine.arguments[2]
let plan = if (dataVariant == "A") {
    parseA(rawData: rawData)
} else {
    parseB(rawData: rawData)
}

for step in plan {
    print(step.dir.rawValue, step.len)
}