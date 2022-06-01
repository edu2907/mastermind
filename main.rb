# frozen_string_literal: true

class Game
  def initialize
    @rounds_history = Array.new(12) { {} }
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
  end

  def start_msg
    puts '
     __  __           _            __  __ _           _
    |  \/  | __ _ ___| |_ ___ _ __|  \/  (_)_ __   __| |
    | |\/| |/ _` / __| __/ _ \ \'__| |\/| | | \'_ \ / _` |
    | |  | | (_| \__ \ ||  __/ |  | |  | | | | | | (_| |
    |_|  |_|\__,_|___/\__\___|_|  |_|  |_|_|_| |_|\__,_|'
    puts "\n"
  end

  def create_players
    @code_breaker = Human.new
    @encoder = Computer.new
  end
  
  def new_round(round_n)
    puts "      Round #{round_n}"
    show_board(round_n) if round_n.positive?
    show_players
    # There are two properties of each obj from @rounds_history:
    #   :guess - the code @code_breaker has guessed
    #   :guess_score - Array of symbols that represent how close the guess was from secret code
    #   (seek explanation for each symbol in next comment below)
    @rounds_history[round_n][:guess] = @code_breaker.guess_code
    @rounds_history[round_n][:guess_score] = @encoder.calc_score(@rounds_history[round_n][:guess])
    @encoder.secret_code?(@rounds_history[round_n][:guess_score])
  end

  def show_board(round_n)
    puts '  ======================'
    round_n.times do |i|
      guess = @rounds_history[i][:guess].join(' ')
      hint_arr = @rounds_history[i][:guess_score].join(' ')
      puts '||                      ||'
      puts "|| #{guess}    #{hint_arr}   ||"
      puts '||                      ||'
    end
    puts '  ======================'
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
    code.map do |digit|
      # ◌ - Not included; O - Included, but wrong position; ● - Included and in correct position
      num_guess_score = '◌'
      num_guess_score = 'O' if @secret_code.include?(digit)
      num_guess_score = '●' if code.index(digit) == @secret_code.index(digit)
      num_guess_score
    end
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
end

Game.new.run
