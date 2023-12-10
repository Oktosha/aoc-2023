import Foundation
import RegexBuilder

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
let data2D = rawData.components(separatedBy: "\n").filter{!$0.isEmpty}.map{Array($0)}

print("width:", data2D[0].count)
print("height:", data2D.count)

struct Pos {
    var row: Int
    var col: Int
}

func +(lhs: Pos, rhs: Pos) -> Pos {
    return Pos(row: lhs.row + rhs.row, col: lhs.col + rhs.col)
}

func ==(lhs: Pos, rhs: Pos) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
}

struct Pipe {
    var shape: Character
    var pos: Pos
}

func findS(in data: [[Character]]) -> Pos {
    for iRow in 0..<data2D.count {
        for iCol in 0..<data2D[iRow].count {
            if data2D[iRow][iCol] == "S" {
                return Pos(row: iRow, col: iCol)
            }
        }
    }
    print("No start position found")
    exit(1)
}

func getConnectionDiffs(for shape: Character) -> [Pos] {
    switch shape {
        case "S":
            return [Pos(row: -1, col: 0), Pos(row: 1, col: 0), Pos(row: 0, col: -1), Pos(row: 0, col: 1)]
        case "|": 
            return [Pos(row: -1, col: 0), Pos(row: 1, col: 0)]
        case "-":
            return [Pos(row: 0, col: -1), Pos(row: 0, col: 1)]
        case "L":
            return [Pos(row: -1, col: 0), Pos(row: 0, col: 1)]
        case "J":
            return [Pos(row: -1, col: 0), Pos(row: 0, col: -1)]
        case "7":
            return [Pos(row: 1, col: 0), Pos(row: 0, col: -1)]
        case "F":
            return [Pos(row: 1, col: 0), Pos(row: 0, col: 1)]
        case ".":
            return []
        default:
            print("Unknown shape \(shape)")
            exit(1)
    }
}

func areConnected(a: Pipe, b: Pipe) -> Bool {
    let posConnectedToA = getConnectionDiffs(for: a.shape).map{$0 + a.pos}
    let posConnectedToB = getConnectionDiffs(for: b.shape).map{$0 + b.pos}
    return posConnectedToB.contains{$0 == a.pos} && posConnectedToA.contains{$0 == b.pos}
}

func isInsideGrid(_ pos: Pos) -> Bool {
    return pos.col >= 0 && pos.row >= 0 && pos.col < data2D[0].count && pos.row < data2D.count
}

let start = findS(in: data2D)
var distances = Array(repeating: Array(repeating: -1, count: data2D[0].count), count: data2D.count)
distances[start.row][start.col] = 0
var q = [start]
while !q.isEmpty {
    let currentPos = q.remove(at: 0)
    let currentShape = data2D[currentPos.row][currentPos.col]
    print("current:", currentShape, "at", currentPos)
    let neigbourDiffs = getConnectionDiffs(for: currentShape)
    // print("neigbourDiffs:", neigbourDiffs)
    let neigbourPositions = neigbourDiffs.map{$0 + currentPos}.filter{isInsideGrid($0)}
    // print("neigbourPositions:", neigbourPositions)
    for pos in neigbourPositions {
        let shape = data2D[pos.row][pos.col]
        if areConnected(a: Pipe(shape: currentShape, pos: currentPos), b: Pipe(shape: shape, pos: pos))
            && distances[pos.row][pos.col] == -1
         {
            distances[pos.row][pos.col] = distances[currentPos.row][currentPos.col] + 1
            q.append(pos)
        }
    }
}

var answer = -1
for line in distances {
    answer = max(answer, line.max()!)
}
print("answer:", answer)