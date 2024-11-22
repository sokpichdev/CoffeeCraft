// 22th, Nov, 2024
import Foundation
//------------------------------
// Copy a function to a variable
//------------------------------
func greetUser(_ name: String) -> String { return "Hello \(name)"} // Define a func
greetUser("Pich") // Call a func

var greetCopy = greetUser // this copy the function.
greetCopy("Natsu")

var AssignValue = greetUser("Nomercy") // this assigns value to the variable
print(AssignValue)

// Copy return void function
func greetCopyVoid() { print("Hello") }
//var greetcopy = greetCopyVoid // you can write like this
var greetcopy: () -> Void = greetCopyVoid // this is the full statement of return void.
// () is the empty parameter, -> void is the return type void = nothing.



// data don't matters, only types
func getUserData(ff id: Int) -> String {
    if id == 123 {
        return "Sok Pich"
    } else {
        return "Anonymous"
    }
}

let data: (Int) -> String = getUserData // accept Int, return String.
let user = data(123)
print(user)
// NOTES: when we take a copy of the function the type of functoin doesn't include the "for" external parameter name, so when the copy is called we use "data(123)" rather then "data(for: 123)".
// THIS APPLIES TO ALL CLOSURES
func test(for i: Int, end e: Int) {
    print("\(i) \(e)")
}
test(for: 12, end: 98) // this is not copy, we call the function directly.

/* ----------------------------------------------------------------
            HOW TO CREATE AND USE CLOUSURE ?
-----------------------------------------------------------------*/
// NOTES: closure don't allow using label/external param labels.
//      : we don't use parameter names wehn calling a closure.

// Assign function to variable
let sayHello = {
    print("Hi there!")
}
sayHello()

// (name: String) is the param, -> String is the return type,
// "in" keyword marks the end of the param and return type. everything after "in" is the closure body.
let sayHi = { (name: String) -> String in
        "Hi \(name)"
}
let hi = sayHi("Batman")
print(hi);print()

var team = ["Nomercy","Aliz","Feb","Bun"]
print("team list   : \(team)")
let sortedTeam = team.sorted()
print("team sorted : \(sortedTeam)")

func captainFirstSorted(name1: String, name2: String) -> Bool {
    if name1 == "Bun" {
        return true
    } else if name2 == "Bun" {
        return false
    }
    return name1 < name2
}

//let captainFirstTeam = team.sorted(by: captainFirstSorted) // normal function
//print(captainFirstTeam)
let captainFirstTeam = team.sorted(by: {(name1: String, name2: String) -> Bool in
    if name1 == "Bun" {
        return true
    } else if name2 == "Bun" {
        return false
    }
    return name1 < name2
})
print("team caption: \(captainFirstTeam) -> \(captainFirstTeam[0])")
/*------------------------------------
    What the heck are the closures and
    why does Swift love them so much?
 -------------------------------------
    -> Closures let us wrap up(store) some functoinality in a single variable, then store that somewhere.
        we can also return it from a functino, and store the closure somewhere else.
    example uses:
        - Running some code after a delay
        - Running some code after an animation has finished
        - Running some code when a download has finished
        - Running some code when a use has selected an option from your menu
 
 ------------------------------------- - - - - - - -
    Why are Swift's closure parametes inside the braces?
 -------------------------------- - - - - - - - - - -
    -> To avoid confusion with other syntax like tuples
        both closures and functions can take parameters, but the way they take params is very different.
    example:
 */
        func pay(user: String, amount: Int) { /*code*/ } // function
        let payment = { (user: String, amount: Int) in /*code*/ } // closure
//------------------- - - - - - - - - - - - - - - - - - -
// How to return value from a closure that takes no param?
//------------- - - - - - - - - - - - - - - - - - - - - -
let payment1 = { (user: String) in
    print("Paying \(user)...")} // a closure that accepts one param and returns nothing.

let payment2 = { (user: String) -> Bool in
    print("Paying \(user)...")
    return true} // A closure that accepts one param and returns a Boolean.

