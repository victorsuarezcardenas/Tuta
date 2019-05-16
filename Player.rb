class Player
  attr_accessor :id, :name, :points, :cards, :card_thrown, :cards_wins

  def initialize(id, name, points)
    @id = id
    @name = name
    @points = points
    @cards = []
    @cards_wins = []
  end

end