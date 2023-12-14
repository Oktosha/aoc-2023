// This doesn't give you the answer directly
// You need to run it with cnt big enough to figure the cycle length
// (Yeah, eventually the positions of the rocks repeat themselves)
// After this you find the load for the position on the cycle
// equivalent to the 1'000'000'000 (same remainder if divided by the length of the cycle)

import Foundation

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
var data = rawData.components(separatedBy: "\n").filter{!$0.isEmpty}.map{Array($0)}

func rollNorth(data: inout [[Character]]) {
    for column in 0..<(data[0].count) {
        for row in 1..<(data.count) {
            if data[row][column] == "O" {
                var boulderRow = row
                    while boulderRow > 0 && data[boulderRow - 1][column] == "." {
                        data[boulderRow][column] = "."
                        data[boulderRow - 1][column] = "O"
                        boulderRow -= 1
                    }
            }
        }
    }
}

func rollSouth(data: inout [[Character]]) {
    for column in 0..<(data[0].count) {
        var row = data.count - 2
        while row >= 0 {
            if data[row][column] == "O" {
                var boulderRow = row
                    while boulderRow < data.count - 1 && data[boulderRow + 1][column] == "." {
                        data[boulderRow][column] = "."
                        data[boulderRow + 1][column] = "O"
                        boulderRow  += 1
                    }
            }
            row -= 1
        }
    }
}

func rollWest(data: inout [[Character]]) {
    for row in 0..<(data.count) {
        var col = 1
        while col < data[row].count {
            if data[row][col] == "O" {
                var boulderCol = col
                    while boulderCol > 0 && data[row][boulderCol - 1] == "." {
                        data[row][boulderCol] = "."
                        data[row][boulderCol - 1] = "O"
                        boulderCol -= 1
                    }
            }
            col += 1
        }
    }
}

func rollEast(data: inout [[Character]]) {
    for row in 0..<(data.count) {
        var col = data[row].count - 2
        while col >= 0 {
            if data[row][col] == "O" {
                var boulderCol = col
                    while boulderCol < data[row].count - 1 && data[row][boulderCol + 1] == "." {
                        data[row][boulderCol] = "."
                        data[row][boulderCol + 1] = "O"
                        boulderCol += 1
                    }
            }
            col -= 1
        }
    }
}

func cycle(data: inout [[Character]]) {
    rollNorth(data: &data)
    rollWest(data: &data)
    rollSouth(data: &data)
    rollEast(data: &data)
}


func areDifferent(a: [[Character]], b: [[Character]]) -> Bool {
    assert(a.count == b.count)
    assert(a[0].count == b[0].count)
    for column in 0..<(a[0].count) {
        for row in 0..<(a.count) {
            if a[row][column] != b[row][column] {
                return true
            }
        }
    }
    return false
}


func countLoad(data: [[Character]]) -> Int {
    var ans = 0
    for column in 0..<(data[0].count) {
        for row in 0..<(data.count) {
            if data[row][column] == "O" {
                ans += data.count - row
            }
        }
    }
    return ans
}

var prevs = [data]
cycle(data:&data)
var cnt = 1

while (cnt <= 200) {
    print("cycle \(cnt)")
    print("load \(countLoad(data: data))")
    for i in 0..<prevs.count {
        if !areDifferent(a: prevs[i], b: data) {
            print("same as \(i)")
        }
    }
    // for line in data {
    //     for ch in line {
    //         print(ch, terminator: "")
    //     }
    //     print()
    // }
    prevs.append(data)
    cycle(data:&data)
    cnt += 1
}




