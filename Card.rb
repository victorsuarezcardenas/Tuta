class Card
  attr_accessor :id, :number, :type, :value

  def initialize(id, number, type, value)
    @id = id
    @number = number
    @type = type
    @value = value
  end
end