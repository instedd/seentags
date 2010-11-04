require 'test_helper.rb'

class LexerTest < ActiveSupport::TestCase

  test "word" do
    assert_token TerminalSymbol::WORD, 'Hello'
    assert_token TerminalSymbol::WORD, 'Hello_World'
    assert_token TerminalSymbol::WORD, 'H1N1'
    assert_token TerminalSymbol::WORD, 'H2'
  end

  test "(" do
    assert_token TerminalSymbol::LPAREN, '('
  end

  test ")" do
    assert_token TerminalSymbol::RPAREN, ')'
  end

  test "[" do
    assert_token TerminalSymbol::LBRACKET, '['
  end

  test "]" do
    assert_token TerminalSymbol::RBRACKET, ']'
  end

  test "{" do
    assert_token TerminalSymbol::LCURLY, '{'
  end

  test "}" do
    assert_token TerminalSymbol::RCURLY, '}'
  end

  test "," do
    assert_token TerminalSymbol::COMMA, ','
  end

  test "." do
    assert_token TerminalSymbol::DOT, '.'
  end

  test ":" do
    assert_token TerminalSymbol::COLON, ':'
  end

  test ";" do
    assert_token TerminalSymbol::SEMICOLON, ';'
  end

  test "/" do
    assert_token TerminalSymbol::SLASH, '/'
  end

  test "=" do
    assert_token TerminalSymbol::EQUALS, '='
  end

  test "space" do
    assert_token TerminalSymbol::SPACE, " \t\n"
  end

  test "integer" do
    lexer = Lexer.new "123"
    assert_equal TerminalSymbol::NUMBER, lexer.next_token
    assert_equal TerminalSymbol::NUMBER, lexer.token.value
    assert_equal "123", lexer.token.input
    assert_equal 123, lexer.token.number
  end

  test "float" do
    lexer = Lexer.new "123.45"
    assert_equal TerminalSymbol::NUMBER, lexer.next_token
    assert_equal TerminalSymbol::NUMBER, lexer.token.value
    assert_equal "123.45", lexer.token.input
    assert_equal 123.45, lexer.token.number
  end

  test "float 2" do
    lexer = Lexer.new "123,45"
    assert_equal TerminalSymbol::NUMBER, lexer.next_token
    assert_equal TerminalSymbol::NUMBER, lexer.token.value
    assert_equal "123,45", lexer.token.input
    assert_equal 123.45, lexer.token.number
  end

  def assert_token(token, source)
    lexer = Lexer.new source
    assert_equal token, lexer.next_token
    assert_equal token, lexer.token.value
    assert_equal source, lexer.token.input
  end

end
