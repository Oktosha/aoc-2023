import Foundation

let data = try! String(contentsOfFile: "3.txt")
var data2D = data.components(separatedBy: "\n").dropLast().map({Array($0)}) // dropping last line, it's empty

let height = data2D.count
let width = data2D[0].count
var numIds = Array(repeating: Array(repeating: 0, count: width), count: height)
var nums = [1]

var currentNumberId = 1
var numberSoFar = 0

for row in 0..<height {
    for col in 0..<width {
        if data2D[row][col].isNumber {
            numberSoFar = numberSoFar * 10 + Int(String(data2D[row][col]))!
            numIds[row][col] = currentNumberId
        } else {
            if (numberSoFar != 0)
            {
                nums.append(numberSoFar)
                numberSoFar = 0
                currentNumberId += 1
            }
        }
    }
    if (numberSoFar != 0)
    {
        nums.append(numberSoFar)
        numberSoFar = 0
        currentNumberId += 1
    }
}

for row in 0..<height {
    for col in 0..<width {
        print(numIds[row][col], terminator: " ")
    }
    print()
}
print(nums)


var answer = 0
let deltas = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
for row in 0..<height {
    for col in 0..<width {
        if data2D[row][col] == "*" {
            var adjacentNumberIds = Set<Int>()
            for (dr, dc) in deltas {
                let adj_row = row + dr
                let adj_col = col + dc
                if (0..<height).contains(adj_row) && (0..<width).contains(adj_col) && numIds[adj_row][adj_col] != 0 {
                    adjacentNumberIds.insert(numIds[adj_row][adj_col])
                }
            }
            if (adjacentNumberIds.count == 2) {
                print(adjacentNumberIds)
                var gearRatio = 1
                for numId in adjacentNumberIds {
                    gearRatio *= nums[numId]
                }
                answer += gearRatio
            }
        }
    }
}

print(answer)
