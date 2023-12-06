// Solves Day 5 part 1
// Run from the command line as follows:
// $ swift 5a.swift 5.example
// answer: 35

import Foundation
import RegexBuilder

struct AlmanacRange {
    let destinationStart: Int
    let sourceStart: Int
    let length: Int
}

struct AlmanacMap {
    let from: String
    let to: String
    let ranges: [AlmanacRange]
}

let rangeRegex = Regex {
    Capture {
        #/\d+/#
    }
    " "
    Capture {
        #/\d+/#
    }
    " "
    Capture {
        #/\d+/#
    }
    "\n"
}

let mapRegex = Regex {
    Capture {
        #/[a-z]+/#
    }
    "-to-"
    Capture {
        #/[a-z]+/#
    }
    " map:\n"
    Capture {
        OneOrMore(rangeRegex)
    }
}

func parseIntArray(_ s: Substring) -> [Int] {
    // print("parsing ints in \(s)...")
    var answer: [Int] = []
    for match in s.matches(of: #/\d+/#) {
        answer.append(Int(match.output)!)
    }
    return answer
}

func parseMaps(_ s: Substring) -> [AlmanacMap] {
    var answer: [AlmanacMap] = []
    for match in s.matches(of: mapRegex) {
        let from = String(match.output.1)
        let to = String(match.output.2)
        var ranges: [AlmanacRange] = []
        let rangesStr = String(match.output.3)
        for rangeStrMatch in rangesStr.matches(of: rangeRegex) {
            let rangeMatchOutput = rangeStrMatch.output
            ranges.append(AlmanacRange(
                destinationStart: Int(rangeMatchOutput.1)!, 
                sourceStart: Int(rangeMatchOutput.2)!,
                length: Int(rangeMatchOutput.3)!))
        }
        answer.append(AlmanacMap(from: from, to: to, ranges: ranges))
    }
    return answer
}

let dataRegex = Regex {
    "seeds:"
    Capture(
        OneOrMore(#/ \d+/#)
    , transform: parseIntArray)
    "\n"
    Capture (
        OneOrMore {
            "\n"
            mapRegex
    }, transform: parseMaps)
}

func performMap(value: inout Int, with map: AlmanacMap)
{
    for range in map.ranges {
        if value >= range.sourceStart && value < range.sourceStart + range.length {
            let diff = value - range.sourceStart
            value = range.destinationStart + diff
            break
        }
    }
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
let parsedData = rawData.firstMatch(of: dataRegex)!.output
var values = parsedData.1
let maps = parsedData.2
for map in maps {
    for i in 0..<values.count {
        performMap(value: &values[i], with:map)
    }
}

print("answer:", values.min()!)
