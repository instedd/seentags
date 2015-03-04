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

