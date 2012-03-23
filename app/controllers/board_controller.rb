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
  
  def human_move(board)
    set_up_turn(board)
    square_pressed = params[:square].to_sym    
    board[square_pressed] = @human_player
    end_turn 
  end
 
  def computer_first_move
    @possible_first_moves = [:s0,:s2,:s6,:s8,:s4]
    @first_move = @possible_first_moves.sample
    @board[@first_move] = @computer_player
  end

  def computer_move
    set_up_turn
    find_available_moves
    if @available_moves.length == 9
      computer_first_move
    else     
      check_for_a_winning_move 
    end
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
    @message = "#{@detect_wins}"
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
    @available_moves.empty? || @someone_has_won == true
  end

  def quit_game
    @player = Player.first.destroy
    @board = Board.first.destroy
    @simulation_board = Simulation_board.first.destroy
    @turn = Turn.first.destroy
    render "home/index"
  end
  
  def check_board_status(board)
    @possible_wins = [[:s0,:s4,:s8], [:s2,:s4,:s6], [:s0,:s1,:s2], [:s3,:s4,:s5], [:s6,:s7,:s8], [:s0,:s3,:s6], [:s1,:s4,:s7], [:s2,:s5,:s8]]
    @check_for_possible_win = []
    @possible_wins.each do |combination| 
      @group = []
      combination.each do |position|
        if board[position] == @computer_player || board[position] == @human_player    
          @group << board[position] 
        elsif board[position].nil?
          @group << position     
        end     
      end 
      @check_for_possible_win << @group
    end
    #@message = "#{@check_for_possible_win}"
  end
  
  def check_for_a_winning_move(board)
    check_board_status(board)
    @check_for_a_winning_move = @check_for_possible_win
    @check_for_a_winning_move.keep_if {|v| v.count(@computer_player) == 2}
    @check_for_a_winning_move.delete_if {|v| v.count(@human_player) == 1}
    @check_for_a_winning_move.flatten!
    @check_for_a_winning_move.delete_if {|v| v == @computer_player}
    if
      @check_for_a_winning_move.empty? == false
      @board[@check_for_a_winning_move.first] = @computer_player
    else
      check_for_a_blocking_move  
    end
    @message << "#{@check_for_a_winning_move}"
  end
 
  def check_for_a_blocking_move(board)
    check_board_status(board)
    @check_for_a_blocking_move = @check_for_possible_win
    @check_for_a_blocking_move.keep_if {|v| v.count(@human_player) == 2}
    @check_for_a_blocking_move.delete_if {|v| v.count(@computer_player) == 1}
    @check_for_a_blocking_move.flatten!
    @check_for_a_blocking_move.delete_if {|v| v == @human_player}
    if
      @check_for_a_blocking_move.empty? == false
      @board[@check_for_a_blocking_move.first] = @computer_player
    else   
      @board[@available_moves.first] = @computer_player
      #decide_on_best_move  
    end
    @message << "#{@check_for_a_blocking_move}"
  end
  
  
  
##################################################### a.i.  
grab max initial state  (should this be the actual ******board or the @detect_wins value?)
grab all available_moves (@available_moves or @available_simulation_moves?)


