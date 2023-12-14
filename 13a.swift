import Foundation

func areSame(col1: Int, col2: Int, in pattern2D: [[Character]]) -> Bool {
    for i in 0..<pattern2D.count {
        if pattern2D[i][col1] != pattern2D[i][col2] {
            return false
        }
    }
    return true
}

func getVerticalLineOfReflection(_ pattern2D: [[Character]])->Int? {
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
        return nColsBeforeReflection
    }
    return nil
}

func getHorizontalLineOfReflection(_ pattern2D: [[Character]])->Int? {
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
        return nRowsBeforeReflection
    }
    return nil
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)

var ans = 0
for pattern in rawData.components(separatedBy: "\n\n") {
    let pattern2D = pattern.components(separatedBy: "\n").filter({!$0.isEmpty}).map{Array($0)}
    print("==pattern==")
    for line in pattern2D {
        print(line)
    }
    print("==end pattern==")
    let verticalLine = getVerticalLineOfReflection(pattern2D) ?? 0
    let horizontalLine = getHorizontalLineOfReflection(pattern2D) ?? 0
    print("Reflection lines: | = \(verticalLine); - = \(horizontalLine)")
    ans += verticalLine + horizontalLine * 100
}

print("answer:", ans)
