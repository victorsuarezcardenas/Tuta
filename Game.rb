require_relative 'Card.rb'
require_relative 'Player.rb'
require 'json'
class Game
  # Se crean las variables de clase
  # cards: Se alamcenaran las cartas del juego
  # players: Se almacenran los jugadores
  # cards_thrown: Cartas lanzadas por los jugadores en cada ronda
  # trump_card: Carta del triunfo
  attr_accessor :cards, :players, :cards_thrown, :trump_card

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
          save_card(card, type)
          title = false
        else
          type = card
          title = true
        end
      end
    end
  end

  # create_player: Agrega un jugador a la lista de jugadores
  # name: nombre del jugador
  def create_player(name)
    @players.push(Player.new(name, name, 0))
  end

  # distribuete_cards: Selecciona la carta del triunfo y
  # reparte las cartas de una en una a cada
  # jugador hasta que lleguen a 8 cartas
  def distribute_cards
    while @players[0].cards.length != 8
      @players.each do |player|
        card = select_card
        @trump_card = card if @cards.length == 25
        player.cards.push(card)
      end
    end
  end

  def show_players
    puts @cards.length
    @players.each do |player|
      puts "Nombre: #{player.name}"
      player.cards.each do |card|
        puts card.id
      end
    end
  end

  def start_game
    start = true
    cant_players = @players.length
    player_random = select_player_random
    cont = 1
    until @players[0].cards.empty?
      puts "Ronda #{cont}"
      round(player_random)
      player_random = whoWinRound(player_random)
      puts "------------Ganador de la ronda #{cont} ------------------"
      puts "Nombre: #{@players[player_random].name}, Con"
      puts "Carta: #{@players[player_random].card_thrown.number} , #{@players[player_random].card_thrown.type}"
      save_card_into_player_win(@players[player_random])
      cont += 1
    end
    who_win

  end

  def who_win
    @players.each do |player|
      result_sum = 0
      player.cards_wins.each do |cards|
        result_sum += cards.value.to_i
      end
      player.points = result_sum
    end
    players_win = @players.sort_by(&:points).reverse![0]
    puts 'GANADOR--------GANADOR---------GANADOR----'
    puts "Nombre: #{players_win.name} Puntos: #{players_win.points}"
    #players_win.cards_wins.each do |cards|
    #  puts cards.id
    #end
    @players.each do |player|
      puts player.name
      player.cards_wins.each do |cards|
        puts "Carta: #{cards.id}"
      end
    end
  end

  def save_card_into_player_win(player)
    cont = @cards_thrown.length - 1
    while cont >= 0
      card = @cards_thrown[cont]
      player.cards_wins.push(card)
      @cards_thrown.delete_at(cont)
      cont -= 1
    end
  end

  def whoWinRound(num_player_start)
    cont = 0
    card_win = @players[num_player_start].card_thrown
    while cont <= (@players.length - 1)
      card = @players[cont].card_thrown
      if card_win != card
        if card.type.to_s == @trump_card.type.to_s || card_win.type.to_s == @trump_card.type.to_s
          aux_card = validate_card_with_trump(card, card_win)
        else
          aux_card = validate_card_without_trump(card, card_win)
        end
        if save_card_win(aux_card).nil?
        else
          card_win = save_card_win(aux_card)
        end
      end
      cont += 1
    end
    cont_player = 0
    while cont_player <= (@players.length - 1)
      return cont_player if @players[cont_player].card_thrown == card_win
      cont_player += 1
    end
  end

  # round: recorre la lista de jugadores
  # num_player: numero que selecciona que jugador inicia la ronda
  def round(num_player)
    cont = 1
    while cont <= @players.length
      num_player = 0 if num_player == @players.length
      throw_card_player(@players[num_player])
      if @cards_thrown.length.zero?
      else
        puts '--------Cartas en la mesa-------'
        @cards_thrown.each do |card|
          puts "Carta: Numero: #{card.number} Tipo: #{card.type} "
        end
      end
      cont += 1
      num_player += 1
    end
  end

  # throw_card_player: Muestra las cartas del jugador y pide que seleccione una para lanzar
  # player: Es el jugador que va a lanzar
  def throw_card_player(player)
    puts "Carta del triunfo: Numero: #{@trump_card.number}, Tipo: #{@trump_card.type}"
    puts "Turno para el jugador: #{player.name}"
    puts "----------Sus Cartas--------------"
    player.cards.each do |card|
      puts card.id
    end
    card_valid = true
    while card_valid
      card_valid = get_card(player, card_valid)
    end
  end

  # search_card: Busca la carta en las cartas del jugador, Si la encuentra, retorna la carta,
  # si no, retorna null
  # player: Es el jugador
  # id_card: El id de la carta seleccionada
  def search_card(player, id_card)
    player.cards.each do |card|
      return card if id_card.to_s == card.id.to_s
    end
    NIL
  end

  # select_player_random: Selecciona aleatoriamente un jugador y lo retorna
  def select_player_random
    num_player = rand(@players.length)
    num_player
  end

  private

  def save_card_win(aux_card)
    if aux_card.nil?
    else
      card_win = aux_card
    end
    card_win
  end

  # validate_card_with_trump: Valida si la carta es la posible gandaora con el triunfo
  # card: carta posible ganadora
  # card_win: La carta que va ganando
  def validate_card_with_trump(card, card_win)
    if card.type.to_s == @trump_card.type.to_s &&
        card_win.type.to_s != @trump_card.type.to_s
      return card
    elsif card_win.type.to_s == @trump_card.type.to_s &&
        card.type.to_s != @trump_card.type.to_s
      return card_win
    end

    if !card_win.value.to_i.zero? || !card.value.to_i.zero?
      return card if card_win.value.to_i < card.value.to_i
    elsif card_win.number.to_i < card.number.to_i
      return card
    end
    NIL
  end

  # validate_card_without_trump: Valida si la carta es la posible gandaora sin el triunfo
  # card: carta posible ganadora
  # card_win: La carta que va ganando
  def validate_card_without_trump(card, card_win)
    if card_win.type.to_s == card.type.to_s
      if !card_win.value.to_i.zero? || !card.value.to_i.zero?
        return card if card_win.value.to_i < card.value.to_i
      elsif card_win.number.to_i < card.number.to_i
        return card
      end
    end
    NIL
  end

  # get_card: Pedir el id de la carta a lanzar por teclado y validarla
  # player: El jugador
  def get_card(player, card_valid)
    puts 'Digite el id de la carta a lanzar'
    card_id = gets.chomp.to_s
    card = search_card(player, card_id)
    if !card.nil?
      player.card_thrown = card
      @cards_thrown.push(player.card_thrown)
      (0..player.cards.length - 1).each do |i|
        player.cards.delete_at(i) if player.cards[i] == card
      end
      card_valid = false
    else
      puts 'Id no valido'
    end
    card_valid
  end

  # save_card: Se guardan las cartas en el array cards
  def save_card(card, type)
    card.each do |i|
      @cards.push(Card.new((i['number'].to_s + type.to_s), i['number'].to_s,
                           type.to_s, i['value'].to_s))
    end
  end

  # select_card: Selecciona una carta aleatorimanete y la retorna
  def select_card
    num_random = rand(@cards.length)
    card = @cards[num_random]
    @cards.delete_at(num_random)
    card
  end
end

game = Game.new
(1..2).each do |i|
  puts "Ingrese el nombre del jugador #{i}"
  name = gets.chomp
  game.create_player(name.to_s)
end
game.distribute_cards
game.start_game