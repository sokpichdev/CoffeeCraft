// 23th Nov 2024
import Foundation
/* ----------------------------------------------------------------
            HOW TO CREATE YOUR OWN STRUCTS
-----------------------------------------------------------------*/
// Swift's structs let us create our own custom, complex data types, complete with their own variabls and their own functions.

/*
    - variables and constants that belong to structs are called properties.
    - functions that belong to structs are called methods.
    - when we create a constant or variable out of a struct, we call that an instance - you might create a dozen unique instances
*/
//example:
struct Album {
    let title: String
    let artist: String
    let year: Int
    func printSummary() {
        print("\(title) \(year) \(artist)")
    }
}
let red = Album(title: "Red", artist: "Taylor Swift", year: 2012)
let wings = Album(title: "Wings", artist: "BTS", year: 2016)

print(red.title)
print(wings.artist)

red.printSummary()
wings.printSummary();print()

// print functions
func printEmp(emp: Employee) {
    print("\(emp.name) has \(emp.vacationRemaining) vacation days left.")
}
func printEmp(emp: Employee1) {
    print("\(emp.name) has \(emp.vacationRemaining) vacation days left.")
}
func printEmp(emp: Employee2) {
    print("\(emp.name) has \(emp.vacationRemaining) vacation days left.")
}
func printEmp(emp: Employee3) {
    print("\(emp.name) has \(emp.vacationRemaining) vacation days left.")
}

// What if you want to change values?
struct Employee {
    let name: String
    var vacationRemaining: Int = 14 // this is default values.
    mutating func takeVacation(days: Int){
        if vacationRemaining > days {
            vacationRemaining -= days
            print("I'm going on vacation!")
            print("Days remaining: \(vacationRemaining)")
        } else {
            print("Oops! There aren't enough days remaining.")
        }
    }
}

// if we create an employee as constant using let, Swift makes the employee and all its data constant - we can call function just fine, but aren't allowd to change the struct's data.
// -remove the keyword "mutating" to see.
var john = Employee(name: "John", vacationRemaining: 10)
john.takeVacation(days: 4)
printEmp(emp: john);print()

var Kane = Employee(name: "Kanfe") // use the default value of vacationRemaining
Kane = Employee(name: "Kane") // change the name for Kane
Kane.takeVacation(days: 10)
printEmp(emp: Kane);print()

/* ----------------------------------------------------------------
            HOW TO COMPUTE PROPERTY VALUES DYNAMICALLY
-----------------------------------------------------------------*/
// Structs have 2 kinds of properties:
//      - a stored property is a variable or constant that has a peice of data inside an instance of the struct.
//      - a computed property calculates the value of the property dynamically every time it's accessed. (they're accessed like stored properties, but work like fuctions.

// NOTES: computed properties can't be constant.

struct Employee1 {
    let name: String
    var vacationRemaining: Int
}
var sara = Employee1(name: "Sorin Sara", vacationRemaining: 12)
sara.vacationRemaining -= 3
printEmp(emp: sara)
sara.vacationRemaining -= 5
printEmp(emp: sara);print()

struct Employee2 {
    let name: String
    var vacationAllocated = 14
    var vacationTaken = 0
    
    var vacationRemaining: Int {
        vacationAllocated - vacationTaken
    }// instead of assigning directly, it's calculated.
}
var jane = Employee2(name: "Jane")
jane.vacationTaken += 10
printEmp(emp: jane)
jane.vacationTaken += 3
printEmp(emp: jane);print()

// get/set mark individual pieces of code to run when reading or writing a value.
// newValue - stores whatever value the user was trying to assign to the property.
struct Employee3 {
    let name: String
    var vacationAllocated = 14
    var vacationTaken = 0
    
    var vacationRemaining: Int {
        get {
            vacationAllocated - vacationTaken
        }
        set {
            vacationAllocated = vacationTaken + newValue
        }
    }
}
var juu = Employee3(name: "Juu", vacationAllocated: 14)
juu.vacationTaken += 4
juu.vacationRemaining = 5 // modifying the value for the property using "set"
printEmp(emp: juu);print()

