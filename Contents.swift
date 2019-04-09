import UIKit
import PlaygroundSupport



let view = UIView()
view.backgroundColor = UIColor.lightGray
view.frame = CGRect(x: 0, y: 0, width: 600, height: 1000)
let backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 600, height: 1000))
backgroundImageView.contentMode = .scaleAspectFill
backgroundImageView.image = UIImage(named: "background2.jpg")
view.addSubview(backgroundImageView)

PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

let width:CGFloat = (560-(20*6))/7

var stackViews:[UIView] = []
var x:CGFloat = 20
for _ in 0..<7 {
    let stackView = UIView(frame: CGRect(x: x, y: (40 + width*1.5), width: width, height: 800))
    x = x + 20 + width
    stackViews.append(stackView)
    view.addSubview(stackView)
}

let completedStacks:UIView = UIView(frame: CGRect(x: 600 - 70 - width*4, y: 20, width: width*4+50, height: width*1.5))

var completedStackImages:[UIImageView] = []
x = 10
for _ in 0...3 {
    let imageView = UIImageView(frame: CGRect(x: x, y: 0, width: width, height: width*1.5))
    x = x + width + 10
    imageView.image = UIImage(named: "emptycard")
    completedStackImages.append(imageView)
    completedStacks.addSubview(imageView)
}

view.addSubview(completedStacks)

// error label
let errorLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 600, height: 50))
errorLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
errorLabel.textAlignment = .center
errorLabel.textColor = UIColor.red
errorLabel.text = ""
errorLabel.font = UIFont.boldSystemFont(ofSize: 16)
view.addSubview(errorLabel)

//let drawpileButton:UIButton = UIButton(frame: CGRect(x: 20, y: 20, width: width, height: width*1.5))
//drawpileButton.setImage(UIImage(named: "cardback1"), for: .normal)
//view.addSubview(drawpileButton)
//drawpileButton.addTarget(responder, action: #selector(responder.drawpileClicked), for: .touchUpInside)



enum Suit {
    case clubs
    case diamonds
    case spades
    case hearts
    
    var description: String {
        switch self {
        case Suit.clubs: return "♣"
        case Suit.diamonds: return "♦"
        case Suit.spades: return "♠"
        case Suit.hearts: return "♥"
        }
    }
    
    init?(char: Character) {
        switch char {
        case "C", "c": self = .clubs
        case "H", "h": self = .hearts
        case "S", "s": self = .spades
        case "D", "d": self = .diamonds
        default: return nil
        }
    }
}

class Card : Comparable {
    static func < (lhs: Card, rhs: Card) -> Bool {
        return lhs.value < rhs.value
    }
    
    let symbol:String!
    let value:Int!
    let suit:Suit!
    var faceUp:Bool!
    
    init(symbol: String, value: Int, suit: Suit, faceUp:Bool = true) {
        self.symbol = symbol
        self.value = value
        self.suit = suit
        self.faceUp = faceUp
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return (lhs.symbol == rhs.symbol && lhs.suit == rhs.suit && lhs.value == rhs.value)
    }
    
    public var description: String {
        if faceUp {
            return "\(symbol ?? "")\(suit.description)"
        }
        return "X"
    }
}

class Deck {
    var cards:[Card] = []
    let symbols:[String] = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"]
    let values:[Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    
    init() {
    }
    
    public func add(card: Card) {
        self.cards.append(card)
    }
    
    public func addAll(cards: [Card]) {
        self.cards.append(contentsOf: cards)
    }
    
    public func shuffle() {
        print("Shuffling \(self.cards.count) cards")
        let times = Int.random(in: cards.count*6..<cards.count*12)
        for _ in 0..<times {
            let firstCard = Int.random(in: 0..<cards.count)
            var secondCard = firstCard
            while (secondCard == firstCard) {
                secondCard = Int.random(in: 0..<cards.count)
            }
            let temp = self.cards[firstCard]
            self.cards[firstCard] = self.cards[secondCard]
            self.cards[secondCard] = temp
        }
        print("Done shuffling")
    }
    
    public func draw() -> Card? {
        if self.cards.count > 0 {
            let card = self.cards.popLast()
            return card
        }
        return nil
    }
    
    public func getTopCard() -> Card? {
        return getCard(at: self.cards.count - 1)
    }
    
    public func getCard(at index:Int) -> Card? {
        if self.cards.count > 0 && self.cards.count > index {
            return self.cards[index]
        }
        return nil
    }
    
    public func getCards(from index:Int) -> [Card] {
        var returnCards:[Card] = []
        print("getCards: \(index), \(cards.count)")
        for _ in index..<cards.count {
            if let card = self.draw() {
                returnCards.insert(card, at: 0)
            }
        }
        print("Returning cards")
        return returnCards
    }
    
    public func fillDeck(with suit: Suit) {
        for i in 0..<values.count {
            self.cards.append(Card(symbol: symbols[i], value: values[i], suit: suit))
        }
    }
    
    public var description:String {
        var str:String = ""
        for card in self.cards {
            str = "\(str) \(card.description)"
        }
        return str
    }
}

class Board {
    let deck:Deck = Deck()
    var stacks:[Deck]!
    let drawPile:Deck!
    let completedPile:Deck = Deck()
    let numStacks:Int!
    
