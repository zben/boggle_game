require 'rubygems'
require 'ruby-dictionary'

class EnglishDictionary
  def self.cached
    @dictionary ||=
      begin
        puts "Building dictionary..."
        Dictionary.from_file('/usr/share/dict/words')
      end
  end
end

class BoggleGame
  attr_accessor :tiles, :words, :dictionary, :input

  def initialize(array_of_array)
    @tiles = []
    @words = []
    @input = array_of_array
  end

  def discover!
    populate_tiles
    Word.new(self).discover
  end

  def populate_tiles
    @input.each_with_index do |letter_array, i|
      letter_array.each_with_index do |letter, j|
        @tiles << Tile.new(self, i+1, j+1, letter)
      end
    end
  end

  def dimension
    @input.length
  end

  def unique_words
    @words.map(&:to_s).uniq
  end
end

class Tile
  attr_accessor :game, :x, :y, :letter, :neighbors

  def initialize(game, x, y, letter)
    @game = game
    @x = x
    @y = y
    @letter = letter
  end

  def neighbors
    @neighbors ||= @game.tiles.select do |tile|
      #(tile.x - x).abs <= 1 && (tile.y - y).abs <= 1  # horizontal, vertical and diagonal
      ((tile.x - x).abs == 1 && tile.y == y) ||         # horizontal and vertical only
      ((tile.y - y).abs == 1 && tile.x == x)
    end - [self]
  end
end

class Word
  attr_accessor :game, :tiles

  def initialize(game, tiles = [])
    @game = game
    @tiles = tiles
  end

  def to_s
    @tiles.map(&:letter).join("").upcase
  end

  def possible_next_tiles
    @tiles.empty? ? game.tiles : @tiles[-1].neighbors - @tiles
  end

  def child_words
    return [] if possible_next_tiles.empty?

    possible_next_tiles.map { |tile| self.class.new(game, self.tiles + [tile]) }
  end

  def discover
    valid_words = child_words.select(&:is_valid?)
    game.words = game.words | valid_words.select(&:is_word?)
    valid_words.map(&:discover)
  end

  def dictionary
    EnglishDictionary.cached
  end

  def is_valid?
    !dictionary.starting_with(to_s).empty?
  end

  def is_word?
    dictionary.exists?(to_s)
  end
end

#Calling code

class Word
  def pretty_print
    puts to_s.upcase
    range = (1..game.dimension)
    range.each do |x|
      range.each do |y|
        tile = @tiles.detect{|t| t.x == x && t.y == y}
        putc tile ? tile.letter.upcase : "*"
        putc " "
      end
      putc "\n"
    end
    puts
  end
end

def default_example_input
  [%w[h e l l],
   %w[s e e o],
   %w[t m e a],
   %w[h i s n]]
end

def user_input
  puts "Enter letters for Boggle, one row at a time with spaces:(Press Enter for example)"
  input = []
  input << letters = gets.strip.split(" ")
  (letters.count - 1).times { input << gets.strip.split(" ") } unless letters.empty?

  input.flatten.empty? ? default_example_input : input
end

def print_game(game)
  game.words.each(&:pretty_print)

  unique_words = game.unique_words
  puts "#{unique_words.count} words found."
  p unique_words
  puts
  puts "The Boggle Game"
  Word.new(game, game.tiles).pretty_print
end

while input = user_input
  game = BoggleGame.new(input)
  game.discover!
  print_game(game)
end
