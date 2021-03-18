# ios_ex2
Set (game). Second exercise in ios course. 

definition: "live play" - Every situation in the game where a match\set isn't specifically marked on the screen. 
Note: If a match\set is specifically marked on the screen, the game is considered to be paused. 

Scoring "mechanism": 


  -- The user\player is rewarded with points for every match s.he founds.
      -- The less open cards are in the game, the more points the user will get for a match (and vice versa). 
      -- every 10 seconds of "live play" that goes by without the user selecting a match, the reward for a match decreases by a point (approximately). 
  
  -- The user\player is penalized with 5 points for every unsuccessful match (especially because deselection of cards was implemented).
  
  -- The enemy(iphone) makes a turn every 5-20 seconds (randomized).
      -- If the enemy's turn has arrived and the player hadn't found a match yet, the enemy is rewarded with 3 points. 

Every time the user presses the "new game" button, all scores and timers are being reset, and a new game of Set is launched to the screen.
