// Solves Day 18 both parts
// Run from the command line as follows
// (second arg is A for first part, B for second part):
// $ swift 18b.swift 18.example A
// answer: 62

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

func +(lhs: Position, rhs: Position) -> Position {
    return Position(row: lhs.row + rhs.row, col: lhs.col + rhs.col)
}

func area(figure: [Position])-> Int {
    var ans = 0
    for i in 0..<figure.count {
        let a = figure[i]
        let b = figure[(i + figure.count - 1) % figure.count]
        ans += a.row * b.col - b.row * a.col
    }
    if ans < 0 {
        ans = -ans
    }
    assert(ans % 2 == 0)
    return ans / 2
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

var pos = Position(row: 0, col: 0)
var lefts = [Position]()
var rights = [Position]()
var perimeter = 0
for i in 0..<plan.count {
    let step = plan[i]
    perimeter += step.len
    let previousStep = plan[(i + plan.count - 1) % plan.count]
    let topLeftPos = pos
    let topRightPos = pos + Position(row: 0, col: 1)
    let bottomLeftPos = pos + Position(row: 1, col: 0)
    let bottomRightPos = pos + Position(row: 1, col: 1)
    assert(step.dir != previousStep.dir)
    switch step.dir {
        case .right:
            if previousStep.dir == .up {
                lefts.append(topLeftPos)
                rights.append(bottomRightPos)
            } else if previousStep.dir == .down {
                lefts.append(topRightPos)
                rights.append(bottomLeftPos)
            } else {
                print("unexpected dir sequence \(previousStep.dir) -> \(step.dir)")
                assert(false)
            }
            pos = pos + Position(row: 0, col: step.len)
        case .left:
            if previousStep.dir == .up {
                lefts.append(bottomLeftPos)
                rights.append(topRightPos)
            } else if previousStep.dir == .down {
                lefts.append(bottomRightPos)
                rights.append(topLeftPos)
            } else {
                print("unexpected dir sequence \(previousStep.dir) -> \(step.dir)")
                assert(false)
            }
            pos = pos + Position(row: 0, col: -step.len)
        case .down:
            if previousStep.dir == .left {
                lefts.append(bottomRightPos)
                rights.append(topLeftPos)
            } else if previousStep.dir == .right {
                lefts.append(topRightPos)
                rights.append(bottomLeftPos)
            } else {
                print("unexpected dir sequence \(previousStep.dir) -> \(step.dir)")
                assert(false)
            }
            pos = pos + Position(row: step.len, col: 0)
        case .up:
            if previousStep.dir == .left {
                lefts.append(bottomLeftPos)
                rights.append(topRightPos)
            } else if previousStep.dir == .right {
                lefts.append(topLeftPos)
                rights.append(bottomRightPos)
            } else {
                print("unexpected dir sequence \(previousStep.dir) -> \(step.dir)")
                assert(false)
            }
            pos = pos + Position(row: -step.len, col: 0)
    }
}
assert(pos.col == 0)
assert(pos.row == 0)

let insideArea = min(area(figure: lefts), area(figure: rights))
let outsideArea = max(area(figure: lefts), area(figure: rights))
assert(insideArea + perimeter == outsideArea)
print("answer:", outsideArea)