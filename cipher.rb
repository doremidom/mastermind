require 'sinatra'
#require 'sinatra/reloader'

def caesar_cipher(string, shift)
	if string.nil? || shift.nil?
		" "
	else
		letters = ("A".."Z").to_a
		string_ary = string.upcase.split('')
		result = []

			string_ary.each do |letter|
				index = letters.index(letter)
				index += shift
				if index > 26
					index -= 26
				end
				puts letters[index]
				result.push(letters[index])
		 	end
		result.join('')
	end
end

get '/' do
	string = params["string"]
	shift = params["shift"].to_i

	result = caesar_cipher(string, shift)

	erb :index, :locals => {:result => result, :string => string}
end

