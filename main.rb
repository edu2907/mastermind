# frozen_string_literal: true

# Common human actions for all human classes
module HumanActions
  def create_name
    puts 'Hello Player! Insert your name here:'
    name = gets.chomp
    return name unless name == 'Computer'

    puts 'Your name cannot be "Computer"! Try again.'
    create_name
  end

  def insert_code
    code = gets.chomp
    if valid?(code)
      code.to_i
    else
      puts 'Invalid code! Be sure that the code have 4 digits of numbers between 1 - 6'
      insert_code
    end
  end

  private

  def valid?(code)
    code.length == 4 && code.match?(/[1-6][1-6][1-6][1-6]/)
  end
end

# Functions that verifys how close a given guess is to another secret code
module PegTools
  def calc_pegs(guess_code_n, real_code_n)
    real_code_arr = real_code_n.to_s.split('')
    guess_code_arr = guess_code_n.to_s.split('')
    # 0 - Not included; 1 - Included, but in wrong position; 2 - Included and in correct position
    pegs_arr = Array.new(4, 1)
    guess_code_arr.each_index do |i|
      if guess_code_arr[i] == real_code_arr[i]
        real_code_arr[i] = nil
        pegs_arr[i] = 2
      end
    end
    guess_code_arr.each_with_index do |digit, i|
      next unless pegs_arr[i] < 2

      if real_code_arr.include?(digit)
        real_code_arr[real_code_arr.index(digit)] = nil
      else
        pegs_arr[i] = 0
      end
    end
    pegs_arr.sort.reverse
  end
end

