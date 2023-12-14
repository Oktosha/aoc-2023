import Foundation

func areSame(col1: Int, col2: Int, in pattern2D: [[Character]]) -> Bool {
    for i in 0..<pattern2D.count {
        if pattern2D[i][col1] != pattern2D[i][col2] {
            return false
        }
    }
    return true
}

func getVerticalLinesOfReflection(_ pattern2D: [[Character]])->[Int] {
    var ans = [Int]()
    let width = pattern2D[0].count
    outer: for nColsBeforeReflection in 1..<width {
        var image = nColsBeforeReflection - 1
        var reflection = nColsBeforeReflection
        while image >= 0 && reflection < width {
            if !areSame(col1: image, col2: reflection, in: pattern2D) {
                continue outer
            }
            image -= 1
            reflection += 1
        }
        ans.append(nColsBeforeReflection)
    }
    return ans
}

func getHorizontalLinesOfReflection(_ pattern2D: [[Character]])->[Int] {
    var ans = [Int]()
    let height = pattern2D.count
    outer: for nRowsBeforeReflection in 1..<height {
        var image = nRowsBeforeReflection - 1
        var reflection = nRowsBeforeReflection
        while image >= 0 && reflection < height {
            if pattern2D[image] != pattern2D[reflection] {
                continue outer
            }
            image -= 1
            reflection += 1
        }
        ans.append(nRowsBeforeReflection)
    }
    return ans
}

enum ReflectionLineType {
    case Vertical
    case Horizontal
}

struct ReflectionLine : Equatable {
    let type: ReflectionLineType
    let x: Int
}

func getReflections(pattern2D: [[Character]])->[ReflectionLine] {
    var ans = [ReflectionLine]()
    let verticalLines = getVerticalLinesOfReflection(pattern2D)
    for line in verticalLines {
        ans.append(ReflectionLine(type: .Vertical, x: line))
    }
    let horizontalLines = getHorizontalLinesOfReflection(pattern2D)
    for line in horizontalLines {
        ans.append(ReflectionLine(type: .Horizontal, x: line))
    }
    return ans
}

func invert(_ ch: Character) -> Character {
    if ch == "." {
        return "#"
    } else if ch == "#" {
        return "."
    }
    print("Inverting impossible symbol \(ch)")
    assert(false)
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)

var ans = 0
outerest: for pattern in rawData.components(separatedBy: "\n\n") {
    let pattern2D = pattern.components(separatedBy: "\n").filter({!$0.isEmpty}).map{Array($0)}
    print("==pattern==")
    for line in pattern2D {
        print(line)
    }
    print("==end pattern==")
    let initialReflection = getReflections(pattern2D: pattern2D).first!
    print("Initial reflection:  \(initialReflection.type == .Vertical ? "|" : "-") = \(initialReflection.x)")
    for row in 0..<pattern2D.count {
        for col in 0..<pattern2D[row].count {
            var desmudgedPattern = pattern2D
            desmudgedPattern[row][col] = invert(desmudgedPattern[row][col])
            // for line in desmudgedPattern {
            //     for ch in line {
            //         print(ch, terminator: "")
            //     }
            //     print()
            // }
            let newReflections = getReflections(pattern2D: desmudgedPattern).filter{$0 != initialReflection}
            if !newReflections.isEmpty {
                let reflection = newReflections.first!
                print("Smudge at \(row) \(col)")
                print("New reflection line \(reflection.type == .Vertical ? "|" : "-") = \(reflection.x)")
                if reflection.type == .Vertical {
                    ans += reflection.x
                } else {
                    ans += reflection.x * 100
                }
                continue outerest
            }
        }
    }
}

print("answer:", ans)
