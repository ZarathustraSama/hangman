# frozen_string_literal: true

require 'pry-byebug'
require 'json'

# The game logic
class Hangman
  attr_accessor :secret_word, :turns, :guesses, :word

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
      if new_guess.length == 1 && new_guess.match(/[a-z]/) && !@guesses.include?(new_guess)
        @guesses << new_guess
        return new_guess
      end
      puts("Try again!\n")
    end
  end

  def check_guess(guess)
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
    new_guess = ask_guess
    letter_positions = check_guess(new_guess)
    letter_positions&.each { |position| @word[position] = new_guess }
  end

  def print_word
    @word.each do |letter|
      if letter.nil?
        print '_ '
      else
        print "#{letter} "
      end
    end
  end
end

def load_dict(path)
  dict_obj = File.open(path)
  dict_list = []
  dict_list << dict_obj.gets.chomp until dict_obj.eof
  dict_list
end

def choose_secret_word(dict_list)
  dict_list.select { |word| word.length > 4 && word.length < 13 }.sample.split('')
end

def dump_to_json(game)
  JSON.dump({ secret_word: game.secret_word, turns: game.turns, guesses: game.guesses, word: game.word })
end

def save_game(game)
  filename = 'save_file'
  game_data = dump_to_json(game)

  File.open(filename, 'w') do |file|
    file.puts game_data
  end
end

def from_json(string)
  data = JSON.parse string
  Hangman.new(data['secret_word'], data['turns'], data['guesses'], data['word'])
end

def load_game(save_file)
  game_data = File.open(save_file).gets.chomp
  from_json(game_data)
end

def ask_save(game)
  loop do
    puts('Do you want to save your game? y/n')
    answer = gets.chomp.downcase
    save_game(game) if answer == 'y'
    return if answer.include?('y' || 'n')

    puts('Give a clear answer!')
  end
end

def ask_load(save_file)
  loop do
    puts('Do you want to load your previous game? y/n')
    answer = gets.chomp.downcase
    return load_game(save_file) if answer == 'y'
    return if answer == 'n'

    puts('Give a clear answer!')
  end
end

secret_word = choose_secret_word(load_dict('google-10000-english.txt'))
game = ask_load('save_file') if File.exist?('save_file')

game ||= Hangman.new(secret_word)

game.initialize_word_length if game.word.empty?

puts("Preparations are completed! Let\'s begin!\n")

loop do
  puts("Remaining guesses: #{game.turns}\n\n")

  game.print_word

  game.fill_blanks

  if game.game_over?(game.word)
    game.print_word.join('').capitalize
    return puts "\n\nCongratulations! You won!"
  end

  game.advance_turn
  return puts "\n The man has been hanged :(\n" if game.turns.zero?

  ask_save(game)
end
