// 25th, Nov, 2024
import Foundation
/* ----------------------------------------------------------------
            CLASSES VS STRUCTS
 - you can name them
 - you can add properties, methods, property observers and access control
 - you can create custom initializers to configure new instances however you want.
-------------------------------------------------------------------
 - Classes:
    - SwiftUI use classes for data
    - share data, among the copy
    - Reference types
    - you can make one class build upon funcionality in another class
    - Swift won't  generate a memeberwise initializer for classes.
    - If you copy an instance of a class, both copies share the same data.
    - We can add a deinitializer to run when the fianl copy is destroyed.
    - Constant class instaces can have their variable properties changed. (especially, when you change name in the UI.
 
 - Structs:
    - SwiftUI use structs for UI design
    - do not share data, among the copy
    - Value type
    - IF nyou copy an instance of a struct, both copies don't share data.
 
 */



/* ----------------------------------------------------------------
            HOW TO CREATE YOUR OWN CLASS ?
-----------------------------------------------------------------*/
class Game {
    var score = 10 {
        didSet {
            print("Score is now \(score)")
        }
    }
}
var newGame = Game()
newGame.score = 20;print()
//------------------------------ - - - - - - - - - - - - - --
// Why does Swift havae both classes and structs?
//----------------------- - - - - - - - - - - - - - - - - - -
// - Classes don't come with synthesized memeberwise initializers
// - One class can build uopn("Inherit from") another class, gaining its properties and methods.
// - Copies of structs are always unique, whereas copies of classe actually point to the same shared data.
// -  Classes havae deinitializers, which are methods that are called when an instance of the class is destroyed, but struct do not.
// - Variable properties in constant classes can be modified freely, but variable properties in constant struct cannot.

//------------------------------ - - - - - - - - - - - - - --
// Why don't Swift classes have a memberwise initializer?
//----------------------- - - - - - - - - - - - - - - - - - -
// - they have inheritance, which would make memberwise initializers hard to work with.
// - User have to write their own init, because it always change depend on the parent class.
/* ----------------------------------------------------------------
            HOW TO MAKE ONE CLASS INHERIT FROM ANOTHER ?
-----------------------------------------------------------------*/
// parent class, base class
class Employee {
    let hours: Int
    init(hours: Int) {
        self.hours = hours
    }
    func printSummary() {
        print("I work \(hours) hours a day.")
    }
}
// subclass, child class.
class Developer: Employee {
    func work() {
        print("I'm writing code for \(hours) hours.") // you can use the property from the parent class.
    }
    // you can change the methods from parent class by using override methods
    override func printSummary() {
        print("I'm a developer who will sometimes work \(hours) hours a day, but other times will spend hours arguing abut whether code should be indeted using tabs or spaces.")
    }
}
class Manager: Employee {
    func work() {
        print("I'm managing the team for \(hours) hours.")
    }
}
let Liz = Developer(hours: 8)
let Pichu = Manager(hours: 20)
Liz.work()
Pichu.work();print()

let Jane = Manager(hours: 10)
Jane.printSummary() // this methods is in Employee class, but called by Developer class.
Liz.printSummary()
/* ----------------------------------------------------------------
            HOW TO ADD INITIALIZERS FOR CLASSES ?
-----------------------------------------------------------------*/
class Vehicle {
    let isElectric: Bool
    
    init(isElectric: Bool) {
        self.isElectric = isElectric
    }
}

class Car: Vehicle {
    let isConvertible: Bool
    
    init(isElectric: Bool, isConvertible: Bool) {
        self.isConvertible = isConvertible
        super.init(isElectric: isElectric) // this is from parent class
    }
}
let teslaX = Car(isElectric: true, isConvertible: false)

class Truck: Vehicle {
    let isTowing = false
}
let myTruct = Truck(isElectric: false)
print()

// Default Initializers
class ShoppingListItem {
    var name: String?
    var quantity: Int = 1
    var purchased: Bool = false
}
var item = ShoppingListItem()
print(item.name)
print(item.quantity)
/*------------------------------ - - - - - - - - - - - - - --
 When would you want to override a method ?
----------------------- - - - - - - - - - - - - - - - - - -
    - when you want to make changes for the methods that inherit from the parent class. especially when you want to keep the whole thing same just small changes.

//------------------------------ - - - - - - - - - - - - - --
 Which classes should be declared as final?
//----------------------- - - - - - - - - - - - - - - - - - -
 Final classes are ones that cannot be niherited from, which means it's not possible for users of your code to add fucntionality or change what they have. This is not the default: you must opt in to this behavior by addding the "final" keyword to your class.
*/


/* ----------------------------------------------------------------
            HOW TO COPY CLASSES ?
-----------------------------------------------------------------*/
// in class when you copy data from one class, and change the data, the other class will also change.
class User {
    var username = "Anonymous"
    
    func copy() -> User {
        let user = User()
        user.username = username
        return user
    }
}
var user1 = User()
//var user2 = user1 // this share data among copy.
var user2 = user1.copy() // this don't share data among copy.
user2.username = "John"
print(user1.username) // John
print(user2.username) // John

// you can deep copy too, copy data by hand