struct Point {
    var x = 0.0, y = 0.0
}
struct Size {
    var width = 0.0, height = 0.0
}
struct Rect {
    var origin = Point()
    var size = Size()
    var center: Point {
//        get {
//            let centerX = origin.x + (size.width / 2)
//            let centerY = origin.y + (size.height / 2)
//            return Point(x: centerX, y: centerY)
//        }
        // Shorthand Getter Declaretion
        get {
            Point(x: origin.x + (size.width / 2),
                  y: origin.y + (size.height / 2))
        }
//        set(newCenter) {
//            origin.x = newCenter.x - (size.width / 2)
//            origin.y = newCenter.y - (size.height / 2)
//        }
        // Shorthand Setter Declaration
        set {
            origin.x = newValue.x - (size.width / 2)
            origin.y = newValue.y - (size.height / 2)
        }
    }
}
var square = Rect(origin: Point(x: 0.0, y: 0.0), size: Size(width: 10.0, height: 10.0))
let initalSquareCenter = square.center// initialSquareCenter is at (5.0, 5.0)

square.center = Point(x: 15.0, y: 15.0)
print("Square.origin is now at \(square.origin.x), \(square.origin.y)")
// Prints "square.origin is now at (10.0, 10.0)"

/* ----------------------------------------------------------------
            HOW TO TAKE ACTION WHEN A PROPERTY CHAGNES
-----------------------------------------------------------------*/
// - Property observers, which are special peices of code that runs when properties change.
// - these take two froms: "didSet" observer run when property just changed,
//                         "willSet" observer run before the property changed
// - You can't attact a property observer to a constant, because it will never change.
// this is why observers might be needed.
struct Game {
    var score = 0
}
var game = Game()
game.score += 10
print("Score is now \(game.score)")
game.score -= 5
print("Score is now \(game.score)")
game.score -= 1 // this is a bug: at the end of the score changed wihout being printed, which is a mistake.
print()
// with property observers, we can solve this problem by attaching the print() call directly to the property using didSet. this will print whenever it changes.
struct Game1 {
    var score = 0 {
        didSet {
            print("Score is now \(score)")
        }
    }
}
var game1 = Game1()
game1.score += 10
game1.score -= 5
game1.score -= 1
print()

struct App {
    var contacts = [String]() {
        willSet {
            print("____WillSet____")
            print("Current value is: \(contacts)")
            print("New value will be: \(newValue)")
        }
        didSet {
            print("____DidSet_____")
            print("There are now \(contacts.count) contacts")
            print("Old value was \(oldValue)")
            print()
        }
    }
}
var app = App()
app.contacts.append("Nomercy")
app.contacts.append("Natsu")
app.contacts.append("Deadshot")
/* ----------------------------------------------------------------
            HOW TO CREATE CUSTOM INITIALIZERS
-----------------------------------------------------------------*/
// RULES: all properties must have a value by the time the initializer for structs:
struct Player {
    let name: String
    let number: Int
}

// memeberwise initializer(constructor)
let player = Player(name: "Dara", number: 21) // create a new Player instance by providing valeus for its two properties.
print(player)

//we could write our own to do the same.
struct Player1 {
    let name: String
    let number: Int
    
    // work the same as the memberwise init. [just add print()]
    init(name: String, number: Int) {
        self.name = name
        self.number = number
        print("HI") // we can customize more
    }
    init(name: String) {
        self.name = name
        number = Int.random(in: 1...99)
    }
    init(number: Int) {
        self.number = number
        name = "Unknown"
    }
}
let player1 = Player1(name: "Laura", number: 24)
let player2 = Player1(name: "Dara") // this will take a random number.
print(player1)
print(player2)
let player3 = Player1(number: 12)
print(player3);print()

// --------------------
// When would you use self ?
//-----------------
//outside of initializers, the main reaosn for using self is becuase we're in a closure and Swift requires it so we're clear we understand what's happening. This is only needed when accessing self from inside a closure that belongs to a class, and Swift will refuse to build your code unless you add it.


// property that is array.
struct SuperHero {
    var nickName: String
    var powers: [String]
    init(nickame: String, superpowers: [String]) {
        self.nickName = nickame
        self.powers = superpowers
    }
}
let batman = SuperHero(nickame: "The Rich Man", superpowers: ["Rich", "Money", "Power"])
print(batman)

struct student {
    var name: String
    var age: Int
    var className: [[[Any]]]
    init(name: String, age: Int, className: [[[Any]]]) {
        self.name = name
        self.age = age
        self.className = className
    }
}
let Liz = student(name: "Aliz", age: 21,
                  className:[
                    [
                        ["Math",[89,90]],
                        ["Science", [87,88]]
                    ],
                    [
                        ["English", [98, 90]],
                        ["History", [87, 99]]
                    ]
                  ])
// print Liz info
for i in 0..<Liz.className.count {
    for j in 0..<Liz.className[i].count {
        print(Liz.className[i][j])
    }
}

/* ----------------------------------------------------------------
            HOW TO LIMIT ACCESS TO INTERNAL DATA USING ACCESS CONTROL
-----------------------------------------------------------------*/
// Be default, structs let us access their properties and mehtods freely.
// sometimes you want to hide some data from external access.

