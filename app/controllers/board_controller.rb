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
    end
    @player.save  
    render "board/index"
  end
  
  def x_or_o
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
   human_move = params[:square].to_sym    
   x_or_o
   @board[human_move] = @human_player
   @board.save
   computer_move   
 end
 

 def computer_move
#   available_computer_moves = []
#   @board.attributes.each do |column_name, column_value|
#     if column_value.nil?
#       available_computer_moves << column_name     
#     end
#   end 
       
#   x_or_o
 #  @board[computer_move] = @computer_player
 #  @board.save
   render "board/index"
 end
  
  
 def quit_game
   @player = Player.first.destroy
   @board = Board.first.destroy
   render "home/index"
 end


#create model for board. * columns

#How do I determine if game board is at win lose or draw?
 
end