let payment3 = { () -> Bool in
    print("Pyaing an anonymours person...")
    return true} // this work the same as a func payment() -> Bool


let addNums: Int // we can create a variable or constant, then we can assign it to be a closure.
addNums = { (a: Int, b: Int) -> Int in
    return a + b
}(2,3) // (2,3) here is the default value.

print(addNums) // 5
// when don't have default value, we have to set the type to be the same.
let addN: (Int, Int) -> Int
addN = { (a: Int, b: Int) -> Int in
    return a + b
}
print(addN(3,5))// 8
print(addN(addNums, 5)) // 10
//print(addNums(addNums, 5)) // error

/* ----------------------------------------------------------------
            HOW TO USE TRAILING CLOSURES ANDS SHORTHAND SYNTAX ?
-----------------------------------------------------------------*/
let sorted1 = team.sorted(by: { (a: String, b: String) -> Bool in
    if a == "Bun" {
        return true
    } else if b == "Bun" {
        return false
    }
    return a < b
})
// in closure, we don't have to specify the types for closure. Swift knows to return boolean and a and b are string.
let sorted2 = team.sorted(by: { a, b in
    if a == "Bun" {
        return true
    } else if b == "Bun" {
        return false
    }
    return a < b
})
// when one func accepts another as its param, like sorted() does, Swift allows special syntax called "traling closure syntax".
let sorted3 = team.sorted{ a, b in
    if a == "Bun" {
        return true
    } else if b == "Bun" {
        return false
    }
    return a < b
}
// we can use special names given too. $0, $1, $2, $3.....
let sorted4 = team.sorted{
    if $0 == "Bun" {
        return true
    } else if $1 == "Bun" {
        return false
    }
    return $0 < $1
} // not recommed if tha value being used more that once, since it makes it hard to read.
// if the sorted() call was simpler, I would use:
let reverseTeam = team.sorted {
    return $0 > $1
}
// since, there is only one line of code.
let revereTeam1 = team.sorted { $0 > $1 }

team.append("Alizz");print(team);
// filter() func, lets us run some code on every items in the array.
let AOnly = team.filter { $0.hasPrefix("A")}
print(AOnly)
// .map() too.
let uppercaseteam = team.map {
    $0.uppercased()
}
print(uppercaseteam);print()

let digitNames = [
    0: "Zero", 1: "One", 2: "Two", 3: "Three", 4: "Four", 5: "Five", 6: "Six",
    7: "Seven", 8: "Eight", 9: "Nine", 10: "Ten", 11: "Eleven", 12: "Twelve",
    13: "Thirteen", 14: "Fourteen", 15: "Fifteen", 16: "Sixteen", 17: "Seventeen",
    18: "Eighteen", 19: "Nineteen", 20: "Twenty", 30: "Thirty", 40: "Forty",
    50: "Fifty", 60: "Sixty", 70: "Seventy", 80: "Eighty", 90: "Ninety"
]

let numbers = [16, 58, 510, 10, 21, 1233]
let strings = numbers.map { number -> String in
    if let name = digitNames[number] {
        return name // Direct match for numbers like 10, 11, 16, etc.
    }
    var output = ""
    if number >= 100 {
        let hundreds = number / 100
        output += "\(digitNames[hundreds]!)Hundred"
    }
    let remainder = number % 100
    if let tensName = digitNames[remainder] {
        output += tensName // Match for numbers like 16, 58, etc.
    } else if remainder > 0 {
        let tens = (remainder / 10) * 10
        let units = remainder % 10
        output += "\(digitNames[tens]!)\(digitNames[units]!)"
    }
    return output
}

print(strings)
for (index, string) in strings.enumerated() {
    print("\(numbers[index]) is \(string)")
}

