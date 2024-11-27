// 27th nov 2024
import Foundation
/* ----------------------------------------------------------------
            HOW TO HANDLE MISSING DATA WITH OPTIONALS ?
-----------------------------------------------------------------*/
// optionals -> this thing might have a value or might not.
var opposites: [String: String] = [:]
opposites["Mario"] = "Wario"
opposites["Luigi"] = "Waluigi"

let peachOpposite = opposites["Peach"]
print(peachOpposite) // nil because "Peach" doesn't exist.
// solutions -> Use optional.
if let marioOpposite = opposites["Mario"] {
    print("Mario's opposite is \(marioOpposite)")
}
// if here is the condition just as normal. if the condition true, the create a constant.
var username: String? = nil

if let unwrappedName = username {
    print("We got a user: \(unwrappedName)")
} else {
    print("The optional was empty.")
}

var num1 = 1_000_000 // this is non-optional Int
var num2 = 0 // this is also non-Optional Int
var num3: Int? = nil // This is optional string
// 0 is not nil

var str1 = "Hello" // this is non-optional String
var str2 = ""   // this is non-optional String
var str3: String? = nil // this is optional string
// empty string is not nil

var arr1 = [0]  // this is non-optional array
var arr2: [Int] = [] // this is non-optional empty array
var arr3: [Int]? = nil // this is optional array
// empty array is not nil

func square(number: Int) -> Int {
    number * number
}
var number: Int? = nil //
//print(square(number: number)) // error, the number is nil. you have to unwrap it first

// Unwrap it first to use the optional value.
if let unwrappedNumber = number {
    print(square(number: unwrappedNumber))
}
number = 21
if let unwrappedNumber = number {
    print(square(number: unwrappedNumber))
    /*Notice you can use the same name "unwrappedNumber twice, because after the if let statement, the constant is also removed.*/
}
//print(unwrappedNumber) // not found in scope

// we can use the same name too
if let number = number {
    /*let name and = name is not the same.
     let name is constant we create if the = number is non-opional.
     so we can only use the name inside this scope*/
    print(square(number: number))
}
/* ----------------------------------------------------------------
            HOW TO UNWRAP OPTIONALS WITH GUARD ?
-----------------------------------------------------------------*/
func printSqaure(of number: Int?) {
    guard let number = number else {
        print("MIssing input")
        return
    }
    print("\(number) x \(number) = \(number * number)")
}
printSqaure(of:6) // 36
printSqaure(of: nil) // Missing input
// like if let, quard let checks whether there is a value inside an optional, and if there is it iwll retrive the vale and place it into a constant of our choosing. However, the way it does so flips things around.
var myVar: Int? = nil
if let unwrapped = myVar {
    print("Run if myVar has a value inside.")
}
//guard let unwrapped = myVar else {
//    print("run if myVar doesn't have a value inside.")
//
//}
func printSquare(of number: Int?) {
    guard let number = number else {
        print("Missing input")
        
        // 1: we *must* exit the function here
        return
    }
    // 2: `number` is still available outside of `guard`
    print("\(number) x \(number) is \(number * number)")
}
printSquare(of: 5)

/*
 So: use 'if let' to unwrap optoinals so we can process them somehow, and
     use 'guard let' to ensure optional have something inside them and exit otherwise.
 
 TIP: you can use guard with any condition, including ones that don't upwrap optionals,
 */

/* ---------------------------------------------------------------
            HOW TO UNWRAP OPTIONALS WITH NIL COALESCING ?
-----------------------------------------------------------------*/
let captains = [
    "Enterprise": "Picard",
    "Voyager": "Janeway",
    "Defiant": "Sisko"
]
var new = captains["Serenity"] // nil
// nil coalescing operator, written ??, we can provide a default value for any optoinal, like this:
new = captains["Serenity"] ?? "N/A" // N/A
print(new)
new = captains["Defiant"] ?? "N/A"
print(new)

new = captains["Serenity", default: "N/A"]
print(new!)

