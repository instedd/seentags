# Lexes an input string into tokens.
class Lexer

  attr_reader :token

  # Creates this lexer from a string.
  def initialize(input)
    @length = input.length
    @input = input
    @p = 0
    @token = Token.new
  end
  
  # Returns the next token in the input string.
  def next_token
    if !@token.following.nil?
			@token = @token.following
			return @token.value
		end

		scan(@token)
		return @token.value
  end
  
  # Returns the token following the given token.
  def peek_next(token)
		if !token.following.nil?
		  return token.following
		end

		peekToken = Token.new
		scan(peekToken)
		token.following = peekToken
		return peekToken
	end
	
	private
	
	def scan(t)
		if @p >= @length
			t.value = TerminalSymbol::EOF
			t.input = nil
			return
	  end

		start = @p

		case (@input[@p]).chr
		when '0' .. '9'
			has_decimal_part = false
			while @p < @length && '0' <= (@input[@p]).chr && (@input[@p]).chr <= '9'
				@p += 1
			end
			
			if @p + 1 < @length && ((@input[@p]).chr == '.' || (@input[@p]).chr == ',') && '0' <= (@input[@p + 1]).chr && (@input[@p + 1]).chr <= '9'
				has_decimal_part = true
				@p += 1
				while @p < @length && '0' <= (@input[@p]).chr && (@input[@p]).chr <= '9'
					@p += 1
				end
			end

			t.value = TerminalSymbol::NUMBER
			t.input = @input[start ... @p]
			if has_decimal_part
				t.number = t.input.sub(',', '.').to_f
			else
				t.number = t.input.to_i
		  end
		when '('
			t.value = TerminalSymbol::LPAREN
			t.input = '('
			@p += 1
		when ')'
			t.value = TerminalSymbol::RPAREN
			t.input = ')'
			@p += 1
		when '['
			t.value = TerminalSymbol::LBRACKET
			t.input = '['
			@p += 1
		when ']'
			t.value = TerminalSymbol::RBRACKET
			t.input = ']'
			@p += 1
		when '{'
			t.value = TerminalSymbol::LCURLY
			t.input = '{'
			@p += 1
		when '}'
			t.value = TerminalSymbol::RCURLY
			t.input = "}"
			@p += 1
		when '.'
			t.value = TerminalSymbol::DOT
			t.input = "."
			@p += 1
		when ','
			t.value = TerminalSymbol::COMMA
			t.input = ","
			@p += 1
		when ':'
			t.value = TerminalSymbol::COLON
			t.input = ":"
			@p += 1
		when ';'
			t.value = TerminalSymbol::SEMICOLON
			t.input = ";"
			@p += 1
		when '='
			t.value = TerminalSymbol::EQUALS
			t.input = "="
			@p += 1
		when '/'
			t.value = TerminalSymbol::SLASH
			t.input = "/"
			@p += 1
		when ' ', "\t", "\n"
			@p += 1
			while @p < @length && ((@input[@p]).chr == ' ' || (@input[@p]).chr == "\n" || (@input[@p]).chr == "\t")
				@p += 1
		  end
			t.value = TerminalSymbol::SPACE
			t.input = @input[start ... @p]
		else
			@p += 1
			while @p < @length && is_char(@input[@p].chr)
				@p += 1
			end
			t.value = TerminalSymbol::WORD
			t.input = @input[start ... @p]
		end
	end
	
	def is_char(c)
	  case c
	  when '('
	  when ')'
	  when '['
	  when ']'
	  when '{'
	  when '}'
	  when ':'
	  when ';'
	  when '.'
	  when ','
	  when '='
	  when '/'
	  when ' '
	  when '\t'
	  when '\n'
	    return false
	  else
	    return true
	  end
	end

end

# Each lexed token.
class Token

  # The TerminalSymbol
  attr_accessor :value
  
  # The input string
  attr_accessor :input
  
  # The integer or float value of this token, in case
  # this token's value is TerminalSymbol::NUMBER
  attr_accessor :number
  
  # The next peeked token, if any. Don't use this
  # field directly, use Lexer#peek_next
  attr_accessor :following

end

class TerminalSymbol
  SPACE = 1
	WORD = 2
	NUMBER = 3
	LPAREN = 4
	RPAREN = 5
	LBRACKET = 6
	RBRACKET = 7
	LCURLY = 8
	RCURLY = 9
	COMMA = 10
	DOT = 11
	COLON = 12
	SEMICOLON = 13
	SLASH = 14
	EQUALS = 15
	EOF = 16
end