//----------------------- - - - - -
// Why have trailing closure syntax?
//--------------- - - - - - - - - -
// -> make code easier to read, tho some prefer to avoid.
func animate(duration: Double, animation: () -> Void) {
    print("Starting a \(duration) second animation...")
    animation()
}
animate(duration: 3, animation: {
    print("Fade out the image")
})
animate(duration: 3) {
    print("Fade out the image")
}
//------------- -- -- -- -- -- -- -- -- -
// when should use shorthand param names?
//------------------ -- -- -- -- -- -- --
// - if more param, use the real names.
// - when the common functions used, so others can understand easily.
// - if the $0... used many times, beter to use the actual name.

/* ----------------------------------------------------------------
            HOW TO ACCEPT FUNCTIONS AS PARAMETERS
-----------------------------------------------------------------*/
func makeArray(size: Int, using generator: () -> Int) -> [Int] {
    var numbers = [Int]()
    
    for _ in 0..<size {
        let newNumber = generator()
        numbers.append(newNumber)
    }
    return numbers
}
/*
 CODE BREAKDOWN:
    - We’re creating a new function.
    - The function is called makeArray().
    - The first parameter is an integer called size.
    - The second parameter is a function called generator, which itself accepts no parameters and returns an integer.
    - The whole thing – makeArray() – returns an array of integers.
 */
let rolls = makeArray(size: 50) {
    Int.random(in: 1...20)
}
print(rolls);print()
// can write like this too.
func generateNumber() -> Int {
    Int.random(in: 1...20)
}
let newRolls = makeArray(size: 50, using: generateNumber) // call generateNumber() 50 times to fill the array.
print(newRolls);print()

// function accepts functions parameters, each of which accept no param and return nothing.
func doSth(first: () -> Void, second: () -> Void, third: () -> Void) {
    print("About to start 1st work")
    first()
    print("About to start 2nd work")
    second()
    print("About to start 3rd work")
    third()
    print("Done!")
}

doSth {
    print("This is the first work\n")
} second: {
    print("This is the second work\n")
} third: {
    print("This is the third work\n")
}
print()
/* ----------------------------------------------------------------
            SUMMARY: CLOSURES
-----------------------------------------------------------------*/
/*
    - You can copy functions in Swift.
    - You can create closures directly by assigning to a constant or variable
    - Closure parameters and return value are declared inside their braces
    - functions are able to accept other functions as parameters.
    - Anywhere you can pass a function, you can also pass a closure.
    - When passing a closure as a function parameter, you don't need to write
        out the types inside your closure if Swift can figure it out.
    - If a function's final parameters are functions, use trailing closure sysntax.
    - You can also use shorthand parameter anmes such as $0 and $1.
    - You can make your own functions that accept functions as parameters.
*/

/* ----------------------------------------------------------------
            CHECKPOINT 5
-----------------------------------------------------------------*/
// Your input is this:
//      let luckyNumbers = [7,4,38, 21, 16, 15, 12, 33, 31, 49]
// Your job is to:
//      Filter out any numbers that are even
//      Sort the array in ascending order
//      Map them to strings in the format "7 is a lucky number"
//      Print the resulting array, one item per line.
let luckyNumbers = [7,4,38, 21, 16, 15, 12, 33, 31, 49]
print("List Numbers    : \(luckyNumbers)")
let filterOutEvenNumbers = luckyNumbers.filter {
    if $0.isMultiple(of: 2) {
        return false
    } else {
        return true
    }
}
print("Filtered Numbers: \(filterOutEvenNumbers)")
let sortedNumbers = filterOutEvenNumbers.sorted()
print("Sorted Numbers  : \(sortedNumbers)")
let mappedNumbers: [String] = sortedNumbers.map{
    "\($0) is a lucky number"
}
print("--------------------")
for number in mappedNumbers {
    print(number)
}

//---------------------------
var addArray: (_ num: [Int]) -> Int = { nums in
    var sum: Int = 0
    for num in nums {
        sum += num
    }
    return sum
}

let result = addArray([1, 2, 3, 4, 5])
print(result)


