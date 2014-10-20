class Argument
	attr_accessor :name
	attr_accessor :position

	def initialize(name,position)
		@name = name
		@position = position
	end
end

class Flag
	attr_accessor :name
	attr_accessor :position

	def initialize(name,position)
		@name = name
		@position = position
	end
end

class Command

	attr_accessor :name
	attr_accessor :flags
	attr_accessor :arguments
	attr_accessor :position

	def initialize(name = "",position = 0)
		@name = name
		@position = position
		@flags = []
		@arguments = []
	end

	def print
		puts ": #{@name} : #{@position}"
		puts ":    #{flags}"
		puts ":    #{arguments}"
		puts "-------------"
	end
end

class Message
	attr_accessor :error
	attr_accessor :text

	def initialize(error,text)
		@error = error
		@text = text
	end

	def isError?
		return error
	end
end