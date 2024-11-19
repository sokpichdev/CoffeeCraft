// 19th, November, 2024
import SwiftUI
/* ----------------------------------------------------------------
            How To Store Ordered Data In Arrays?
-----------------------------------------------------------------*/
// when we want to store lots of data in a single place.
var beatles = ["John", "Paul", "Mike", "Frank"] // Array of Strings
var numbers = [4, 8, 15, 18, 23, 45]  // Array of Integers
var temperatures = [25.3, 28.2, 27.1, 30.5] // Array of Doubles/Decimals
// We can get the values from the arrays by using Index, which start from 0
print(beatles[0])
print(numbers[2])
print(temperatures[3])
//print(temperatures[4]) // You always wanna make sure that the index you ask is in the array.
// You can modify the values in the array.
beatles.append("George")
beatles.append("Allen")
beatles.append("Novall")
beatles.append("Ringo") // There is nothing stopping you from adding more than one.
//beatles.append("Clint", "Natasha") // Extra argument is not allowed.

//temperatures.append("Chris") // You can't add String to an Array of Other types.

beatles += ["Sara"] // you can append item to array like this too.
beatles += ["Tony", "johny"] // this way you can append more items.
print(beatles)
beatles[5] = "Laura" //  modify "Allen" -> "Laura"
print(beatles)


beatles.insert("Jimmy", at: 0)// you can insert by specifing the index too.
print(beatles)

let listOfName = ["Johnson", "Smith"]
beatles.append(contentsOf: listOfName) // you can append the whole array
beatles.append(contentsOf: ["Sara", "Tony"]) // you can append like this too
print(beatles)

beatles.remove(at: 8) // remove item at index 8
print(beatles)

beatles.removeLast() // remove the last index
print(beatles)

beatles.removeFirst() // remove the first index
print(beatles)

// You can't mix two different types tgt.
let firstBeatle = beatles[0]
let firstNumber = numbers[0]
//let notAllowed = firstBeatle + firstNumber

// Empty Array
var scores = Array<Int>() // Specialized array type. (empty array)
scores.append(10)
scores.append(100)
scores.append(32)
print(scores[1])

var someInts: [Int] = [] // this is empty array.
print("\(someInts.count) \(someInts)")

someInts.append(3);someInts.append(1);someInts.append(8)
print("\(someInts.count) \(someInts)")

someInts = [] // now empty again.
print("\(someInts.count) \(someInts)")

var albums = Array<String>() // Specialized array type.
//var albums = [String]() // You can write like this too.
albums.append("Folklore")
albums.append("Fearless") // add the item to the end of the array.
albums.append("Red")
// When you give some initial value, Swift can figure by itself.
var singers = ["Taylor Swift"]
singers.append("Ed Sheeran")
singers.append("Justin Bieber")

// Creating an Array with a default value
var threeeDuobles: [Double] = Array(repeating: 1.3, count: 3)
var anotherThreeoubles = Array(repeating: 2.5, count: 3)
var sixDoubles = threeeDuobles + anotherThreeoubles

// Create an array with any type values
var anyType: [Any] = ["school", "home", 21, 25.1, true]
print(anyType)

// How many items are in the array.
print(singers.count)

print("\(beatles.count) \(beatles)") // Remove items from an array.

beatles.remove(at: 3) // Remove one Item at a specific index, which is 3.
print("\(beatles.count) \(beatles)")

beatles.removeAll() // Remove Everything.
print("\(beatles.count) \(beatles)")

// Check if the item is in the array.
let BondMovies = ["Casino Royale", "Spectre", "No Time To Die"]
print(BondMovies.contains("Frozen")) // false

// Sort Array
var cities = ["Phnom Penh", "Siem Reap", "Kompong Cham", "Takeo", "Svay Rieng"]
print(cities)
print(cities.sorted()) // asc order

cities.shuffle() // the items in the array keeping shuffing everytime you run code.
print(cities)

cities.swapAt(0,4)
print(cities)

// Reverse Array
let presidents = ["Bush", "Obamana", "Trump", "SleepyJoe"]
print(presidents)
let reversedPresidents = presidents.reversed()
print(reversedPresidents)



var employee = ["Taylor Swift", "Singer", "Nashville"]
print("Name     : \(employee[0])")
//employee.remove(at: 1) This here, is the problem. You removed the [1], which means that there is now only [0] and [1] <- [2]
print("Job Title: \(employee[1])")
print("Location : \(employee[2])") // don't have [2] no more.

