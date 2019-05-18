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
  #
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
  # Muestra las cartas de cada jugador
  def show_players
    puts @cards.length
    @players.each do |player|
      puts "Nombre: #{player.name}"
      player.cards.each do |card|
        puts card.id
      end
    end
  end

  # Selecciona quien inicia la partida y luego hace un ciclo hasta que los jugadores se queden sin cartas
  # En el ciclo se muestra la ronda que se esta jugando
  # llama a ronda
  # luego llama whoWinRound()
  # Y muestra quien gano la ronda con la carta que gano
  # Al terminar el ciclo, llama a who_win
  def start_game
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

  # who_win: Recorre el array de players y dentro,
  # recorre el array de cartas ganadas de cada jugador
  # haciendo la suma de las cartas ganadas guardando el resultado
  # en la variable de poinst de cada jugador,
  # Una vez finalizado ordena el array de players de mayor
  # a menor con la variable poinst, se selecciona el primer player
  # y se muestran los datos del nombre y los puntos del jugador ganador
  # despues se listan los jugadores con sus cartas
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
    puts "Nombre: #{players_win.name} || Puntos: #{players_win.points}"
    #players_win.cards_wins.each do |cards|
    #  puts cards.id
    #end
    @players.each do |player|
      puts ''
      puts player.name
      puts 'Cartas: '
      player.cards_wins.each do |cards|
        print "#{cards.id}"
        print ' || '
      end
    end
  end

  # save_card_into_player_win: Guarda las cartas que estan en la mesa
  # en el array de cartas ganadas que tiene el player,
  # y las va elminando de la lista de cartas de la mesa.
  #
  # player: Jugador que gano la ronda
  def save_card_into_player_win(player)
    cont = @cards_thrown.length - 1
    while cont >= 0
      card = @cards_thrown[cont]
      player.cards_wins.push(card)
      @cards_thrown.delete_at(cont)
      cont -= 1
    end
  end

  # whoWinRound: Toma la carta del player que empezo la ronda
  # luego hace un ciclo recorriendo los players.
  # En el ciclo toma la carta del player,
  # valida que si la carta del player que inicio la ronda no es la misma
  # que la del player a comprobar.
  # Si no son las mismas, valida que el tipo de la carta del player sea igual
  # al tipo de la carta del triunfo o que el tipo de la carta del player que
  # inicio la ronda sea igual al del triunfo.
  # Si alguno de los dos es valido va a validate_card_with_trump y
  # guarda el resultado.
  # Si no va a validate_card_without_trump y guarda el resultado
  # Luego comprueba que save_card_win no sea nulo
  # Si no es nulo guarda el resultado.
  #
  # Luego recorre la lista de players y comprueba si la carta que lanzo el
  # jugador es igual a la carta que se selecciona como ganadora retorna la
  # posicion del player
  #
  # num_player_start: posicion del player que inicio la ronda
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

  # round: recorre la lista de players desde el jugador que inicio la ronda
  # hasta que llega a una posicion antes de el.
  # Si hay cartas en la mesa, las muestra por cada jugador
  #
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

  # throw_card_player: Muestra las cartas del player y va a get_card,
  # si el resultado no es valido vuelve a get_card hasta que sea valido
  #
  # player: Es el player que va a lanzar
  def throw_card_player(player)
    puts "Carta del triunfo: Numero: #{@trump_card.number}, Tipo: #{@trump_card.type}"
    puts "Turno para el jugador: #{player.name}"
    puts "-------------------------------------Sus Cartas-----------------------------------------"
    player.cards.each do |card|
      print card.id
      print ' || '
    end
    card_valid = true
    while card_valid
      card_valid = get_card(player, card_valid)
    end
  end

  # search_card: Busca la carta en las cartas del player, Si la encuentra,
  # retorna la carta, si no, retorna null
  #
  # player: Es el player
  # id_card: El id de la carta seleccionada
  def search_card(player, id_card)
    player.cards.each do |card|
      return card if id_card.to_s == card.id.to_s
    end
    NIL
  end

  # select_player_random: Selecciona aleatoriamente un player y lo retorna
  def select_player_random
    num_player = rand(@players.length)
    num_player
  end

  private

  # save_card_win: Si la carta que recive no es unal guarda la carta y la retorna
  # aux_card: Carta a validar
  def save_card_win(aux_card)
    if aux_card.nil?
    else
      card_win = aux_card
    end
    card_win
  end

  # validate_card_with_trump: Comprueba si el tipo de carta del
  # player a comprobar es igual al tipo de carta del triunfo Y
  # si el tipo de carta del player que inicio es diferente al tipo
  # de carta del triunfo, retorna la carta del player a comprobar.
  # Si no.
  # Comprueba si el tipo de carta del player que inicio es igual al tipo
  # de carta del triunfo Y si el tipo de carta del player a comprobar es
  # diferente al tipo de carta del triunfo,
  # retorna la carta del player que inicio
  #
  # card: La carta del player a comprobar
  # card_win: La carta del player que inicio la ronda
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

  # validate_card_without_trump: Comprueba si el tipo de la carta del player
  # que lanzo de primeras, es igual a la del player a comprobar,
  # y si (El valor de la carta del player que inicio es 0 o
  # El valor de la carta del player a comprobar es 0),
  # devuelve la carta del player a comprobar si el valor de la carta
  # es mayor al del player que lanzo primero.
  # Si no devuelve la carta del player a comprobar si el numero
  # de la carta es mayor.
  # Si el tipo de carta no es igual devuelve null.
  #
  # card: La carta del player a comprobar
  # card_win: La carta del player que inicio la ronda
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

  # get_card: Pide el id de la carta a lanzar por teclado,
  # luego va a search_card y si no retorna null guarda la carta en el player
  # en la variable cart_thrown (carta lanzada) luego la guarda en cards_trhown
  # (lista de cartas en la mesa) y luego la elimina de la lista de cartas del
  # player.
  # Si retorna null muestra el mensaje "Id no valido"
  #
  # player: El player que tiene que lanzar la carta
  def get_card(player, card_valid)
    puts ''
    puts '----------------------------------------------------------------------------------------'
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
  # card: json de la carta
  # type: pala de la carta
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