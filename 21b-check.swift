// This code checks if for the given input data
// 1. the tile is a square with odd side size
// 2. start point is in the center
// 3. for distance DIST (number of steps of the elf)
// all cells within the DIST as if there were no rocks are reachable
// (this checked by looking at first 1000 distances and their remainder modulo TILE SIZE)

// Given these checks succeseed we get the ans by counting the dots on odd positions within a romb

import Foundation

struct Point : Hashable {
    var row: Int
    var col: Int
    static func + (lhs: Point, rhs: Point) -> Point {
        return Point(row: lhs.row + rhs.row, col: lhs.col + rhs.col)
    }
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
let rawData = try! String(contentsOfFile: dataFile)

var a = rawData.trimmingCharacters(in: .newlines).components(separatedBy: .newlines).map {Array($0).map {e in String(e)}}
let height = a.count
let width = a[0].count
assert(height == width)
let L = height
assert(L % 2 == 1)
assert(a[L / 2][L / 2] == "S")
print("L = \(L)")

var front = Set([Point(row: 0, col: 0)])
var prev = Set<Point>()
let deltas = [
    Point(row: 1, col: 0),
    Point(row: -1, col: 0),
    Point(row: 0, col: 1),
    Point(row: 0, col: -1)
    ]

var unevenFronts = Set<Int>()
for distance in 1...1000 {
    var next = Set<Point>()
    for p in front {
        for d in deltas {
            let nextPoint = p + d
            if getGroundType(at: nextPoint, in: a) == "." && !prev.contains(nextPoint) {
                next.insert(nextPoint)
            }
        }
    }
    prev = front
    front = next
    for row in -distance...distance {
        let columnDelta = distance - abs(row)
        let leftPoint = Point(row: row, col: -columnDelta)
        let rightPoint = Point(row: row, col: columnDelta)
        if !(getGroundType(at: leftPoint, in: a) == "#" || front.contains(leftPoint)) {
            // print("left point \(leftPoint) is missing")
            unevenFronts.insert(distance)
        }
        if !(getGroundType(at: rightPoint, in: a) == "#" || front.contains(rightPoint)) {
            // print("right point \(rightPoint) is missing")
            unevenFronts.insert(distance)
        }
    }
}

for i in 1...1000 {
    if !unevenFronts.contains(i) {
        print(i)
    }
}
