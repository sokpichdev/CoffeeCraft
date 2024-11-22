// 21th, Nov, 2024
import Foundation // iOS
// import Cocoa // macOS
import SwiftUI
/* ----------------------------------------------------------------
            HOW TO REUSE CODE WITH FUNCTIONS?
-----------------------------------------------------------------*/
// Functions are just chunks of code you've split off from the rest of the program, and given a name that can be called easily.
print("Welcome to my app! <3")
print("By dfault This prints out a conversation")
print("chart from centimers to inches, but you")
print("can also set a custom range if you want.");print()
/* Why functions?
 -> when you want to have the same code run so many times at different places,
 -> later when you want to change somethings in the code, you can just change code in the function and it's good to go.
*/
// Create function
func showWelcome() { /*func is a keyword*/
    print("Welcome to my app! <3")
    print("By dfault This prints out a conversation")
    print("chart from centimers to inches, but you")
    print("can also set a custom range if you want.")
}
showWelcome();print() // calling the function

let num = 6
if num.isMultiple(of: 2) {
    print("\(num) is Even number")
} else {
    print("\(num) is Odd number")
};print()

// function with parameter
func printTimesTables(number: Int) {
    for i in 1...10 {
        print("\(number) x \(i) is \(i * number)")
    }
}
printTimesTables(number: 5);print() // calling function with argument.

// function with 2 parameters
func printTimesTables(number: Int, end: Int) {
    for i in 1...end {
        print("\(i) x \(number) is \(i * number)")
    }
}


printTimesTables(number: 5, end: 5);print() // calling function with 2 arguments.
printTimesTables(number: 2, end: 10);print()
//printTimesTables(end: 10, number: 3);print() // wrong order, error

// normaly function wihtout return type
func greeting(name: String) {
    print("Hello \(name)!")
}
greeting(name: "Nomercy")
greeting(name: "Pich");print()

/* ----------------------------------------------------------------
            HOW TO RETURN VALUES FROM FUNCTIONS?
-----------------------------------------------------------------*/
let root = sqrt(100)
print("root of 100 is \(root)");print()
 
// Create own function
func rollDice() -> Int {
    return Int.random(in: 1...6)
}
let result = rollDice()
print("You rolled a dice and got \(result)");print()

// function with more parameters
func areLettersIdentical1(str1: String, str2: String) -> Bool  {
    let first = str1.sorted() // .sorted, only works with string.
    let second = str2.sorted()
    return first == second // T/F
}

func areLettersIdentical2(str1: String, str2: String) -> Bool  {
    return str1.sorted() == str2.sorted()
}
// when function only has one line of code, we can remove the "return" keyword
func areLettersIdentical(str1: String, str2: String) -> Bool {
    str1.sorted() == str2.sorted()
}

print(areLettersIdentical(str1: "abc", str2: "cba"));print() // true
print(areLettersIdentical(str1: "321", str2: "122"));print() // false

func pythagoras(a: Double, b: Double) -> Double {
//    let input = a * a + b * b
//    let root = sqrt(input)
//    return root
    return sqrt(a * a + b * b)
}
let c = pythagoras(a: 3, b: 4)
print(c);print()

/* ----------------------------------------------------------------
            HOW TO RETURN MULTIPLE VALUES FROM FUNCTIONS?
-----------------------------------------------------------------*/
// You can use array.
func getUser() -> [String] {
    ["Taylor", "Swift"] // return array of string
}
let user = getUser()
// this can be problem since we don't know how many value we have in the function.
print("Name: \(user[0]) \(user[1])")

// use dictionary
func getUser1() -> [String: String] {
    [
        "firstName": "No",
        "lastName": "Mercy"
    ]
}
let user1 = getUser1()
print("Name: \(user1["firstName", default: "?"]) \(user1["lastName", default: "?"])")
// array and dictionary are bad solution here. a Better solution is using tuples

// use tuple

func getUser2() -> (firstName: String, lastName: String) {
    (firstName: "The", lastName: "Rock")
}
let user2 = getUser2()
print("Name: \(user2.firstName) \(user2.lastName)")

/* Why use Tuple rather than Dictionary?
    - when access value in dictionary, Swift don't know whether they are present or not.
        ofc, we know, but Swift doesn't.
    - when access value in tuple, Swift knows it's available.
    - no typos, becuase we don't access value using string. (user.firstName)
    - dictionary might containt hundreds of other values alongside "firstName",
        tuple cna't - we must list all the value it will contain -> result = containt them all.
*/
// this code does the same as getUser2()
func getUser3() ->(firstName: String, lastName: String) {
    ("John", "Cena")
}
print("Name: \(getUser3().firstName) \(getUser3().lastName)")

// sometime, given tuples element don't have name. when this happens, you can use numerical indices starting from 0..
func getUser4() -> (String, String) {
    ("Sabrina", "Carpenter")
}
let user4 = getUser4()
print("Name: \(user4.0) \(user4.1)")

// copy value from tuple before use.
let user5 = getUser3()
//let firstName = user5.firstName // getUser3 tuple parameters have names.
let firstName = user5.0 // can use index also.
let lastName = user5.lastName
print("Name: \(firstName) \(lastName)")

