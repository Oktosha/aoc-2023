import Foundation

let gameTitleRegex = #/Game (?<gameId>\d+): /#
let redRegex = #/(?<count>\d+) red/#
let greenRegex = #/(?<count>\d+) green/#
let blueRegex = #/(?<count>\d+) blue/#
var answer = 0

let data = try! String(contentsOfFile: "2.txt")
for line in data.components(separatedBy: "\n") {
    guard let gameTitleMatch = try! gameTitleRegex.firstMatch(in: line) else { continue }
    let gameId = Int(gameTitleMatch.gameId)!
    print("game id = \(gameId)")
    let sets = line.trimmingPrefix(gameTitleRegex)
    print("sets = \(sets)")
    var gameIsPossible = true
    var maxes = [0, 0, 0]
    let regexes = [redRegex, greenRegex, blueRegex]
    for entry in sets.components(separatedBy: ";") {
        for colorEntry in entry.components(separatedBy: ",") {
            for (colorId, colorRegex) in regexes.enumerated() {
                if let count = try! colorRegex.firstMatch(in: colorEntry)?.count {
                    maxes[colorId] = max(Int(count)!, maxes[colorId])
                }
            }
        }
    }
    answer += maxes[0] * maxes[1] * maxes[2]
}
print(answer)