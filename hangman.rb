# frozen_string_literal: true

require 'pry-byebug'
# The main game
class Hangman
  attr_accessor :dict, :secret_word, :turns, :guesses

  def initialize(secret_word, turns = 20, guesses = [])
    @secret_word = secret_word
    @turns = turns
    @guesses = guesses
  end

  def advance_turn
    @turns -= 1
  end

  def game_over?(guess_word)
    guess_word == @secret_word
  end

  def check_guess(guess)
    secret_word = @secret_word.clone
    if secret_word.include?(guess)
      positions = []
      while secret_word.include?(guess)
        positions << secret_word.index(guess)
        secret_word[secret_word.index(guess)] = nil
      end
      return positions
    end
    nil
  end
end

# Useful function(s) for the interaction between objects
class Utility
  def load_dict(path)
    dict_obj = File.open(path)
    dict_list = []
    dict_list << dict_obj.gets.chomp until dict_obj.eof
    dict_list
  end

  def choose_secret_word(dict)
    dict.select { |word| word.length > 4 && word.length < 13 }.sample.split('')
  end
end

# As the name implies, the player
class Player
  attr_accessor :guesses, :word

  def initialize(guesses = [], word = [])
    @guesses = guesses
    @word = word
  end

  def ask_guess
    loop do
      puts("\n\nChoose a letter\n")
      new_guess = gets.chomp.downcase
      unless @guesses.include?(new_guess)
        @guesses << new_guess
        return new_guess
      end
      puts("You've already chosen that letter!\n")
    end
  end
end

u = Utility.new
player = Player.new

dict_path = 'google-10000-english.txt'
dict_list = u.load_dict(dict_path)
secret_word = u.choose_secret_word(dict_list)

game = Hangman.new(secret_word)
secret_word = game.secret_word
word = player.word
secret_word.each { |_letter| word << nil }

puts("Preparations are completed! Let\'s begin!\n")

loop do
  puts("Remaining guesses: #{game.turns}\n\n")
  word.each do |letter|
    if letter.nil?
      print '_ '
    else
      print "#{letter} "
    end
  end
  new_guess = player.ask_guess
  letter_positions = game.check_guess(new_guess)
  letter_positions&.each { |position| word[position] = new_guess }
  if game.game_over?(word)
    puts "\n#{word.join('').capitalize}"
    return puts "\nCongratulations! You won!"
  end

  game.advance_turn
  return puts "\n The man has been hanged :(\n" if game.turns.zero?
end
