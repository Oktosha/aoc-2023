// Solves Day 2 part 1
// Run from the command line as follows:
// $ swift 2a.swift 2.example
// ...[some debug data]...
// answer: 8

import Foundation

let gameTitleRegex = #/Game (?<gameId>\d+): /#
let redRegex = #/(?<count>\d+) red/#
let greenRegex = #/(?<count>\d+) green/#
let blueRegex = #/(?<count>\d+) blue/#
var answer = 0

let dataFile = CommandLine.arguments[1]
let data = try! String(contentsOfFile: dataFile)
for line in data.components(separatedBy: "\n") {
    guard let gameTitleMatch = try! gameTitleRegex.firstMatch(in: line) else { continue }
    let gameId = Int(gameTitleMatch.gameId)!
    print("game id = \(gameId)")
    let sets = line.trimmingPrefix(gameTitleRegex)
    print("sets = \(sets)")
    var gameIsPossible = true
    let maxRed = 12
    let maxGreen = 13
    let maxBlue = 14
    let colorRestrictions = [(redRegex, maxRed), (greenRegex, maxGreen), (blueRegex, maxBlue)]
    for entry in sets.components(separatedBy: ";") {
        for colorEntry in entry.components(separatedBy: ",") {
            for restriction in colorRestrictions {
                let colorRegex = restriction.0
                let colorMax = restriction.1
                if let count = try! colorRegex.firstMatch(in: colorEntry)?.count {
                    if Int(count)! > colorMax {
                        gameIsPossible = false
                    }
                }
            }
        }
    }
    if gameIsPossible {
        answer += gameId
    }
}
print("answer:", answer)