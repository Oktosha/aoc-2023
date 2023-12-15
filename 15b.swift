import Foundation

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
let data = rawData.trimmingCharacters(in: .newlines)

func hash(_ s: String) -> Int {
    var ans = 0
    for ch in s {
        ans += Int(exactly:ch.asciiValue!)!
        ans *= 17
        ans %= 256
    }
    return ans
}

struct Lens {
    var label: String
    var focalLength: Int
}
var boxes = Array(repeating: [Lens](), count: 256)

for instruction in data.components(separatedBy: ",") {
    if instruction.contains("-") {
        let label = String(instruction.dropLast())
        let boxId = hash(label)
        boxes[boxId] = boxes[boxId].filter{$0.label != label}
    } else {
        assert(instruction.contains("="))
        let label = String(instruction.wholeMatch(of: #/([a-z]+)=(\d+)/#)!.output.1)
        let focalLength = Int(instruction.wholeMatch(of: #/([a-z]+)=(\d+)/#)!.output.2)!
        let lens = Lens(label: label, focalLength: focalLength)
        let boxId = hash(label)
        if let existingLensIndex = boxes[boxId].firstIndex(where: {$0.label == label}) {
            boxes[boxId][existingLensIndex].focalLength = lens.focalLength
        } else {
            boxes[boxId].append(lens)
        }        
    }
    print("After '\(instruction)'")
    for i in 0..<boxes.count {
        if !boxes[i].isEmpty {
            print("Box \(i):", terminator: "")
            for lens in boxes[i] {
                print(" [\(lens.label) \(lens.focalLength)]", terminator: "")
            }
            print()
        }
    }
    print()
}

var ans = 0
for i in 0..<boxes.count {
    for j in 0..<boxes[i].count {
        ans += (i + 1) * (j + 1) * boxes[i][j].focalLength
    }
}
print("answer:", ans)