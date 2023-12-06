// Solves Day 6 both parts

// Run from the command line as follows to get the first part:
// $ swift 6.swift 6.example
// ...[some debug data]...
// answer: 288

// To get the answer for the second part delete spaces between numbers in the input file:
// $ swift 6.swift 6b.example
// ...[can take a while]...
// answer: 71503

import Foundation
import RegexBuilder

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)

func parseIntArray(_ s: Substring) -> [Int] {
    // print("parsing ints in \(s)...")
    var answer: [Int] = []
    for match in s.matches(of: #/\d+/#) {
        answer.append(Int(match.output)!)
    }
    return answer
}

let dataRegex = Regex {
    "Time:"
    Capture(OneOrMore(#/\s+\d+/#), transform: parseIntArray)
    "\n"
    "Distance:"
    Capture(OneOrMore(#/\s+\d+/#), transform: parseIntArray)
    "\n"
}

let (_, times, distances) = rawData.wholeMatch(of: dataRegex)!.output
let count = times.count
var answer = 1
for i in 0..<count {
    var winningCount = 0
    for holdingTime in 0...times[i] {
        let distance = (times[i] - holdingTime) * holdingTime
        if distance > distances[i] {
            winningCount += 1
        }
    }
    print("You can win race \(i) with \(winningCount) different strategies")
    answer *= winningCount
}
print("answer:", answer)