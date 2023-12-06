// Solves Day 4 part 2
// Run from the command line as follows:
// $ swift 4b.swift 4.example
// ...[some debug data]...
// answer: ???

import Foundation
import RegexBuilder

let dataFile = CommandLine.arguments[1]
let data = try! String(contentsOfFile: dataFile)

func parseIntArray(_ s: Substring) -> [Int] {
    // print("parsing ints in \(s)...")
    var answer: [Int] = []
    for match in s.matches(of: #/\d+/#) {
        answer.append(Int(match.output)!)
    }
    return answer
}

let cardRegex = Regex {
    #/Card\s+\d+:/#
    Capture {
        OneOrMore(#/\s+\d+/#)
    } transform: { substring -> [Int] in
        parseIntArray(substring)
    }
    #/\s+\|/#
    Capture {
        OneOrMore(#/\s+\d+/#)
    } transform: { substring -> [Int] in
        parseIntArray(substring)
    }
}

var numbersOfMatches: [Int] = [] 
for card in data.components(separatedBy: "\n") {
    guard let (_, winning, given) = card.firstMatch(of: cardRegex)?.output else {
        print("skipping \(card)")
        continue
    }
    let matchingCount = Set(given).intersection(winning).count
    numbersOfMatches.append(matchingCount)
}
let NumberOfCardTypes = numbersOfMatches.count
var numberOfCopies = Array<Int>(repeating: 1, count: NumberOfCardTypes)
var sum = 0
for i in 0..<NumberOfCardTypes {
    if numbersOfMatches[i] > 0 {
        for j in 1...numbersOfMatches[i] {
            numberOfCopies[i+j] += numberOfCopies[i]
        }
    }
    sum += numberOfCopies[i]
    print(i, numberOfCopies[i])
}
print(sum)