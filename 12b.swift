import Foundation

func canFit(at start: Int, len: Int, pattern: String) -> Bool {
    if start + len > pattern.count {
        return false
    }
    let patternArr = Array(pattern)
    let before = patternArr[0..<start]
    if before.contains("#") {
        return false
    }
    let middle = patternArr[start..<(start + len)]
    if middle.contains(".") {
        return false
    }
    if patternArr[start + len] == "#" {
        return false
    }
    return true
}

func waysToFitOneNum(num: Int, pattern: String) -> Int {
    // print("calculating ways to fit \(num) into \(pattern)")
    var ans = 0
    let patternArr = Array(pattern)
    for start in 0...(patternArr.count - num) {
        let before = patternArr[0..<start]
        let middle = patternArr[start..<(start + num)]
        let after = patternArr[(start + num)..<patternArr.count]
        if !before.contains("#") && !after.contains("#") && !middle.contains(".") {
            ans += 1;
        }
    }
    return ans
}



func fit(_ nums: [Int], into pattern: String) -> Int {
    // print("fitting \(nums) into \(pattern)")
    if nums.isEmpty {
        if pattern.contains("#") {
            return 0
        } else {
            return 1
        }
    }
    let minimalRequiredWidth = nums.reduce(0, +) + nums.count - 1
    if pattern.count < minimalRequiredWidth {
        return 0
    }
    let currentNum = nums.first!
    let restNums = nums.dropFirst()
    if restNums.isEmpty {
        return waysToFitOneNum(num: currentNum, pattern: pattern)
    }
    var ans = 0
    for currentNumStart in 0..<(pattern.count - currentNum - 1) {
        if canFit(at: currentNumStart, len: currentNum, pattern: pattern) {
            ans += fit(Array(restNums), into: String(pattern.dropFirst(currentNumStart + currentNum + 1)))
        }
    }
    return ans
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
let recordRegex = #/(?<s>[#\.\?]+) (?<nums>(\d+,)+\d+)\n/#

var ans = 0
for match in rawData.matches(of: recordRegex) {
    let s = match.output.s
    let nums = match.output.nums.components(separatedBy: ",").map{Int($0)!}

    let unfoldedS = Array(repeating: s, count: 5).joined(separator: "?")
    let unfoldedNums = Array(repeating: nums, count: 5).flatMap{$0}
    print("calculating for \(unfoldedS) \(unfoldedNums)")
    let currentAns = fit(unfoldedNums, into: unfoldedS)
    print(s, nums, "->", currentAns)
    ans += currentAns
}
print("answer:", ans)