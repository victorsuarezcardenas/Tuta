require_relative 'Card.rb'
require_relative 'Player.rb'
require 'json'
class Game
  # Se crean las variables de clase
  # cards: Se alamcenaran las cartas del juego
  # players: Se almacenran los jugadores
  # cards_thrown: Cartas lanzadas por los jugadores
  attr_accessor :cards, :players, :cards_thrown

  # Contructor: se inicializan las las varialbes de clases
  # y se lee el archivo cards.json para obtener las cartas
  def initialize
    @cards = []
    @players = []
    @cards_thrown = []
    cards_json = File.read('cards.json')
    cards_data = JSON.load cards_json
    cards_data.each do |data|
      title = false
      type = ''
      data.each do |card|
        if title
          saved_card(card, type)
          title = false
        else
          type = card
          title = true
        end
      end
    end
  end

  def create_player(name)
    @players.push(Player.new(name, name, 0))
  end

  def distribute_carsd

  end

  private

  # save_card: Se guardan las cartas en el array cards
  def saved_card(card, type)
    card.each do |i|
      @cards.push(Card.new((i['number'].to_s + type.to_s), i['number'].to_s,
                           type.to_s, i['value'].to_s))
    end

  end
end

game = Game.new
