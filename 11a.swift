import Foundation
import RegexBuilder

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
var data = rawData.components(separatedBy: "\n").filter{!$0.isEmpty}.map{Array($0)}

print("original map height:", data.count)
print("original map width:", data[0].count)

func expandColumns(_ data: inout [[Character]]) {
    var column = 0
    while (column < data[0].count) {
        let isEmpty = data.map{$0[column]}.allSatisfy{$0 == "."}
        if isEmpty {
            for row in 0..<data.count {
                data[row].insert(".", at: column)
            }
            column += 2
        } else {
            column += 1
        }
    }
}

func expandRows(_ data: inout [[Character]]) {
    var row = 0
    while (row < data.count) {
        let isEmpty = data[row].allSatisfy{$0 == "."}
        if isEmpty {
            data.insert(Array(repeating: ".", count: data[0].count), at: row)
            row += 2
        } else {
            row += 1
        }
    }
}

func expand(universe data: inout [[Character]]) {
    expandColumns(&data)
    expandRows(&data)
}

struct Position {
    var row: Int
    var col: Int
}

func distance(a: Position, b: Position) -> Int {
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

expand(universe: &data)

/*
for line in data {
    for ch in line {
        print(ch, terminator: "")
    }
    print()
}
*/

let galaxies = getGalaxyPositions(data: data)
print("galaxies count:", galaxies.count)

var ans = 0
for i in 0..<(galaxies.count - 1) {
    for j in (i+1)..<galaxies.count {
        ans += distance(a: galaxies[i], b: galaxies[j])
    }
}

print("answer:", ans)