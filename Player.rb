class Player
  attr_accessor :id, :name, :points, :cards

  def initialize(id, name, points)
    @id = id
    @name = name
    @points = points
    @cards = []
  end

end