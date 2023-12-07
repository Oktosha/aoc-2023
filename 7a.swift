// Solves Day 7 part 1
// Run from the command line as follows:
// $ swift 7a.swift 7.example
// answer: 6440

import Foundation
import RegexBuilder

let dataFile = CommandLine.arguments[1]
let rawData = try! String(contentsOfFile: dataFile)

struct HandWithBid {
    let hand: String
    let bid: Int
}

let handWithBidRegex = #/(?<hand>\S{5}) (?<bid>\d+)/#
var a: [HandWithBid] = []
for match in rawData.matches(of: handWithBidRegex) {
    a.append(HandWithBid(hand: String(match.output.hand), bid: Int(match.output.bid)!))
}

enum CamelHandType: Int {
    case FiveOfAKind = 0
    case FourOfAKind
    case FullHouse
    case ThreeOfAKind
    case TwoPair
    case OnePair
    case HighCard
}

let cardLiterals = "AKQJT98765432"

func getHandType(_ hand: String) -> CamelHandType {
    var counts: [Int] = []
    for card in cardLiterals {
        counts.append(hand.filter{$0==card}.count)
    }
    counts = counts.sorted().reversed()
    if (counts[0] == 5) {
        return .FiveOfAKind
    } else if (counts[0] == 4) {
        return .FourOfAKind
    } else if (counts[0] == 3 && counts[1] == 2) {
        return .FullHouse
    } else if (counts[0] == 3) {
        return .ThreeOfAKind
    } else if (counts[0] == 2 && counts[1] == 2) {
        return .TwoPair
    } else if (counts[0] == 2) {
        return .OnePair
    } else {
        return .HighCard
    }
}

func aIsWeaker(a: Character, b: Character) -> Bool {
    return cardLiterals.firstIndex(of: a)! > cardLiterals.firstIndex(of: b)!
}

func aIsWeaker(a: CamelHandType, b: CamelHandType) -> Bool {
    return a.rawValue > b.rawValue
}

func aIsWeaker(a: HandWithBid, b: HandWithBid) -> Bool {
    let aHandType = getHandType(a.hand)
    let bHandType = getHandType(b.hand)
    if aIsWeaker(a: aHandType, b: bHandType) {
        return true
    }
    if aIsWeaker(a: bHandType, b: aHandType) {
        return false
    }
    let arr = Array(a.hand)
    let brr = Array(b.hand)
    for i in 0..<5 {
        if aIsWeaker(a: arr[i], b: brr[i]) {
            return true
        }
        if aIsWeaker(a: brr[i], b: arr[i]) {
            return false
        }
    }
    return false
}

a.sort(by:aIsWeaker)
var ans = 0
var rnk = 1
for handWithBid in a {
    print(
        "rank: ", String(format: "%4d", rnk), 
        "hand:", handWithBid.hand,
        "handType:", getHandType(handWithBid.hand).rawValue,
        "bid:", handWithBid.bid)
    ans += handWithBid.bid * rnk
    rnk += 1
    
}
print("answer:", ans)