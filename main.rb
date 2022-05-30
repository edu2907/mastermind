# frozen_string_literal: true

class Game
  def initialize

  end

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
    @code_breaker.guess_code
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
    puts "\n"
    puts "Try to guess the encoder's code and insert here:"
    gets.chomp
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
end

Game.new.run
