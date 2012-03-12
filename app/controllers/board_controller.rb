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
   set_player_markers
   square_pressed = params[:square].to_sym    
   @board[square_pressed] = @human_player
   @board.save
   determine_winner_or_draw
   @message
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
   if available_computer_moves.empty? == true
     determine_winner_or_draw
   else 
     @board[available_computer_moves.first] = @computer_player
   end   
   @board.save
   determine_winner_or_draw
   @message 
 end
  
 def determine_winner_or_draw
   @possible_wins = [[:s0,:s4,:s8], [:s2,:s4,:s6], [:s0,:s1,:s2], [:s3,:s4,:s5], [:s6,:s7,:s8], [:s0,:s3,:s6], [:s1,:s4,:s7], [:s2,:s5,:s8]]
   @board = Board.first
   @detect_wins = []
   available_moves = []
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
      elsif  
         @board.attributes.each do |column_name, column_value|
           if column_value.nil?
             available_moves << column_name       
           end
         end
         if available_moves.empty? == true
           @message = "It's a draw." 
          end 
       end        
    end 
 end

  def quit_game
    @player = Player.first.destroy
    @board = Board.first.destroy
    render "home/index"
  end
 


 
 

    
=begin 
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

=begin
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
=end