//
//  ViewController.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import UIKit

class SetViewController: UIViewController {
    
    /* -------
     Constants
     -------- */
    
    let timeForPlayersToFindSet = 5.0
    let penaltyForMatchlessTurn = 3
    let scoreRewardForMatch = 5

    // Dictonaries that map SetCard properties to visual elements that will be displayed on the matching SetCardViews.
    let shapesDict = [SetCard.Shape.typeOne: "▲", SetCard.Shape.typeTwo: "●", SetCard.Shape.typeThree: "■"]
    let colorDict = [SetCard.Color.typeOne: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), SetCard.Color.typeTwo: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), SetCard.Color.typeThree: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)]
    // filling dict: [1: full, 2: outline, 3: striped]
    
    // Selected cards in the game are highlighted on the screen by having a border.
    let borderWidthForSelectedCards: CGFloat = 3.0
    
    // All SetCardView will be displayed on the openCardsCanvas with the ratio (width/height) below:
    let ratioForCardViews = CGFloat(5.0/8.0)
    
    
    /* ----------------
     Players Properties
     -------------- */
    
    var playerOneScore = 0
    var playerOneTimer: Timer?
    var isPlayerOneTurn = false
    @IBOutlet weak var playerOneScoreLabel: UILabel!
    
    var playerTwoScore = 0
    var playerTwoTimer: Timer?
    var isPlayerTwoTurn = false
    @IBOutlet weak var playerTwoScoreLabel: UILabel!

    
    /* -----------------
     All Other Properties
     ------------------*/
    
    // A view that displays the SetCardViews of the setCards included in openCards.
    @IBOutlet weak var openCardsCanvas: UIView!
    
    @IBOutlet weak var gameOverLabel: UILabel!
    
    var game: SetGame = SetGame()
    
    // A mapper between setCard objects (part of the model) and setCardViews (part of the view)
    var cardsToViewsMapper: [SetCard: UIView] = [:]
    
    // A "helper variable" used to alert when a match is found
    var matchesCounter = 0
    
    var isAMatchMarked: Bool {
        get {
            return matchesCounter < game.matches.count
        }
    }
    
    // A "helper varibale" used to make initial setups in the viewDidLayoutSubviews method.
    var isJustInitiated = true
        
    
    /* ---------------
     Overriden Methods
     ---------------- */

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The following snippet will run only once after the initial view and its subviews will be laid out.
        if isJustInitiated {
            createCardsToCardsViewsMapper() // This function creates cardsToViewsMapper (a map: [SetCard: SetCardView])
            placeOpenCardsViewsOnGrid()
            
            // Define gesture recognizers for the entire screen
            addGesturesRecognizers()
            
            // Hide gameOver label
            gameOverLabel.isHidden = true
            
            // make the scoreLabels' borders transparent but with some width.
            initiateScoreLabelBorders()
            
            // make sure all the setups above only happen once.
            isJustInitiated = false
 
        } else { // will happen every time the device will change orientation:
            placeOpenCardsViewsOnGrid()
        }
    }
    
    /* -------------------
     Functions for Buttons
     ---------------------*/
    
    // Resets the relevant propeties for a new game:
    @IBAction func newGamePressed(_ sender: UIButton) {
        game = SetGame()
        
        // reset scores:
        playerOneScore = 0
        playerTwoScore = 0
        matchesCounter = 0
        
        // hide gameOverLabel and display the openCardsCanvas:
        openCardsCanvas.isHidden = false
        gameOverLabel.isHidden = true
        
        initiateScoreLabelBorders()
        
        updateViewFromModel()
    }
    
    @IBAction func dealButtonPressed(_ sender: UIButton) {
        preformThreeCardsDealing()
    }

    // Pressing the cheatButton on a player's turn automatically finds a match and ends the turn
    // (no scores rewards or penalties).
    @IBAction func cheatButtonPressed(_ sender: UIButton) {
        guard !isAMatchMarked else {return} // if a match is marked, the game is paused, and we can ignore the pressing.
        
        game.resetCardSelection()
        if let match = game.findMatchInOpenCards() {
            for i in 0..<match.count {
                game.chooseCard(chosenCard: match[i])
            }
        } else if !game.deck.isEmpty {
            print("There isn't a 'set' in the currently open cards, so the game is opening more cards (if available) and finds a set")
            preformThreeCardsDealing()
            cheatButtonPressed(sender)
        }
        stopTimer()
        updateViewFromModel()
    }
    
    @IBAction func playerOneButtonPressed(_ sender: Any) {
        playerButtonPressed(playerIdentifier: 1)
        updateViewFromModel()
    }
    
    @IBAction func playerTwoButtonPressed(_ sender: Any) {
        playerButtonPressed(playerIdentifier: 2)
        updateViewFromModel()
    }
    
    /* ---------------
     Gesture Handlers
     ---------------- */
    
    // This function is called every time a user taps on a setCardView. It updates the model
    // that a card was selected and it updates the view accordingly.
    @objc private func cardTapHandler(recognizer: UITapGestureRecognizer) {
        
        if !isPlayerOneTurn && !isPlayerTwoTurn { // if this is already one of the players' turns, ignore
            print("Tried to touch a card witout taking the turn (by pressing player 1 or player 2)")
            return
        }
        
        // make sure that the recognizer finished recognizing the tap,
        // and then downcast the view that recognized the tap because we know its a SetCardView
        guard recognizer.state == .ended, let cardView = recognizer.view as? SetCardView else {
            return
        }
        // get the SetCard instance that its view was tapped on
        if let index = cardsToViewsMapper.values.firstIndex(of: cardView){
            let card = cardsToViewsMapper.keys[index]
            
            if isAMatchMarked {
                // if selected card is already selected, ignore.
                if game.selectedCards.contains(card) {return}
                else {
                    matchesCounter += 1
                    game.chooseCard(chosenCard: card)
                }
            } else {
                game.chooseCard(chosenCard: card)
                if let lastMatch = game.matches.last {
                    if game.selectedCards == lastMatch {
                        updateScoreForMatch()
                        stopTimer()
                    }
                }
            }
        }
        updateViewFromModel()
    }
    
    // This function is called every time the user makes a swipe down gesture.
    @objc private func swipeDownHandler(recognizer: UISwipeGestureRecognizer){
        guard recognizer.direction == [.down] else {
            return
        }
        preformThreeCardsDealing()
    }
    
    // This function is called every time the user makes a rotation gesture. It
    // shuffles the openCards (in the model) and then it displays the result on openCardsCanvas.
    @objc private func rotationHandler(recognizer: UIRotationGestureRecognizer) {
        guard recognizer.state == .ended else {
            return
        }
        game.shuffleOpenCards()
        updateViewFromModel()
    }
    
    /* ------------------------
     Private Methods for Timers
     -------------------------- */
    
    // This function is called whenever a player turn's time has elpased.
    @objc private func TimeForTurnElapsed() {
        game.resetCardSelection()
        // penalize the player
        if isPlayerOneTurn {
            playerOneScore -= penaltyForMatchlessTurn
        } else {
            playerTwoScore -= penaltyForMatchlessTurn
        }
        stopTimer()
        updateViewFromModel()
    }

    
    /* -------
     Private Methods
     -------- */

    // Updates the display settings of the labels and the SetCardViews according to their matching
    // instances in the model.
    private func updateViewFromModel() {
        // Creates a grid for openCardsCanvas and assigns each openCard view with a cell within that grid.
        placeOpenCardsViewsOnGrid()

        // Update labels
        playerOneScoreLabel.text = "Score: \(playerOneScore)"
        playerTwoScoreLabel.text = "Score: \(playerTwoScore)"
        
        playerOneScoreLabel.layer.borderColor = isPlayerOneTurn ? #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1): #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        playerTwoScoreLabel.layer.borderColor = isPlayerTwoTurn ? #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1): #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

        // Go over every subview of openCardsCanvas, and set is border color (orange\green for selected\matched cards)
        for view in openCardsCanvas.subviews {
            if let index = cardsToViewsMapper.values.firstIndex(of: view) {
                let card = cardsToViewsMapper.keys[index]
                view.layer.borderColor = game.selectedCards.contains(card) ? #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1): #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                if let lastMatch = game.matches.last {
                    if lastMatch.contains(card) {
                        view.layer.borderColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                    }
                }
            }
        }
        
        // Check if need to display the game over label
        if game.isGameOver {
            displayGameOverLabel()
        }
    }
    
    // Whenever the setGame is over, hides openCardsCanvas and displays an informative label.
    private func displayGameOverLabel() {
        openCardsCanvas.isHidden = true
        gameOverLabel.isHidden = false
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]
        
        if playerOneScore == playerTwoScore {
            gameOverLabel.attributedText = NSAttributedString(string: "The game ended with a tie!\n Press new game to play again!", attributes: attributes)
        } else {
            let winner = (playerOneScore < playerTwoScore) ? "Player 2!" : "Player 1!"
            gameOverLabel.attributedText = NSAttributedString(string: "The winner is\n" + winner + "\n Press new game to play again!", attributes: attributes)
        }
    }
    
    // Creates a grid for openCardsCanvas and assigns each openCard view with a cell within that grid.
    private func placeOpenCardsViewsOnGrid() {
        updateOpenCardsViews() // asures openCardsCanvas.subviews only include views of cards in openCards
                
        var grid = Grid(layout: .aspectRatio(ratioForCardViews), frame: openCardsCanvas.bounds)
        grid.cellCount = game.openCards.count
        
        // Go over all open cards, place and set their view on the grid.
        for (index, card) in game.openCards.enumerated() {
            guard let cardView = cardsToViewsMapper[card], let frameForCardView = grid[index] else {
                return
            }
            cardView.frame = frameForCardView
        }
    }
    
    // Define gesture recognizers and add them to the entire screen
    // (meaning, the gestures will be recognized wherever they will be made on the screen [not only on cards])
    private func addGesturesRecognizers() {
        // Adding a swipe down gesture recognizer (to the entire screen)
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownHandler(recognizer:)))
        swipeRecognizer.direction = [.down]
        openCardsCanvas.superview?.addGestureRecognizer(swipeRecognizer)
        
        // Adding a rotation gesture recognizer (to the entire screen)
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationHandler(recognizer: )))
        openCardsCanvas.superview?.addGestureRecognizer(rotationRecognizer)
    }
    
    // Creates and returns a custom SetCardView for the provided setCard object.
    private func getCardView(of card: SetCard) -> SetCardView {
        // initiate "empty" cardView instance:
        let viewCard = SetCardView(frame: CGRect())
        
        // Define a tap recognizer and assign it to every SetCardView
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(cardTapHandler(recognizer:)))
        viewCard.addGestureRecognizer(tapRecognizer)
        
        // set SetCardView color:
        switch card.color {
        case .typeOne: viewCard.color = .pink
        case .typeTwo: viewCard.color = .purple
        case .typeThree: viewCard.color = .green
        }
        // set SetCardView shapeType:
        switch card.shapeType {
        case .typeOne: viewCard.shape = .triangle
        case .typeTwo: viewCard.shape = .circle
        case .typeThree: viewCard.shape = .square
        }
        // set SetCardView numberOfShapes:
        switch card.shapesNum {
        case .one: viewCard.numberOfShapes = .single
        case .two: viewCard.numberOfShapes = .double
        case .three: viewCard.numberOfShapes = .triple
        }
        // set setCardView fillings
        switch card.filling {
        case .typeOne: viewCard.filling = .full
        case .typeTwo: viewCard.filling = .outline
        case .typeThree: viewCard.filling = .striped
        }
        return viewCard
    }
    
    // Creates the mapper between setCard objects and their matching setCardViews
    private func createCardsToCardsViewsMapper() {
        
        // When a SetGame instance is initialized, it has 69 cards in the deck and 12 cards in openCards:
        for card in game.deck {
            cardsToViewsMapper[card] = getCardView(of: card)
        }
        
        for card in game.openCards {
            cardsToViewsMapper[card] = getCardView(of: card)
        }
    }
    
    // Makes sure that the cardView of every open card in the game is a subview of openCardsCanvas
    private func updateOpenCardsViews() {
        
        // remove from the canvas views of cards that were already matched (and aren't in openCards anymore)
        for view in openCardsCanvas.subviews {
            guard let index = cardsToViewsMapper.values.firstIndex(of: view) else {
                print("Encountered an error.")
                return
            }
            let card = cardsToViewsMapper.keys[index]
            if !game.openCards.contains(card) {
                view.removeFromSuperview()
            }
        }
        
        // adds views of cards that were recently popped from the deck to openCards
        for card in game.openCards {
            guard let currCardView = cardsToViewsMapper[card] else{
                print("Couldn't find the view (cardView) for one of the open cards in the game")
                return
            }
            if !openCardsCanvas.subviews.contains(currCardView) {
                openCardsCanvas.addSubview(currCardView)
            }
        }
    }
    
    // Initiates a turn for the player of the given player identifier.
    private func playerButtonPressed(playerIdentifier: Int) {
        // if this is already one of the players' turns, ignore
        if isPlayerOneTurn || isPlayerTwoTurn {return}
        
        // "start a turn" for player #\(playerNumber)
        switch playerIdentifier {
        case 1:
            isPlayerOneTurn = true
            playerOneTimer = Timer.scheduledTimer(timeInterval: timeForPlayersToFindSet, target: self, selector: #selector(TimeForTurnElapsed), userInfo: nil, repeats: false)
        case 2: // if playernumber == 2
            isPlayerTwoTurn = true
            playerTwoTimer = Timer.scheduledTimer(timeInterval: timeForPlayersToFindSet, target: self, selector: #selector(TimeForTurnElapsed), userInfo: nil, repeats: false)
        default:
            print("Provided an unsupported player identifier")
        }
    }
    
    // Make all necessary adjustments and setups in the model to display 3 new SetCardViews on the screen.
    // (and then update the view from the model)
    private func preformThreeCardsDealing() {
        if isPlayerOneTurn || isPlayerTwoTurn {
            print("Try to deal again when the turn time is over ")
            return
        }
        
        if isAMatchMarked {
            matchesCounter += 1
            game.replaceMatchWithCardsFromDeck() // get new cards from the deck to replace the match
        }
        else if !game.deck.isEmpty {
            game.resetCardSelection()
            game.popThreeCardsFromDeck()
        }
        updateViewFromModel()
    }
    
    // Stops the current player's (whose turn just ended) timer
    private func stopTimer() {
        if isPlayerOneTurn {
            playerOneTimer?.invalidate()
            isPlayerOneTurn = false
        } else {
            playerTwoTimer?.invalidate()
            isPlayerTwoTurn = false
        }
    }
    
    // Rewards the current player (whose turn is now) if a score boost.
    private func updateScoreForMatch() {
        if isPlayerOneTurn {
            playerOneScore += scoreRewardForMatch
        } else {
            playerTwoScore += scoreRewardForMatch
        }
    }
    
    // make the scoreLabels' borders transparent but with some width.
    private func initiateScoreLabelBorders() {
        playerOneScoreLabel.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        playerOneScoreLabel.layer.borderWidth = 2.0
        
        playerTwoScoreLabel.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        playerTwoScoreLabel.layer.borderWidth = 2.0
    }
}
