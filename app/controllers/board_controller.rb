class BoardController < ApplicationController  
  def index
     @board=["","","","","","","","",""]    
  end  
  
  def who_is_first
#    @player = Player.find(1).update_attribute()#can I put params in here?
#    @player.first = params[:first]
#    @player.second = params[:second]
#    if @widget.update
#      @message = "the board was updated"
#    else
#      @message = "there is a problem with your code!"
#    end  
  end



#make You and Computer buttons into submit tags and put them into the database.
#make the players model Boolean.  Whoever is 1 is player 1.

#create model for board. * columns

#Create a form for each "submit tag square link"
# figure out a CRUD for the board state
#How do I determine if game board is at win lose or draw?

#how do I remember game states between turns? (write it to a batabase using crud?)
 
end

