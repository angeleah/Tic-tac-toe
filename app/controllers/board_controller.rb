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
  
  def find_available_moves
    @available_moves = []
    @board.attributes.each do |column_name, column_value|
      @available_moves << column_name if column_value.nil?
    end
  end
  
  def prepare_board_for_evaluation
    @possible_winning_combinations = [[:s0,:s4,:s8], [:s2,:s4,:s6], [:s0,:s1,:s2], [:s3,:s4,:s5], [:s6,:s7,:s8], [:s0,:s3,:s6], [:s1,:s4,:s7], [:s2,:s5,:s8]]
    @evaluation_state = []
    @possible_winning_combinations.each do |combination|
      @group = []
      combination.each do |position|
        if @board[position] == @computer_player || @board[position] == @human_player
          @group << @board[position] 
        elsif @board[position].nil?
          @group << position
        end
      end
      @evaluation_state << @group
    end
    #@message = "#{@evaluation_state}"
  end
  
  def determine_winner
    @someone_has_won = false
    @evaluation_state.each do |value|
      if value == ["#{@computer_player}","#{@computer_player}","#{@computer_player}"]
       @message = "The Computer is the winner!"
       @someone_has_won = true
      elsif value == ["#{@human_player}","#{@human_player}","#{@human_player}"]
       @message = "You are the winner!"
       @someone_has_won = true
      end
    end
  end

  def score_game
    prepare_board_for_evaluation
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
    @turn = Turn.first.destroy
    render "home/index"
  end
  
  def check_for_a_winning_move
    prepare_board_for_evaluation
    @check_for_a_winning_move = @evaluation_state
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
  end
 
  def check_for_a_blocking_move
    prepare_board_for_evaluation
    @check_for_a_blocking_move = @evaluation_state
    @check_for_a_blocking_move.keep_if {|v| v.count(@human_player) == 2}
    @check_for_a_blocking_move.delete_if {|v| v.count(@computer_player) == 1}
    @check_for_a_blocking_move.flatten!
    @check_for_a_blocking_move.delete_if {|v| v == @human_player}
    if
      @check_for_a_blocking_move.empty? == false
      @board[@check_for_a_blocking_move.first] = @computer_player
    else
      convert_available_moves_to_symbols
      set_up_fork_holding_array
      test_for_computer_forks
      #@board[@available_moves.first] = @computer_player
    end
  end
  
  def convert_available_moves_to_symbols
    find_available_moves
    @available_fork_testing_moves = []
    @available_moves.each do |move|
      @available_fork_testing_moves << move.to_sym
    end 
    @message = "#{@available_fork_testing_moves}"
  end
  
  def set_up_fork_holding_array
    @fork_holding_array = [] 
    @message << "#{@fork_holding_array}"
  end
  
  def test_for_computer_forks
    if @available_fork_testing_moves.empty?
      evaluate_possible_computer_forks 
    else
      look_a_move_ahead
      analyze_simulation_to_find_computer_forks
      test_for_computer_forks
    end    
  end
  
  def look_a_move_ahead
    prepare_board_for_evaluation
    #@message << "#{@evaluation_state}"
    @testing_position = @available_fork_testing_moves.first
    #@message << "#{@testing_position}"
    substitute_move(@computer_player)
    #@message << "#{@evaluation_state_with_subsitute_move}"
    @available_fork_testing_moves.shift
    #@message << "#{@available_fork_testing_moves}"
    #@message << "#{@testing_position}"
  end
  
  def substitute_move(player)
    @evaluation_state_with_subsitute_move = []
    @evaluation_state.each do |combination|
      @combos = []
      combination.each do |position|
        if position == @testing_position
          @combos << position = player
        else
          @combos << position
        end 
      end
      @evaluation_state_with_subsitute_move << @combos
    end
  end
  
  def analyze_simulation_to_find_computer_forks
    #@message << "#{@testing_position}"
    @evaluation_state_with_subsitute_move.keep_if {|v| v.count(@computer_player) == 2}
    #@message << "#{@evaluation_state_with_subsitute_move}"
    @evaluation_state_with_subsitute_move.delete_if {|v| v.count(@human_player) == 1}
    #@message << "#{@evaluation_state_with_subsitute_move}"
    if @evaluation_state_with_subsitute_move.length == 2
      @fork_holding_array << @testing_position
     # @message << "#{@testing_position}"
    end
    #@message << "#{@fork_holding_array}"
  end
  
  def evaluate_possible_computer_forks
    if @fork_holding_array.empty?
      #@board[@available_moves.first] = @computer_player
      convert_available_moves_to_symbols
      set_up_fork_holding_array
      test_for_human_forks
    else
      @board[@fork_holding_array.first] = @computer_player 
    end  
  end
  
  def create_set_of_available_moves_for_looking_a_move_ahead 
    find_available_moves
    @available_look_ahead_moves = []
    @available_moves.each do |move|
      @available_look_ahead_moves << move.to_sym unless move == @testing_position.to_s
    end
    @message << "#{@available_look_ahead_moves}"
  end
  
  def substitute_second_move_ahead(player)
    @evaluation_state_with_a_second_move_ahead = []  
    @evaluation_state_with_subsitute_move.each do |combination|
      @combos = []
      combination.each do |position|
        if position == @second_testing_position
          @combos << position = player
        else
          @combos << position
        end 
      end
      @evaluation_state_with_a_second_move_ahead << @combos
    end 
  end
  
  def copy_of_evaluation_state_with_a_second_move_ahead
    @copy_of_evaluation_state_with_a_second_move_ahead = []
    @evaluation_state_with_a_second_move_ahead.each do |combo|
      @copy_of_evaluation_state_with_a_second_move_ahead << combo
    end   
  end
    
  def test_for_human_forks
    if @available_fork_testing_moves.empty?
      evaluate_possible_human_forks
    else    
    look_a_move_ahead
    @message << "#{@testing_position}"
    create_set_of_available_moves_for_looking_a_move_ahead
    look_a_second_move_ahead
    #@message << "#{@evaluation_state_with_subsitute_move}"
    #will there be a problem resetting @available_look_ahead_moves
    end  
  end 
  
  def look_a_second_move_ahead
    @second_testing_position = @available_look_ahead_moves.first
    @message << "#{@second_testing_position}"
    substitute_second_move_ahead(@human_player)
    @message << "#{@evaluation_state_with_a_second_move_ahead}"
    copy_of_evaluation_state_with_a_second_move_ahead
    @message << "#{@copy_of_evaluation_state_with_a_second_move_ahead}"
    analyze_simulation_to_find_human_forks
    #@message << "#{@testing_position}"
    @message << "#{@evaluation_state_with_a_second_move_ahead}"
    test_simulation_board_for_immediate_wins
    @message << "#{@copy_of_evaluation_state_with_a_second_move_ahead}"
    @message << "#{@testing_position}"
  end
  
   def analyze_simulation_to_find_human_forks
     @evaluation_state_with_a_second_move_ahead.keep_if {|v| v.count(@human_player) == 2}
     #@message << "#{@evaluation_state_with_a_second_move_ahead}"
     @evaluation_state_with_a_second_move_ahead.delete_if {|v| v.count(@computer_player) == 1}
     #@message << "#{@evaluation_state_with_a_second_move_ahead}"
   end
   
   def test_simulation_board_for_immediate_wins
     @copy_of_evaluation_state_with_a_second_move_ahead.keep_if {|v| v.count(@computer_player) == 2}
     @copy_of_evaluation_state_with_a_second_move_ahead.delete_if {|v| v.count(@human_player) == 1}
   end
   
   def compare_human_forks_against_immediate_wins
     if @evaluation_state_with_a_second_move_ahead.length == 2 && test_for_immediate_wins == 0
        @fork_holding_array << @testing_position
      end  
      @message << "#{@fork_holding_array}"
   end
   
   #need to find a way to test to see if I can have an immediate win after a computer move
   #I need to force the computer to block if there is a blocking move? or detect that even if there
   
   #I need to find best move if there is no computer_fork
   
  def evaluate_possible_human_forks
    #@fork_holding_array can have the same value more than 1 x? so mAybe remove duplicates?
  end
  #when testing for human_forks, change_the array to @evaluation_state_with_a_second_move_ahead
end









