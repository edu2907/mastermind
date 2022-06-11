# frozen_string_literal: true

module Mastermind
  LOGO = '
  __  __           _            __  __ _           _
 |  \/  | __ _ ___| |_ ___ _ __|  \/  (_)_ __   __| |
 | |\/| |/ _` / __| __/ _ \ \'__| |\/| | | \'_ \ / _` |
 | |  | | (_| \__ \ ||  __/ |  | |  | | | | | | (_| |
 |_|  |_|\__,_|___/\__\___|_|  |_|  |_|_|_| |_|\__,_|'
  class Game
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

    def tutorial_msg
      print_intro
      print_how
      print_example
      puts 'Press enter to continue: '
      gets
    end

    def print_intro
      puts "\nHello #{@code_breaker.name}! In this game, the encoder creates a secret code,
and you, the code breaker, is responsible for decifring the
secret code. Here are how it works:"
    end

    def print_how
      puts "\n> 12 rounds
> Each round, the code breaker guess a code of 4 unique numbers from 1 to 6
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
      example_list = Array.new(1) { { guess: [2, 3, 1, 4], guess_score: ['●', 'o', '◌', '◌'] } }
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

    def start_msg
      puts LOGO
      puts "\n"
    end

    def create_players
      @code_breaker = Human.new
      @encoder = Computer.new
    end

    def new_round(round_n)
      puts "\n                           Round #{round_n}"
      show_board(round_n, @rounds_list) if round_n.positive?
      show_players
      # There are two properties of each obj from @rounds_list:
      #   :guess - the code @code_breaker has guessed
      #   :guess_score - Array of symbols that represent how close the guess was from secret code
      #   (seek explanation for each symbol in the comment below)
      @rounds_list[round_n][:guess] = @code_breaker.guess_code
      @rounds_list[round_n][:guess_score] = @encoder.calc_score(@rounds_list[round_n][:guess])
      @encoder.secret_code?(@rounds_list[round_n][:guess_score])
    end

    def show_board(size, rounds_list)
      puts '                    ======================'
      size.times do |i|
        guess = rounds_list[i][:guess].join(' ')
        hint_arr = rounds_list[i][:guess_score].join(' ')
        puts '                  ||                      ||'
        puts "                  || #{guess}    #{hint_arr}   ||"
        puts '                  ||                      ||'
      end
      puts '                    ======================'
    end

    def show_players
      puts "\n"
      puts "Encoder: #{@encoder.name}"
      puts "Code-Breaker: #{@code_breaker.name}"
    end

    def print_win_msg(player)
      case player
      when @encoder.name
        puts "Too bad, the game has ended! The secret code was #{@encoder.secret_code.join}."
      when @code_breaker.name
        puts 'You guessed right!'
      end
      puts "#{player} wins!"
    end
  end

  class Human
    attr_reader :name

    def initialize
      @name = create_name
    end

    def guess_code
      puts "\nTry to guess the secret code and insert here:"
      code = gets.chomp.split('')
      if valid?(code)
        code.map(&:to_i)
      else
        puts 'Invalid guess! Be sure that the code have 4 digits of unique numbers between 1 - 6'
        guess_code
      end
    end

    def valid?(code)
      code.length == 4 && code.all? { |num| num.match?(/[1-6]/) } && code.eql?(code.uniq)
    end

    private

    def create_name
      puts 'Hello Player! Insert your name here:'
      gets.chomp
    end
  end

  class Computer
    attr_reader :name, :secret_code

    def initialize
      @name = 'Computer'
      @secret_code = generate_code
    end

    def calc_score(code)
      scores_arr = code.map do |digit|
        # 0 - Not included; 1 - Included, but wrong position; 2 - Included and in correct position
        num_guess_score = 0
        num_guess_score = 1 if @secret_code.include?(digit)
        num_guess_score = 2 if code.index(digit) == @secret_code.index(digit)
        num_guess_score
      end
      convert_each(scores_arr)
    end

    def secret_code?(code_score)
      code_score.eql?(['●', '●', '●', '●'])
    end

    private

    def generate_code
      code = []
      4.times do |i|
        loop do
          num = rand(1..6)
          unless code.include?(num)
            code[i] = num
            break
          end
        end
      end
      code
    end

    def convert_each(num_arr)
      num_arr.sort.reverse.map do |num|
        case num
        when 2
          '●'
        when 1
          'o'
        when 0
          '◌'
        end
      end
    end
  end
end

Mastermind::Game.new.run
