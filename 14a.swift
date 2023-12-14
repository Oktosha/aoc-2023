import Foundation

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
var data = rawData.components(separatedBy: "\n").filter{!$0.isEmpty}.map{Array($0)}

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

for line in data {
    for ch in line {
        print(ch, terminator: "")
    }
    print()
}

var ans = 0

for column in 0..<(data[0].count) {
    for row in 0..<(data.count) {
        if data[row][column] == "O" {
            ans += data.count - row
        }
    }
}

print("answer:", ans)