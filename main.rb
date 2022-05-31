# frozen_string_literal: true

class Game
  def initialize

  end

  # Main Function
  def run
    start
    new_round(0)
  end

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
    puts "Round #{round_n}"
    show_table
    show_players
    guess = @code_breaker.guess_code
    guess_score = @encoder.calc_score(guess)
    win_condition = @encoder.secret_code?(guess_score)
    round_msg(win_condition)
  end

  def show_table
    puts '  ======================'
    puts '||                      ||'
    puts "|| 1 2 3 4    ø • o ø   ||"
    puts '||                      ||'
    puts '  ======================'
  end

  def show_players
    puts "\n"
    puts "Encoder: #{@encoder.name}"
    puts "Code-Breaker: #{@code_breaker.name}"
  end

  def round_msg(win_condition)
    if win_condition
      puts "You guess the correct code!\n#{@code_breaker.name} wins!"
    else
      puts "Too bad, this isn't the correct code!"
    end
  end
end

class Human
  attr_reader :name

  def initialize
    @name = create_name
  end

  def create_name
    puts 'Hello Player! Insert your name here:'
    gets.chomp
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
end

class Computer
  attr_reader :name

  def initialize
    @name = 'Computer'
    @secret_code = generate_code
  end

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

  def calc_score(code)
    code.map do |digit|
      # 0 - Not included; 1 - Included, but wrong position; 2 - Included and in correct position
      num_guess_score = 0
      num_guess_score = 1 if @secret_code.include?(digit)
      num_guess_score = 2 if code.index(digit) == @secret_code.index(digit)
      num_guess_score
    end
  end

  def secret_code?(code_score)
    code_score.eql?([2, 2, 2, 2])
  end
end

Game.new.run
