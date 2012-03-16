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
  
  def create_new_turn
    @turn = Turn.new
    @turn.save
  end
  
  def start_game
    create_new_board
    create_new_player
    create_new_turn
    if params[:first] == "true"
      Player.first.update_attribute(:is_first, true) 
      Turn.first.update_attribute(:player, "human")     
    else  
      params[:first] == "false"
      Player.first.update_attribute(:is_first, false)
      Turn.first.update_attribute(:player, "computer")     
    end 
    @player.save 
    update_turn
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
  
  def set_up_turn
    @board = Board.first
    @player = Player.first
    @turn = Turn.first
    set_player_markers
  end
  
  def update_turn
    @turn.save
    @turn = Turn.first
    if @turn[:player] == "human"
      render "board/index"  
    else
      computer_move  
    end
  end
     
  def end_turn
    @board.save
    score_game
    if game_is_over
       render "board/index"
    else   
      if @turn[:player] == "human" 
        find_available_moves
        if @available_moves.empty? 
          render "board/index" 
        else  
          Turn.first.update_attribute(:player, "computer")
        end
      else 
        Turn.first.update_attribute(:player, "human") 
      end
      @turn.save unless @available_moves.empty?
      update_turn unless @available_moves.empty?
    end  
  end
  
  def human_move
    set_up_turn
    square_pressed = params[:square].to_sym    
    @board[square_pressed] = @human_player
    end_turn 
  end
 
  def computer_first_move_setup
    @possible_first_moves = [:s0,:s2,:s6,:s8,:s4]
    @first_move = @possible_first_moves.sample
  end
  
  def non_ai_computer_moves
    @available_computer_moves = []     
    @board.attributes.each do |column_name, column_value|
      if column_value.nil?
        @available_computer_moves << column_name  
      end
    end 
  end

  def computer_move
    set_up_turn
    computer_first_move_setup
    non_ai_computer_moves   
    #check_for_a_winning_move
    @board[@first_move] = @computer_player 
    end_turn  
  end
  
  def mapping_possible_wins_to_the_actual_board_state
    @possible_wins = [[:s0,:s4,:s8], [:s2,:s4,:s6], [:s0,:s1,:s2], [:s3,:s4,:s5], [:s6,:s7,:s8], [:s0,:s3,:s6], [:s1,:s4,:s7], [:s2,:s5,:s8]]
    @detect_wins = []
    @possible_wins.each do |combination| 
      @group = []
      combination.each do |position|     
        @group << @board[position]    
      end 
      @detect_wins << @group
    end
    #@message = "#{@detect_wins}"
  end
  
  def determine_winner
    @someone_has_won = false
    @detect_wins.each do |value|
      if value == ["#{@computer_player}","#{@computer_player}","#{@computer_player}"]
       @message = "The Computer is the winner!"
       @someone_has_won = true
      elsif value == ["#{@human_player}","#{@human_player}","#{@human_player}"]
       @message = "You are the winner!"
       @someone_has_won = true
      end  
    end
  end
    
  def find_available_moves   
    @available_moves = []
    @board.attributes.each do |column_name, column_value|
      @available_moves << column_name if column_value.nil?      
    end
  end 

  def score_game
    mapping_possible_wins_to_the_actual_board_state
    determine_winner
    if !@someone_has_won && game_is_over 
      @message = "It's a draw."
    end
  end
  
  def game_is_over
    find_available_moves   
    @available_moves.empty?
  end

  def quit_game
    @player = Player.first.destroy
    @board = Board.first.destroy
    @turn = Turn.first.destroy
    render "home/index"
  end
=begin  
  def check_for_a_winning_move
    @possible_wins = [[:s0,:s4,:s8], [:s2,:s4,:s6], [:s0,:s1,:s2], [:s3,:s4,:s5], [:s6,:s7,:s8], [:s0,:s3,:s6], [:s1,:s4,:s7], [:s2,:s5,:s8]]
    @board = Board.first
    @detect_wins = []
    available_moves = []
    @possible_wins.each do |combination| 
      @group = {}
      combination.each do |position| 
        @winning_moves = []
        @board.attributes.each do |column_name, column_value|
          if column_value == @computer_move
            @group << @board[column_name, column_value]    
          end
          
          @group.each do |marker|
            if column_value == @computer_move
              ?????
            end
            available_computer_moves << column_name  
          end
        end    
        @detect_wins << @group
      end
     
      ######  I need to find out if there are 2 X in a group and if there are, return the value of the nil :s in the group. 
      #choose that.  if there are two, pick either one.
     
     
      http://stackoverflow.com/questions/5128200/how-to-count-identical-string-elements-in-a-ruby-array
      #read possible wins and look inside array at groups .
    #if there are any groups with 2 of @computer_player values,
#    choose that move.
#    if not, check_for_a_blocking_move
  end
  
  
  def check_for_a_blocking_move
       #read possible win and look inside array at groups .
        #if there are any groups with 2 of @human_player values,
    #    choose that move.
    #    if not, check_for_best_move
    
  end
  
  def decide_on_best_move
    #determine if something could possibly result in a win by determining if I could get 3 @computer_moves out of it.
    #if they are all nil, then yes.
    #if there is 1 x then yes.
    
    #then i need a way to map these nil values that could be a potential best move to their square. 
    #maybe an array of hashes [s0 -> nil, s1 =>x, s3 => nil]
    
  #then I need to keep track of how many times each square value is used. 
  #then I need to pick the square with the biggest number of use.
  #if the largest number is shared with others, select all of them into an array. 
  
  
  ####then find out all possible moves :s(#) where the human player has a value in the array ie. [:s0 =>nil, :s3 => O, :s6 =>nil ]
  # @human move in possible win [ nil, nil, O]
  #return :s values into an array
  
  #then do an array of possible_best_computer_moves - an array of blocked_moves = an array 
  # then if there is more than 1 value. do a sample on it. 
  
  
  #and that is hopefully it.  BABY STEPS!!!!!!
  
  end
  
  
=begin  
 chunks-
 -got computer to choose winning move if there are 2 in a row.
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