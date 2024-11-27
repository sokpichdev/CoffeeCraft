// 26th, Nov 2024
import Foundation
/* ----------------------------------------------------------------
            HOW TO CREATE AND USE PROTOCOLS ?
-----------------------------------------------------------------*/
// Protocols let us define contracts that conforming types must adhere to.
protocol Vehicle {
    var name: String {get} // cannot assign value as default.
    var currentPassenger: Int {get set} // because protocol must not have implementation.
    
    func estimateTime(for distance: Int) -> Int
    func travel(distance: Int) // no function body
    // any struct, classes or enum that that conform this struct must implement these two methods.
}
// when we work with/implement the protocol, which the process called adopting the protocol or conforming the protocol
struct Car: Vehicle {
    let name = "Car"
    var currentPassenger: Int = 2
    /* Conform the Protocol */
    func estimateTime(for distance: Int) -> Int {
        distance / 50
    }
    func travel(distance: Int) { /* Now have body */
        print("I'm driving \(distance)km")
    }
    
    func openSunroof() { /* You can add more func */
        print("It's a nice day!")
    }
}

struct Bicycle: Vehicle {
    let name = "Bicycle"
    var currentPassenger: Int = 1
    func estimateTime(for distance: Int) -> Int {
        distance / 10
    }
    func travel(distance: Int) {
        print("I'm cycling \(distance)km")
    }
}

func commute(distance: Int, using vehicle: Vehicle) {
    if vehicle.estimateTime(for: distance) > 100 {
        print("That's too slow! I'll try a different vehicle.")
    } else {
        vehicle.travel(distance: distance)
    }
}

let car = Car()
commute(distance: 50, using: car)
let bicycle = Bicycle()
commute(distance: 34, using: bicycle)

func getTravelEstimates(using vehicles: [Vehicle], distance: Int) {
    for vehicle in vehicles {
        let estimate = vehicle.estimateTime(for: distance)
        print("\(vehicle.name): \(estimate) hours to travel \(distance)km")
    }
}
getTravelEstimates(using: [car, bicycle], distance: 150)
// KeyFeatureOfProtocols
//1. Defining a Protocol
protocol MyProtocol {
    var property: String {get}
    func doSomething()
}
//2. Protocol Adoption: Any Type(class, struct, enum) can conform to a protocol by implementing its requirement.
struct Example: MyProtocol {
    var property: String = "Hello, World!"
    func doSomething() {
        print(property)
    }
}
//3. Protocols for Properties: Protocols can specify property requirements
//  - Read-only: { get }
//  - Read-Write: { get set }
protocol PropertyProtocol {
    var name: String { get }
    var agae: Int { get set }
}
//4. Protocols for Methods: Protocols specify method signatures without implementation
protocol Greetable {
    func greey() -> String
}
//5. Protocol Inheritance: A protocol can inherit from one or more protocols.
protocol AdvancedProtocol: MyProtocol {
    func doAnotherThing()
}
//6. Protocol Extensions: Protocols can have default method implementations using extensions.
extension MyProtocol {
    func doSomething() {
        print("Default Implementation")
    }
}
//7. Protocol Composition: Combine multiple protocols in a single requirement.
func display(item: MyProtocol & AnotherProtocol){
    // Use combined functionality
}
//8. Protocols as Types: Protocols can be used as types for variables, parameters, or return values.
var myObject: MyProtocol
//9. Optional Requirements (Objective-C Protocols): Use @objc for optional methods (works with classes only).
@objc protocol OptionalProtocol {
    @objc optional func optionalMethod()
}
//10. Associated Types: Protocols can define placeholders for types with
protocol Container {
    associatedtype Item
    func add(item: Item)
    func getItem(at index: Int) -> Item
}
/* ----------------------------------------------------------------
            HOW TO USE OPAQUE RETURN TYPES ?
-----------------------------------------------------------------*/
//func getRandomNumber() -> Int {
//    Int.random(in: 1...6)
//}
//func getRandomBoolean() -> Bool {
//    Bool.random()
//}
func getRandomNumber() -> some Equatable {
    Int.random(in: 1...6)
}
func getRandomBoolean() -> some Equatable {
    Bool.random()
}
// Both Int and Bool conform to a common Swift protocol called Equatable, which means "can be compared for equality" use ==
print(getRandomNumber() == getRandomNumber())

