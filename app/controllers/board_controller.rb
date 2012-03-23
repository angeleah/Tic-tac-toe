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
 
  def computer_first_move(board)
    @possible_first_moves = [:s0,:s2,:s6,:s8,:s4]
    @first_move = @possible_first_moves.sample
    board[@first_move] = @computer_player
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
    
  def find_available_moves(board)  
    @available_moves = []
    board.attributes.each do |column_name, column_value|
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
      board[@check_for_a_winning_move.first] = @computer_player
    else
      check_for_a_blocking_move(board) 
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
      board[@check_for_a_blocking_move.first] = @computer_player
    else   
      board[@available_moves.first] = @computer_player
      #decide_on_best_move  
    end
    @message << "#{@check_for_a_blocking_move}"
  end
  
  def detect_terminal_state
    @detect_wins.each do |value|
      if value == ["#{@computer_player}","#{@computer_player}","#{@computer_player}"]
       return  1
      elsif value == ["#{@human_player}","#{@human_player}","#{@human_player}"]
       return -1
      elsif @available_moves.empty?
       return  0 
      end  
    end
  end

end  
#####################  
  so what do i need to determine a fork?
    
    
    
    
    
    
    
    
##############################  
infinity (I think INF) or giant #
so I can fork or use minimax.   with what I have fork(where there are 2 winning moves) may be the best option to try since I already have all that code. I want to detect a fork for myself and go for that but I also want to detect a fork for the other person and avoid them taking it. 
but maybe a good idea is to also rewrite in minimax. (or maybe finish it and then write it in minimax)
# if there are no -INF moves, I can add the values together scoring moves according to their depth? to determine the better move.(see Doug's  scratch paper)  closer moves get higher values?

#prob if human goes first, how does computer move pick?
#check into keep if

work on renaming things 
##################################################### a.i.  
grab max initial state  (should this be the actual ******board or the @detect_wins value?)
grab all available_moves (@available_moves or @available_simulation_moves?)


for each sf(available_moves or @available_simulation_moves) go through them 1 at a time
   and add an x to the board (no db)
   ... is the state termnal? (actually, 
   for the first round we know the state will not be terminal because a winning move is first checked for 
     before this function runs)
  if it is, return the value(the utility_state) 1, 0, -1) (and the s value for the board)
    default_utility_value = -1 (we will assume thet the human player will pick the worst move for computer) this will need to know currboard state, 
    v = default_utility_value
    if  utilty_state_value  >= v
      v = utilty_state_value
      
    else 
      
      run this function again with the human_player
           
****if I can get it for 1, I can get it for the rest. ****    
   how do I run the simulation?  
     
     i need the current board state. @simulation_board = @board.clone
     then I need the available moves. 
     then i need somewhere to store the values of the simulation board 
   

 ######################################## 

  
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
   
#shifting an array?
  
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
   

