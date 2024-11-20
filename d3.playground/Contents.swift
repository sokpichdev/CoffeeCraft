// 20th, Nov, 2024
import SwiftUI
/* ----------------------------------------------------------------
            How To Check a Condition Is True or False?
-----------------------------------------------------------------*/
let score = 85
if score > 80 {
    print("Great Job!")
}

let speed = 88
let percentage = 85
var age = 18
if speed >= 88 {
    print("Where we're going, we don't need roads.")
}

if percentage < 85 {
    print("Sorry, you failed the test")
}

if age >= 18 {
    print("You're eligible to vote.")
}

let ourName = "Nomercy"
let friendName = "Deadshot"

if ourName < friendName {
    print("It's \(ourName) vs \(friendName).")
}

if ourName > friendName {
    print("It's \(friendName) vs \(ourName).")
}

var numbers = [1, 2, 4, 6]
numbers.append(8)

if numbers.count > 3 {
    numbers.remove(at: 0)
}
print(numbers)

let country = "Canada"
if country == "Cambodia" {
    print("Sur Sdey")
}

let name = "Taylor Swift"
if name != "Anonymous" {
    print("Welcome, \(name)")
}

var username = "taylorswift13" // now remove taylorswift13, what will happen?
if username == "" {
    username = "anonymous"
}
//if username.isEmpty { /*this works too.*/
//    username = "anonymous"
//}
//if username.count == 0 { /*this works too, but slow, since it has to go through all the string.*/
//    username = "anonymous"
//}
print("Welcome, \(username)")

// HOW DOES SWIFT LET US COMPARE MANY TYPES OF DATA?
let fn = "sok", ln = "pich"
let fa = 20, sa = 32
print(fn == ln) // false
print(fn != ln) // true
print(fn < ln) // false
print(fn >= ln) // true

print(fa == sa) // false
print(fa != sa) // true
print(fa < sa) // true
print(fa >= sa) // false

enum Sizes: Comparable {
    case small
    case medium
    case large
}
let first = Sizes.small
let second = Sizes.large
print(first < second) // true, because "small" comes before "large" in the enum case list.

/* ----------------------------------------------------------------
            How To Check Multiple Conditions?
-----------------------------------------------------------------*/
/*
1. What's the different between if and else if?
  -> you can have an many "else if" checks as you want, but you need exactly one "if" and either zero or one "else".
2. How to check multiple conditions? -> use && and ||.
*/

age = 20
if age >= 18 {
    print("You can vote in the next election. :)")
} else {
    print("Sorry, you're too young to vote. :(")
}

let temp = 25
//if temp > 20 {
//    if temp < 30 {
//        print("It's a nice day.")
//    }
//} bad code
if temp > 20 && temp < 30 {
    print("It's a nice day.")
}

let userAge = 14
let hasParentalConsent = true

if userAge >= 18 || hasParentalConsent == true {
    print("You can buy the game.")
}

// condition with enum
enum TransportOption {
    case airplane, helicoper, bicyle, car, escooter
}
let transport = TransportOption.airplane

if transport == .airplane || transport == .helicoper {
    print("Let's fly!")
} else if transport == .bicyle {
    print("I hope there's a bile path....")
} else if transport == .car {
    print("Time to get stuck in traffic.")
} else {
    print("I'm going to hire a scooter now!!")
}

/* ----------------------------------------------------------------
        How To Use Switch Statements to Check Multiple conditions
-----------------------------------------------------------------*/
/*When should you use switch statements rather that if?
 
 1. Exhaustiveness: switch ensures all possible cases are covered (via specific cases or a default case).
    if doesn’t have this requirement, so you might miss a case.
 
 2. Efficiency: switch reads the value only once, while if may check it multiple times.
    This matters for slow operations, like function calls.
 
 3. Pattern Matching: switch handles complex pattern matching more cleanly than if.
 
 4. Readability: For 3+ cases on the same value,
    switch is often clearer and more concise than multiple if conditions.
 
 Note: The fallthrough keyword is rarely used in Swift, so don’t worry about it unless you need it.
 */
