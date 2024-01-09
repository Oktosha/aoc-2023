import Foundation

enum Direction : Int {
    case right = 0
    case up = 1
    case left = 2
    case down = 3
}

struct Point {
    var row: Int
    var col: Int
}

struct Position {
    var p: Point
    var beamDir: Direction
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile).trimmingCharacters(in: .newlines)
let tiles = rawData.components(separatedBy: "\n").map { Array($0) }
let height = tiles.count
let width = tiles[0].count
var visited = Array(repeating: Array(repeating: Array(repeating: false, count: 4), count: width), count: height)

var q = [Position(p: Point(row: 0, col: 0), beamDir: .right)]
visited[0][0][Direction.right.rawValue] = true
while (!q.isEmpty) {
    let cur = q.popLast()!
    let tile = tiles[cur.p.row][cur.p.col]
    var nextPositions = [Position]()
    switch(tile) {
        case ".":
            switch(cur.beamDir) {
                case .right:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row, col: cur.p.col + 1),
                        beamDir: cur.beamDir))
                case .up:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row - 1, col: cur.p.col),
                        beamDir: cur.beamDir))
                case .left:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row, col: cur.p.col - 1),
                        beamDir: cur.beamDir))
                case .down:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row + 1, col: cur.p.col),
                        beamDir: cur.beamDir))
            }
        case "|":
            switch(cur.beamDir) {
                case .right:
                    nextPositions.append(contentsOf: [
                        Position(
                            p: Point(row: cur.p.row - 1, col: cur.p.col),
                            beamDir: .up),
                        Position(
                            p: Point(row: cur.p.row + 1, col: cur.p.col),
                            beamDir: .down),   
                    ])
                case .up:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row - 1, col: cur.p.col),
                        beamDir: cur.beamDir))
                case .left:
                    nextPositions.append(contentsOf: [
                        Position(
                            p: Point(row: cur.p.row - 1, col: cur.p.col),
                            beamDir: .up),
                        Position(
                            p: Point(row: cur.p.row + 1, col: cur.p.col),
                            beamDir: .down),   
                    ])
                case .down:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row + 1, col: cur.p.col),
                        beamDir: cur.beamDir))
            }
        case "-":
            switch(cur.beamDir) {
                case .right:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row, col: cur.p.col + 1),
                        beamDir: cur.beamDir))
                case .up:
                    nextPositions.append(contentsOf: [
                        Position(
                            p: Point(row: cur.p.row, col: cur.p.col - 1),
                            beamDir: .left),
                        Position(
                            p: Point(row: cur.p.row, col: cur.p.col + 1),
                            beamDir: .right),   
                    ])
                case .left:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row, col: cur.p.col - 1),
                        beamDir: cur.beamDir))
                case .down:
                    nextPositions.append(contentsOf: [
                        Position(
                            p: Point(row: cur.p.row, col: cur.p.col - 1),
                            beamDir: .left),
                        Position(
                            p: Point(row: cur.p.row, col: cur.p.col + 1),
                            beamDir: .right),   
                    ])
            }
        case "\\":
            switch(cur.beamDir) {
                case .right:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row + 1, col: cur.p.col),
                        beamDir: .down))
                case .up:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row, col: cur.p.col - 1),
                        beamDir: .left))
                case .left:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row - 1, col: cur.p.col),
                        beamDir: .up))
                case .down:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row, col: cur.p.col + 1),
                        beamDir: .right))
            }
        case "/":
            switch(cur.beamDir) {
                case .left:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row + 1, col: cur.p.col),
                        beamDir: .down))
                case .down:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row, col: cur.p.col - 1),
                        beamDir: .left))
                case .right:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row - 1, col: cur.p.col),
                        beamDir: .up))
                case .up:
                    nextPositions.append(Position(
                        p: Point(row: cur.p.row, col: cur.p.col + 1),
                        beamDir: .right))
            }
        default:
            print("Unexpected tile \(tile)")
    }
    for pos in nextPositions {
        if pos.p.row >= 0 && pos.p.row < height 
            && pos.p.col >= 0 && pos.p.col < width
            && !visited[pos.p.row][pos.p.col][pos.beamDir.rawValue] {
            visited[pos.p.row][pos.p.col][pos.beamDir.rawValue] = true
            q.append(pos)
        }
    }
}

var ans = 0
for row in visited {
    element: for e in row {
        for dir in e {
            if dir {
                ans += 1
                continue element
            }
        }
    }
}

print("answer:", ans)