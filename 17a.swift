import Foundation

enum Direction: String {
    case Enter = "."
    case Right = ">"
    case RightRight = ">>"
    case RightRightRight = ">>>"
    case Left = "<"
    case LeftLeft = "<<"
    case LeftLeftLeft = "<<<"
    case Up = "^"
    case UpUp = "^^"
    case UpUpUp = "^^^"
    case Down = "v"
    case DownDown = "vv"
    case DownDownDown = "vvv"
}

struct Position {
    var row: Int
    var col: Int
}

struct State {
    var pos: Position
    var dir: Direction
    var dist: Int
}

func +(lhs: Position, rhs: Position) -> Position {
    return Position(row: lhs.row + rhs.row, col: lhs.col + rhs.col)
}

func nextDirections(direction: Direction) -> [Direction] {
    switch direction {
        case .Enter:
            return [.Right, .Left, .Up, .Down]
        case .Down:
            return [.Right, .Left, .DownDown]
        case .DownDown:
            return [.Right, .Left, .DownDownDown]
        case .DownDownDown:
            return [.Right, .Left]
        case .Up:
            return [.Right, .Left, .UpUp]
        case .UpUp:
            return [.Right, .Left, .UpUpUp]
        case .UpUpUp:
            return [.Right, .Left]
        case .Right:
            return [.Up, .Down, .RightRight]
        case .RightRight:
            return [.Up, .Down, .RightRightRight]
        case .RightRightRight:
            return [.Up, .Down]
        case .Left:
            return [.Up, .Down, .LeftLeft]
        case .LeftLeft:
            return [.Up, .Down, .LeftLeftLeft]
        case .LeftLeftLeft:
            return [.Up, .Down]
    }
}

func lastMove(direction: Direction) -> Position {
    switch(direction) {
    case .Enter:
        print("trying to get prev dir before the first move")
        assert(false)
    case .Right, .RightRight, .RightRightRight:
        return Position(row: 0, col: +1)
    case .Down, .DownDown, .DownDownDown:
        return Position(row: +1, col: 0)
    case .Left, .LeftLeft, .LeftLeftLeft:
        return Position(row: 0, col: -1)
    case .Up, .UpUp, .UpUpUp:
        return Position(row: -1, col: 0)
    }
}

func isInside(pos: Position, height: Int, width: Int) -> Bool {
    return pos.col >= 0 && pos.col < width && pos.row >= 0 && pos.row < height
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

var d = Array(repeating: Array(repeating: Dictionary<Direction, Int>(), count: width), count: height)
d[0][0][.Enter] = 0
var q = [State(pos: Position(row: 0, col: 0), dir: .Enter, dist: 0)]
while (!q.isEmpty) {
    var currentNodeIndex = 0
    for i in 0..<q.count {
        if q[i].dist < q[currentNodeIndex].dist {
            currentNodeIndex = i
        }
    }
    let cur = q.remove(at: currentNodeIndex)
    for nextDir in nextDirections(direction: cur.dir) {
        let nextPos: Position = cur.pos + lastMove(direction: nextDir)
        if isInside(pos: nextPos, height: height, width: width) 
            && (d[nextPos.row][nextPos.col][nextDir] == nil 
            || d[nextPos.row][nextPos.col][nextDir]! > d[cur.pos.row][cur.pos.col][cur.dir]! + data2D[nextPos.row][nextPos.col]){
            d[nextPos.row][nextPos.col][nextDir] = d[cur.pos.row][cur.pos.col][cur.dir]! + data2D[nextPos.row][nextPos.col]
            q.append(State(pos: nextPos, dir: nextDir, dist: d[nextPos.row][nextPos.col][nextDir]!))
        }
    }
}

print("answer:", d[height - 1][width - 1].min{$0.value < $1.value}!.value)