// Autocorrect algorithm implementation in Swift

import Foundation

extension Character {
    
    func neighbours() -> [Character] {
        let layout: [Character] = ["|", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "|", "a", "s", "d", "f", "g", "h", "j", "k", "l", "|", "z", "x", "c", "v", "b", "n", "m", "|"]
        
        guard layout.contains(self) else { return [] }
        
        let prev = layout[layout.index(of: self)! - 1]
        let next = layout[layout.index(of: self)! + 1]
        
        let neighbours = [prev, next]
        
        return neighbours.filter({ return $0 != "|" })
    }
}

extension String {
    
    func isBigger(than other: String) -> Bool {
        return self.characters.count > other.characters.count
    }
    
    func prefixMatchRate(to word: String) -> Double {
        var rate: Double = 0
        let first, second: String
        
        if word.isBigger(than: self) {
            first = self
            second = word
        } else {
            first = word
            second = self
        }
        
        for i in first.indices {
            let firstChar = first[i]
            let secondChar = second[i]
            
            if firstChar == secondChar {
                rate += 1
            } else {
                break
            }
        }
        
        return rate / Double(self.characters.count)
    }
    
    func suffixMatchRate(to word: String) -> Double {
        let first = String(self.reversed())
        let second = String(word.reversed())
        
        return first.prefixMatchRate(to: second)
    }
    
    func matchRate(to word: String) -> Double {
        let matchingCharacters = self.characters.filter({ word.characters.contains($0) })
        let nonMatchingCharacters = self.characters.filter({ !word.characters.contains($0) })
        let diff = abs(self.characters.count - word.characters.count)
        
        return Double(matchingCharacters.count - nonMatchingCharacters.count - diff) / Double(self.characters.count)
    }
    
    func averageMatchRate(to word: String) -> Double {
        let prefixMatch = self.prefixMatchRate(to: word)
        let suffixMatch = self.suffixMatchRate(to: word)
        let allMatch = self.matchRate(to: word)
        
        return (prefixMatch * 0.45) + (suffixMatch * 0.45) + (allMatch * 0.1)
    }
    
    func isPossibleMatch(to word: String) -> Bool {
        return averageMatchRate(to: word) >= 0.05
    }
}

class AutoCorrector {
    
    let seed: [String]
    
    init(seed: [String]) {
        self.seed = seed
    }
    
    func correct(word input: String, printScores: Bool = false) -> String {
        var results = [String: Int]()
        let availableWords = seed.filter { (word) -> Bool in
            return word.isPossibleMatch(to: input)
        }
        
        for word in availableWords {
            let characters = word.characters
            results[word] = 0
            
            // Simple count of matches/possible matches w/ neighbours. Misses detract 1
            for i in input.characters.indices {
                if characters.indices.contains(i) {
                    let inputChar = input.characters[i]
                    let wordChar = characters[i]
                    
                    if inputChar == wordChar || inputChar.neighbours().contains(wordChar) {
                        results[word]! += 1
                    } else {
                        results[word]! -= 1
                    }
                } else {
                    results[word]! -= 1
                }
                
            }

            // Now in reverse
            let reversedCharacters = word.reversed()
            let reversedInput = input.reversed()
            
            for i in reversedInput.indices {
                if reversedCharacters.indices.contains(i) {
                    let inputChar = reversedInput[i]
                    let wordChar = reversedCharacters[i]

                    if inputChar == wordChar || inputChar.neighbours().contains(wordChar) {
                        results[word]! += 1
                    } else {
                        results[word]! -= 1
                    }
                } else {
                    results[word]! -= 1
                }
            }

            // Add the average match rate (prefix + suffix + overall characters)
            results[word]! += Int(round(input.averageMatchRate(to: word) * 100.0))
        }
        
        let sortedResults = results.sorted(by: { first, second in
            let diff1 = abs(first.key.characters.count - input.characters.count)
            let diff2 = abs(second.key.characters.count - input.characters.count)
            
            return first.value == second.value ? diff1 < diff2 : first.value > second.value
        }).filter({ $0.value > 0 }).prefix(3)
        
        let corrected = sortedResults.first?.key ?? input
        
        if printScores {
            var str = "\(input) -> \(corrected)"
            
            sortedResults.forEach { (result) in
                str += " | \(result.key): \(result.value) @ \(input.averageMatchRate(to: result.key) * 100.0)%"
            }
            
            print(str)
        }
        
        return corrected
    }
    
}

let words = [
    "definitely",
    "apparently",
    "weird",
    "chauffeur",
    "camaraderie",
    "completely",
    "dilemma",
    "ecstasy",
    "fahrenheit",
    "foreseeable",
    "indubitably",
    "fluorescent",
    "sacrilegious",
    "incidentally",
    "pharaoh",
    "referred",
    "prefer",
    "bellwether",
    "conscientious",
    "daiquiri",
    "dumbbell",
    "guarantee",
    "inoculate",
    "leisure",
    "liaison",
    "millennium",
    "misspelt",
    "playwright",
    "precede",
    "publicly",
    "questionnaire",
    "superseed",
    "threshold"
]

let inputs = [
    "definately",
    "definatly",
    "definantly",
    "definetly",
    "aparantly",
    "apparantly",
    "aperently",
    "wierd",
    "chaufer",
    "chauffur",
    "camaradirie",
    "cameradirie",
    "complitely",
    "completily",
    "dilema",
    "dillema",
    "extasy",
    "fareneit",
    "fahrenhait",
    "forseeable",
    "forseable",
    "foreseable",
    "indubitabely",
    "indubetabely",
    "fluroescent",
    "sacrilidgeous",
    "incidentaly",
    "incedentally",
    "pharoah",
    "refered",
    "reffered",
    "prefferr",
    "belweather",
    "contientious",
    "daikiri",
    "dumbel",
    "dummbel",
    "dumbell",
    "garantee",
    "innoculate",
    "laisure",
    "laison",
    "milenium",
    "mispelt",
    "playright",
    "preceede",
    "preceed",
    "publicaly",
    "questionair",
    "supersede",
    "trashold"
]

let autocorrector = AutoCorrector(seed: words)

for input in inputs {
    autocorrector.correct(word: input, printScores: true)
//    print("\(input) -> \(autocorrector.correct(word: input))")
}

