Tic-tac-toe
===========
This is an unbeatable tic tac toe app written in rails.  Even though you can never win, you can tie sometimes and there is a little surprise ending when the computer wins. :D  This was my first unbeatable tic tac toe before I used the minimax algorithm.  It uses fork detection and calculates the best move based on winning, losing, or making a fork.

To run the app:
---------------
+ Clone the repo
+ Type $ bundle install
+ This app is using postgres, so make sure you have a server running.
+ Type rake db:migrate. If you get an error you may need to type rake db:reset.
+ Start the server $ rails s
+ Navigate to localhost:3000 in you browser.
+ Choose who you would like to go first.
