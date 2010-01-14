class Knowledge

  attr_reader :dictionary, :labels, :types

  def initialize(reports)
    @dictionary = {}
    @labels = Set.new
    @types = {}
    reports.each do |rep|
      rep.each do |value|
        if value.has_name?
          val = value.value_downcase
          name = value.name_downcase
          
          add_to_dictionary name, val
          
          # Add to labels
          @labels.add name
          
          add_to_types name, val
        end
      end
    end
  end
  
  def apply_to(report)
    i = 0
    while i < report.length
      value = report[i]
      
      # Check if the value is actually a label and what follows is the value.
      if value.is_unnamed?
        val = value.value_downcase
        
        if i + 1 < report.length && @labels.include?(val)
          following = report[i + 1]
          if following.is_unnamed?
            following_val = following.value_downcase
            if @dictionary.include?(following_val) && @dictionary[following_val].include?(val)
              value.name = value.value
              value.value = following.value
              report.remove i + 1
              i += 1
              next
            end
          end
        end 
      end
      
      # Check if the following value is a label and it matches the found value.
      if value.is_unnamed?
        val = value.value_downcase
        
        if i + 1 < report.length && @dictionary.include?(val)
          following = report[i + 1]
          if following.is_unnamed?
            following_val = following.value_downcase
            if @labels.include?(following_val) && @dictionary[val].include?(following_val)
              value.value = value.value  
              value.name = following.value
              report.remove i + 1
              i += 1
              next
            end
          end
        end
      end
      
      # Check if the value appears labelled by just a single label.
      if value.is_unnamed?
        val = value.value_downcase
        
        if @dictionary.include?(val)
          entry = @dictionary[val]
          if entry.length == 1
            value.name = entry.keys[0]
            i += 1
            next
          end
        end
      end
      
      i += 1
    end
    
    # If the amount of unlabelled values is one, remove found labels from LABELS.
    unlabelled = report.unlabelled
    remaining_labels = @labels - report.names
    
    if unlabelled.length == 0
      return false
    end
    
    if unlabelled.length == 1
      # If one label remains in LABELS, apply that label to the value.
      if remaining_labels.length == 1
        label = remaining_labels.to_a[0]
        val = unlabelled[0].value_downcase
        
        unlabelled[0].name = label
        
        # We learn
        add_to_dictionary label, val
        add_to_types label, val
        return true
      end
    end
    
    # If the amount of unlabelled values is more than one we use heuristics.
    
    # If the REMAINING_LABELS types are all different and not one of them is mixed
    # (for example "number: integer, confirmed: string") and the types of the unlabelled
    # values match those types, apply the labelling.
    if remaining_labels.length == unlabelled.length
      remaining_labels = remaining_labels.to_a
    
      remaining_labels_types = remaining_labels.map{|x| @types[x]}
      unlabelled_types = unlabelled.map{|x| get_type(x.value)}
      
      if all_different_and_not_mixed(remaining_labels_types) &&
        all_different_and_not_mixed(unlabelled_types) &&
        Set.new(unlabelled_types) == Set.new(remaining_labels_types)
        
        unlabelled.each do |value|
          type = get_type(value.value)
          label = remaining_labels[remaining_labels_types.index(type)]
          value.name = label
          
          val = value.value_downcase
          
          # We learn
          add_to_dictionary label, val
          add_to_types label, val
        end
        
        return true
      end
    end
    
    return false
  end
  
  def add_to_dictionary(name, val)
    if !@dictionary.has_key?(val)
      @dictionary[val] = {}
    end
    
    entry = @dictionary[val]
    if !entry.has_key?(name)
      entry[name] = 0
    end
    
    entry[name] += 1
  end
  
  def add_to_types(name, val)
    if @types.has_key?(name)
      old_type = @types[name]
      new_type = get_type(val)
      
      if old_type != new_type
        if (old_type == :string && (new_type == :integer || new_type == :decimal)) ||
          (new_type == :string && (old_type == :integer || old_type == :decimal))
          @types[name] = :mixed
        elsif (old_type == :integer && new_type == :decimal) ||
          (new_type == :integer && old_type == :decimal)
          @types[name] = :decimal
        end
      end
    else
      @types[name] = get_type(val)
    end
  end
  
  def get_type(value)
    return :string if value.class <= String
    return :integer if value.class <= Integer
    return :decimal if value.class <= Float
    
    puts value
    puts value.class
    raise 'Error!'
  end
  
  def all_different_and_not_mixed(array)
    array.each_index do |i|
      first = array[i]
      return false if first == :mixed
      
      (i+1...array.length).each do |j|
        second = array[j]
        return false if second == :mixed
        return false if first == second
      end
    end
    
    return true
  end

end