// assign two constants
let (fName, lName) = getUser2()
print("Name: \(fName) \(lName)")
 
// when you don't need all value
let (fn, _) = getUser2()
print("Name: \(fn)");print()

// functions with multiple return vlaues
func minMax(array: [Int]) -> (min: Int, max: Int) {
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array[1..<array.count] {
        if value < currentMin {
            currentMin = value
        } else if value > currentMax {
            currentMax = value
        }
    }
    return (currentMin, currentMax)
}
let bounds = minMax(array: [5,-1,12,44,-54])
//let bounds = minMax(array: []) // error, bcuz the array is empty.
print("min is \(bounds.min) and max is \(bounds.max)")
// to handle empty array safely, write function with optional tuple return type. and return nil when the array is empty.
func minmax(array: [Int]) -> (min: Int, max: Int)? {
    if array.isEmpty {
        return nil
    }
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array[1..<array.count] {
        if value < currentMin {
            currentMin = value
        } else if value > currentMax {
            currentMax = value
        }
    }
    return (currentMin, currentMax)
}
if let bounds = minmax(array: [2,1,4,29,-12]) {
    print("min is \(bounds.min) and max is \(bounds.max)")
}
/* ----------------------------------------------------------------
            HOW TO CUSTOMIZE PARAMETER LABELS?
 -----------------------------------------------------------------*/

// we want to customize the name for our parameters, so that we can remember it later on.
func rollDice(sides: Int, count: Int) -> [Int] {
    // Start with an empty array
    var rolls: [Int] = []
    //Roll as many dice as needed
    for _ in 1...count {
        // add each result to our array
        let roll = Int.random(in: 1...sides)
        rolls.append(roll)
    }
    //send back all the rolls
    return rolls
}
let rolls = rollDice(sides: 6, count: 3)
print(rolls);print()

func hireEmployee(name: String) { print("Hi, \(name)")}
func hireEmployee(title: String) { print("you work as \(title)")}
func hireEmployee(location: String) { print("you work at \(location)")}
func hireEmployee(age: Int) { print("you're \(age) years old.")}

hireEmployee(name: "Pich")
hireEmployee(title: "iOS Developer")
hireEmployee(location: "Loma Technology")
hireEmployee(age: 23);print()

let lyric = "I see a red door and I want it painted black"
print(lyric.hasPrefix("I see"))
// two kinds of paramenters, one is used where the function is called, and one for use inside the function itself.
func isUppercase(string: String) -> Bool {
    string == string.uppercased()
}
let string = "Hello World"
let result1 = isUppercase(string: string)
print(result1)

func isLowerCase(_ string: String) -> Bool {
    string == string.lowercased()
}
let string2 = "hello world"
let result2 = isLowerCase(string2)
print(result2);print()

//---------------------------
// Specifying Argument Labels
//---------------------------
func printTimesTables(for number: Int, end: Int) {
    for i in 1...end {
        print("\(i) x \(number) is \(i*number)")
    }
}
printTimesTables(for: 2, end: 4);print()

// "from" is the label, you can change to any label as you like.
func sursdey(name: String, from hometown: String) -> String {
    return "Sursdey all, My name is \(name)! I'm from \(hometown)"
}
print(sursdey(name: "Nomercy",from: "Phnom Penh"));print() // make sure the argument label and parameter label matches.

//-------------------------
// Omitting Argument Labels
//-------------------------
// if you don't want a label for your argument, try to use underscore _
func fun(_ firstParam: Int, sencondParam: Int) {
    print( firstParam + sencondParam)
}
fun(1, sencondParam: 5)
//fun(5,3) // error, missing label for secondParam.

//--------------------
// Variadic Parameters
//--------------------
func arithmeticMean(_ numbers: Double...) -> Double {
    var total: Double = 0
    for number in numbers {
        total += number
    }
    return total / Double(numbers.count)
}
print(arithmeticMean(1,2,3,4,5)) // 3.0
let am = arithmeticMean(3, 8.25, 18.75) // 10.0
print(am);print()

//------------------
// In-Out Parameters
//------------------
//Note: In-Out parameters can't have default values, and variadic parameters can't be marked as inout.
func swapTwoInts(_ a: inout Int, _ b: inout Int) {
    let tempA = a
    a = b
    b = tempA
}
var someInt = 3
var anotherInt = 5
print("someInt is \(someInt), and anotherInt is \(anotherInt)")
swapTwoInts(&someInt, &anotherInt)
print("someInt is now \(someInt), and anotherInt is now \(anotherInt)")

/* ----------------------------------------------------------------
            HOW TO GIVE DEFAULT VALUES FOR PARAMETERS
-----------------------------------------------------------------*/
func printTimesTables1(for number: Int, end: Int = 10) { // give default value 10 to end.
    for i in 1...end {
        print("\(number) x \(i) = \(number * i)")
    }
}
printTimesTables1(for: 5, end: 5);print() // end = 5 is a priority.
printTimesTables1(for: 4);print() // no end given, so it take the default value. end = 10

/* ----------------------------------------------------------------
            HOW TO HANDLE ERRORS IN FUNCTIONS?
-----------------------------------------------------------------*/

