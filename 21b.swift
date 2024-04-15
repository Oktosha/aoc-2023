import Foundation

struct Point : Hashable {
    var row: Int
    var col: Int
    static func + (lhs: Point, rhs: Point) -> Point {
        return Point(row: lhs.row + rhs.row, col: lhs.col + rhs.col)
    }
}

func countOccurrenciesFromZero(of r: Int, modulo: Int, totmet: Int) -> Int {
    return totmet / modulo + ((r <= totmet % modulo) ? 1 : 0)
}

// (0, 0) is the starting position
// top left of the tile is (-L/2, -L/2)
func getGroundType(at pos: Point, in a: [[String]]) -> String {
    let L = a.count
    let row = ((pos.row + (L / 2)) % L + L) % L
    let col = ((pos.col + (L / 2)) % L + L) % L
    return a[row][col] == "#" ? "#" : "."
}

let dataFile = CommandLine.arguments[1]
let nSteps = Int(CommandLine.arguments[2])!
let rawData = try! String(contentsOfFile: dataFile)

let a = rawData.trimmingCharacters(in: .newlines).components(separatedBy: .newlines).map {Array($0).map {e in String(e)}}
let L = a.count
let shift = (nSteps / (2 * L)) * (2 * L) + 4 * L

var ans = 0
for row in -nSteps...nSteps {
    let columnDelta = nSteps - abs(row)
    let preLeft = -columnDelta + shift - 1
    let right = columnDelta + shift
    for r in 0..<2*L {
        let count = countOccurrenciesFromZero(of: r, modulo: 2 * L, totmet: right) - countOccurrenciesFromZero(of: r, modulo: 2 * L, totmet: preLeft)
        // if count > 0 {
        //     print("row = \(row), r = \(r), count =", count, "ground = \(getGroundType(at: Point(row: row, col: r), in: a))")
        // }
        if getGroundType(at: Point(row: row, col: r), in: a) == "." && (((r + row) % 2 + 2) % 2 == nSteps % 2) {
            ans += count
        }
    }
    if (row % 500000 == 0) {
        print(row)
    }
}

print("answer:", ans)