enum Weather {
    case sun, rain, wind, snow, unknown
}

let forecast = Weather.sun

// NOTES: In Swift, you have to put all the cases from enum to the switch.
switch forecast {
case .sun:
    print("It should be a nice day.")
case .rain:
    print("Pack an umbrelaa.")
case .wind:
    print("Wear somthing warm")
case .snow:
    print("School is cancelled.")
case .unknown:
    print("Our forecast generator is broken!")
}

let place = "Metroplis"
// Default case
switch place {
case "Gotham":
    print("You're Batman!")
case "Mega-City One":
    print("You're Judge Dredd!")
case "Wakanda":
    print("You're Black Panther")
default:
    print("Whoo are Youuu?")
}

// fallthrough
let day = 5
print("My true love gave to me...")

switch day {
case 5:
    print("5 golden rings")
case 4:
    print("4 callling birds")
case 3:
    print("3 French hens")
case 2:
    print("2 turtle doves")
default: // the default can only be put in the last.
    print("A partridge in a pear tree")
} // this code only run on case 5. the exit the switch

switch day {
case 5:
    print("5 golden rings")
    fallthrough
case 4:
    print("4 callling birds")
    fallthrough
case 3:
    print("3 French hens")
    fallthrough
case 2:
    print("2 turtle doves")
    fallthrough
default:
    print("A partridge in a pear tree")
} // this switch runs all cases.

/* ----------------------------------------------------------------
    How To Use The Ternary Conditional Operator for Quick Tests
-----------------------------------------------------------------*/
var a,b,c:Int
// a + b is what we call binary operator, which means two data.

let yourAge = 18
let canVote = age >= 18 ? "Yes" : "No" // ">=" check the condition. return "Yes" if true/"No" if false.
print(canVote)

let hour = 23
print(hour < 12 ? "It's before noon" : "It's after noon")

let names = ["Jake", "Kaylee", "Mal"]
let crewCount = names.isEmpty ? "No ONe" : "\(names.count) People"
print(crewCount)

enum Theme {
    case light, dark
}
let theme = Theme.dark
let background = theme == .dark ? "black" : "white"
print(background)

/* ----------------------------------------------------------------
            How To Use A For Loop to Repeat Work
-----------------------------------------------------------------*/
//repeat some code a fixed number of times
let platforms = ["iOS", "macOS", "tvOS", "watchOS"]

for os in platforms { // this loop all the items in the array
    print("Swift works great on \(os).")
}

for i in 1...5 { // this will loop through a range of 1 to 5.
    print("5 x \(i) is \(5 * i)")
}
for i in 1...5 { // this nested foor loop
    print("The \(i) tiems tables")
    
    for j in 1...3 {
        print(" \(i) x \(j) is \(i * j)")
    }
    print()
}
// 1...5 vs 1..<5
for i in 1...5 {
    print("Counting from 1 through 5: \(i)")
}
print()
for i in 1..<5 {
    print("Counting 1 up to 5: \(i)")
}
var lyrics = "Haters gonna"
for _ in 1...5 {
    lyrics += " hate"
}
print(lyrics)

let base = 3, power = 2
var answer = 1
for _ in 1...power {
    answer *= base
}
print("\(base) to the power of \(power) is \(answer)");print() // 3^2 is 9

// loop through Dictionary
let numberOfLegs = ["spider": 8, "ant": 6, "fly": 2, "cat": 4]
for (animal, legCount) in numberOfLegs {
    print("\(animal) has \(legCount) legs.")
};print()

var ships: [String: String] = [:]
ships["Star Trek"] = "Enterprise"
ships["Firefly"] = "Serenity"
ships["Aliens"] = "Sulaco"

for ship in ships {
    print("\(ship.value) is from \(ship.key)")
};print()

for ship in ships.reversed() {
    print("\(ship.value) is from \(ship.key)")
};print()

/*use enumerated() to get back position and value in one go.*/
for (index, ship) in ships.enumerated() {
    print("\(index + 1). \(ship.value) is from \(ship.key).")
};print()

