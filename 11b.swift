// Solves Day 11 both parts;
// You need to pass how big the empty rows will become as second arg
// Run from the command line as follows:
// $ swift 11b.swift 11.example 100
// ...[some debug data]...
// answer: 8410

import Foundation

let dataFile = CommandLine.arguments[1]
let expansionFactor = Int(CommandLine.arguments[2])!
let rawData = try! String(contentsOfFile: dataFile)
var data = rawData.components(separatedBy: "\n").filter{!$0.isEmpty}.map{Array($0)}

let emptyRows = (0..<data.count).filter{data[$0].allSatisfy{$0=="."}}
let emptyColumns = (0..<data[0].count).filter{col in 
    (0..<data.count).allSatisfy{
        data[$0][col] == "."
    }}

print("empty rows:", emptyRows)
print("empty columns:", emptyColumns)

struct Position {
    var row: Int
    var col: Int
}

func distance(_ a: Position, _ b: Position) -> Int {
    return abs(a.col - b.col) + abs(a.row - b.row)
}

func getGalaxyPositions(data: [[Character]]) -> [Position] {
    var ans = [Position]()
    for row in 0..<data.count {
        for col in 0..<data[row].count {
            if data[row][col] == "#" {
                ans.append(Position(row: row, col: col))
            }
        }
    }
    return ans
}

let galaxies = getGalaxyPositions(data: data)

func expanededBetween(_ a: Position, _ b: Position) -> Int {
    var ans = 0
    let topRow = min(a.row, b.row)
    let bottomRow = max(a.row, b.row)
    let leftColumn = min(a.col, b.col)
    let rightColumn = max(a.col, b.col)
    for row in emptyRows {
        if topRow < row && row < bottomRow {
            ans += 1
        }
    }
    for column in emptyColumns {
        if leftColumn < column && column < rightColumn {
            ans += 1
        }
    }
    return ans
}

var ans = 0
for i in 0..<(galaxies.count - 1) {
    for j in (i+1)..<galaxies.count {
        let a = galaxies[i]
        let b = galaxies[j]
        ans += distance(a, b) + expanededBetween(a, b) * (expansionFactor - 1)
    }
}

print("answer:", ans)