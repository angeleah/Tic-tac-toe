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
   determine_winner
   @message = "#{@detect_wins}"  
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
   determine_winner
   @message = "#{@detect_wins}"
 end
  
 def quit_game
   @player = Player.first.destroy
   @board = Board.first.destroy
   render "home/index"
 end 
 
 def determine_winner
   @possible_wins = [[:s0,:s4,:s8], [:s2,:s4,:s6], [:s0,:s1,:s2], [:s3,:s4,:s5], [:s6,:s7,:s8], [:s0,:s3,:s6], [:s1,:s4,:s7], [:s2,:s5,:s8]]
   @board = Board.first
   @detect_wins = []
   @possible_wins.each do |combination| 
     @group = []
     combination.each do |position|     
       @group << @board[position].to_s
     end 
     @detect_wins << @group
   end
 end
 
 
 
=begin  
 def determine_winner
   possible_wins = [[:s0,:s4,:s8], [:s2,:s4,:s6], [:s0,:s1,:s2], [:s3,:s4,:s5], [:s6,:s7,:s8], [:s0,:s3,:s6], [:s1,:s4,:s7], [:s2,:s5,:s8]]
   @board = Board.first
   @detect_wins = []
   possible_wins.each do |combination| 
     @row = []
     combination.each do |position|     
       @row << @board[position].to_s
     end 
     @detect_wins << @row
   end
 end
 
 #       win = true
 #       if @board[position] == "X"
 #         row << "X"
 #       end
 #       if row.match /O/
 #         win = false
 #       end
   
   
   


here are the possible moves. I need to
-compare the values
-return w,l,or,d


  
   possible_wins.each do |column_value|
      if column_value == "X" 
       
      elsif
         column_value == "O" 
        @message = "O is the winner!" 
      elsif
        column_value != nil && column_value != "X" && column_value != "O"
        @message = "It is a draw."          
      end
   end  
 end 

 
# def determine_winner
#   @board = Board.first
#    possible_wins.each do |array|
# array.each do |column_value|
#       if column_value.all == "X" 
#         @message = "X is the winner!"
#        elsif
#           column_value.all == "O" && value !nil
#          @message = "O is the winner!" 
#        elsif
#          column_value.!nil && column_value !=
#          @message = "It is a draw."          
#       end         
#      end  
#    end  
# end

 def possible_wins
   @diagonal_right = [:s0,:s4,:s8] 
   @diagonal_left = [:s2,:s4,:s6]
   @horizontal_top = [:s0,:s1,:s2]
   @horizontal_middle = [:s3,:s4,:s5]
   @horizontal_bottom = [:s6,:s7,:s8]
   @vertical_left = [:s0,:s3,:s6]
   @vertical_middle = [:s1,:s4,:s7]
   @vertical_right = [:s2,:s5,:s8]
 end  
 
 def determine_winner
   @board = Board.first
   possible_wins.each do |column_name, column_value|
      if column_value == "X" 
       @message = "X is the winner!"
      elsif
         column_value == "O" 
        @message = "O is the winner!" 
      elsif
        column_value != nil && column_value != "X" && column_value != "O"
        @message = "It is a draw."          
      end
   end  
 end
   
     @message_loser = "Congrats Player. you are the loser." # it would be fun to keep track of games and make snarky remarks, like you lost, again.  etc. 
   elsif all of the board is full but no 3 in a row 
     @message = "It is a draw."
     #option to play again
    
 
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
