class BoardController < ApplicationController  
  def index
   @board = Board.first
  end  
  
  def who_is_first
    create_new_board
    @player = Player.new
    @player.save
    if params[:first] == "true"
      Player.first.update_attribute(:is_first, "true")    
      @message = 'you are player X'
    else  
      params[:first] == "false"
      Player.first.update_attribute(:is_first, "false") 
      @message = 'params[:first] == "false"'       
    end
    @player.save  
    render "board/index"
  end
  
#  def turns
#    @turns = 
#    find @player t or f   
#  end
  
#  def x_or_o
#    if 
#  end
  
 def create_new_board
   @board = Board.new
   @board.save
 end 
 
 def human_move
   @board = Board.first
   @player = Player.first
   human_move = params[:square].to_sym   
   if @player[:is_first] 
    @board[human_move] = "X"
   else
    @board[human_move] = "O"    
   end
  @board.save
  computer_move   
 end
 
 def computer_move
   
#   @board.attributes.each do |column_name, column_value|
#    computer_move =  
#   end
   
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

