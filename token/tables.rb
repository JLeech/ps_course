class FlagsTable
	include Singleton

	attr_accessor :flags
	attr_accessor :file

	def initialize
		@file = "token/flags.txt"
		@flags = {}
		lines = IO.readlines(@file)
		lines.each { |line| line.chomp! }
		lines.each do |line|
			words = line.split(" ")
			@flags[words.first] = words.drop(1)
		end
	end

	def has_flag?(command,flag)
		return true if @flags[command.name].include?(flag.name)
		return false
	end
end

class CommandTable
	include Singleton

	attr_accessor :commands
	attr_accessor :file

	def initialize
		@file = "token/commands.txt"
		@commands = IO.readlines(@file)
		@commands.each { |command| command.chomp! }
	end

	def command?(token)
		if @commands.include?(token)
			return true
		else
			return false
		end
	end
end

class TypesTable
	include Singleton

	attr_accessor :types
	attr_accessor :file

	def initialize
		@file = "token/types.txt"
		@types = {}
		lines = IO.readlines(@file)
		lines.each { |line| parce_line(line)}
		@types.keys.each { |key| puts "#{key} #{@types[key]}" }
	end

private
	
	def parce_line(line)
		parts = line.split(" ")
		command = parce_command(parts)
		parce_types(command,parts.drop(1))
	end

	def parce_command(parts)
		return parts[0]
	end

	def parce_types(command,parts)
		if parts[0].start_with?("-")
			parce_outcome(command,parts[0])
		else
			parce_income(command,parts[0])
			unless parts[1].nil?
				parce_outcome(command,parts[1])	
			end
		end
	end

	def parce_income(command,income)
		types = income.split("||")
		types.each { |type| type.gsub!("[","") }
		types.each { |type| type.gsub!("]","") }
		@types["#{command}"] = {} unless @types.has_key?("#{command}")
		@types["#{command}"]["in"] = types

	end

	def parce_outcome(command,outcome)
		outcome.gsub!("]","")
		outcome.gsub!("[","")
		outcome.gsub!("-","")
		types = outcome.split(",")
		@types["#{command}"] = {} unless @types.has_key?("#{command}")
		@types["#{command}"]["out"] = []
		types.each { |type| @types["#{command}"]["out"].push(type) }
	end

end