//
//  ViewController.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import UIKit

class ViewController: UIViewController {
    
    /* ------------
     Scores Updates
     -------------- */
    
    var playerOneScore = 0
    var playerOneTimer: Timer?
    
    var playerTwoScore = 0
    var playerTwoTimer: Timer?
        
    /* -------
     Constants
     -------- */
    
    // After players press their button, they have this much time to select a set.
    let timeForPlayersToFindSet = 5.0
    
    // When the time for players to find a match elapses, their score is penalized with the value below.
    let scoreTimePenalty = 10
    
    // Dictonaries that map SetCard properties to visual elements that will be displayed on the matching SetCardViews.
    let shapesDict = [SetCard.Shape.typeOne: "▲", SetCard.Shape.typeTwo: "●", SetCard.Shape.typeThree: "■"]
    let colorDict = [SetCard.Color.typeOne: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), SetCard.Color.typeTwo: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), SetCard.Color.typeThree: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)]
    // filling dict: [1: full, 2: outline, 3: striped]
    
    // Selected cards in the game are highlighted on the screen by having a border.
    let borderWidthForSelectedCards: CGFloat = 3.0
    
    // All SetCardView will be displayed on the openCardsCanvas with the ratio (width/height) below:
    let ratioForCardViews = CGFloat(5.0/8.0)
    
    
    /* --------------------
     Properties (variables)
     -----------------------*/
    
    // A view that displays the SetCardViews of the setCards included in openCards.
    @IBOutlet weak var openCardsCanvas: UIView!
    
    @IBOutlet weak var playerOneScoreLabel: UILabel!

    @IBOutlet weak var playerTwoScoreLabel: UILabel!
        
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
        
    /* -------
     Methods
     -------- */

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The following snippet will run only once after the initial view and its subviews will be laid out.
        if isJustInitiated {
            createCardsToCardsViewsMapper() // This function creates cardsToViewsMapper (a map: [SetCard: SetCardView])
            placeOpenCardsViewsOnGrid()
            
            // Define gesture recognizers for the entire screen
            addGesturesRecognizers()
            gameOverLabel.isHidden = true
            isJustInitiated = false
        } else {
            placeOpenCardsViewsOnGrid()
        }
    }
    
    // The sole puprpose of this (overriden) function is to invalidate the timers to prevent reference cycles in memory.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        stopTimers()
    }
    
    /* -------------------
     Functions for Buttons
     ---------------------*/
    
    @IBAction func newGamePressed(_ sender: UIButton) {
        // Reset the relevant propeties for a new game:
        game = SetGame()
        matchesCounter = 0
        openCardsCanvas.isHidden = false
        gameOverLabel.isHidden = true
        updateViewFromModel()
    }
    
    @IBAction func dealButtonPressed(_ sender: UIButton) {
        preformThreeCardsDealing()
    }

    // This function currently doesn't penalize with points reduction (meaning, it rewards the player for a found match).
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
        updateViewFromModel()
    }
    
    
    @IBAction func playerOneButtonPressed(_ sender: Any) {
        //
    }
    
    @IBAction func playerTwoButtonPressed(_ sender: Any) {
        //
    }
    
    
    /* ---------------
     Gesture Handlers
     ---------------- */
    
    // This function is called every time a user taps on a setCardView. It updates the model
    // that a card was selected and it updates the view accordingly.
    @objc private func cardTapHandler(recognizer: UITapGestureRecognizer) {
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
        game.openCards.shuffle()
        updateViewFromModel()
    }
    
    /* ------------------------
     Private Methods for Timers
     -------------------------- */
    
    // Every time the gameTimer run out of time, the potential score for a match decreases.
    @objc private func updateUserScoreForTime() {
        if game.baseScoreFactor > 0 {
            game.baseScoreFactor -= scoreTimePenalty
        }
    }
    
    // Every time the enemyTimer run out of time, the computer marks a match.
    @objc private func makeEnemyTurn() {
        if isAMatchMarked {return} // ignore (if a match is marked, the game is paused).
        
        game.makeEnemyTurn()
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
        playerTwoScoreLabel.text = "Score: \(game.score)"
//        iphoneScoreLabel.text = "Score: \(game.enemyScore)"
//        iphoneStateLabel.text = (game.score >= game.enemyScore) ? enemyLosingTitle : enemyWinningTitle
        
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
        // Check if need to display the game over label and hide the cards' canvas
        if game.isGameOver {
            openCardsCanvas.isHidden = true
            gameOverLabel.isHidden = false
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
    
//    // Invalidate timer instances.
//    private func stopTimers() {
//        gameTimer?.invalidate()
//        enemyTimer?.invalidate()
//    }
//
    // Start timers and reset the Base for score (which decreases as the timer proceeds).
//    private func startTimers() {
//        gameTimer = Timer.scheduledTimer(timeInterval: timeForPlayerToFindSet, target: self, selector: #selector(updateUserScoreForTime), userInfo: nil, repeats: true)
//
//        let enemyTime = Double.random(in: minWaitingDurationForEnemyTurn..<maxWaitingDurationForEnemyTurn)
//        enemyTimer = Timer.scheduledTimer(timeInterval: enemyTime, target: self, selector: #selector(makeEnemyTurn), userInfo: nil, repeats: true)
//        game.baseScoreFactor = game.initialBaseScoreFactor
//    }
    
    
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
    
    // Returns a tuple representing the desired dimensions for a grid of openCards.count card views.
    private func getGridDimensions(for openCardsCount: Int) -> (Int,Int) {
        // We always seek to create a "perfect square" grid (2x2 or 3x3, 4x4..).
        // When openCardsCount is not a perfect square, we create a perfect square grid with bigger capacity
        // than openCardsCount (dim*dim > openCardsCount), and if this grid (dim*dim)
        // is too big for openCardsCount, we "trim" one column from the grid.
        
        var rows, cols: Int
        
        // number of rows is the integer root of "openCardsCount"
        rows = Int(sqrt(Double(openCardsCount)))
        
        // if the current square grid (rows x rows) isn't big enough, extend it to (rows+1) x (rows+1)
        if rows * rows < openCardsCount {
            rows += 1
        }
        
        // if openCardsCount can fit into (rows+1) x (rows), use these dimensions. otherwise, use (rows+1)x(rows+1)
        cols = (rows * (rows - 1) >= openCardsCount) ? rows - 1: rows
        
        return (rows,cols)
    }
    
    // Make all necessary adjustments and setups in the model to display 3 new SetCardViews on the screen.
    // (and then update the view from the model)
    private func preformThreeCardsDealing() {
        if isAMatchMarked {
            matchesCounter += 1
            game.replaceMatchWithCardsFromDeck() // get new cards from the deck to replace the match
        }
        else if !game.deck.isEmpty {
            // Check if need tp penalize
            if game.findMatchInOpenCards() != nil {
                // if the user pressed "deal" but there was a match in openCards
                game.score -= game.unRequiredDrawPenalty
            }
            
            game.resetCardSelection()
            game.popThreeCardsFromDeck()
        }
        updateViewFromModel()
    }
}
