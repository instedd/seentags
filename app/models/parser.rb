# Parser a string into a ParsedReport.
#
# Some examples of parsed inputs:
#
#   label: string ==> label: value
#   value ==> ?1: value
#   label1: value1, label2: value2 ==> label1: value1, label2: value2
#   value1 value2 value3 ==> ?1: value1, ?2: value2, ?3: value3
#   value1 number1 value2 number2 ==> value1: number1, value2: number2
#   number1 value1 number2 value2 ==> value1: number1, value2: number2
#
# where the left hand side is the input and the right hand side shows
# label value pairs of the ParsedReport. If a label is unknown it
# beings with a question mark.
#
# Nested reports are possibled:
#
#   label1[value1, value2] ==> label1: {?1: value1, ?2: value}
#   label1[label2: value2, label3: value3] ==> label1: {label2: value2, label3: value3}
#
# For groupings, any of parenthesis, bracket or curly braces are allowed, but
# the start and end symbols must match.
#
# The parser
class Parser < Lexer

  # Creates this parser from a string
  def initialize(source)
    super
  end

  # Parses the input given in the initializer and returns
  # an array of ParsedReports.
  def parse
		next_token_skip_space
		result = parse_sub(nil)
    split result
	end

  def self.parse(source)
    Parser.new(source).parse
  end

	private

	def parse_sub(finish)
		report = ParsedReport.new

		last_was_smart_match = true;
		while token.value != TerminalSymbol::EOF
			if token.value == finish
				next_token_skip_space
				break
			end

			case token.value
			# Groupings
			when TerminalSymbol::LCURLY, TerminalSymbol::LBRACKET, TerminalSymbol::LPAREN
				cl = closing token.value
				next_token_skip_space
				nested = parse_sub(cl)
				add_nested report, nested
				last_was_smart_match = true
			when TerminalSymbol::WORD
				# Case of a single word
				if peek_next_skip_space_is_EOF(token)
					report.add_unlabelled token.input
					next_token_skip_space
					last_was_smart_match = false
				else
  				peek = peek_next_skip_space token
  				case peek.value
  				when TerminalSymbol::COLON, TerminalSymbol::EQUALS
            peek2 = peek_next_skip_space peek
            case peek2.value
            when TerminalSymbol::NUMBER
              # Case word:number => it's a reported quantity
              report.add token.input, peek2.number
              next_token_skip_space_times 3
              last_was_smart_match = true
            when TerminalSymbol::WORD
              # Case word:word => it's a reported something
              report.add token.input, peek2.input
              next_token_skip_space_times 3
              last_was_smart_match = true
            else
              # Case of a single word followed by colon or equals
  						report.add_unlabelled token.input
  						next_token_skip_space_times 2
  						last_was_smart_match = false
            end
  				when TerminalSymbol::NUMBER
  					# Case word number
  					# It's a reported quantity if "word number" pairs follow
  					# until the next separator
  					if last_was_smart_match && word_number_folllows_until_next_separator(peek)
  						report.add token.input, peek.number
  						next_token_skip_space_times 2
  						last_was_smart_match = true
  					else
    					# No smart match
    					report.add_unlabelled token.input
    					next_token_skip_space
    					last_was_smart_match = false
    				end
  				else
  					# No smart match, add unknown
  					report.add_unlabelled token.input
  					next_token_skip_space
  					last_was_smart_match = false
  			  end
  			end
			when TerminalSymbol::NUMBER
				# Case of a single number
				if peek_next_skip_space_is_EOF(token)
					report.add_unlabelled token.number
					next_token_skip_space
					last_was_smart_match = false
				else
  				peek = peek_next_skip_space token
  				case peek.value
  				when TerminalSymbol::WORD
  					# Case number word
  					# It's a reported quantity if "number word" pairs follow
  					# until the next separator
  					if last_was_smart_match && number_word_follows_until_next_separator(peek)
  						report.add peek.input, token.number
  						next_token_skip_space_times 2
  						last_was_smart_match = true
  					else
  					  # No smart match, add unknown
  					  report.add_unlabelled token.number
    					next_token_skip_space
    					last_was_smart_match = false
  					end
  				else
  					# No smart match, add unknown
  					report.add_unlabelled token.number
  					next_token_skip_space
  					last_was_smart_match = false
  			  end
  		  end
  		when TerminalSymbol::COMMA, TerminalSymbol::DOT, TerminalSymbol::SEMICOLON, TerminalSymbol::SLASH
  		  last_was_smart_match = true
  		  next_token_skip_space
			else
			  last_was_smart_match = false
				next_token_skip_space
			end
		end

		return report
	end

	def word_number_folllows_until_next_separator(peek)
		following = peek_next_skip_space peek
		while !is_separator?(following.value)
			if following.value != TerminalSymbol::WORD
				return false
		  end

			following = peek_next_skip_space(following);
			if following.value == TerminalSymbol::COLON || following.value == TerminalSymbol::EQUALS
				following = peek_next_skip_space following
			end

			if following.value != TerminalSymbol::NUMBER
				return false
			end

			following = peek_next_skip_space following
		end
		return true
	end

	def number_word_follows_until_next_separator(peek)
		following = peek_next_skip_space peek
		while !is_separator?(following.value)
			if following.value != TerminalSymbol::NUMBER
				return false
			end

			following = peek_next_skip_space(following);

			if following.value != TerminalSymbol::WORD
				return false
			end

			following = peek_next_skip_space following
		end
		return true
	end

	def add_nested(report, nested)
		size = report.length
		if size == 0
		  nested.each do |value|
		    report.add value.label, value.value
		  end
		elsif report[size - 1].is_unlabelled? && report[size - 1].value.class == String
			last = report[size - 1]
			last.label = last.value.to_s
			last.value = nil
			last.nested = nested
		else
			report[size - 1].nested = nested
		end
	end

	def closing(type)
		case type
		when TerminalSymbol::LPAREN
		  return TerminalSymbol::RPAREN
		when TerminalSymbol::LBRACKET
		  return TerminalSymbol::RBRACKET
		when TerminalSymbol::LCURLY
		  return TerminalSymbol::RCURLY
		end
  end

	def next_token_skip_space
		value = next_token
		if token.value == TerminalSymbol::SPACE
			value = next_token
	  end
		return value
	end

	def next_token_skip_space_times(times)
	  while times > 0
	    next_token_skip_space
	    times -= 1
	  end
	end

	def peek_next_skip_space(token)
		following = peek_next token
		if following.value == TerminalSymbol::SPACE
			following = peek_next following
	  end
		return following
	end

	def peek_next_skip_space_is_EOF(token)
		return peek_next_skip_space(token).value == TerminalSymbol::EOF
	end

	def is_separator?(value)
		case value
		when TerminalSymbol::COMMA, TerminalSymbol::DOT, TerminalSymbol::SLASH, TerminalSymbol::SEMICOLON, TerminalSymbol::EOF
			return true
		else
			return false
		end
	end

  def split(result)
    labels = []
    different_sets = []
    fix_set = nil
    fix_set_after = []
    counter = 0
    result.values.each_with_index do |value, idx|
      label = value.label.downcase
      label_idx = labels.index label
      if label_idx
        if fix_set.nil?
          fix_set = result.values[0 ... label_idx]
          labels = labels[label_idx ... idx]
          different_sets << result.values[label_idx ... idx]
          different_sets << [value]
        else
          different_sets << [] if different_sets.last.length == labels.length
          different_sets.last << value
        end
      else
        if fix_set
          fix_set_after << value
        end
      end
      labels << label.downcase if different_sets.empty?
    end

    return [result] if different_sets.length <= 1

    result = []
    different_sets.each do |diff|
      values = []
      fix_set.each{|v| values << v}
      diff.each{|v| values << v}
      fix_set_after.each{|v| values << v}
      result << ParsedReport.new(values)
    end
    result
  end

end