/* ----------------------------------------------------------------
            HOW TO CREATE AND USE EXTENSIONS ?
-----------------------------------------------------------------*/
// extensions let us add functionality to existing types,
/*
    Extension in Swift can:
    - Add computed instance properties and computed type properties (look at d6
    - Define instance methods and type methods
    - Provide new initializers
    - Define subscripts
    - Define and use new nested types
    - Make an existing type conform to a protocol
In Swift, you can even extend a protocol to give implementation.
--------
 NOTE   | Extensions can add new functionality to a type, but can't override existing funcionality.
--------
 
 */

var quote = "   The truth is rarely pure and never simple   "
print(quote)
let trimmed = quote.trimmingCharacters(in: .whitespacesAndNewlines)
print(trimmed)
print()

// you can extent too
extension String {
    func trimmed() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
print(quote)
print(quote.trimmed())

// we could write like this too.
func trim(_ string: String) -> String {
    string.trimmingCharacters(in: .whitespacesAndNewlines)
}
let trimmed2 = trim(quote)
print(trimmed2)

// you can also use extensions to addd properties to types, they must only be computed properties, not stored properties.

extension String {
    var lines: [String] {
        self.components(separatedBy: .newlines)
    }
}
let lyrics = """
But I keep cruising
Can't stop, won't stop moving
It's like I got this music in my mind
Saying it's gonna be alright
"""
print(lyrics.lines.count)

struct Book {
    let title: String
    let pageCount: Int
    let readingHours: Int
    
}
extension Book {
    init(title: String, pageCount: Int) {
        self.title = title
        self.pageCount = pageCount
        self.readingHours = pageCount / 50
    }
}

protocol Purchaseable {
    var name: String { get set }
}

struct Bookk: Purchaseable {
    var name: String
    var author: String
}

struct Movie: Purchaseable {
    var name: String
    var actors: [String]
}

struct Carr: Purchaseable {
    var name: String
    var manufacturer: String
}

struct Coffee: Purchaseable {
    var name: String
    var strength: Int
}

func buy(_ item: Purchaseable) {
    print("I'm buying \(item.name).")
}

buy(Bookk(name: "The Swift Programming Language", author: "Kenneth C. Lee"))
buy(Coffee(name: "Ice Latte", strength: 6))

// computed properties
extension Double {
    var km: Double { return self * 1_000.0 }
    var m: Double { return self }
    var cm: Double { return self / 100.0 }
    var mm: Double { return self / 1_000.0 }
    var ft: Double { return self / 3.28084}
}
let oneInch = 25.4.mm
print("One inch is \(oneInch) meters.")
let threeFeet = 3.ft
print("Three feet is \(threeFeet) meters")

let aMarathon = 42.km + 195.m
print("A marathon is \(aMarathon) meters long.")


/* ----------------------------------------------------------------
            HOW TO CREATE AND USE PROTOCOL EXTENSIONS
-----------------------------------------------------------------*/
// Protocols let us define contracts that conforiminng types must adhere to, and extensions let us add functionality to existing types. But what would happend if we could write extensions on protocols?
let guests = ["Mario", "Luigi", "Peach"]
if guests.isEmpty {
    print(guests.isEmpty)
} else {
    print("Guest count: \(guests.count)")
}
// some write like this
if guests.isEmpty == false {
    print("Guest count: \(guests.count)")
}
// some prefer Boolean operator:
if !guests.isEmpty {
    print("Guest count: \(guests.count)")
}
// we can do this:
extension Array {
    var isNotEmpty: Bool {
        isEmpty == false
    }
}
if guests.isNotEmpty {
    print("Guest count: \(guests.count)")
}

// what about sets and dictionaries? since Array, Set and Dictionary all conform to a built-in protocol called Collection.
extension Collection {
    var isNotEmpty: Bool {
        isEmpty == false
    }
}
let numbers: Set<Int> = [1, 2, 3, 4, 5]
if numbers.isNotEmpty {
    print("Numbers: \(numbers)")
}

let nicknames: [String: String] = ["Mario": "Mario Bros.", "Luigi": "Luigi Bros."]
if nicknames.isNotEmpty {
    print("Nicknames: \(nicknames.values)")
}

protocol Person {
    var name: String {get}
    func sayHello()
}
extension Person {
    func sayHello() {
        print("Hello, my name is \(name)")
    }
}
struct Employee: Person {
    let name: String
    // you don't have to implement the sayHello() because it's alreay implemented in the extension
}
let taylor = Employee(name: "Taylor Swift")
taylor.sayHello()

// extent more protocols
struct SomeType {}
protocol SomeProtocol {}
protocol AnotherProtocol {}

extension SomeType: SomeProtocol, AnotherProtocol {
    // implementation
}
/* ----------------------------------------------------------------
            HOW TO GET THE MOST FROM PROTOCOL EXTENSION ?
-----------------------------------------------------------------*/
//extension Int {
//    func squared() -> Int {
//        self * self
//    }
//} this work,
// what if we want to do the same for Double but don't want to write another code? use Numberic.
extension Numeric {
    func squared() -> Self { // why Self ?. because Numeric can be Int, Double and so on. if we specify the type, it's gonna show error.
        self * self
    }
}

let wholeNumber = 3.3
print(wholeNumber.squared())

// NOTE: self is different from Self.
// - self refers to the current value.
// - Self refers to the current Type.

//struct User: Equatable {
//    let name: String
//}
struct User: Equatable, Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        lhs.name < rhs.name
    }
    
    let name: String
}
let user1 = User(name: "link")
let user2 = User(name: "Zelda")
print(user1 == user2)
print(user1 != user2)
print(user1 < user2)
print(user1 > user2)