/* ----------------------------------------------------------------
            How To Store and Find Data In Dictionaries?
-----------------------------------------------------------------*/
// Key:Value Pairs
let employee2 = ["name": "Taylor Swift", "job": "Singer", "location": "Nashville"]
print(employee2["name"]) // the warning means that the data might not be there.
print(employee2["album"]) // you'll get nil.
// solution:
print(employee2["name", default: "Unknown"])
print(employee2["job", default: "Unknown"])
print(employee2["location", default: "Unknown"])
print(employee2["album", default: "Unknown"])

// the value can't be any types.
let hasGraduated = ["Sith": true,"Sal": false,"Jake": true]
print("Has Jake graduated? -> \(hasGraduated["Jake", default: false])")

let olypics = [
    2012: "London",
    2016: "Rio de Janeiro",
    2020: "Tokyo"
]
print(olypics[2012, default: "Unknown"])


// Empty Dictionary
var numOfInts: [Int: String] = [:]
numOfInts[23] = "Twenty-three"
numOfInts[42] = "Forty-two"
print(numOfInts[23, default: "None"])
print(numOfInts[11, default: "None"])

var people = [String: Any]()
people["id"] = 82907500
people["name"] = "Sok Pich"
people["age"] = 25
people["isGraduated"] = true
//var dict2 = ["name": "Dara", "age": 16]
// this is why we should declare type for the value of dict.
var dict2: [String: Any] = ["name": "Dara", "age": 16]// we should declare type for the dict first.

// Empty dictionary using explicit types.
var heights = [String: Int]()
heights["Yao Ming"] = 229
heights["Shaquille O'Neal"] = 216
heights["LeBron James"] = 206
print(heights)

/*
 when the new key is added, it adds new key:value.
 but if the same key is added, it overrided the old one.
*/
var archEnemies = [String: String]()
archEnemies["Batman"] = "The Joker"
archEnemies["Superman"] = "Lex Luthor"
archEnemies["The Flash"] = "Barry Allen"
print(archEnemies)
archEnemies["Batman"] = "The Penguin" // overrides "The Joker"
print(archEnemies)



// Count
archEnemies.count
archEnemies.removeValue(forKey: "The Flash")
archEnemies.count
print(archEnemies)

// Check if empty or not
archEnemies.isEmpty
archEnemies.updateValue("Reverse Flash", forKey: "The Flash")
print(archEnemies)

// you can use subscript syntax ro remove key-value pair
archEnemies["Iron Man"] = "Thanos"
print(archEnemies)
archEnemies["Iron Man"] = nil // "Thanos" has been removed from the dictionary.
print(archEnemies)

archEnemies.removeValue(forKey: "Superman") // remove value for key "Superman"
print(archEnemies)

archEnemies.removeAll() // remove everything
print(archEnemies)
/* ----------------------------------------------------------------
            How To Use Sets For Fast Data Lookup?
-----------------------------------------------------------------*/
// works similar to array, but can't add duplicate items, and items are not in a particular order.
let actors = Set(["Denzel Washington", "Tom Cruise", "Nicolas Cage", "Samuel L Jackson"])
//actors.insert("Leonardo DiCaprio") // you can't insert, since the type is "let"
print(actors) // the order always changes.

var movies = Set<String>() // Create Empty set
movies.insert("The Shawshank Redemption") // you can insert because the type is "var"
movies.insert("The Godfather")
movies.insert("The Dark Knight")
movies.insert("The Dark Knight Rises")
movies.insert("The Lord of the Rings: The Return of the King")
movies.insert("The Lord of the Rings: The Fellowship of the Ring")

/* Array vs Set
   ------------
 Set makes it faster to locate items compare to Array.
 especially with thousands of data.
 */
actors.contains("Nicolas Cage")
print(actors.sorted()) // returns a sorted array containing the set's items.

let n = Set([4,2,7,2,9,3,4,5,6,7,8,9])
print(n)
print(n.sorted())


/* ---------------------------------------------------------------
            How To Create And Use Enums?
----------------------------------------------------------------*/
// Enum = Enumeration
var selected = "Monday" // let's say you want to select Monday
selected = "Tuesday" // later on you want to select Tuesday
selected = "january" // but you accidently choose Month instead
selected = "Friday " // or mispell, it has extra space!

