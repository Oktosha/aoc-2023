import Foundation

enum PulseFrequency {
    case high
    case low
}

struct Pulse {
    var source: String
    var target: String
    var freq: PulseFrequency
}

enum Module {
    case broadcaster(outputs: [String])
    case conjunction(inputs: Dictionary<String, PulseFrequency>, outputs: [String])
    case flipflop(isOn: Bool, outputs: [String])
    mutating func setInput(input: String, freq: PulseFrequency) {
        switch self {
            case .conjunction(var inputs, let outputs):
                inputs[input] = freq
                self = .conjunction(inputs: inputs, outputs: outputs)
            default:
                break
        }
    }

    mutating func receive(pulse: Pulse) -> [Pulse] {
        self.setInput(input: pulse.source, freq: pulse.freq)
        switch self {
            case let .broadcaster(outputs):
                return outputs.map{Pulse(source: pulse.target, target: $0, freq: pulse.freq)}
            case let .flipflop(isOn, outputs):
                switch pulse.freq {
                    case .high:
                        return []
                    case .low:
                        switch isOn {
                            case false:
                                self = .flipflop(isOn: true, outputs: outputs)
                                return outputs.map{Pulse(source: pulse.target, target: $0, freq: .high)}
                            case true:
                                self = .flipflop(isOn: false, outputs: outputs)
                                return outputs.map{Pulse(source: pulse.target, target: $0, freq: .low)}
                        }
                }
            case let .conjunction(inputs, outputs):
                let outputFreq: PulseFrequency
                if inputs.values.allSatisfy({$0 == .high}) {
                    outputFreq = .low
                } else {
                    outputFreq = .high
                }
                return outputs.map{Pulse(source: pulse.target, target: $0, freq: outputFreq)}
        }
    }
}

func parseModules(rawData: String) -> Dictionary<String, Module> {
    var modules = Dictionary<String, Module>()
    let moduleRegex = #/([\&\%]?)([a-z]+) -> ([^\n]+)\n/#
    for match in rawData.matches(of: moduleRegex) {
        let (_, typeMatch, nameMatch, outputsMatch) = match.output
        let outputs = outputsMatch.components(separatedBy: ", ")
        let name = String(nameMatch)
        if (typeMatch == "") {
            modules[name] = .broadcaster(outputs: outputs)
        } else if (typeMatch == "%") {
            modules[name] = .flipflop(isOn: false, outputs: outputs)
        } else if (typeMatch == "&") {
            modules[name] = .conjunction(inputs: [String:PulseFrequency](), outputs: outputs)
        } else {
            print("unknown module type \(typeMatch)")
        }
    }
    for (name, module) in modules {
        switch module {
            case let .broadcaster(outputs):
                fallthrough
            case let .conjunction(_, outputs):
                fallthrough
            case let .flipflop(_, outputs):
                for output in outputs {
                    modules[output]?.setInput(input: name, freq: .low)
                }
        }
    }
    return modules
}

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)
var modules = parseModules(rawData: rawData)
print(modules)
var nLow = 0
var nHigh = 0
for _ in 1...1000 {
    var q = [Pulse(source: "button", target: "broadcaster", freq: .low)]
    while !q.isEmpty {
        let pulse = q.remove(at: 0)
        if pulse.freq == .high {
            nHigh += 1
        } else {
            nLow += 1
        }
        print(pulse)
        q.append(contentsOf: modules[pulse.target]?.receive(pulse: pulse) ?? [])
    }
}
print(nHigh * nLow)
