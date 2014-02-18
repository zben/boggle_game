require 'rubygems'
require 'rspec'
require_relative '../boggle_solver'

describe BoggleGame do
  subject do
    input = [%w[h e l l],
             %w[s e e o],
             %w[t m e a],
             %w[h i s n]]

    BoggleGame.new(input)
  end

  before { subject.discover }

  describe "#words" do
    it "returns the right words" do
      words = subject.words.map(&:to_s)
      expect(words).to include("HELLO")
      expect(words).to include("THIS")
      expect(words).to include("MEAN")
      expect(words).to include("SEE")
    end
  end
end
