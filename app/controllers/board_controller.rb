class BoardController < ApplicationController  
  def index
   @board = Board.first
  end 
  
  def create_new_board
    @board = Board.new
    @board.save
  end 
  
  def create_new_player
    @player = Player.new
    @player.save
  end
  
  def who_is_first
    create_new_board
    create_new_player
    if params[:first] == "true"
      Player.first.update_attribute(:is_first, true)        
    else  
      params[:first] == "false"
      Player.first.update_attribute(:is_first, false) 
      computer_move       
    end
    @player.save  
    render "board/index"
  end
  
  def set_player_markers #is there a better name for this?
    @player = Player.first
    if @player[:is_first] 
       @human_player = "X"
       @computer_player = "O"
      else
       @human_player = "O"
       @computer_player = "X"    
      end
  end
 
 def human_move
   @board = Board.first
   @player = Player.first
   square_pressed = params[:square].to_sym    
   set_player_markers
   @board[square_pressed] = @human_player
   @board.save
   computer_move 
   render "board/index"  
 end
 
 def computer_move
   available_computer_moves = []
   @board.attributes.each do |column_name, column_value|
     if column_value.nil?
       available_computer_moves << column_name     
     end
   end
   set_player_markers
   @board[available_computer_moves.first] = @computer_player
   @board.save
 end
  
 def quit_game
   @player = Player.first.destroy
   @board = Board.first.destroy
   render "home/index"
 end
 
#How do I determine if game board is at win lose or draw?

=begin 
 def possible_outcomes
   @diagonal_right = [s0,s4,s8] #if @board.attributes are 3 x or 3 o in [s0,s4,s8] then congratulate winner
   make this a hash with 
   key                value
   @diagonal_left = [s2,s4,s6]
   @horizontal_top = [s0,s1,s2]
   @horizontal_middle = [s3,s4,s5]
   @horizontal_bottom = [s6,s7,s8]
   @vertical_left = [s0,s3,s6]
   @vertical_middle = [s1,s4,s7]
   @vertical_right = [s2,s5,s8]
   if any of the arrays have 3 in a row of the same either x or o
     @message_winner = "Congrats Player you are the winner."
     @message_loser = "Congrats Player. you are the loser." # it would be fun to keep track of games and make snarky remarks, like you lost, again.  etc. 
   elsif all of the board is full but no 3 in a row 
     @message = "It is a draw."
     #option to play again
     
 end
 
 
 def evaluate
 available_computer_moves = []
 @evaluate.attributes.each do |column_name, column_value|
    if column_value = +1  #figure how to use/can use pos and neg numbers
      available_computer_moves << column_name     
    end
  end
  
 end
=end   
   

end
