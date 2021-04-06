//
//  ViewController.swift
//  Concentration
//
//  Created by Alon Reik on 09/03/2021.
//

import UIKit

class ConcentrationViewController: UIViewController {
    
    var gameTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateScoreForTime), userInfo: nil, repeats: true)
        startNewGame()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameTimer?.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        for button in cardButtons {
            button.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }
    
    @objc func updateScoreForTime() {
        game.score -= 1
    }
    
    lazy var game = Concentration(numberOfPairsOfCards: (cardButtons.count + 1) / 2)
    
    @IBOutlet var background: UIView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var flipCountLabel: UILabel!
    
    @IBOutlet var cardButtons: [UIButton]!
        
    @IBAction func touchCard(_ sender: UIButton) {
        game.flipCount += 1
        if let cardNumber = cardButtons.firstIndex(of: sender){
            game.chooseCard(at: cardNumber) // Controller is updating the model
            updateViewFromModel() // Controller is updating the view
        } else {
            print("chosen card was not in cardButtons") 
        }
    }
    
    // Resets the score(flipCount) and flips back all cards.
    @IBAction func newGamePressed(_ sender: UIButton) {
        startNewGame()
    }
    
    let themes = [GameTheme(emojis: ["🦇", "😱", "🙀", "😈", "🎃", "👻", "🍭", "🍬", "🍎"], cardsColor: #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1), bgColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
                  GameTheme(emojis: ["🙀", "🦇", "🐱", "🐥", "🐦", "🦉", "🐺", "🦄", "🐷"], cardsColor: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), bgColor: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)),
                  GameTheme(emojis: ["⚽️", "🥎", "⚾️", "🥋", "🎽", "🥏", "🤿","🏒", "🏉"], cardsColor: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), bgColor: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)),
                  GameTheme(emojis: ["🍭", "🎃", "🍎", "🍬", "🍌", "🥝" ,"🍞", "🥕", "🥯"], cardsColor: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), bgColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)),
                  GameTheme(emojis: ["😱", "😀", "😋", "😁", "😜", "🥳", "😛", "🤩", "😏"], cardsColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), bgColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)),
                  GameTheme(emojis: ["🏳️‍🌈", "🏳️", "🏴","🏴‍☠️","🏁","🇧🇿","🇫🇯","🇹🇭","🇮🇳"], cardsColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), bgColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
    ]
    
    var gameTheme: GameTheme? {
        didSet {
            if let gameTheme = self.gameTheme {
                emoji.removeAll()
                emojies = gameTheme.emojies
                updateViewFromModel()
            }
        }
    }
    
    // Resets all Model and View properties
    func startNewGame() {
        if let currentTheme = gameTheme {
            background.backgroundColor = currentTheme.bgColor
            emojies = currentTheme.emojies
            resetGameProperties()
            updateViewFromModel()
        } else {
            let themeIndex = Int.random(in: 0..<themes.count)
            gameTheme = themes[themeIndex]
            emojies = themes[themeIndex].emojies
            resetGameProperties()
            updateViewFromModel()
        }
    }

    func updateViewFromModel() {
        guard let gameTheme = self.gameTheme, let background = self.background else {
            return
        }
        background.backgroundColor = gameTheme.bgColor
        
        scoreLabel.text = "Score: \(game.score)"
        flipCountLabel.text = "Flips: \(game.flipCount)"
        for index in cardButtons.indices { // making sure every card is viewed correctly
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : gameTheme.cardsColor
            }
        }
    }

    // A dictionary mapping an identifier of a card (Int) to an emoji (String)
    var emoji = [Int: String]()
    
    // The current set of emojies.
    var emojies: [String] = []
    
    // Assigns the given card with an emoji from the emojiChoices array.
    func emoji(for card: Card) -> String {
        let numOfEmojiChoices = emojies.count
        if emoji[card.identifier] == nil, numOfEmojiChoices > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(numOfEmojiChoices)))
            emoji[card.identifier] = emojies.remove(at: randomIndex)
        }
        return emoji[card.identifier] ?? "?"
    }
    
    // Resets the emoji dictionary, the game (model) object and the game's timer.
    private func resetGameProperties() {
        emoji.removeAll() // clear previous mapping between cards and emojis
        game.resetGame()
        
        // reset timer
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateScoreForTime), userInfo: nil, repeats: true)
    }
}

class GameTheme {

    var emojies: [String]
    let cardsColor: UIColor
    let bgColor: UIColor
    
    init(emojis: [String], cardsColor: UIColor, bgColor: UIColor) {
        self.emojies = emojis
        self.cardsColor = cardsColor
        self.bgColor = bgColor
    }
}
