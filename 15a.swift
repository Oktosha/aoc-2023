import Foundation

func hash(_ s: String) -> Int {
    var ans = 0
    for ch in s {
        ans += Int(exactly:ch.asciiValue!)!
        ans *= 17
        ans %= 256
    }
    return ans
}
let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
let data = rawData.trimmingCharacters(in: .newlines)
var ans = 0
for instruction in data.components(separatedBy: ",") {
    let hashValue = hash(instruction)
    print("'\(instruction)' -> \(hashValue)")
    ans += hashValue
}
print("answer:", ans)