#big problems are only scary when you refuse to believe you can solve them. 

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
 
# def computer_move
#  computer_first_move
#  set_player_markers
#  @board.save
#  determine_winner_or_draw
#  @message 
 #end
=begin 
 def computer_first_move
    possible_first_moves = [:s0,:s2,:s6,:s8,:s4]
    first_move = possible_first_moves.sample 
    set_player_markers   
    @board[first_move] = @computer_player
    @board.save
    human_move
    @message = "#{@open_columns}"
    render "board/index" 
  end
=end 

 def computer_move
   @board = Board.first
   possible_first_moves = [:s0,:s2,:s6,:s8,:s4]
   first_move = possible_first_moves.sample
   available_computer_moves = []
   @board.attributes.each do |column_name, column_value|
     if column_value.nil?
       available_computer_moves << column_name  
     end
   end
   set_player_markers
   if available_computer_moves.length == 9
     @board[first_move] = @computer_player
   elsif available_computer_moves.empty? == true
     determine_winner_or_draw
   elsif available_computer_moves.length != 9 
#     move_to_choose
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
#    @message = "#{@detect_wins}"
 end

  def quit_game
    @player = Player.first.destroy
    @board = Board.first.destroy
    render "home/index"
  end
  
=begin  
  def computer_first_move
    @open_columns = []
    @board = Board.first
    possible_first_moves = [:s0,:s2,:s6,:s8,:s4]
    first_move = possible_first_moves.sample
    @board.attributes.each do |column_name, column_value|
      if column_value.nil?
        @open_columns << column_name  
      end
    end
    if @open_columns.length == 8
      @board[first_move] = @computer_player
    elsif @open_columns.length != 8   
      check_for_a_winning_move
    end
    @message = "#{@open_columns}"
    @board.save
  end
=end  
  def check_for_a_winning_move
    
  end
  
  
=begin  
 chunks-
- get computer to choose random corner move
 -got computer to choose winning move if there are 3 in a row.
 -get computer to block if opponent has 3 in a row.
 figure out best move detection if the  
 
 -figure out how to make the computer choose the 1st or 3rd position if [v, , ] or [ , ,v].
   if two values intersect are = ie [s0-x,s1,s2-  s2 would be the coice ]
   or [s2, s4, x- s6] , s2 would be the chioce.  if there are 
   
   return the values of :s where there is already an x.  if two s's intersect, select that square.'
   if 2 values that are not equal are in the [ x,0 s2] go to next?
   
  
##########
 ary - other_ary → new_ary click to toggle source
   Array Difference---Returns a new array that is a copy of the original array,
    removing any items that also appear in other_ary. (If you need set-like behavior, see the library class Set.)
   [ 1, 1, 2, 2, 3, 3, 4, 5 ] - [ 1, 2, 4 ]  #=>  [ 3, 3, 5 ]
   
########   
   count → int
   count(obj) → int
   count { |item| block } → int
   Returns the number of elements. If an argument is given, 
   counts the number of elements which equals to obj. If a block is given, counts the number of elements yielding a true value.
   ary = [1, 2, 4, 2]
   ary.count             #=> 4
   ary.count(2)          #=> 2
   ary.count{|x|x%2==0}  #=> 3
   
##########   
   flatten → new_ary click to toggle source
   flatten(level) → new_ary
   Returns a new array that is a one-dimensional flattening of this array (recursively). That is, for every element that is an array, 
   extract its elements into the new array. If the optional level argument determines the level of recursion to flatten.
   s = [ 1, 2, 3 ]           #=> [1, 2, 3]
   t = [ 4, 5, 6, [7, 8] ]   #=> [4, 5, 6, [7, 8]]
   a = [ s, t, 9, 10 ]       #=> [[1, 2, 3], [4, 5, 6, [7, 8]], 9, 10]
   a.flatten                 #=> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
   a = [ 1, 2, [3, [4, 5] ] ]
   a.flatten(1)              #=> [1, 2, 3, [4, 5]]
   
   
   
   



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
  @board = Board.first
=end
end