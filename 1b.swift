// Solves Day 1 part 2
// Run from the command line as follows:
// $ swift 1b.swift 1b.example
// ...[some debug data]...
// answer: 281

import Foundation

func parseNumber(_ num: Substring) -> Int {
    switch(num)
    {
    case "one":
        return 1
    case "two":
        return 2
    case "three":
        return 3
    case "four":
        return 4
    case "five":
        return 5
    case "six":
        return 6
    case "seven":
        return 7
    case "eight":
        return 8
    case "nine":
        return 9
    default:
        return Int(num)!
    }
}

func parseReversedNumber(_ num: Substring) -> Int {
    switch(num)
    {
    case "eno":
        return 1
    case "owt":
        return 2
    case "eerht":
        return 3
    case "ruof":
        return 4
    case "evif":
        return 5
    case "xis":
        return 6
    case "neves":
        return 7
    case "thgie":
        return 8
    case "enin":
        return 9
    default:
        return Int(num)!
    }
}

let dataFile = CommandLine.arguments[1]
let data = try! String(contentsOfFile: dataFile)
var overallSum = 0
let numregex = try! Regex(#"\d|one|two|three|four|five|six|seven|eight|nine"#)
let reversedNumregex = try! Regex(#"\d|eno|owt|eerht|ruof|evif|xis|neves|thgie|enin"#)
// let numregex = try! Regex(#"\d"#)
for line in data.components(separatedBy: "\n") {
    guard line.contains(numregex) else {
        print("ill line without numbers: \(line)")
        continue
    }
    let firstNumStr = line.firstMatch(of: numregex)!.0
    let lastNumStr = String(line.reversed()).firstMatch(of: reversedNumregex)!.0
    let lineSum = parseNumber(firstNumStr) * 10 + parseReversedNumber(lastNumStr)
    print("\(line): \(firstNumStr) --- \(lastNumStr) = \(lineSum)")
    overallSum += lineSum
}
print("answer:", overallSum)
