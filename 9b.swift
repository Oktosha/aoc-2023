import Foundation
import RegexBuilder

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)

func parseIntArray(_ s: String) -> [Int] {
    var answer: [Int] = []
    for match in s.matches(of: #/\-?\d+/#) {
        answer.append(Int(match.output)!)
    }
    return answer
}

func getNextSeqItem(seq: [Int])->Int {
    var seqs = [seq]
    while !seqs.last!.allSatisfy({$0 == 0}) {
        var nextLvl = [Int]()
        for i in 1..<seqs.last!.count {
            nextLvl.append(seqs.last![i] - seqs.last![i - 1])
        }
        seqs.append(nextLvl)
    }
    var i = seqs.count - 2
    while i >= 0 {
        seqs[i].insert(seqs[i].first! - seqs[i + 1].first!, at: 0)
        i -= 1
    }
    return seqs[0].first!
}

var sequences = [[Int]]()
for m in rawData.components(separatedBy: "\n") {
    if m.contains(#/\d+/#) {
        sequences.append(parseIntArray(m))
    }
}
let answers = sequences.map{getNextSeqItem(seq: $0)}
// print(answers)
let ans = answers.reduce(0, +)
print("answer:", ans)