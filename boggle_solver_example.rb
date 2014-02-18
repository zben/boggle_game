require_relative 'boggle_solver'

def default_example_input
  [%w[h e l l],
   %w[s e e o],
   %w[t m e a],
   %w[h i s n]]
end

def user_input
  puts "Enter letters for Boggle, one row at a time with spaces: (Press enter for example, Ctr+C to quit)"
  input = []
  input << letters = gets.strip.split(" ")
  (letters.count - 1).times { input << gets.strip.split(" ") } unless letters.empty?

  input.flatten.empty? ? default_example_input : input
end

while input = user_input
  game = BoggleGame.new(input)
  game.discover
  printer = BogglePrinter.new(game)
  printer.print_words
  printer.print_game
  printer.list_words
end
