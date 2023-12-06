// Solves Day 3 part 1
// Run from the command line as follows:
// $ swift 3a.swift 3.example
// answer: 4361

import Foundation

let dataFile = CommandLine.arguments[1]
let data = try! String(contentsOfFile: dataFile)
var data2D = data.components(separatedBy: "\n").dropLast().map({Array($0)}) // dropping last line, it's empty

let height = data2D.count
let width = data2D[0].count
let deltas = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]

var ans = 0
var numberSoFar = 0
var adjacentToPart = false

for row in 0..<height {
    for col in 0..<width {
        if data2D[row][col].isNumber {
            numberSoFar = numberSoFar * 10 + Int(String(data2D[row][col]))!
            for (dr, dc) in deltas {
                let adj_row = row + dr
                let adj_col = col + dc
                if (0..<height).contains(adj_row) && (0..<width).contains(adj_col)
                    && !data2D[adj_row][adj_col].isNumber && data2D[adj_row][adj_col] != "." {
                    adjacentToPart = true
                }
            }
        } else {
            if (adjacentToPart) {
                ans += numberSoFar
            }
            numberSoFar = 0
            adjacentToPart = false
        }
    }
    if (adjacentToPart) {
        ans += numberSoFar
    }
    numberSoFar = 0
    adjacentToPart = false
}

if (data2D.last!.last!.isNumber && adjacentToPart) {
    ans += numberSoFar   
}

print("answer:", ans)
