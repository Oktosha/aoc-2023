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
    var color: String
}

struct Position {
    var row: Int
    var col: Int
}

func +(lhs: Position, rhs: Position) -> Position {
    return Position(row: lhs.row + rhs.row, col: lhs.col + rhs.col)
}

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
    Capture {
        #/[0-9a-f]+/#
    }
    transform: {
        String($0)
    }
    ")" 
}

func apply(step: Step, to pos: Position) -> Position {
    switch step.dir {
        case .up:
            return Position(row: pos.row - step.len, col: pos.col)
        case .down:
            return Position(row: pos.row + step.len, col: pos.col)
        case .left:
            return Position(row: pos.row, col: pos.col - step.len)
        case .right:
            return Position(row: pos.row, col: pos.col + step.len)
    }
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile).trimmingCharacters(in: .newlines)
var plan = [Step]()
for match in rawData.matches(of: stepRegex) {
    let (_, dir, len, color) = match.output
    plan.append(Step(dir: dir, len: len, color: color))
}

var minRow = 0
var maxRow = 0
var minCol = 0
var maxCol = 0

var pos = Position(row: 0, col: 0)
for step in plan {
    // print(pos, step)
    pos = apply(step: step, to: pos)
    minRow = min(pos.row, minRow)
    minCol = min(pos.col, minCol)
    maxRow = max(pos.row, maxRow)
    maxCol = max(pos.col, maxCol)
}

print("mins: row = \(minRow), col = \(minCol)")
print("maxs: row = \(maxRow), col = \(maxCol)")
print("end pos = \(pos.row), \(pos.col)")

let height = maxRow - minRow + 6
let width = maxCol - minCol + 6
var field = Array(repeating: Array(repeating: ".", count: width), count: height)
let start = Position(row: 2 - minRow, col: 2 - minCol)
pos = start
for step in plan {
    for i in 1...step.len {
        switch step.dir {
            case .up:
                pos = Position(row: pos.row - 1, col: pos.col)
            case .down:
                pos = Position(row: pos.row + 1, col: pos.col)
            case .left:
                pos = Position(row: pos.row, col: pos.col - 1)
            case .right:
                pos = Position(row: pos.row, col: pos.col + 1)
        }
        assert(field[pos.row][pos.col] == ".")
        field[pos.row][pos.col] = "#"
    }
}

print("==After digging==")
for line in field {
    for ch in line {
        print(ch, terminator: "")
    }
    print()
}
print()

let outer = Position(row: 0, col: 0)
var q = [outer]
field[outer.row][outer.col] = "x"
let deltas = [Position(row: -1, col: 0), Position(row: 1, col: 0), Position(row: 0, col: 1), Position(row: 0, col: -1)]
while !q.isEmpty {
    let pos = q.remove(at: 0)
    for d in deltas {
        let next = pos + d
        if next.row >= 0 && next.row < height && next.col >= 0 && next.col < width
            && field[next.row][next.col] == "." {
                field[next.row][next.col] = "x"
                q.append(next)
        }
    }   
}

print("==After excluding outers==")
for line in field {
    for ch in line {
        print(ch, terminator: "")
    }
    print()
}
print()

var ans = 0
for line in field {
    for ch in line {
        if ch == "#" || ch == "." {
            ans += 1
        }
    }
}
print("answer: ", ans)