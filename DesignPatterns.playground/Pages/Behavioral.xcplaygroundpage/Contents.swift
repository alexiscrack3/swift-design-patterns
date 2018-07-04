//: Behavioral |
//: [Creational](Creational) |
//: [Structural](Structural)
/*:
 Behavioral
 ==========
 
 >In software engineering, behavioral design patterns are design patterns that identify common communication patterns between objects and realize these patterns. By doing so, these patterns increase flexibility in carrying out this communication.
 >
 >**Source:** [wikipedia.org](https://en.wikipedia.org/wiki/Behavioral_pattern)
 */
import Swift
import Foundation
/*:
 Command
 --------
 
 The command pattern is used to express a request, including the call to be made and all of its required parameters, in a command object. The command may then be executed immediately or held for later use.
 
 ### Example:
 */
enum Operator {
    case plus
    case minus
    case asterisk
    case slash
}

protocol Command {
    func execute()
    func unExecute()
}

class CalculatorCommand: Command {
    let `operator`: Operator
    let operand: Int
    let calculator: Calculator
    
    init(calculator: Calculator, operator: Operator, operand: Int) {
        self.calculator = calculator
        self.operator = `operator`
        self.operand = operand
    }
    
    func execute() {
        calculator.operation(operator: `operator`, operand: operand)
    }
    
    func unExecute() {
        calculator.operation(operator: undo(`operator`), operand: operand)
    }
    
    private func undo(_ `operator`: Operator) -> Operator {
        switch `operator` {
        case .plus:
            return .minus
        case .minus:
            return .plus
        case .asterisk:
            return .slash
        case .slash:
            return .asterisk
        }
    }
}

class Calculator {
    private var current: Int = 0
    
    func operation(operator: Operator, operand: Int) {
        switch `operator` {
        case .plus:
            current += operand
        case .minus:
            current -= operand
        case .asterisk:
            current *= operand
        case .slash:
            current /= operand
        }
        print("Current value = \(current) (following \(`operator`) \(operand))")
    }
}

class Computer {
    private var calculator = Calculator()
    private var commands = [Command]()
    private var current = 0
    
    func redo(levels: Int) {
        print("\n---- Redo \(levels) levels")
        
        var i = 0
        while i < levels {
            if current < commands.count {
                let command = commands[current]
                current += 1
                command.execute()
            }
            i += 1
        }
    }
    
    func undo(levels: Int) {
        print("\n---- Undo \(levels) levels");
        
        var i = 0
        while i < levels {
            if current > 0 {
                current -= 1
                let command = commands[current]
                command.unExecute()
            }
            i += 1
        }
    }
    
    func compute(_ `operator`: Operator, _ operand: Int) {
        let command = CalculatorCommand(calculator: calculator, operator: `operator`, operand: operand)
        command.execute()
        commands.append(command)
        current += 1
    }
}
/*:
 ### Usage:
 */
let computer = Computer()
computer.compute(.plus, 100)
computer.compute(.minus, 50)
computer.compute(.asterisk, 10)
computer.compute(.slash, 2)

computer.undo(levels: 4)

computer.redo(levels: 3)
/*:
 Immutable
 ----------
 
 The immutable pattern is used to allow .
 
 ### Example
 */
class ImmutablePerson {
    private var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func uppercased() -> String {
        return ImmutablePerson(name: self.name).name.uppercased()
    }
}
/*:
 ### Usage
 */
let person = ImmutablePerson(name: "Foo")
person.uppercased()
/*:
 Iterator
 ---------
 
 The iterator pattern is used to provide a standard interface for traversing a collection of items in an aggregate object without the need to understand its underlying structure.
 
 ### Example:
 */
struct Song {
    let title: String
}

protocol MusicLibrary: Sequence {
    var songs: [Song] { get }
}

class MusicLibraryIterator: IteratorProtocol {
    private var current = 0
    private let songs: [Song]
    
    init(songs: [Song]) {
        self.songs = songs
    }
    
    func next() -> Song? {
        defer { current += 1 }
        return songs.count > current ? songs[current] : nil
    }
}

class PandoraIterator: MusicLibraryIterator {
}

class SpotifyIterator: MusicLibraryIterator {
}

class Pandora: MusicLibrary {
    var songs: [Song]
    
