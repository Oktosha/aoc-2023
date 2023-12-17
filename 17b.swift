import Foundation

enum Direction {
    case Enter
    case Right
    case Left
    case Down
    case Up
}

struct Position: Hashable {
    var row: Int
    var col: Int
}

func +(lhs: Position, rhs: Position) -> Position {
    return Position(row: lhs.row + rhs.row, col: lhs.col + rhs.col)
}

func isInside(pos: Position, height: Int, width: Int) -> Bool {
    return pos.col >= 0 && pos.col < width && pos.row >= 0 && pos.row < height
}

func getNextDirections(for dir: Direction) -> [Direction] {
    switch(dir) {
        case .Enter:
            return [.Right, .Down, .Left, .Up]
        case .Left:
            return [.Down, .Up]
        case .Right:
            return [.Down, .Up]
        case .Down:
            return [.Right, .Left]
        case .Up:
            return [.Right, .Left]
    }
}

func getMove(to direction: Direction, len: Int) -> Position {
    switch(direction) {
        case .Enter:
            print("trying to move .Enter")
            assert(false)
        case .Down:
            return Position(row: len, col: 0)
        case .Up:
            return Position(row: -len, col: 0)
        case .Left:
            return Position(row: 0, col: -len)
        case .Right:
            return Position(row:0, col: len)
    }
}

func getMoveCost(from: Position, to direction: Direction, len: Int, data: [[Int]]) -> Int {
    let diff = switch direction {
        case .Down:
            Position(row: 1, col: 0)
        case .Up:
            Position(row: -1, col: 0)
        case .Left:
            Position(row: 0, col: -1)
        case .Right:
            Position(row: 0, col: 1)
        default:
            Position(row: 10000, col: 100000)
    }
    var pos = from
    var ans = 0
    for _ in 1...len {
        pos = pos + diff
        ans += data[pos.row][pos.col]
    }
    return ans
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile).trimmingCharacters(in: .newlines)
var data2D = [[Int]]()
for line in rawData.components(separatedBy: "\n") {
    let chars = Array(line)
    let nums = chars.map{Int(String($0))!}
    data2D.append(nums)
}

let height = data2D.count
let width = data2D[0].count
let INFINITY = 100 * height * width + 500
var d: [[Dictionary<Direction, Int>]] = Array(repeating: Array(repeating: Dictionary<Direction, Int>(), count: width), count: height)

let startPosition = Position(row: 0, col: 0)
let finishPosition = Position(row: height - 1, col: width - 1)

d[0][0][.Enter] = 0
var lastAddedPos = startPosition
var lastAddedDir = Direction.Enter

var cnt = 0
var frontier = Set([startPosition])
while lastAddedPos != finishPosition {
    var distanceToNext = INFINITY
    var nextFrontier: Set<Position> = Set()
    for curPos in frontier {
        for (dir, dist) in d[curPos.row][curPos.col] {
            for nextDir in getNextDirections(for: dir) {
                for len in 4...10 {
                    let nextPos = curPos + getMove(to: nextDir, len: len)
                    if isInside(pos: nextPos, height: height, width: width) {
                        let cost = getMoveCost(from: curPos, to: nextDir, len: len, data: data2D) 
                        if d[nextPos.row][nextPos.col][nextDir] == nil {
                            nextFrontier.insert(curPos)
                            if dist + cost < distanceToNext {
                                lastAddedPos = nextPos
                                distanceToNext = dist + cost
                                lastAddedDir = nextDir
                            }
                        }
                    }
                }
            }
        }
    }
    d[lastAddedPos.row][lastAddedPos.col][lastAddedDir] = distanceToNext
    nextFrontier.insert(lastAddedPos)
    frontier = nextFrontier
    cnt += 1
    if cnt % 1000 == 0 {
        print("Step \(cnt)")
        print("added \(lastAddedPos.row) \(lastAddedPos.col)")
        print("frontier size: \(frontier.count)")
    }
    
}
print("answer:", d[finishPosition.row][finishPosition.col].min{$0.value < $1.value}!.value)