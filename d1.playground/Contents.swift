import SwiftUI
/* ---------------------------------------------------------------------
            How to Create Variables and Constants?
----------------------------------------------------------------------*/

var hi = "Hello, World!"
print(hi)

var name = "Pich" // it's variable, so we can change the value.
name = "Sok"
name = "Sok Pich"
print(name)

let character = "Deadshot"
//character = "Natsu" it's a constant, so we can't change the value.
print(character)

// when diclare variable, recommend to use the camel style. _/\_/\_
var playerName = "Nomercy"
print(playerName)

playerName = "Natsu"
print(playerName)

// most of the time we better use constant over variable since we don't want to accidently change the value.
let managerName = "Sok Pich"
let carBrand = "Bugatti"
let meaningOFLife = "How many roads must a man walk down?"

// Sometime the declare "let" but don't assign value, this case, we can assign first then later on, we can't.
let emptyValue: String
emptyValue = "somthing"
//emptyValue = "anotherthing" // this will throw an error since we can't modify value of a constant.

/* ---------------------------------------------------------------------
            How To Create Strings?
----------------------------------------------------------------------*/
let actor = "Denzel Wahsington"
let fileName = "cambodia.jpg"
let result = "⭐️ You Win!!! ⭐️"
let quote = "Then he taped a sign saying \"Believe\" and walked away." // backslash before quotes
// the triple quotes are used to create a multi-line string.
// the triple quotes need to be on the seperate lines from the string.
let movie = """
A day
in the life of
an Apple engineer.
"""
print(actor.count)
print(result.uppercased())
print(movie.hasPrefix("A")) // hasPrefix check if movie starts with "A"
print(movie.hasPrefix("a")) // hasPrefix is case-senstitive
print(fileName.hasSuffix(".jpg")) // hasSuffix check if the fileName ends with ".jph"

/* ---------------------------------------------------------------------
            How To Store Whole Numbers
----------------------------------------------------------------------*/
let score = 10
let reallyBig = 100_000_000 // Swift ingore "_"
let swiftDontCare = 1_00__000____0000

let lowerScore = score - 2
let higherScore = score + 10
let doubleScore = score * 2
let squreScore = score * score
let halvedScore = score / 2

// you can store a new value to the same variables without declare a new one.
var counter = 10
counter = counter + 5
print(counter)
// These are compound Assignment Operators
counter += 5
counter *= 2
counter -= 10
counter /= 2

let number = 120
print(number.isMultiple(of: 3))
print(120.isMultiple(of: 3))

/* ---------------------------------------------------------------------
            How To Store Decimal numbers
----------------------------------------------------------------------*/
let num = 0.1 + 0.2 // the result is not simply 0.3
print(num)

//However, you can't write code like below
let a = 1 // Int
let b = 3.2 // Double
//let c = a + b // this will throw error, because you can't mix different data types. (Int,Double)
// you have to convert that data type.
let c = a + Int(b) // = 4 <= int + int = int
let d = Double(a) + b // = 4.2 <= double + double = double

let double1 = 3.1
let double2 = 3131.3131
let double3 = 3.0 // even .0 is still considered double
let int1 = 3

var name1 = "Swift"
//name1 = 17 // this will show an error saying you can't "Cannot assign value of type 'Int' to type 'String'"
var rating = 5.0
rating *= 2
/* ---------------------------------------------------------------------
            How To Store Truth With Booleans
----------------------------------------------------------------------*/
// Boolean Snuck in
let fn = "Cambodia.jph"
print(fn.hasSuffix(".jph")) // because you snuck that methods into a constant.
let n = 120
print(n.isMultiple(of: 3))

let goodDogs = true
// you can store boolean base on the previous variable or constnat
let isMultiple = 120.isMultiple(of: 3)

// you can flip the boolean too
var isAuthenticated = false
print(isAuthenticated) // false
isAuthenticated = !isAuthenticated // flip from F -> T
print(isAuthenticated) // true
isAuthenticated = !isAuthenticated // flop from T -> F
print(isAuthenticated) // false

// you can use .toggle() too
//let gameOver = false // you can't use let with toggle becuase it changes value
var gameOver = false
print(gameOver)
gameOver.toggle()
print(gameOver)

/* ---------------------------------------------------------------------
            How To Join Strings Together
----------------------------------------------------------------------*/
// using + to join string
let firstPart = "Hello, "
let secondPart = "World!"
let greeting = firstPart + secondPart

let people = "Haters"
let action = "hate"
let lyric = people + " gonna " + action

/*
 Here if you wonder why we can use + to add number and now string?
 it's because this is an operator overloading, which means
 we can use the same operator for different purposes.
 FOR STRING -> Concatination, string + string
 FOR INT -> add, integer + integers
 this applies too for, compound assignment operators
 -----
 note that strings don't take all string into one, but one by one.
*/
let luggageCode = "1" + "2" + "3" + "4" + "5"
print(luggageCode) // 12345
// but the code actualy went like this.
/*
    luggageCode = "1" + "2" + "3" + "4" + "5"
    luggageCode = "12" + "3" + "4" + "5"
    luggageCode = "123" + "4" + "5"
    luggageCode = "1234" + "5"
    luggageCode = "12345"
*/

// String Interpolation
let quote1 = "Then he taped a sign saying \"Believe\" and walked away."
let name2 = "Taylor"
let age = 26
let message = "Hello, my name is \(name2) and I'm \(age) years old."
print(message)

let numb = 11
//let missionMessage = "Applo " + numb + " landed on the moon." // Swift doesn't allow us to do this.
let missionMessage = "Applo \(numb) landed on the moon."

// PRO TIP
print("5 x 5 is \( 5*5)")

/* ---------------------------------------------------------------------
            Summary: Simple Data
----------------------------------------------------------------------*/
/*
    - Swift lets us create constants using let, and variables using var
    - Swift's string containt text, from short strings up to whole novels
    - You create strings by using double quotes at the start and end
    - Swift calls its whole numbers integers, or Int
    - In Swift decimal numbers are called Double
    - You can store a simple true or false using a Boolean, or Bool
    - String interpolation lets us place data into strings efficiently
*/

/* ---------------------------------------------------------------------
            Checkpoint 1
----------------------------------------------------------------------*/
// Create a constant holding any temperature in Celsius.
let tempInCelsius = 30.0
// Converts that temperature to Fahrenheit by multiplying by 9, dividing by 5, then adding 32.
let tempInFahrenheit = (tempInCelsius * 9.0) / 5.0 + 32.0
// Prints the result, showing both the Celsius and Fahrenheit values.
print("\(tempInCelsius)°C is \(tempInFahrenheit)°F") // use Option+Shift+8 to get the degrees symbol.




// extra
typealias Paramaters = [String: Any]

let params: Paramaters = [:]


func getTest(data: Paramaters) {
    
}

let http404Error = (404, "Not Found", "hi")
print(http404Error)
print(http404Error.self)
