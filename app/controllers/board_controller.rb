class BoardController < ApplicationController  
  def index

     @board=["","","","","","","","",""]    
  end  
  
  def who_is_first
    @player = Player.new
    @player.save
    if params[:first] == "true"
      Player.first.update_attribute(:player_1, "true")    
      @message = 'params[:first] == "true"'
    else  
      params[:first] == "false"
      Player.first.update_attribute(:player_1, "false") 
      @message = 'params[:first] == "false"'       
    end
    @player.save
    @board=["","","","","","","","",""]    
    render "board/index"
  end
  
  
  
  
 def quit_game
     @player = Player.first.destroy
     render "home/index"
 end


#create model for board. * columns

#How do I determine if game board is at win lose or draw?
 
end

