import Foundation

struct CategoryRange {
    var l: Int // inclusive
    var r: Int // inclusive
    var count: Int {
        return r - l + 1
    }
}

enum CriterionType: String {
    case isGreater = ">"
    case isLess = "<"
}

struct Criterion {
    var type: CriterionType
    var category: String
    var threshold: Int
}

struct Rule {
    var criterion: Criterion?
    var target: String
}

struct PositionInWorkflow {
    var name: String
    var n: Int 
}

struct PositionedBatch {
    var pos: PositionInWorkflow
    var batch: Dictionary<String, CategoryRange>
}

func parseWorkflows(rawData: String) -> Dictionary<String, [Rule]> {
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
                workflows[name]?.append(Rule(
                    criterion: Criterion(type: CriterionType(rawValue: String(sign))!, category:String(category), threshold: Int(num)!), 
                    target: String(target)))
            } else {
                workflows[name]?.append(Rule(criterion: nil, target: ruleString))
            }
        }
    }
    return workflows
}

// first output is batch of parts accepted by rule, second output is rejected batch
func split(batch: Dictionary<String, CategoryRange>, by criterion: Criterion?)
    -> (Dictionary<String, CategoryRange>?, Dictionary<String, CategoryRange>?) {
        guard let criterion = criterion else {
            return (batch, nil)
        }
        if criterion.type == .isLess {
            if criterion.threshold <= batch[criterion.category]!.l {
                return (nil, batch)
            }
            if criterion.threshold > batch[criterion.category]!.r {
                return (batch, nil)
            }
            var accepted = batch
            accepted[criterion.category]!.r = criterion.threshold - 1
            var rejected = batch
            rejected[criterion.category]!.l = criterion.threshold
            return (accepted, rejected)
        } else {
            if criterion.threshold >= batch[criterion.category]!.r {
                return (nil, batch)
            }
            if criterion.threshold < batch[criterion.category]!.l {
                return (batch, nil)
            }
            var accepted = batch
            accepted[criterion.category]!.l = criterion.threshold + 1
            var rejected = batch
            rejected[criterion.category]!.r = criterion.threshold
            return (accepted, rejected)
        }
        
}

func countParts(batch: Dictionary<String, CategoryRange>) -> Int {
    return batch["x"]!.count * batch["m"]!.count * batch["a"]!.count * batch["s"]!.count
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile).trimmingCharacters(in: .newlines)
let workflows = parseWorkflows(rawData: rawData)

var queue = [PositionedBatch(
    pos: PositionInWorkflow(name: "in", n: 0),
    batch: [
        "x": CategoryRange(l: 1, r: 4000),
        "m": CategoryRange(l: 1, r: 4000), 
        "a": CategoryRange(l: 1, r: 4000), 
        "s": CategoryRange(l: 1, r: 4000) 
        ])]

var ans = 0
while !queue.isEmpty {
    let e = queue.popLast()!
    let rule = workflows[e.pos.name]![e.pos.n]
    let (accepted, rejected) = split(batch: e.batch, by: rule.criterion)
    if let accepted = accepted {
        if rule.target == "A" {
            ans += countParts(batch: accepted)
        }
        if rule.target != "R" && rule.target != "A" {
            queue.append(PositionedBatch(
                pos: PositionInWorkflow(name: rule.target, n: 0),
                batch: accepted))
        }  
    }
    if let rejected = rejected {
        queue.append(PositionedBatch(
                pos: PositionInWorkflow(name: e.pos.name, n: e.pos.n + 1),
                batch: rejected))
    }
}

print("answer:", ans)