import Foundation

struct Rule {
    var target: String
    var rule: Optional<(Dictionary<String, Int>) -> Bool>
}

func parseWorkflows(rawData: String) -> [String: [Rule]] {
    let workflowRegex = #/(?<name>[a-z]+)\{(?<rules>[^}]+)\}/#
    var workflows = Dictionary<String, [Rule]>()
    for match in rawData.matches(of: workflowRegex) {
        let name = String(match.output.name)
        workflows[name] = []
        let ruleStrings = match.output.rules
        for ruleString in ruleStrings.components(separatedBy: ",") {
            if (ruleString.contains(":")) {
                let ruleRegex = #/([xmas])([<>])(\d+):([a-zAR]+)/#
                let (_, category, sign, num, target) = ruleString.wholeMatch(of: ruleRegex)!.output
                if sign == "<" {
                    workflows[name]?.append(Rule(target: String(target)) {$0[String(category)]! < Int(num)!})
                } else {
                    workflows[name]?.append(Rule(target: String(target)) {$0[String(category)]! > Int(num)!})
                }
            } else {
                workflows[name]?.append(Rule(target: ruleString, rule: nil))
            }
        }
    }
    return workflows
}

func parseParts(rawData: String) -> [Dictionary<String, Int>] {
    let partRegex = #/\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}/#
    var parts = [Dictionary<String, Int>]()
    for match in rawData.matches(of: partRegex) {
        let (_, x, m, a, s) = match.output
        parts.append(["x": Int(x)!, "m": Int(m)!, "a": Int(a)!, "s": Int(s)!])
    }
    return parts
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile).trimmingCharacters(in: .newlines)

let parts = parseParts(rawData: rawData)
let workflows = parseWorkflows(rawData: rawData)

var ans = 0

for part in parts {
    print(part)
    var res = "in"
    print(res, terminator: "")
    while res != "A" && res != "R" {
        print(" ->", res, terminator: "")
        let rules = workflows[res]!
        for e in rules {
            if let rule = e.rule {
                if rule(part) {
                    res = e.target
                    break
                }
            } else {
                res = e.target
            }
        }
    }
    print(" ->", res)
    if res == "A" {
        ans += part["x"]! + part["m"]! + part["a"]! + part["s"]!
    }
}

print("answer:", ans)