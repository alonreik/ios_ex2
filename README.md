# ios_ex3
Set (game). Third exercise in ios course. 

Notes: 

1. The app currently only support a game of two (human) players.
2. The set "board" (openCardCanvas) is "freezed\paused" until one of the players claim its turn by pressing its appropiate button.
  a. Players should press their buttons only when they think they recognize a match.
  b. If one of the players pressed their button and couldn't find a match within 5 seconds, they will be penalized with 3 points. 
  
3. If one of the players managed use its turn to select 3 cards that form a set\match, the game is "paused" until new cards are dealt (using the relevant button or gesture).

4. Each player in its own turn may use the cheat button to find a new set\match, but it will not reward them with points. 

5. An informative message will be displayed at the end of each game. The message will indicate which player has won, and will suggest starting a new game.