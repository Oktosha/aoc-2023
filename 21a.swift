import Foundation

let dataFile = CommandLine.arguments[1]
let nSteps = Int(CommandLine.arguments[2])!
let rawData = try! String(contentsOfFile: dataFile)

var a = rawData.trimmingCharacters(in: .newlines).components(separatedBy: .newlines).map {Array($0).map {e in String(e)}}
// for line in a {
//     print(line)
// }
let height = a.count
let width = a[0].count

for _ in 1...nSteps {
    var next = Array(repeating: Array(repeating: "*", count: width), count: height)
    for row in 0..<height {
        for col in 0..<width {
            if a[row][col] == "#" {
                next[row][col] = "#"
            } else {
                if (row - 1 >= 0 && (a[row - 1][col] == "S" || a[row - 1][col] == "O"))
                || (row + 1 < height && (a[row + 1][col] == "S" || a[row + 1][col] == "O"))
                || (col - 1 >= 0 && (a[row][col - 1] == "S" || a[row][col - 1] == "O"))
                || (col + 1 < width && (a[row][col + 1] == "S" || a[row][col + 1] == "O")) {
                    next[row][col] = "O"
                } else {
                    next[row][col] = "."
                }
            }
        }
    }
    a = next
}

var ans = 0
for line in a {
    for ch in line {
        if ch == "O" {
            ans += 1
        }
        // print(ch, terminator: "")
    }
    // print()
}

print("answer:", ans)