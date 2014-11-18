require 'singleton'
require_relative 'token/tokens'
require_relative 'token/tables'

class Semantic

	attr_accessor :blocks
	attr_accessor :messages

	def initialize(blocks, messages)
		puts blocks.length
		@blocks = blocks
		@messages = messages
	end

	def test
		blocks.each { |block| block.print }
	end

end