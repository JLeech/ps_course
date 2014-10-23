class Argument
	
	INSERT = "$_"

	attr_accessor :name
	attr_accessor :position
	attr_accessor :insertion

	def initialize(name,position)
		@name = name
		@position = position
		@insertion = @name.index(INSERT)
	end

	def has_insertion?
		return !@insertion.nil?
	end
end

class Pipe
	USUAL = "|"
	ACCUMULATE = "accum"
	EACH = "each"
	OVER = "end"

	attr_accessor :name
	attr_accessor :type
	attr_accessor :position

	def initialize(name,position)
		@name = name
		@position = position
		@type = def_type
	end

	def def_type
		type = ACCUMULATE if @name.end_with?(ACCUMULATE)
		type = EACH if @name.end_with?(EACH)
		type = OVER if @name.end_with?(OVER)
		type = USUAL if @name == USUAL
		return type
	end

	def print
		puts ": #{@name} : #{@position}"
		puts ":    #{type}"
		puts "-------------"
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
		arguments.each do |arg|
			puts ":    #{arg.name} : #{arg.has_insertion?}"
		end
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