/*
    - Use "private" for don't let anything outside the struct use this.
    - Use "fileprivate" for dont' let anything outside the current file use this.
    - Use "public" for let anyone, anywhere use this.
*/
struct BankAccount {
//    var funds = 0
//    private var funds = 0 // only works inside the struct.
    private(set) var funds = 0 // let anyone read this properties, but only let my mehtods write it.
    mutating func deposit(amount: Int) {
        funds += amount
    }
    mutating func withDraw(amount: Int) -> Bool {
        if funds >= amount {
            funds -= amount
            return true
        } else {
            return false
        }
    }
}
var account = BankAccount()
account.deposit(amount: 300) // dak luy
let success = account.withDraw(amount: 400) // dork luy

if success {
    print("Withdrawal successful")
} else {
    print("Insufficient funds")
}
//account.funds = 500 // can't: because private(set)
// IMPORTANT: if you use private access contorl for one or more properties, chances are you'll need to create your own initializer.

/* ----------------------------------------------------------------
            STATIC PROPERTIES AND STATIC METHODS
-----------------------------------------------------------------*/
// use the static properties wihtout creating an instance.
struct School {
    static var studentCount = 0
    var location: String
    static func add(student: String) {
        print("\(student) joined the school.")
        studentCount += 1
    }
}
School.add(student: "John");print(School.studentCount)
School.add(student: "Poo");print(School.studentCount)


struct AppData {
    static let version = "1.3 beta 2"
    static let saveFilename = "settings.json"
    static let gomeRUL = "https://www.learningswiftfromscratch.com"
}

struct Employee5 {
    let username: String
    let password: String
    static let example = Employee5(username: "sokpich", password: "pichsok")
}
print()
/* ----------------------------------------------------------------
            SUMMARY: STRUCTS
-----------------------------------------------------------------*/
/*
    - You can create your own structs using the "struct" keywords
    - Structs can have their own properties and methods.
    - If a method modifies properties of its struct, it must be mutating.
    - Structs can have stored properties and computed properities.
    - We can attach didSet and willSet property observers to properties.
    - Swift generates an initializer for all structs using their properties names.
    - You can create custom initializers to override Swift's default.
    - Access control limits what code can use properties and methods.
    - Static properties and methods are attached directly to a struct.
*/

/* ----------------------------------------------------------------
            CHECKPOINT 6
-----------------------------------------------------------------*/
/*
 - Create a struct to store information about a car. Include:
    - its model
    - number of seats
    - current gear
 - Add a method to change gears up or down
 - Have a think about variables and access control.
 - don't allow invalid gears - 1...10 seems a fair maximum range.
 */
struct Car {
    private let model: String
    private let numberOfSeats: Int
    private(set) var currentGear: Int // Prevent direct modification outside the struct
    
    init(model: String, numberOfSeats: Int, CurrentGear: Int = 1) {
        self.model = model
        self.numberOfSeats = numberOfSeats
        self.currentGear = max(1, min(CurrentGear, 10)) // Ensure Initial gear is valid
    }
    mutating func changeGear(up: Bool) {
        if up {
            if currentGear < 10 {
                currentGear += 1
                print("Your current gear is now \(currentGear)")
            } else {
                print("Already at maximum gear!")
            }
        } else {
            if currentGear > 1 {
                currentGear -= 1
                print("Your current gear is now \(currentGear)")
            } else {
                print("Already at minimum gear!")
            }
        }
    }
    func descripton() -> String {
        return "Model: \(model), Seats: \(numberOfSeats), Current Gear: \(currentGear)"
    }
}
var myCar = Car(model: "Ford", numberOfSeats: 5)
print(myCar.descripton())
myCar.changeGear(up: false)
myCar.changeGear(up: true)


struct test {
    var a: Int = 3
    var b: Int
    mutating func increment(n1: Int) {
        a += n1
    }
    func show() {
        print("a = \(a), b = \(b)")
    }
}
var t = test(b: 5)
t.increment(n1: 2) // increment a
t.show()


struct B {
    var b = 4
    mutating func changeB() {
        b += 1
    }
}
var b = B()
b.changeB()
print(b.b);print()

struct Calc {
    var a = 3
    var b = 5
    var aAddB: Int {
        get { a + b}
        set { a = newValue}
    }
}
var num = Calc() // a = 3, b = 5
print(num.aAddB) // a + b = 8
num.aAddB = 7   // a = 7, b = 5
print(num.aAddB) // a + b = 12
print(num.a)    // a = 7
