require "pstore"

class Hangman
	attr_reader :moves_left, :word_slots

	def initialize
		@word = choose_word
		@word_slots = generate_word_slots
		@moves_left = 10
		@wrong_letters = []
	end



	def over?
		if @moves_left <= 0
			puts "game over"
			puts "word was #{@word}"
			return true
		elsif @word_slots.include?("_") == false
			puts "you win!"
			puts "word was #{@word}"
			return true
		else
		return false
	end
	end

	def choose_word
		word = ""
		until (5..12).include?(word.length)
			word = File.readlines("wordlist.txt").sample.chop.upcase
		end
		return word
	end

	def display_game_status
		@word_slots.each {|slot| print slot + " "}
		puts " "
		puts "Moves left: #{@moves_left}"
		puts "Wrong guesses: #{@wrong_letters.each {|letter| print letter + " "}}"
	end

	def generate_word_slots
		return Array.new(@word.length, "_")
	end

	def update_word_slots(positions, letter)
		positions.each {|position| @word_slots[position] = letter}
	end


	def subtract_move
		@moves_left -= 1
	end

	def accept_guess(guess)
		if is_guess_valid?(guess) == false
			puts "invalid input, try again"
			return false
		elsif guess.length == 1
			check_letter(guess)
		elsif guess.length > 1
			check_word(guess)
		end
		return true
	end

	def is_guess_valid?(guess)
		
		if guess.length == 0 || guess =~ /[^A-Z]/
			return false
		else
			return true
		end
	end

	def check_letter(letter)
		if @word =~ /#{letter}/
			matched_spots = []
			@word.each_char.with_index do |hidden_letter, idx|
				if hidden_letter == letter
					matched_spots << idx
				end
			end
			update_word_slots(matched_spots, letter)
		else
			puts "no match"
			subtract_move
			add_wrong_letter(letter)
		end
	

	end

	def check_word(word)
		if word == @word
			@word_slots = @word
		else
			puts "incorrect"
			subtract_move
		end

	end

	def add_wrong_letter(letter)
		@wrong_letters << letter
	end

end

class Player


	def initialize(game)
		@game = game
		game_play_loop
	end

	def game_play_loop
		while @game.over? == false
			@game.display_game_status
			get_input
			
			
		end

	end

	def get_input
		response = false
		until response == true
			puts "guess a letter or guess a word"
			guess = gets.chop.upcase
			if guess == "SAVE"
				save(@game)
			
			else
				response = @game.accept_guess(guess)
			end
		end
	end

end

def save(game)
		store = PStore.new("storagefile")
		store.transaction do
			store[:games] ||= Array.new
			store[:games] << game
			end
			puts "saved"
end

def load_choice
	store = PStore.new("storagefile")
	games = []
	store.transaction do
		games = store[:games]
	end
	puts "please choose a game by number"
	games.each.with_index do |game, idx|
		puts "#{idx} + #{game.word_slots}"
	end
	choice = gets
	return games[choice.to_i]
end

def new_or_load
	puts "Welcome to hangman, input NEW for new game or LOAD to load old game"
	choice = gets.chop.upcase
	if choice == "LOAD"
		game = load_choice
	elsif choice == "NEW"
		game = Hangman.new
	end
		player = Player.new(game)
end

new_or_load


	