    init(numStacks:Int, suits:[Suit]) {
        self.numStacks = numStacks
        for suit in suits {
            deck.fillDeck(with: suit)
        }
        
        deck.shuffle()
        
        stacks = []
        drawPile = Deck()
        for _ in 0..<numStacks {
            stacks.append(Deck())
        }
    }
    
    public func setupStacks() {
        
    }
    
    public func makeMove(symbol: String, suit: Suit, src: Int, dest: Int) -> String? {
        return nil
    }
    
    public func draw() {
        for i in 0..<numStacks {
            if let card = drawPile.draw() {
                card.faceUp = true
                stacks[i].add(card: card)
            }
        }
    }
    
    public func clear(stackNum: Int) -> Suit? {
        if stackNum < self.numStacks {
            print ("Stack number \(stackNum) does not exist")
            return nil
        }
        let deck = stacks[stackNum]
        
        if deck.cards.count < 13 {
            print("Stack \(stackNum) has only \(deck.cards.count) cards. Cannot be cleared")
            return nil
        }
        
        guard let topCard = deck.getTopCard(),
            topCard.value == 1 else {
                print("Top card of stack should be an Ace")
                return nil
        }
        
        var topCardValue:Int = topCard.value
        let topCardSuit = topCard.suit
        for i in (0..<deck.cards.count).reversed() {
            if deck.cards[i].value != topCardValue && deck.cards[i].suit != topCardSuit {
                print("This stack cannot be cleared")
                return nil
            }
            topCardValue = topCardValue - 1
        }
        
        // we came this far so this means we can clear
        for _ in 0..<13 {
            deck.draw()
        }
        return topCardSuit
    }
    
    public var description:String {
        var str:String = ""
        for i in 0..<self.numStacks {
            let deck = self.stacks[i]
            str = "\(str)\(i):\(deck.description)\n"
        }
        str = "\(str)Draw Pile:\(drawPile.description)\n\nCompleted Stacks:\(completedPile.description)\n"
        return str
    }
}

class ScorpionBoard : Board {
    
    init() {
        super.init(numStacks: 7, suits: [.clubs, .diamonds, .hearts, .spades])
    }
    
    override
    public func setupStacks() {
        var stackNum = 0
        for i in 0..<deck.cards.count - 3 {
            let card = deck.cards[i]
            stacks[stackNum].add(card: deck.cards[i])
            if stackNum < 4 && stacks[stackNum].cards.count < 4 {
                card.faceUp = false
                print("Stack \(stackNum), card \(stacks[stackNum].cards.count)")
            } else {
                card.faceUp = true
            }
            stackNum = (stackNum + 1) % numStacks
        }
        deck.cards[deck.cards.count - 3].faceUp = false
        deck.cards[deck.cards.count - 2].faceUp = false
        deck.cards[deck.cards.count - 1].faceUp = false
        drawPile.add(card: deck.cards[deck.cards.count - 3])
        drawPile.add(card: deck.cards[deck.cards.count - 2])
        drawPile.add(card: deck.cards[deck.cards.count - 1])
    }