print(user1 <= user2)
/* ----------------------------------------------------------------
            SUMMARY: PRTOCOLS AND EXTENSIONS
-------------------------------------------------------------------
    - Protocols are like constracts for code.
    - Opaque return types let us hide some information in our code.
    - Extensions let us add functionality to existing types.
    - Protocol extensions let us add funcionality to many types all at once.
 */


/* ----------------------------------------------------------------
            CHECKPOINT 8
-----------------------------------------------------------------*/
// Make a protocol that describes a building
// Your protocol should require the following.
// -    A property storing how many rooms it has.
// -    A property storing the cost as an integer.
// -    A property storing the name of the estate agent selling the builidng.
// -    A method for printing the sales summary of the builiding.
// Create two struct, House and Office, that conform to it.

protocol Building {
    var rooms: Int { get set}
    var cost: Int { get set}
    var estateAgent: String { get set}
    func printSalesSummary()
}

struct House: Building {
    
    var rooms: Int
    var cost: Int
    var estateAgent: String
    
    init(rooms: Int, estateAgent: String) {
        self.rooms = rooms
        self.cost = rooms * 5000 // 1 room = 1350
        self.estateAgent = estateAgent
    }
    
    func printSalesSummary() {
        print("<-----------HOUSE----------->")
        print("This House has \(rooms) rooms.")
        print("Starting Price is \(cost)$.")
        print("<-----------HOUSE----------->")
        print("Estate Agent: \(estateAgent)")
    }
}
struct Office: Building {
    var rooms: Int
    var cost: Int
    var estateAgent: String
    
    init(rooms: Int, estateAgent: String) {
        self.rooms = rooms
        self.cost = rooms * 8999
        self.estateAgent = estateAgent
    }
    
    func printSalesSummary() {
        print("<---------BUILDING----------->")
        print("This House has \(rooms) rooms.")
        print("Starting Price is \(cost)$.")
        print("<---------BUILDING----------->")
        print("Estate Agent: \(estateAgent)")
    }
}
let house = House(rooms: 3, estateAgent: "John D. Juju")
house.printSalesSummary();print()

let office = Office(rooms: 16, estateAgent: "Dadan P. Panda")
office.printSalesSummary();print()


protocol A {
    func a()
}
extension A {
    func a() {
        print("call from extension")
    }
    func b() {}
}
struct B: A {
    func a() {
        print("call from struct")
    }
}
struct C: A {
    
}
let b = B()
b.a()
let c = C()
c.a()
