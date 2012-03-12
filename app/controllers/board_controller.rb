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
  
  def set_player_markers 
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
   @message   
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
   @message 
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
       @group << @board[position]    
     end 
     @detect_wins << @group
   end
    @detect_wins.each do |value|
      if value == ["X","X","X"]
       @message = "Player X is the winner!"
      elsif value == ["O","O","O"]
        @message = "Player O is the winner!" 
      end      
    end 
#    detect_draw  
#     @message = "#{@board.attributes}"  
 end
 
 
 
 # !!!! There is a problem if you win on the last square press!!!!!!  It will not register. Maybe make an
#  array with all of the :s0, :s2, etc and pop them off when they are pressed or used by the computer
#  and then when it has 0 if no one won it would be a draw or if you add them in when it has 9 and no winner it will be a draw. 
 # I believe the problem has to do with the automatic ping ponging back and forth between the human_move and computer_move. 
 #Check the error screen. 
 
=begin 
  def detect_draw
    @board = Board.first
    detect_draw = [] 
    @board.attributes.each do |c, v|
      if v.nil?
        detect_draw << v     
      end
    end  
    if detect_draw.empty? == true
      @message = "It is a draw."
    end 
#    render "board/index"  
  end


 def win_lose_draw
  @board = Board.first
  @what_is_going_on = []
  @detect_wins.each do |combination|
    @what_is_going_on << combination
    @message = "#{@what_is_going_on}"
#    
#    elsif 
 #      @board.attributes.each do |column_name, column_value|
#          if column_value.all !=nil
 #           @message = "It is a draw."
#    end  
#  end  
  render "board/index" 
 end
end 
=end 
 
=begin
 

        column_value != nil && column_value != "X" && column_value != "O"
        @message = "It is a draw."          


 
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
