# ios_ex2
Set (game). Second exercise in ios course. 

Definition: "live play" - Every situation in the game where a match\set isn't specifically marked on the screen. 

Notes: 
1. As soon as the app is initiated, the game starts a "live play", and the enemy player ("the iphone") "starts to look for matches". 
1. If a match\set is specifically marked on the screen, the game is considered to be paused. 

Scoring "mechanism": 

  1. The user\player is rewarded with points for every match s.he founds:
      a. The less open cards are in the game, the more points the user will get for a match (and vice versa). 
      b. every 10 seconds of "live play" that goes by without the user selecting a match, the reward for a match decreases by a point 
         (approximately; This operation is handled by a var called "baseForScore"). 
  
  2. The user\player is penalized with 5 points for every unsuccessful match (especially because deselection of cards was implemented).

  3. The enemy(iphone) makes a turn every 5-20 seconds (randomized).
      a. If the enemy's turn has arrived and the player hadn't found a match yet, the enemy is rewarded with 3 points. 

General Notes: 
  1. Whenever the enemy's score is higher than the user's score, it is displayed with 😂 in the bottom left corner o the screen. Otherwise, it is displayed with 😢.
  2. Every time the user presses the "new game" button, all scores and timers are being reset, and a new game of Set is launched to the screen.