/* ----------------------------------------------------------------
            HOW TO CREATE A DEINITIALIZER FOR A CLASS ?
-----------------------------------------------------------------*/
class User1 {
    let id: Int
    
    init(id: Int) {
        self.id = id
        print("User \(id): I'm alive!")
    }
    deinit {
        print("User \(id): I'm Dead!") // Init -> doSth -> deinit.
    }
}

for i in 1...3 {
    let user = User1(id: i)
    print("User \(user.id): I'm in contorl!")
} // this way, deinit called each time the loop finish.
print()

// when using array,  the reference is still there, unless you remove it by yourself.
var users: [User1] = []
for i in 1...3 {
    let user = User1(id: i)
    print("User \(user.id): I'm in control!")
    users.append(user)
}
print("Loop is finishsed")
users.removeAll() // this will call deinit.
print("Array is clear!")

/* ----------------------------------------------------------------
            HOW TO WORK WITH VARIABLES INSIDE CLASSES ?
-----------------------------------------------------------------*/
class User2 {
    var name = "Paul" // variable property
}
let useR2 = User2() // constant instance
useR2.name = "John"
print(useR2.name) // don't change at all. still "John"

var u = User2()
u.name = "John"
print(u.name) // John
u = User2()
print(u.name) // Pual

//----------------------
// Four Options:
//----------------------
//  - Constant Instance, Constant property - always points to the same user, who always has the same name.
//  - Constant Instance, Variable property - always points to the same user, but their name can change.
//  - Variable Instance, Constant property - can points to different users, but their name can never change.
//  - Variable Instance, Variable property - can points to different users, and their name can change.
/* ----------------------------------------------------------------
            SUMMARY: CLASSES
-------------------------------------------------------------------
    - Classes have lots of things in common with structs.
    - Classes can inherit from other classes, so they get access to the properties and methods of their parent.
    - Swift doesn't generate a memberwise initializer ofr classes.
    - Copies of a class instance point to the same instance
    - Classes run deinitializer when the last copy of an instance is destroyed.
    - You can change variable properties inside constant class istances.
 */


/* ----------------------------------------------------------------
            CHECKPOINT 7
-----------------------------------------------------------------*/
// Make a class heirarchy for animals
// - start with Animal. Add a legs property for the number of legs an animal has.
// - Make Dog a subclass of Animal, giving it a speak() mehtod that prints a dog barking string, but each subclass shold print something different.
// - make Corgi and Poodle subclasses of Dog.
// - Make Cat an Animal subclass. Add a speak() method, with each subclass printing something different, and an isTame Boolean, set with an initializer.
// - make Persian and Linon as subclasses of Cat.
class Animal {
    var legs: Int
    
    init(legs: Int) {
        self.legs = legs
    }
    func info() {
        print("I have \(legs) legs");print()
    }
}
class Dog: Animal {
    override init(legs: Int = 4) {
        super.init(legs: legs)
    }
    func speak() {
        print("woof woof")
    }
}
class Corgi: Dog {
    override func speak() {
        print("wif wif")
    }
}
class Poodle: Dog {
    override func speak() {
        print("wuf wuf")
    }
}

class Cat: Animal {
    var isTame: Bool
    
    init(isTame: Bool, legs: Int = 4) {
        self.isTame = isTame
        super.init(legs: legs)
    }
    
    func speak() {
        print("Meow")
    }
    override func info() {
        if isTame {
             print("I am tame")
        } else {
            print("I am not tame")
        }
        print()
    }
}

class Persian: Cat {
    override func speak() {
        print("Mew Mew")
    }
}

class Lion: Cat {
    override func speak() {
        print("Roar")
    }
}

var dog1 = Dog()
dog1.speak()
dog1.info()

var corgi = Corgi()
corgi.speak()
corgi.info()

var poodle = Poodle()
poodle.speak()
poodle.info()

var cat = Cat(isTame: true)
cat.speak()
cat.info()

var persian = Persian(isTame: true)
persian.speak()
persian.info()

var lion = Lion(isTame: false)
lion.speak()
lion.info()



struct Calculator {
    var currentTotal = 0
}
var baseModel = Calculator()
var casio = baseModel
var texas = baseModel
casio.currentTotal = 342
texas.currentTotal = 657
print(casio.currentTotal)
print(texas.currentTotal)
print(baseModel.currentTotal)
 
class Hospital {
    var onCallstaff: [String] = []
}
var londonCentral = Hospital()
var londonWest = londonCentral
londonCentral.onCallstaff.append("Bun")
londonWest.onCallstaff.append("Feb")
londonWest.onCallstaff.append("Aliz")
print(londonWest.onCallstaff)
print(londonCentral.onCallstaff)


enum CompasPoint {
    case north, south, east, west
    mutating func turnNorth() {
        self = .north
    }
}
var currentDirection = CompasPoint.west
let rememberedDirection = currentDirection
currentDirection.turnNorth()

print("The current directino is \(currentDirection)")
print("The remembered direction is \(rememberedDirection)")

class A {
    var a: Int = 50
    
}
var a = A()
print(a.a)
var b = a
b.a = 100
print(b.a)
print(a.a)
