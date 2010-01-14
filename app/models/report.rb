require 'guid'

class Report

  attr_reader :values

  def initialize
    @values = []
  end
  
  def add(name, value)
    @values.push Value.new(self, name, value)
  end
  
  def add_unnamed(value)
    add '?' + Guid.new.to_s, value
  end
  
  def [](index_or_name)
    if index_or_name.class <= Integer
      return @values[index_or_name]
    else
      @values.each do |value|
        return value if value.name == index_or_name
      end
      return nil
    end
  end
  
  def remove(index)
    @values.slice!(index)
  end
  
  def unlabelled
    @values.select{|x| x.is_unnamed?}
  end
  
  def names
    Set.new(@values.select{|x| x.has_name?}.map{|x| x.name})
  end
  
  def simplify!
    i = 1
    @values.each do |value|
      if value.is_unnamed?
        value.name = "?" + i.to_s
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
    sb = '{'
    (0...length).each do |i|
      if i != 0
        sb += ', '
      end
      sb += @values[i].to_s
    end
    sb += '}'
		sb
  end

end

class Value

  attr_reader :parent
  attr_accessor :name, :value, :nested
  
  def initialize(parent, name, value)
    @parent = parent
    @name = name
    @value = value
  end
  
  def is_unnamed?
    return (name[0]).chr == '?'
  end
  
  def has_name?
    return !is_unnamed?
  end
  
  def name_downcase
    return name.downcase
  end
  
  def value_downcase
    return value.downcase if value.class <= String
    return value
  end
  
  def to_s
    sb = ''
    sb += name
    sb += ': '
    sb += value.to_s if !value.nil?
    sb += nested.to_s if !nested.nil?
    sb
  end

end