    init(songs: [Song]) {
        self.songs = songs
    }
    
    func makeIterator() -> MusicLibraryIterator {
        return PandoraIterator(songs: songs)
    }
}

class Spotify: MusicLibrary {
    var songs: [Song]
    
    init(songs: [Song]) {
        self.songs = songs
    }
    
    func makeIterator() -> MusicLibraryIterator {
        return SpotifyIterator(songs: songs)
    }
}
/*:
 ### Usage
 */
let spotify = Spotify(songs: [Song(title: "Foo"), Song(title: "Bar")] )

for song in spotify {
    print("I've read: \(song)")
}
/*:
 Observer
 ---------
 
 The observer pattern is used to allow an object to publish changes to its state.
 Other objects subscribe to be immediately notified of any changes.
 
 ### Example
 */
protocol Observable {
    var observers: Array<Observer> { get }
    
    func attach(observer: Observer)
    func detach(observer: Observer)
    func notify()
}

class Product: Observable {
    var id: String = UUID().uuidString
    
    var inStock = false {
        didSet {
            notify()
        }
    }
    
    var observers: Array<Observer> = []
    
    func attach(observer: Observer) {
        observers.append(observer)
    }
    
    func detach(observer: Observer) {
        if let index = observers.index(where: { ($0 as! Product).id == (observer as! Product).id }) {
            observers.remove(at: index)
        }
    }
    
    func notify() {
        for observer in observers {
            observer.getNotification(inStock)
        }
    }
}

protocol Observer {
    func getNotification(_ inStock: Bool)
}

class User: Observer {
    func getNotification(_ inStock: Bool) {
        print("Is product available? \(inStock)")
    }
}
/*:
 ### Usage
 */
let foo = User()
let bar = User()

let shorts = Product()
shorts.attach(observer: foo)
shorts.attach(observer: bar)

shorts.inStock = true
/*:
 Strategy
 ---------
    
The strategy pattern is used to create an interchangeable family of algorithms from which the required process is chosen at run-time.

### Example
*/
class SaveFileDialog {
    private let strategy: Strategy
    
    init(strategy: Strategy) {
        self.strategy = strategy
    }
    
    func save(_ fileName: String) {
        let path = strategy.save(fileName)
        print("Saved in \(path)")
    }
}

protocol Strategy {
    func save(_ fileName: String) -> String
}

class DocFileStrategy: Strategy {
    func save(_ fileName: String) -> String {
        return "\(fileName).doc"
    }
}

class TextFileStrategy: Strategy {
    func save(_ fileName: String) -> String {
        return "\(fileName).txt"
    }
}
/*:
 ### Usage
 */
let docFile = SaveFileDialog(strategy: DocFileStrategy())
docFile.save("file")

let textFile = SaveFileDialog(strategy: TextFileStrategy())
textFile.save("file")
/*:
 Template
 ---------
 
 The Template Pattern is used when two or more implementations of an
 algorithm exist. The template is defined and then built upon with further
 variations. Use this method when most (or all) subclasses need to implement
 the same behavior. Traditionally, this would be accomplished with abstract
 classes and protected methods (as in Java). However in Swift, because
 abstract classes don't exist (yet - maybe someday),  we need to accomplish
 the behavior using interface delegation.
 
 ### Example
 */
protocol BoardGame {
    func play()
}

protocol BoardGamePhases {
    func initialize()
    func start()
}

class BoardGameController: BoardGame {
    private var delegate: BoardGamePhases
    
    init(delegate: BoardGamePhases) {
        self.delegate = delegate
    }
    
    private func openBox() {
        // common implementation
        print("BoardGameController openBox() executed")
    }
    
    final func play() {
        openBox()
        delegate.initialize()
        delegate.start()
    }
}

class Monoply: BoardGamePhases {
    func initialize() {
        print("Monoply initialize() executed")
    }
    
    func start() {
        print("Monoply start() executed")
    }
}

class Battleship: BoardGamePhases {
    func initialize() {
        print("Battleship initialize() executed")
    }
    
    func start() {
        print("Battleship start() executed")
    }
}
/*:
 ### Usage
 */
let monoply = BoardGameController(delegate: Monoply())
monoply.play();

let battleship = BoardGameController(delegate: Battleship())
battleship.play();