let tvShows = ["Archer", "Babylon 5", "Ted Lasso"]
let favorite = tvShows.randomElement() ?? "None"
print(favorite)

struct Book {
    let title: String
    let author: String?
}
let book = Book(title: "Beowulf", author: nil)
let author = book.author ?? "Unknown"
print(author)

//let input = "1"
let input = "h"
let number1 = Int(input) ?? 0 /* attempt to convert string into integer.
                               if the convertion fails, (strings doesn't represent a valid number,
                               it assigns a default value of 0 to the variable number1*/
print(number1)
/* ----------------------------------------------------------------
            HOW TO HANDLE MULTIPLE OPTIONAL USING OPTIONAL CHAINING ?
-----------------------------------------------------------------*/
// Optional chaining is a simplified syntax for reading optionals inside optionals.
var names: [String]? = nil
names = ["Arya", "Bran", "Robb", "Sansan"]
let chosen = names?.randomElement()?.uppercased() ?? "No one"
print("Next in line: \(chosen)")

struct Book1 {
    let title: String
//    let author: String = "Arya"
    let author: String?
}
var book1: Book1? = nil
let author1 = book1?.author?.first?.uppercased() ?? "A"
// it reads "if we have a book, and the book has an author, and the author has a first letter, then uppercase it and send it back, otherwise send back "A".
print(author1)
/* ----------------------------------------------------------------
            HOW TO HANDLE FUNCTION FAILURE WITH OPTIONAL ?
-----------------------------------------------------------------*/
enum UserError: Error {
    case badID, networkFailed
}
func getUser(id: Int) throws -> String {
    throw UserError.networkFailed
}
if let user = try? getUser(id: 32) {
    print("User: \(user)")
}
// you can combine `try?` with  `nil coalesing`, which means "attemp to get the return value from this function, but if it fails use this default value instead."
let user1 = (try? getUser(id: 34)) ?? "Anonymous"
print("User: \(user1)")
/* ----------------------------------------------------------------
            SUMMARY: OPTIONALS
-----------------------------------------------------------------*/
/*
    - Optionals let us represent the absence of data.
    - Everything that isn't optional definitely has a value inside.
    - Unwrapping looks inside the optional: if there's a value it's sent back.
    - `if let` runs code if the optoinal has a value; `guard let` runs code if the optional doesn't have a value
    - `??` unwraps and returns an optoinal's value, or a default value instead.
    - Optional chaining read an optional inside another optional.
    - `try?` can conert throwing functions so they return an optional
 */
print()
/* ----------------------------------------------------------------
            CHECKPOINT 9
-----------------------------------------------------------------*/
// Write a functino that accepts an optional array of integeres, and returns one of those integers randomly.
// if the array is smissing or empty, return a new random number in the range of 1 through 100.
// write your function in a signle line of code.

func randomNumber(from array: [Int]?) -> Int {
    
    return array?.randomElement() ?? Int.random(in: 1...100)
}
var array1: [Int]? = [111,222,333]
print(randomNumber(from: array1))
array1 = nil
print(randomNumber(from: array1))
array1 = []
print(randomNumber(from: array1))
//------
// Optional Chaining as an Alternative to Forced Unwrapping
//------
class Person1 {
    var residence: Residence1?
}
class Residence1 {
    var numberOfRooms = 1
}

let john = Person1()
print(john.residence)

//let roomCount = john.residence!.numberOfRooms // this triggers a runtime error
if let roomCount = john.residence?.numberOfRooms {
    print("John's residence has \(roomCount) room(s).")
} else {
    print("Unable to retrieve the number of rooms.")
}
// Prints "Unable to retrieve the number of rooms."

john.residence = Residence1()
print(john.residence)

if let roomCount = john.residence?.numberOfRooms {
    print("John's residence has \(roomCount) room(s).")
} else {
    print("Unable to retrieve the number of rooms.")
}
// Prints "John's residence has 1 room(s)."

//------ - - - - - - - - - - - - - -  - -  - --
// Defining Model Classes for Optional Chaining
//------ - - - - - -- - -  - - - - - - - - - --
