# frozen_string_literal: true

require 'pry-byebug'

# The game logic
class Hangman
  attr_accessor :dict, :secret_word, :turns, :guesses, :word

  def initialize(secret_word, turns = 20, guesses = [], word = [])
    @secret_word = secret_word
    @turns = turns
    @guesses = guesses
    @word = word
  end

  def advance_turn
    @turns -= 1
  end

  def game_over?(guess_word)
    guess_word == @secret_word
  end

  def initialize_word_length
    @secret_word.each { |_letter| @word << nil }
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

  def check_guess
    guess = ask_guess
    secret_word = @secret_word.clone
    return mark_letter_positions(secret_word, guess) if secret_word.include?(guess)

    nil
  end

  def mark_letter_positions(secret_word, guess)
    positions = []
    while secret_word.include?(guess)
      positions << secret_word.index(guess)
      secret_word[secret_word.index(guess)] = nil
    end
    positions
  end

  def fill_blanks
    check_guess&.each { |position| @word[position] = new_guess }
  end

  def print_word(word)
    word.each do |letter|
      if letter.nil?
        print '_ '
      else
        print "#{letter} "
      end
    end
  end
end

def load_dict(path)
  dict_list = []
  dict_list << File.open(path).gets.chomp until File.open(path).eof
  dict_list
end

def choose_secret_word(dict_list)
  dict_list.select { |word| word.length > 4 && word.length < 13 }.sample.split('')
end

secret_word = choose_secret_word(load_dict('google-10000-english.txt'))
game = Hangman.new(secret_word)

game.initialize_word_length

puts("Preparations are completed! Let\'s begin!\n")

loop do
  puts("Remaining guesses: #{game.turns}\n\n")

  game.print_word(game.word)

  game.fill_blanks

  if game.game_over?(game.word)
    game.print_word(game.word).capitalize
    return puts "\nCongratulations! You won!"
  end

  game.advance_turn
  return puts "\n The man has been hanged :(\n" if game.turns.zero?
end
