require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17

# Blackjack game web app.

helpers do
  def calculate_sum(cards)
    sum = 0
    cards.each do |card|
      sum = sum + card[2]
    end
    cards.select{|card| card[1] == 'A' }.count.times do  # correction of "A" if sum > Blackjack::BLACKJACK_AMOUNT
      sum -= 10 if sum > BLACKJACK_AMOUNT
    end
    return sum
  end

  def card_image(card)
    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'  
      end
    end
    "<img src='/images/cards/#{card[0]}_#{value}.jpg' class='card_image'>"   
  end 

  def win_msg(msg)
    @show_play_again = true
    @show_button = false
    @success = "<strong>#{msg} #{session[:username]} won at #{calculate_sum(session[:player_cards])} and dealer at #{calculate_sum(session[:dealer_cards])}.</strong>"
  end

  def loose_msg(msg)
    @show_play_again = true
    @show_button = false
    @error = "<strong>#{msg} dealer won at #{calculate_sum(session[:dealer_cards])} and #{session[:username]} at #{calculate_sum(session[:player_cards])}.</strong>"
  end

  def tie_msg(msg)
    @show_play_again = true
    @show_button = false
    @success = "<strong>#{msg} Both #{session[:username]} and dealer at #{calculate_sum(session[:player_cards])}.</strong>"
  end

end

before do
  @show_button = true
end


get '/' do
  if session[:username]
    redirect '/blackjack'
  else
    redirect '/get_name'         # Get the user name
  end  
  
end

get '/get_name' do
  erb :get_name
end

post '/get_name' do
  if params[:username].empty?
    @error = 'Name can not be empty! Please enter your name!'
    halt erb :get_name
  end  
  session[:username] = params[:username]
  redirect '/blackjack'
end

get '/blackjack' do                # Blackjack main web page
  session[:turn] = session[:username]

  # create a deck
  deck_temp = []
  suits = ['spades', 'hearts', 'diamonds', 'clubs']
  cards = [ ['2', 2], ['3', 3], ['4', 4], ['5', 5], ['6', 6], ['7', 7], ['8', 8], ['9', 9], ['10', 10], ['J', 10], ['Q', 10], ['K', 10], ['A', 11 ]]
  deck_temp = suits.product(cards).each do |card|
    card.flatten!
  end  
  session[:deck] =  deck_temp.shuffle!

  # deal cards
  
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :blackjack
end

post '/blackjack/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_sum = calculate_sum(session[:player_cards])
  dealer_sum = calculate_sum(session[:dealer_cards])
  if player_sum == BLACKJACK_AMOUNT && dealer_sum == player_sum 
    tie_msg("It's a tie!")
  elsif player_sum == BLACKJACK_AMOUNT 
    win_msg('BLACKJACK!') 
  elsif player_sum > BLACKJACK_AMOUNT
    loose_msg("#{session[:username]} has busted!")
  end
  erb :blackjack
end

post '/blackjack/player/stay' do
  @success = "#{session[:username]} stay!"
  #@show_button = false
  redirect '/blackjack/dealer'
end

get '/blackjack/dealer' do
  session[:turn] = 'dealer'
  @show_button = false
  dealer_total = calculate_sum(session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loose_msg('Sorry, the dealer won!')
  elsif dealer_total > BLACKJACK_AMOUNT
    win_msg("Dealer busted, #{session[:username]} won!")
  elsif dealer_total >= DEALER_MIN_HIT   # 17, 18, 19, 20
    # dealer stay
    redirect '/blackjack/compare'
  else
    # dealer hit
    @show_dealer_hit_button = true
  end

  erb :blackjack
end

post '/blackjack/dealer/hit' do
  # @show_button = false
  session[:dealer_cards] << session[:deck].pop
  redirect '/blackjack/dealer'
end

get '/blackjack/compare' do
  # @show_button = false
  player_total = calculate_sum(session[:player_cards])
  dealer_total = calculate_sum(session[:dealer_cards])

  if player_total > dealer_total
    win_msg("#{session[:username]} has won!")
  elsif player_total < dealer_total
    loose_msg("The dealer won!")
  else
    tie_msg("It's a tie!")
  end

  erb :blackjack
end

get '/bye' do
  erb :bye
end