// this will count down from 3 to 1
for (index, ship) in ships.enumerated().reversed() {
    print("\(index + 1). \(ship.value) is from \(ship.key).")
};print()
// this will count up from 1 to 3
for (index, ship) in ships.reversed().enumerated() {
    print("\(index + 1). \(ship.value) is from \(ship.key).")
};print()

// forEach()
ships.forEach {
    print("\($0.value) is from \($0.key)")
}
/* ----------------------------------------------------------------
            How To Use a While Loop to Repeat Work
-----------------------------------------------------------------*/
var countdown = 10
while countdown > 0 {
    print("\(countdown)...")
    countdown -= 1
}

print("Blast Off!!")

let id = Int.random(in: 1...1000)
let amount = Double.random(in: 0...1)

var roll = 0

while roll != 20 {
    roll = Int.random(in: 1...20)
    print("I rolled a \(roll)")
}



/* ----------------------------------------------------------------
            How to Skip Loop Items with Break and Continue
-----------------------------------------------------------------*/
// When do we use Continue? Break?

let filenames = ["me.jpg", "work.txt", "pich.jpg"]

for fn in filenames {
    if fn.hasSuffix(".jpg") == false {
        continue // skip this iteration.
    }
    print("Found picture: \(fn)")
}
let number1 = 4
let number2 = 14
var multiple = [Int]()

for i in 1...100_000 {
    if i.isMultiple(of: number1) && i.isMultiple(of: number2) {
        multiple.append(i) // add value to the last index of the array.
        
        if multiple.count == 10 {
            break // break = stop the loop
        }
    }
}
print(multiple)

/* ----------------------------------------------------------------
            Summary: Conditions and Loops
-----------------------------------------------------------------*/
/*
    - We use "if", "else", "else if" statements to check conditions.
    - You can combine conditions using "||" and "&&".
    - "switch" statements can be easier than using "if" and "else if" a lot, and Swift
        will check that they are exhaustive
    - The ternary conditional operator lets us check WTF: What?, True, False
    - "for" loops let us loop over arrays, sets, dictionaries, and ranges.
*/

/* ----------------------------------------------------------------
            Checkpoint 3
-----------------------------------------------------------------*/
// Your goal is to loop from 1 through 20 and for each number:
// 1. If it's a multiple of 3, print "Fizz".
// 2. If it's a multiple of 5, print "Buzz".
// 3. If it's multiple of 3 and 5, print "FizzBuzz".
// 4. Otherwise, just print the number.

for i in 1...20 {
    if i.isMultiple(of: 3) && i.isMultiple(of: 5) {
        print("FizzBuzz")
    } else if i.isMultiple(of: 5) {
        print("Buzz")
    } else if i.isMultiple(of: 3) {
        print("Fizz")
    } else {
        print(i)
    }
}
/* ----------------------------------------------------------------
            EXTRA
-----------------------------------------------------------------*/
// 1. print Even numbers
for i in 1...20 {
    if i % 2 == 0 {
        print(i)
    }
};print()

// 2. count vowels
let str = "Swift Programming"
var numOfVowels = 0
for i in str {
    if "aeiou".contains(i) {
        numOfVowels += 1
    }
};print(numOfVowels);print()

// 3. sum of multiples
var sum = 0
for i in 1...50 {
    if i % 5 == 0 {
        sum += i
    }
};print(sum);print()

// 4. reverse an array
var arr: [Int] = [1,2,3,4,5]
arr.reverse()
print(arr);print()

// FizzBuzz
for i in 1...20 {
    if i.isMultiple(of: 3) && i.isMultiple(of: 5) {
        print("FizzBuzz")
    } else if i.isMultiple(of: 5) {
        print("Buzz")
    } else if i.isMultiple(of: 3) {
        print("Fiz")
    } else {
        print(i)
    }
};print()

// Find the largest number
var arr1: [Int] = [3, 7, 2, 9, 5]
var max = arr1[0] // Init with the first element

for i in 1..<arr1.count { // Loop from the second element to the last
    if arr1[i] > max {
        max = arr1[i]
    }
}
print(max);print()
