require 'guid'

# A report returned by a Parser.
class ParsedReport

  include Enumerable

  # The values in the report. Each of this is of class Value.
  attr_reader :values

  # Creates an empty report.
  def initialize(values = [])
    @values = values
  end

  # Adds a label value pair to this report.
  def add(label, value)
    @values.push Value.new(self, label, value)
  end

  # Adds a value with an unknown label.
  def add_unlabelled(value)
    add '?' + Guid.new.to_s, value
  end

  # Returns the value in the given index or labelled with
  # the given label.
  def [](index_or_label)
    if index_or_label.class <= Integer
      return @values[index_or_label]
    else
      index_or_label = index_or_label.downcase
      @values.each do |value|
        return value if value.label_downcase == index_or_label
      end
      return nil
    end
  end

  # Removes the value at the given index.
  def remove(index)
    @values.slice!(index)
  end

  # Returns all values that are unlabelled.
  def unlabelled
    @values.select{|x| x.is_unlabelled?}
  end

  # Returns a Set of all different labels present in this report.
  def labels
    Set.new(@values.select{|x| x.has_label?}.map{|x| x.label})
  end

  # Returns the amount of values in this report.
  def length
    return @values.length
  end

  # Iterates each of the values in this report.
  def each
    @values.each do |value|
      yield value
    end
  end

  # Returns a string representation of this report such that when this
  # string is parsed, the same report is returned.
  def to_s
    sb = ''
    (0...length).each do |i|
      if i != 0
        sb += ', '
      end
      sb += @values[i].to_s
    end
		sb
  end

  def inspect
    "[#{to_s}]"
  end

end

# Each value present in a report. It's a "label value" pair.
class Value

  # The report this value belongs to.
  attr_reader :parent

  # The label of this value. Never nil, might start
  # with ? if this value is unlabelled.
  attr_accessor :label

  # The "value" in this "label value" pair. Might be a string,
  # an integer or a float.
  attr_accessor :value

  # The nested report, if any, or nil.
  attr_accessor :nested

  def initialize(parent, label, value)
    @parent = parent
    @label = label
    @value = value
  end

  # Is this value unlabelled?
  # Returns true if the label starts with a question mark.
  def is_unlabelled?
    return (label[0]).chr == '?'
  end

  # Does this value have a label?
  # Returns true if the label doesn't start with a question mark.
  def has_label?
    return !is_unlabelled?
  end

  # Returns the label in downcase
  def label_downcase
    return label.downcase
  end

  # Returns the value in downcase. If it's a number, it is
  # converted to a string.
  def value_downcase
    return value.downcase if value.class <= String
    return value
  end

  def to_s
    sb = ''
    sb += label
    sb += ': '
    sb += value.to_s if !value.nil?
    sb += '{' + nested.to_s + '}' if !nested.nil?
    sb
  end

  def inspect
    to_s
  end

end