for each sf(available_moves or @available_simulation_moves) go through them 1 at a time
   and add an x to the board (should I use the db for this?)
   ... is the state termnal? (actually, 
   for the first round we know the state will not be terminal because a winning move is first checked for 
     before this function runs)
  if it is, return the value(the utility_state) 1, 0, -1) 
    default_utility_value = -1 (we will assume thet the human player will pick the worst move for computer)
    if  
      
      
      
      
      
      
    















 
  @simulation_board = @board.clone
  def find_simulation_moves   
      @available_simulation_moves = []
      @simulation_board.attributes.each do |column_name, column_value|
        @available_moves << column_name if column_value.nil?      
      end
    end
    
    
    
  def decide_on_best_move
    
  
  end
  
  def Max(board_state)
    #v = -1
    @available_simulation_moves.each do |move|
      if 
    end  
    if tv >= v 
      v = tv
    end
    return v
  end
  
  
  
  
  
  
  
  
  def find_simulation_moves   
     @available_simulation_moves = []
     @simulation_board.attributes.each do |column_name, column_value|
       @available_moves << column_name if column_value.nil?      
     end
   end
  
  def mapping_possible_wins_to_the_simulation_board_state
     @possible_wins = [[:s0,:s4,:s8], [:s2,:s4,:s6], [:s0,:s1,:s2], [:s3,:s4,:s5], [:s6,:s7,:s8], [:s0,:s3,:s6], [:s1,:s4,:s7], [:s2,:s5,:s8]]
     @detect_wins = []
     @possible_wins.each do |combination| 
       @group = []
       combination.each do |position|     
         @group << @board[position]    
       end 
       @detect_wins << @group
     end
     @message = "#{@detect_wins}"
   end

   def check_board_status
     @possible_wins = [[:s0,:s4,:s8], [:s2,:s4,:s6], [:s0,:s1,:s2], [:s3,:s4,:s5], [:s6,:s7,:s8], [:s0,:s3,:s6], [:s1,:s4,:s7], [:s2,:s5,:s8]]
     @check_for_possible_win = []
     @possible_wins.each do |combination| 
       @group = []
       combination.each do |position|
         if @board[position] == @computer_player || @board[position] == @human_player    
           @group << @board[position] 
         elsif @board[position].nil?
           @group << position     
         end     
       end 
       @check_for_possible_win << @group
     end
     @message = "#{@check_for_possible_win}"
   end

   def detect_terminal_state
     @detect_wins.each do |value|
       if value == ["#{@computer_player}","#{@computer_player}","#{@computer_player}"]
        return   tv = 1
       elsif value == ["#{@human_player}","#{@human_player}","#{@human_player}"]
        return  tv = -1
       elsif @available_moves.empty?
        return  tv = 0 
       end  
     end
   end
  
  
























 ######################################## 
   def decision(state)
      v = maxvalue(#board  - of that particular node @board or @simulation_board?)
      return action in S.f.(state) with value v  (return the s value to choose)
    end


    def maxvalue(state)
      if current_board   state is terminal(detect_terminal_state) then return utility state  (1, 0 or -1)
      v = -1
      for s in sf(state   @available_moves?)
        v = MAX(v,minvalue(s))  
        return v
    end

    def minvalue
       if state is terminalthen return utility state
        v = 1
        for s in sf(state)
          v = MIN(v,minvalue(s))  
          return v
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
    @message = "#{@detect_wins}"
  end
  
  def check_board_status
    @possible_wins = [[:s0,:s4,:s8], [:s2,:s4,:s6], [:s0,:s1,:s2], [:s3,:s4,:s5], [:s6,:s7,:s8], [:s0,:s3,:s6], [:s1,:s4,:s7], [:s2,:s5,:s8]]
    @check_for_possible_win = []
    @possible_wins.each do |combination| 
      @group = []
      combination.each do |position|
        if @board[position] == @computer_player || @board[position] == @human_player    
          @group << @board[position] 
        elsif @board[position].nil?
          @group << position     
        end     
      end 
      @check_for_possible_win << @group
    end
    @message = "#{@check_for_possible_win}"
  end
  
  def find_simulation_moves   
    @available_simulation_moves = []
    @simulation_board.attributes.each do |column_name, column_value|
      @available_moves << column_name if column_value.nil?      
    end
  end
  
  def detect_terminal_state
    @detect_wins.each do |value|
      if value == ["#{@computer_player}","#{@computer_player}","#{@computer_player}"]
       return 1
      elsif value == ["#{@human_player}","#{@human_player}","#{@human_player}"]
       return -1
      elsif @available_moves.empty?
       return 0 
      end  
    end
  end
  
  
   

  
  if score > result keep this move
  
  
  
  
  
  

  
  
  
  

  

  
  
    
  if ( base case 1 )
     // return some simple expression
  else if ( base case 2 )
     // return some simple expression
  else if ( base case 3 )
     // return some simple expression
  else if ( recursive case 1 )
    {
       // some work before 
       // recursive call 
       // some work after 
    }
  else if ( recursive case 2 )
    {
       // some work before 
       // recursive call 
       // some work after 
    }
  else // recursive case 3
    {
       // some work before 
       // recursive call 
       // some work after 
    }
end  
 
  current board state
  available_moves
  if @computer = "X"
    maxvalue
  else
    min value
  
=end  

  
=begin  
  def find_computer_player_containing_combos
    check_board_status
    @computer_containing_combos = @check_for_possible_win
    @computer_containing_combos.keep_if {|v| v.count(@computer_player) == 1}
    @computer_containing_combos.delete_if {|v| v.count(@human_player) == 1}
    @computer_containing_combos.flatten!
    @computer_containing_combos.delete_if {|v| v == @computer_player}
    @message << "<br />#{@computer_containing_combos}"
  end

  def find_human_player_containing_combos
    check_board_status
    @human_player_containing_combos = @check_for_possible_win
    @human_player_containing_combos.keep_if {|v| v.count(@human_player) == 1}
    @human_player_containing_combos.delete_if {|v| v.count(@computer_player) == 1}
    @human_player_containing_combos.flatten!
    @human_player_containing_combos.delete_if {|v| v == @human_player}
    @message << "<br />#{@human_player_containing_combos}"
  end

  def decide_on_best_move
    find_computer_player_containing_combos
    find_human_player_containing_combos
    @find_best_move = @computer_containing_combos & @human_player_containing_combos
    if @find_best_move.empty?
      @board[@available_moves.first] = @computer_player  
    else
      @board[@find_best_move.first] = @computer_player
    end 
    #@message = "#{@find_best_move}" 
      
  end 
=end   
end  
  

  
#prob if human goes first, how does computer move pick?
#check into keep if 
  
  

  
  
  
  
  
  
  
def check_board_status(board)
  possible_wins = [[:s0,:s4,:s8], [:s2,:s4,:s6], [:s0,:s1,:s2], [:s3,:s4,:s5], [:s6,:s7,:s8], [:s0,:s3,:s6], [:s1,:s4,:s7], [:s2,:s5,:s8]]
  @check_for_possible_win = []
  possible_wins.each do |combination| 
    @group = []
    combination.each do |position|
      if board[position] == @computer_player || board[position] == @human_player    
        @group << board[position] 
      elsif board[position].nil?
        @group << position     
      end     
    end 
    @check_for_possible_win << @group
  end
  #@message = "#{@check_for_possible_win}"
  possible_wins
end


def other
  @possible_wins = check_for_possible_win(@board)
end
  
  
  

  
  
 
  

=begin  
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
