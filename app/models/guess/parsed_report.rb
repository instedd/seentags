require 'guid'

class ParsedReport

  attr_reader :values

  def initialize
    @values = []
  end
  
  def add(label, value)
    @values.push Value.new(self, label, value)
  end
  
  def add_unlabelled(value)
    add '?' + Guid.new.to_s, value
  end
  
  def [](index_or_label)
    if index_or_label.class <= Integer
      return @values[index_or_label]
    else
      @values.each do |value|
        return value if value.label == index_or_label
      end
      return nil
    end
  end
  
  def remove(index)
    @values.slice!(index)
  end
  
  def unlabelled
    @values.select{|x| x.is_unlabelled?}
  end
  
  def labels
    Set.new(@values.select{|x| x.has_label?}.map{|x| x.label})
  end
  
  def simplify!
    i = 1
    @values.each do |value|
      if value.is_unlabelled?
        value.label = "?" + i.to_s
        i += 1
      end
    end
  end
  
  def length
    return @values.length
  end
  
  def each
    @values.each do |value|
      yield value
    end
  end
  
  
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

end

class Value

  attr_reader :parent
  attr_accessor :label, :value, :nested
  
  def initialize(parent, label, value)
    @parent = parent
    @label = label
    @value = value
  end
  
  def is_unlabelled?
    return (label[0]).chr == '?'
  end
  
  def has_label?
    return !is_unlabelled?
  end
  
  def label_downcase
    return label.downcase
  end
  
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

end