enum PasswordError: Error {
    case short, obvious
}
func checkPassword(_ password: String) throws -> String {
    if password.count < 5 {
        throw PasswordError.short
    }
    if password == "12345" {
        throw PasswordError.obvious
    }
    if password.count < 8 {
        return "OKa"
    } else if password.count < 10 {
        return "Good"
    } else {
        return "Excellent"
    }
}
 // test
let s = "12345"
do {
    let resul = try checkPassword(s)
    print("Password rating: \(resul)")
} catch PasswordError.short {
    print("Please use a longer password.")
} catch PasswordError.obvious {
    print("I have the same combination on my luggage!")
} catch {
    print("There was an error")
}
print()

/* ----------------------------------------------------------------
            SUMMARY: FUNCTIONS
-----------------------------------------------------------------*/
/*
    - Functions reuse code by carving off chuncks and giving it a name.
    - Functions start with the word "func", followed by the function's name.
    - Functions can accept parameters to contorl their behavior.
    - You can add custom external parameter names, or use _ to skip one.
    - Function parameters can have default values for common scenarios.
    - Funcions can optionally return a value, but you can return multiple pieces of data from a function using a tuple.
    - Funcions can throw errors using do, try and catch.
*/
//---------------
// Function Types
//---------------
func addTwoInts(_ a: Int, _ b: Int) -> Int {
    return a + b
}
func multiplyTwoInts(_ a: Int, _ b: Int) -> Int {
    return a * b
}
print(addTwoInts(4, 2))
print(multiplyTwoInts(3, 5))

//---------------------
// Using Function Types
//---------------------
var mathFunction: (Int, Int) -> Int = addTwoInts
print("Result: \(mathFunction(2,3))") // 5

mathFunction = multiplyTwoInts
print("Result: \(mathFunction(2,3))") // 6
// let's Swift to infer the function type.
let anothermathFunction = addTwoInts
print(type(of: anothermathFunction)) // (Int,Int) -> Int

//-----------------------------------
// Function Types as Parameters Types
//-----------------------------------
func printMathResult(_ mathFunction: (Int, Int) -> Int, _ a: Int, _ b: Int) {
    print("Result: \(mathFunction(a,b))")
}
printMathResult(addTwoInts, 2, 5)// 7

//----------------------------------
// Function Types as Return Types
//----------------------------------
func stepForward(_ input: Int) -> Int {
    return input + 1
}
func stepBackward(_ input: Int) -> Int {
    return input - 1
}
func chooseStepFunction(backward: Bool) -> (Int) -> Int {
    let a = backward ? stepBackward : stepForward
    return a
//    return backward ? stepBackward : stepForward // can't use ternary operator here.
}
//func chooseStepFunction(backward: Bool) -> (Int) -> Int {
//    if backward {
//        return stepBackward
//    } else {
//        return stepForward
//    }
//}
var currentValue = 3
let moveNearertoZero = chooseStepFunction(backward: currentValue > 0)
print("Counting to Zero:")
while currentValue != 0 {
    print("\(currentValue)")
    currentValue = moveNearertoZero(currentValue)
}
print("Zero!")
// 3
// 2
// 1
// Zero!
//-----------------
// Nested functions
//-----------------
func chooseStepFunction1(backward: Bool) -> (Int) -> Int {
    func stepForward(input: Int) -> Int { return input + 1}
    func stepBackward(input: Int) -> Int {return input - 1}
    return backward ? stepBackward : stepForward
}
var currentValue1 = -3
let moveNearertoZero1 = chooseStepFunction1(backward: currentValue1 > 0)
print("Counting to Zero:")
// moveNearerToZero refers to the nested stepForward()
while currentValue1 != 0 {
    print("\(currentValue1)")
    currentValue1 = moveNearertoZero1(currentValue1)
}
print("Zero!")
// -3
// -2
// -1
// Zero!
/* ----------------------------------------------------------------
            CHECKPOINT 4
-----------------------------------------------------------------*/
/*
    - Write a function that accepts an integer from 1 through 10,000, and returns the integer sqaure root of that number.
        - you can't use the built-in sqrt() function or similar - you need to find the square root yourself.
        - if the number is less than 1 or greater thatn 10,000 you should throw an "out of bounds error.
        - you should only consider integer square roots.
        - if you cna't fint the square root, throw a "no root" error.
 */
enum SquareRootError: Error {
    case outOfBounds
    case noRoot
}
func findSquareRoot(_ number: Int) throws -> Int {
    if number < 1 || number >= 10_000 {
        throw SquareRootError.outOfBounds
    }
    for i in 1...number {
        if i * i == number {
            return i
        } else if i * i > number {
            break
        }
    }
    // if no int square root found
    throw SquareRootError.noRoot
}
do {
    let reslt = try findSquareRoot(16)
    print("Square root of \(16) is \(reslt)")
} catch SquareRootError.outOfBounds {
    print("Error: The number is out of bound.")
} catch SquareRootError.noRoot {
    print("Error: No integer square root exist.")
} catch {
    print("An unexpected error occurred: \(error)")
}
