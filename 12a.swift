import Foundation
import RegexBuilder

func generatePossible(prefix: String, pattern: String, possibilities: inout [String]) {
    assert(prefix.count <= pattern.count)
    if prefix.count == pattern.count {
        possibilities.append(prefix)
        return
    }
    let nextIndex = prefix.count
    let nextSymbol = Array(pattern)[nextIndex]
    if nextSymbol  == "." || nextSymbol  == "#" {
        generatePossible(prefix: prefix + String(nextSymbol), pattern: pattern, possibilities: &possibilities)
        return
    }
    if nextSymbol == "?" {
        generatePossible(prefix: prefix + ".", pattern: pattern, possibilities: &possibilities)   
        generatePossible(prefix: prefix + "#", pattern: pattern, possibilities: &possibilities)   
    }
}

func getNumArray(pattern: String) -> [Int] {
    return pattern.components(separatedBy: ".").filter {!$0.isEmpty}.map{$0.count}
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
let recordRegex = #/(?<s>[#\.\?]+) (?<nums>(\d+,)+\d+)\n/#

var ans = 0
for match in rawData.matches(of: recordRegex) {
    let s = match.output.s
    let nums = match.output.nums.components(separatedBy: ",").map{Int($0)!}

    var possibilities = [String]()
    generatePossible(prefix: "", pattern: String(s), possibilities: &possibilities)
    for variant in possibilities {
        if getNumArray(pattern: variant) == nums {
            ans += 1
        }
    }
}
print("answer:", ans)