module Mastermind
  LOGO = '
   __  __           _            __  __ _           _
  |  \/  | __ _ ___| |_ ___ _ __|  \/  (_)_ __   __| |
  | |\/| |/ _` / __| __/ _ \ \'__| |\/| | | \'_ \ / _` |
  | |  | | (_| \__ \ ||  __/ |  | |  | | | | | | (_| |
  |_|  |_|\__,_|___/\__\___|_|  |_|  |_|_|_| |_|\__,_|'
  ALL_CODES = [1, 2, 3, 4, 5, 6].repeated_permutation(4).to_a.map { |code| code.join.to_i }

  # Main class, where the game happens
  class Game
    attr_reader :rounds_list
    def initialize
      @rounds_list = Array.new(12) { {} }
    end

    # Main Function
    def run
      start
      winner = @encoder.name
      12.times do |i|
        if new_round(i)
          winner = @code_breaker.name
          break
        end
      end
      print_win_msg(winner)
    end

    private

    def start
      start_msg
      create_players
      tutorial_msg
    end

    def start_msg
      puts LOGO
      puts "\n"
    end

    def create_players
      puts 'Type c to choose Code Breaker roll or e for Encoder roll'
      roll_n = gets.chomp
      case roll_n
      when 'c'
        @code_breaker = HumanBreaker.new
        @encoder = ComputerEncoder.new
      when 'e'
        @encoder = HumanEncoder.new
        @code_breaker = ComputerBreaker.new(self)
      else
        puts 'Invalid roll! Try again.'
        create_players
      end
    end

    def tutorial_msg
      print_intro
      print_how
      print_example
      puts 'Press enter to continue: '
      gets
    end

    def print_intro
      puts "\nHello Player! In this game, the encoder creates a secret code,
and you, the code breaker, is responsible for decifring the
secret code. Here are how it works:"
    end

    def print_how
      puts "\n> 12 rounds
> Each round, the code breaker guess a code of 4 numbers from 1 to 6
> Then the encoder check if the guess matches with the secret code
> If not, the encoder provides a feedback about the code:
  - A list of symbols for each number from code that represents:
  - ● for correct number
  - o for correct number, but in wrong position
  - ◌ for incorrect number
> The game end when the code breaker guess the secret code or
all the 12 rounds ends without the code breaker decifring the code."
    end

    def print_example
      example_list = Array.new(1) { { guess: 2314, guess_score: [2, 1, 0, 0] } }
      puts "\nLet's see an example:"
      puts "Consider that the secret code is '6345'"
      show_board(1, example_list)
      puts "Here the code breaker has guessed the number '2314', which gave him
these hints: '● o ◌ ◌'. One number was correct, other was correct
but in wrong position ando two are not in the code. Here we can
check which number was correct or not, but in real game the code
breaker needs to use logic to discover which numbers are correct.
Note that the feedback isn't in same order as the code numbers."
    end

    def new_round(round_n)
      puts "\n                           Round #{round_n + 1}"
      show_board(round_n, @rounds_list) if round_n.positive?
      show_players
      # There are two properties of each obj from @rounds_list:
      #   :guess - the code @code_breaker has guessed
      #   :guess_score - Array of symbols that represent how close the guess was from secret code
      #   (seek explanation for each symbol in the comment below)
      @rounds_list[round_n][:guess] = @code_breaker.guess_code
      @rounds_list[round_n][:guess_score] = @encoder.calc_pegs(@rounds_list[round_n][:guess])
      @encoder.real_code_arr?(@rounds_list[round_n][:guess_score])
    end

    def show_board(size, rounds_list)
      puts '                    ======================'
      size.times do |i|
        guess = rounds_list[i][:guess].to_s.split('').join(' ')
        hint_arr = to_symbol(rounds_list[i][:guess_score]).join(' ')
        puts '                  ||                      ||'
        puts "                  || #{guess}    #{hint_arr}   ||"
        puts '                  ||                      ||'
      end
      puts '                    ======================'
    end

    def to_symbol(pegs)
      pegs.map do |peg|
        case peg
        when 0
          '◌'
        when 1
          '○'
        when 2
          '●'
        end
      end
    end

    def show_players
      puts "\n"
      puts "Encoder: #{@encoder.name}"
      puts "Code-Breaker: #{@code_breaker.name}"
    end

    def print_win_msg(player)
      @encoder.encoder_msg
      case player
      when 'Computer'
        puts "Too bad, you didn't win!"
      else
        puts 'You win!'
      end
    end
  end

  # Responsible for breaking the secret code
  class CodeBreaker
    attr_reader :name

    def guess_code
      puts "\nTry to guess the secret code and insert here:"
      insert_code
    end
  end

  # Human Version of Code Breaker
  class HumanBreaker < CodeBreaker
    include HumanActions
    def initialize
      @name = create_name
    end
  end

  # Computer Version of Code Breaker
  class ComputerBreaker < CodeBreaker
    include PegTools

    def initialize(game)
      @name = 'Computer'
      @last_guess = 0
      @round_list = game.rounds_list
      @set = ALL_CODES
    end

    def guess_code
      puts 'Waiting for Computer play it\'s guess...'
      last_round = @round_list.filter { |round| round[:guess] == @last_guess }
      @last_guess = calc_next_guess(@last_guess, last_round)
    end

    private

    # Donald Knuth's algoritm to calculate next guess
    def calc_next_guess(last_guess, last_round)
      return 1122 if last_guess.zero?

      @set = f_eql_pegs(last_guess, last_round[0][:guess_score])
      g_possibilites = calc_each_score
      g_max_score = filter_highest_score(g_possibilites)
      pick_code(g_max_score)
    end

    def f_eql_pegs(guess, pegs)
      @set.filter do |code|
        calc_pegs(code, guess) == pegs
      end
    end

    def calc_each_score
      @set.map do |g|
        g_scores = @set.map do |c|
          g_pegs = calc_pegs(g, c)
          new_set = f_eql_pegs(c, g_pegs)
          eliminated = @set - new_set
          eliminated.length
        end
        { code: g, min_score: g_scores.min }
      end
    end

    def filter_highest_score(g_list)
      max_score = g_list.max { |a, b| a[:min_score] <=> b[:min_score] }[:min_score]
      g_list.filter { |guess| guess[:min_score] == max_score }
    end

    def pick_code(g_list)
      g_list[rand(g_list.size - 1)][:code]
    end
  end

  # Creates secret code and verify if code breaker guessed it
  class Encoder
    include PegTools
    attr_reader :name

    def calc_pegs(guess)
      super(guess, @secret_code)
    end

    def real_code_arr?(code_score)
      code_score.eql?([2, 2, 2, 2])
    end

    def encoder_msg
      puts "The secret code was #{@secret_code}"
    end
  end

  # Human version of Encoder
  class HumanEncoder < Encoder
    include HumanActions
    def initialize
      @name = create_name
      puts 'Insert the secret code here:'
      @secret_code = insert_code
    end
  end

  # Computer Version of Encoder
  class ComputerEncoder < Encoder
    def initialize
      @name = 'Computer'
      @secret_code = generate_code
    end

    def generate_code
      code = []
      4.times do |i|
        code[i] = rand(1..6)
      end
      code.join.to_i
    end
  end
end

Mastermind::Game.new.run
