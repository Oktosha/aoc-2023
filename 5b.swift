// Work in progress for day 5 part 2
// Run from the command line as follows:
// $ swift 5b.swift 5.example
// ...[some debug data]...
// answer: ???

import Foundation
import RegexBuilder

struct ValueRange {
    let start: Int
    let length: Int
}

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

func parseValueRangeArray(_ s: Substring) -> [ValueRange] {
    var answer: [ValueRange] = []
    for match in s.matches(of: #/(\d+) (\d+)/#) {
        answer.append(ValueRange(start:Int(String(match.output.1))!, length:Int(String(match.output.2))!))
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
    , transform: parseValueRangeArray)
    "\n"
    Capture (
        OneOrMore {
            "\n"
            mapRegex
    }, transform: parseMaps)
}

func performMap(sources: inout [ValueRange], with mapping: AlmanacRange) -> [ValueRange]
{
    var newValues: [ValueRange] = []
    var unaffectedValues: [ValueRange] = []
    for source in sources {
        // no mapping
        if (source.start + source.length < mapping.sourceStart 
        || source.start >= mapping.sourceStart + mapping.length) {
            unaffectedValues.append(source)
            continue
        }
        let diff = mapping.destinationStart - mapping.sourceStart
        // whole range mapped
        if (source.start >= mapping.sourceStart 
        && source.start + source.length <= mapping.sourceStart + mapping.length) {
            newValues.append(ValueRange(start: source.start + diff, length: source.length))
            continue
        }
        // mapped values in the middle
        if (source.start < mapping.sourceStart
        && source.start + source.length > mapping.sourceStart + mapping.length) {
            let leftRemaining = ValueRange(start: source.start, length: mapping.sourceStart - source.start)
            let rightRemaining = ValueRange(start: mapping.sourceStart + mapping.length, 
                length: source.start + source.length - mapping.sourceStart - mapping.length)
            newValues.append(ValueRange(start: mapping.destinationStart, length: mapping.length))
            unaffectedValues.append(contentsOf: [leftRemaining, rightRemaining])
            continue
        }
        // mapped values in the beginning
        if (source.start >= mapping.sourceStart 
        && source.start + source.length > mapping.sourceStart + mapping.length) {
            let rightRemaining = ValueRange(start: mapping.sourceStart + mapping.length, 
                length: source.start + source.length - mapping.sourceStart - mapping.length)
            newValues.append(ValueRange(start: mapping.destinationStart, length: mapping.length))
            unaffectedValues.append(rightRemaining)
            continue
        }
        // mapped values in the end
        if (source.start < mapping.sourceStart
        && source.start + source.length <= mapping.sourceStart + mapping.length) {
            let leftRemaining = ValueRange(start: source.start, length: mapping.sourceStart - source.start)
            newValues.append(ValueRange(start: mapping.destinationStart, length: source.start + source.length - mapping.sourceStart))
            unaffectedValues.append(leftRemaining)
            continue
        }
        print("something went wrong with source \(source) and mapping \(mapping)")
    }
    sources = unaffectedValues
    return newValues
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
let parsedData = rawData.firstMatch(of: dataRegex)!.output
var values = parsedData.1
var maps = parsedData.2
for map in maps {
    var newValues: [ValueRange] = []
    for value in values {
        var sourceValues = [value]
        for mapping in map.ranges {
            newValues.append(contentsOf: performMap(sources: &sourceValues, with: mapping))
        }
        newValues.append(contentsOf: sourceValues)
    }
    values = newValues
    print(values)
}
print(values.min(by: {$0.start < $1.start})!.start)