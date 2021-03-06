require 'sinatra'
require 'sinatra/reloader' if development?

class Mastermind
	attr_accessor :computer_output, :guess_feedback, :code, :game_over

	def initialize(gametype, code, saved_code=nil)
		@colors = ['r','g','y','b','o','v'] 	
		@game_over = false
		@tried_codes = []
		if gametype == 1
			@code = code.split('')
			@computer_output =[]
			computer_guess
		elsif gametype == 2
			if saved_code
				@code = saved_code
			else
				@code = code_generator
			end
			@guess = code.split('')
			@guess_feedback = []
			check_guess(@guess)
		end
	end


	def code_generator(colors=@colors)		
		code = []
		4.times do |x|
			random = rand((colors.length))
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
			@tried_codes.push(guess_code)
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
					close.push(color) unless close.include?(color)
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
				#@computer_output.push("deleted #{color}")
			end
		end 

		new_guess = []

		if !close.empty?
			@computer_output.push("making a new code that includes #{close}")
			until close.all? { |e| new_guess.include?(e) } && !@tried_codes.include?(new_guess)
				#@computer_output.push("close is #{close[0]}")
				new_guess = code_generator(new_colors)

				unless known.empty?
					known.each_pair do |color, pos| 
						pos.each do |ind|
							new_guess[ind] = color
						end
					end
				end
			end
			#close = [] 
		else
			@computer_output.push("making a new code")
			

			new_guess = code_generator(new_colors)	
			
			unless known.empty?
			known.each_pair do |color, pos| 
				pos.each do |ind|
					new_guess[ind] = color
				end
			end


		end	
		
		end



		#@computer_output.push("new guess is #{new_guess}")
		computer_guess(new_guess, known, close, wrong)
	end

	def check_guess(guess)
		if guess == @code
			@game_over = true
			@guess_feedback.push("You won!")
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
			@guess_feedback.push("This color is in the right position.")
		elsif guess_response == "partial match"
			@guess_feedback.push("This color is in the wrong position.")
		else
			@guess_feedback.push("This color was not found in the code.")
		end
	end
end

enable :sessions

get '/' do
	#checking for the presence of either type of game parameter
	if !params['code-guess'].nil? || !params['user-code'].nil?
		game_started = true
		if !params['code-guess'].nil?
				code_guess = params['code-guess']
				game_type = "user"			
			
				if !session[:game_code].nil?
					@saved_code = session[:game_code]
					game = Mastermind.new(2, code_guess, @saved_code)
					if game.game_over
						session[:game_code] = nil
						game_over = true
					end					
				else
					game = Mastermind.new(2, code_guess)
					session[:game_code] = game.code
					session[:game] = game
				end

				guess_feedback = game.guess_feedback
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
		guess_feedback = nil
		code_guess = nil
		code = nil
		game_over = false
	end

	erb :index , :locals => {:game_started => game_started, :game_type => game_type, :computer_output => computer_output, :guess_feedback => guess_feedback, :code_guess => code_guess, :saved_code => @saved_code, :game_over => game_over}
end
