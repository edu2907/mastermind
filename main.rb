# frozen_string_literal: true

class Game
  def initialize

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
    |_|  |_|\__,_|___/\__\___|_|  |_|  |_|_|_| |_|\__,_|
'
    puts "\n"
  end

  def create_players
    @code_breaker = Human.new
    @encoder = Computer.new
  end
end

class Human
  def initialize
    @name = create_name
  end

  def create_name
    puts 'Hello Player! Insert your name here:'
    gets.chomp
  end
end

class Computer
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

Game.new.start
