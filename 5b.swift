// Solves day 5 part 2
// Run from the command line as follows:
// $ swift 5b.swift 5.example
// ...[some debug data]...
// answer: 46

import Foundation
import RegexBuilder

struct ValueRange {
    var start: Int
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

func aIsStrictlyInsideB(a: ValueRange, b: ValueRange) -> Bool
{
    return a.start >= b.start && a.start + a.length <= b.start + b.length
}

func aIsStrictlyOutsideB(a: ValueRange, b: ValueRange) -> Bool
{
    return ((a.length + a.start - 1 < b.start)
        || (a.start > b.start + b.length - 1))
}

enum RangeEventType {
    case rangeStart
    case rangeEnd // this point is excluded
    case knife
}

struct RangeEvent {
    let x: Int
    let type: RangeEventType
}

func cut(_ range: ValueRange, with knife: ValueRange) -> [ValueRange]
{
    if (aIsStrictlyInsideB(a: range, b: knife) 
    || aIsStrictlyOutsideB(a: range, b: knife)) {
        return [range]
    }
    var ans:[ValueRange] = []
    var events = [
        RangeEvent(x: range.start, type: .rangeStart),
        RangeEvent(x: range.start + range.length, type: .rangeEnd),
        RangeEvent(x: knife.start, type: .knife),
        RangeEvent(x: knife.start + knife.length, type: .knife)
    ]
    events.sort(by: {$0.x < $1.x })
    var latestStart = -1
    var balance = 0
    for event in events {
        if event.type == .rangeStart {
            balance += 1
            latestStart = event.x
        } else if event.type == .rangeEnd {
            let length = event.x - latestStart
            if (length > 0) {
                ans.append(ValueRange(start: latestStart, length: event.x - latestStart))
            }
            balance -= 1
        } else if event.type == .knife && balance > 0 {
            let length = event.x - latestStart
            if (length > 0)
            {
                ans.append(ValueRange(start: latestStart, length: event.x - latestStart))
                latestStart = event.x
            }
        }
    }
    return ans
}

func chop(_ ranges: [ValueRange], with knife: ValueRange) -> [ValueRange] {
    var ans: [ValueRange] = []
    for range in ranges {
        ans.append(contentsOf: cut(range, with: knife))
    }
    return ans
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
let parsedData = rawData.firstMatch(of: dataRegex)!.output
var values = parsedData.1
var maps = parsedData.2
for map in maps {
    for mappingRange in map.ranges {
        values = chop(values, with: ValueRange(start: mappingRange.sourceStart, length:mappingRange.length))
    }
    print(values)
    for i in 0..<values.count {
        for mappingRange in map.ranges {
            if aIsStrictlyInsideB(a: values[i], b: ValueRange(start: mappingRange.sourceStart, length: mappingRange.length)) {
                values[i].start = values[i].start - mappingRange.sourceStart + mappingRange.destinationStart
                break
            }
        }    
    }
    
}
print("answer:", values.min(by: {$0.start < $1.start})!.start)