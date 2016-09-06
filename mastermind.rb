require 'sinatra'
#require 'sinatra/reloader'

class Mastermind
	attr_accessor :computer_output

	def initialize(gametype, code)
		@colors = ['r','g','y','b','o','v'] 	
		@game_over = false
		if gametype == 1
			@code = code.split('')
			@computer_output =[]
			computer_guess
		elsif gametype == 2
			@code = code_generator
			@guess = code 
			play
		end
	end


	def code_generator(colors=@colors)		
		code = []
		4.times do |x|
			random = rand(5)
			code.push(colors[random])
		end
		code
	end

	def play
		until @game_over
			guess
		end
	end

	def guess
		puts "Enter a guess for a code"
		guess = gets.chomp.split('')
		feedback = check_guess(guess)
	end

	def computer_guess(guess_code = code_generator, known ={}, close =[], wrong=[])
		@computer_output.push("guessing #{guess_code}")

		if guess_code == @code
			@game_over = true
			@computer_output.push("Computer won!")
		else

			guess_code.each_with_index do |color, index|
				diagnosis = feedback(color,index)
				if diagnosis == "match"
					@computer_output.push("found a match")
					if known[color]
						known[color].push(index)
					else
						known[color] = [index]
					end
				elsif diagnosis == "partial match"
					@computer_output.push("found a partial match")
					close.push(color)
				else
					@computer_output.push("color not found, removing from possibilities")
					wrong.push(color)
				end
			end
			@computer_output.push("trying new guess")
			computer_new_guess(known, close, wrong)
		end
	end
	

	def computer_new_guess(known={}, close=[], wrong=[])
		new_colors = @colors
		wrong.each do |color|
			if new_colors.include?(color)
				new_colors.delete(color)
				@computer_output.push("deleted #{color}")
			end
		end 

		new_guess = []

		if !close.empty?
			until new_guess.include?(close[0])
				new_guess = code_generator(new_colors)
			end
			close.shift
		else
			@computer_output.push("making a new code")
			4.times do |y|
				random = rand(0..(new_colors.length-1))
				new_guess.push(new_colors[random])
			end
		end

		unless known.empty?
			known.each_pair do |color, pos| 
				pos.each do |ind|
					new_guess[ind] = color
				end
			end
		end

		@computer_output.push("new guess is #{new_guess}")
		computer_guess(new_guess, known, close, wrong)
	end

	def check_guess(guess)
		if guess == @code
			@game_over = true
			puts "You won!"
		else 
			guess.each_with_index do |color, index|
				response = feedback(color,index)
				hint(response)
			end
		end
	end

	def feedback(color, index)
		if @code.include?(color)
			if color == @code[index]
				"match"					
			else
				"partial match"
			end
		else
			"not found"
		end
	end

	def hint(guess_response)
		if guess_response == "match"
			puts "This color is in the right position."
		elsif guess_response == "partial match"
			puts "This color is in the wrong position."
		else
			puts "This color was not found in the code."
		end
	end
end



get '/' do
	#checking for the presence of either type of game parameter
	if !params['code-guess'].nil? || !params['user-code'].nil?
		game_started = true
		if !params['code-guess'].nil?
			game_type = "user"
		else
			game_type = "computer"
			user_code = params['user-code']
			game = Mastermind.new(1, user_code)
			computer_output = game.computer_output
		end 
	else
		game_started = false
		game_type = nil
		computer_output = nil
	end

	erb :index , :locals => {:game_started => game_started, :game_type => game_type, :computer_output => computer_output}
end

post '/' do
	erb :game #, :locals
end

