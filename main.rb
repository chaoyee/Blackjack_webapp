require 'rubygems'
require 'sinatra'

set :sessions, true

# Blackjack game web app.

helpers do
  def calculate_sum(cards)
    sum = 0
    cards.each do |card|
      sum = sum + card[2]
    end
    cards.select{|card| card[0] == 'A' }.count.times do  # correction of "A" if sum > Blackjack::BLACKJACK_AMOUNT
      sum -= 10 if sum > 21
    end
    return sum
  end

  def card_image(card)
    value = card[1]
    value = case card[1]
      when 'J' then 'jack'
      when 'Q' then 'queen'
      when 'K' then 'king'
      when 'A' then 'ace'  
    end

    "<img src='/image/cards/#{card[0]}_#{value}.jpg' class='card_image'"   
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
  session[:username] = params[:username]
  redirect '/blackjack'
end

get '/blackjack' do                # Blackjack main web page
  
  # create a deck

  deck_temp = []
  suits = ['spades', 'hearts', 'dimonds', 'clubs']
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
  if calculate_sum(session[:player_cards]) > 21
    @error = 'You busted!'
    @show_button = false
  end
  erb :blackjack
end

post '/blackjack/player/stay' do
  @success = 'You stay!'
  @show_button = false
  erb :blackjack
end









