import Foundation
import RegexBuilder

func parseIntArray(_ s: Substring) -> [Int] {
    // print("parsing ints in \(s)...")
    var answer: [Int] = []
    for match in s.matches(of: #/\d+/#) {
        answer.append(Int(match.output)!)
    }
    return answer
}

let data = try! String(contentsOfFile: "4.input")
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

func score(_ winningCount: Int) -> Int {
    if winningCount <= 1 {
        return winningCount
    }
    var x = 1
    for _ in 1..<winningCount {
        x *= 2
    }
    return x
}

var ans = 0
for card in data.components(separatedBy: "\n") {
    guard let (_, winning, given) = card.firstMatch(of: cardRegex)?.output else {
        print("skipping \(card)")
        continue
    }
    let winningCount = Set(given).intersection(winning).count
    // print(winningCount)
    ans += score(winningCount)
}
print(ans)