    override
    public func makeMove(symbol: String, suit: Suit, src: Int, dest: Int) -> String? {
        print("\(symbol), \(suit.description), \(src), \(dest)")
        guard src < numStacks && dest < numStacks else {
                return "***Invalid Move***: Source stack \(src) or destination stack \(dest) not found"
        }
        let srcDeck = stacks[src]
        let destDeck = stacks[dest]
        
        var foundCard:Card!
        var foundCardIndex = 0
        for card in srcDeck.cards {
            if card.symbol == symbol && card.suit == suit {
                foundCard = card
                break
            }
            foundCardIndex += 1
        }
        
        print(srcDeck.cards[foundCardIndex].description)
        
        guard foundCard != nil else {
            return "***Invalid Move***: Card \(symbol)\(suit) not found in \(src) stack"
        }
        
        if let destTopCard = destDeck.getTopCard() {
            if destDeck.getTopCard()?.value == foundCard.value + 1 {
                let cardsToMove:[Card] = srcDeck.getCards(from: foundCardIndex)
                destDeck.addAll(cards: cardsToMove)
            } else {
                return "***Invalid Move***: Card \(String(describing: foundCard)) cannot be moved to \(destTopCard)"
            }
            
        } else if foundCard.value == 13 {
            // foundCard is a K and dest deck is empty
            let cardsToMove:[Card] = srcDeck.getCards(from: foundCardIndex)
            destDeck.addAll(cards: cardsToMove)
        } else {
            return "***Invalid Move***"
        }
        
        return nil
    }
}

func updateLabels() {
    print ("Entering updateLabels")
    for i in 0..<scorpion.numStacks {
        stackViews[i].subviews.forEach { $0.removeFromSuperview() }

        var y:CGFloat = 0
        for card in scorpion.stacks[i].cards {
            let cardImageView = UIImageView()
            if card.faceUp {
                switch card.suit! {
                case .clubs : cardImageView.image = UIImage(named: "club_\(card.symbol.lowercased())")
                case .diamonds : cardImageView.image = UIImage(named: "diamond_\(card.symbol.lowercased())")
                case .spades : cardImageView.image = UIImage(named: "spade_\(card.symbol.lowercased())")
                case .hearts : cardImageView.image = UIImage(named: "heart_\(card.symbol.lowercased())")
                }
            } else {
                cardImageView.image = UIImage(named: "cardback1")
            }
            cardImageView.frame = CGRect(x: CGFloat(0.0), y: y, width: width, height: width*1.5)
            cardImageView.contentMode = .scaleAspectFit
            cardImageView.backgroundColor = UIColor.white
            cardImageView.layer.cornerRadius = 5
            y += 40
            stackViews[i].addSubview(cardImageView)
        }
    }
    errorLabel.text = ""
    print ("Leaving updateLabels")
//    labels[7].text = "Draw Pile: \(scorpion.drawPile.description)"
//    labels[8].text = "Completed Stacks: \(scorpion.completedPile.description)"

}

let scorpion:Board = ScorpionBoard()
scorpion.setupStacks()
updateLabels()

var selectedStack = -1

class Responser: NSObject
{
    
    @objc func drawpileClicked(button:UIButton) {
        let numberOfCardsInDrawPile = scorpion.drawPile.cards.count
        scorpion.draw()
        for i in 0..<numberOfCardsInDrawPile {
            scorpion.clear(stackNum: i)
        }
        button.setImage(UIImage(named: "emptycard"), for: .normal)
        updateLabels()
    }
    
    @objc func stackClicked(button:UIButton) {
//        updateLabels()
        if selectedStack == -1 {
            selectedStack = button.tag
            errorLabel.text = ""
        } else if selectedStack == button.tag {
            selectedStack = -1
            errorLabel.text = ""
        } else {
            let srcDeck = scorpion.stacks[selectedStack]
            if let destCard = scorpion.stacks[button.tag].getTopCard() {
                for card in srcDeck.cards {
                    if (card.value == (destCard.value - 1)) && card.suit == destCard.suit {
                        // card found
                        if let error = scorpion.makeMove(symbol: card.symbol, suit: card.suit, src: selectedStack, dest: button.tag) {
                            // display error
                            errorLabel.text = error
                            print(error)
                        } else {
                            if let card = srcDeck.getTopCard() {
                                card.faceUp = true
                            }
                            if let suit = scorpion.clear(stackNum: button.tag) {
                                
                            }
                            updateLabels()
                            selectedStack = -1
                            return
                        }
                    }
                    print ("Card \(card.description) -> \(destCard.description)")
                }
                errorLabel.text = "No card found in stack \(selectedStack + 1) that can be moved to stack \(button.tag + 1)"
                selectedStack = -1
                print ("Card not found")
            } else {
                for card in srcDeck.cards {
                    // move the first key you find in the src stack to the destination stack
                    if card.value == 13 && card.faceUp {
                        if let error = scorpion.makeMove(symbol: card.symbol, suit: card.suit, src: selectedStack, dest: button.tag) {
                            errorLabel.text = error
                            print(error)
                        } else {
                            if let card = srcDeck.getTopCard() {
                                card.faceUp = true
                            }
                            scorpion.clear(stackNum: button.tag)
                            updateLabels()
                            selectedStack = -1
                            return
                        }
                    }
                }
                errorLabel.text = "Destination stack empty and there is no K in the source stack"
                print ("Destination stack empty and there is no K in the source stack")
            }
        }
        print("Stack # \(button.tag) clicked")
    }
}

let responder = Responser()

for i in 0..<stackViews.count {
    let button:UIButton = UIButton(frame: stackViews[i].frame)
    button.tag = i
    view.addSubview(button)
    button.addTarget(responder, action: #selector(responder.stackClicked), for: .touchUpInside)
}

let drawpileButton:UIButton = UIButton(frame: CGRect(x: 20, y: 20, width: width, height: width*1.5))
drawpileButton.setImage(UIImage(named: "cardback1"), for: .normal)
view.addSubview(drawpileButton)
drawpileButton.addTarget(responder, action: #selector(responder.drawpileClicked), for: .touchUpInside)