enum Weekday {
//    case monday
//    case tuesday
//    case wednesday
//    case thursday
//    case friday
    case monday, tuesday, wednesday, thursday, friday
}
var day = Weekday.monday
day = Weekday.tuesday
day = Weekday.friday
//day = Weekday.January // January don't exist.
day = .thursday // swift knows that .thursday is Weekday.thursday becuase of the var day must always be some kind of Weekday.

/* ---------------------------------------------------------------
            How To Use Type Annotations?
----------------------------------------------------------------*/
/* Swift knows what type of data a constant or variable holds based on what we assign to it.
 but sometimes we don't want to assign a value immediately, or sometimes we want to override Swift's choice of type,
 and that's where type annotations come in. */
let surname = "Doe" // Swift knows it's string
var score = 19 // Integer

let surname1: String = "Dara" // surname1 must be string
var score1: Int = 12 // score1 must be integer

var score2: Double = 0 // without : Double, Swift would infer this to be integer.

let playerName: String = "Nomercy"
let luckyNumber: Int = 7
let pi: Double = 3.141
var isAuthenticated: Bool = true

var albums1: [String] = ["Red", "Fearless"] // specialized array of string
var user: [String: String] = ["id": "82907500"] // specialized dictionary
var books: Set<String> = Set(["The Bluest Eye","Foundation", "Girl, Woman, Other"]) //specialized set

// when to use Type Annotaion?
var soda: [String] = ["Coke", "Pepsi"] // not here, Swift knows you are assigning the array of strings.
// make an empty array.
var teams: [String] = [String]() // this is not required too. but need to open and close parentheses.
var school: [String] = [] // some ppl prefer to use type annotation, then assign an empty array.
var clues = [String]() // this is type inference

enum UIStyle {
    case light, dark, system
}
var style = UIStyle.light
style = .dark

let username: String
// lots more complex logic
//print(username) // this is not allow because the constant need to be initialized once.
username = "Nomercy" // this is correct because you assign it once.
//username = "Deadshot" // this is not allowd, constant can be assigned only once.
// lots more complex logic
print(username)

//let grade: Int = "Twelve" // you can't do this either.

/* ----------------------------------------------------------------
            Summary: Complex Data
-----------------------------------------------------------------*/
/*
    - Arrays store many values, and erad them using indices.
    - Dictionaries store many values, and read them using keys we specify.
    - Sets store many values, but we don't choose their order.
    - Enums create our own types to specify a range of acceptable values.
    - Swift uses type inference to figure what data we're storing.
    - It's also possible tosue type annotation to force a particular type.
*/

/* ----------------------------------------------------------------
            Checkpoint 2
-----------------------------------------------------------------*/
// Create an array of strings, then write some code that prints the number of items in the array and also the number of unique items in the array.

var arrayOFStrings: [String] = ["hi", "this", "is", "me", "Sok,", "Pich.", "hi", "hi", "hi"]
print(arrayOFStrings.count)
let uniqueItem: Set<String>  = Set(arrayOFStrings)
print(uniqueItem.count)




/* ----------------------------------------------------------------
            Extra
-----------------------------------------------------------------*/
var arr2d = [[Int]]() // create empty array 2 Dimensional
var a2d = [[1,2],[3,4]] // create array 2d with init values
var arra: [Array<Int>] = [] // create array 2 Dimensional
var arrd: [[Int]] = [] //Create array 2 Dimensional
print(a2d[1][0])
var country = ["1": "cbd", "2": "dfs"]
print(country["4", default: "not found"])
 
var a = [1,2,3,4]
a = a + [5,6,7,8]

var studentsInfo: [Int: [String: Any]] = [
    1: [
        "name": "Sok Pich",
        "age": 23,
        "Grade": "A",
        "Subjects": ["C/C++", "Swift", "Python", "C#"],
        "Contact": [
            "email": "sokpich@gmail.com",
            "phone": "077-742-462"
        ]
    ],
]
print(studentsInfo)
if let PichContact = studentsInfo[1]?["Contact"] as? [String: String],
   let PichEmail = PichContact["email"],
   let PichName = studentsInfo[1]?["name"] as? String {
    print("\(PichName)'s email is \(PichEmail)")
}

if let PichContact = studentsInfo[1]?["Contact"] as? [String: String],
   let PichPhone = PichContact["phone"] {
    print(PichPhone)
}
