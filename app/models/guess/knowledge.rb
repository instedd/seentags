class Knowledge

  attr_reader :dictionary, :labels, :types

  def initialize(reports)
    @dictionary = {}
    @labels = Set.new
    @types = {}
    reports.each do |rep|
      rep.each do |value|
        if value.has_label?
          val = value.value_downcase
          label = value.label_downcase
          
          add_to_dictionary label, val
          
          # Add to labels
          @labels.add label
          
          add_to_types label, val
        end
      end
    end
  end
  
  def apply_to(report)
    i = 0
    while i < report.length
      value = report[i]
      
      # Check if the value is actually a label and what follows is the value.
      if value.is_unlabelled?
        val = value.value_downcase
        
        if i + 1 < report.length && @labels.include?(val)
          following = report[i + 1]
          if following.is_unlabelled?
            following_val = following.value_downcase
            if @dictionary.include?(following_val) && @dictionary[following_val].include?(val)
              value.label = value.value
              value.value = following.value
              report.remove i + 1
              i += 1
              next
            end
          end
        end 
      end
      
      # Check if the following value is a label and it matches the found value.
      if value.is_unlabelled?
        val = value.value_downcase
        
        if i + 1 < report.length && @dictionary.include?(val)
          following = report[i + 1]
          if following.is_unlabelled?
            following_val = following.value_downcase
            if @labels.include?(following_val) && @dictionary[val].include?(following_val)
              value.value = value.value  
              value.label = following.value
              report.remove i + 1
              i += 1
              next
            end
          end
        end
      end
      
      # Check if the value appears labelled by just a single label.
      if value.is_unlabelled?
        val = value.value_downcase
        
        if @dictionary.include?(val)
          entry = @dictionary[val]
          if entry.length == 1
            value.label = entry.keys[0]
            i += 1
            next
          end
        end
      end
      
      i += 1
    end
    
    # If the amount of unlabelled values is one, remove found labels from LABELS.
    unlabelled = report.unlabelled
    remaining_labels = @labels - report.labels
    
    if unlabelled.length == 0
      return false
    end
    
    if unlabelled.length == 1
      # If one label remains in LABELS, apply that label to the value.
      if remaining_labels.length == 1
        label = remaining_labels.to_a[0]
        val = unlabelled[0].value_downcase
        
        unlabelled[0].label = label
        
        # We learn
        add_to_dictionary label, val
        add_to_types label, val
        return true
      end
    end
    
    # If the amount of unlabelled values is more than one we use heuristics.
    
    # For each value, we see if it's the is different from other values.
    # If so, and if a single label is found for that type, we apply and learn.
    # For this, we make a dictionary of type -> labels, and type -> values.
    type2labels = {}
    type2values = {}
    
    remaining_labels.each do |label|
      type = @types[label]
      push_to_list_in_hash type2labels, type, label
    end
    
    unlabelled.each do |un|
      type = get_type un.value
      push_to_list_in_hash type2values, type, un
    end
    
    learned = false
    
    type2values.each_pair do |type, values|
      next if values.length > 1
      value = values[0]
      
      next if !type2labels.include?(type)
      labels = type2labels[type]
      next if labels.length > 1
      
      value.label = labels[0]
      
      # We learn
      val = value.value_downcase
      add_to_dictionary label, val
      add_to_types label, val
      learned = true
    end
    
    return learned
  end
  
  def apply_recursively_to(reports)
    learned = true
    while learned
      learned = false
      reports.each{|rep| learned |= apply_to(rep)}
    end
  end
  
  def unify_labels(reports)
    dict = {}
    reports.each do |r|
      r.each do |v|
        push_to_list_in_hash(dict, v.value_downcase, v) if !v.has_label?
      end
    end
    
    i = 0
    dict.each_pair do |k,vs|
      label = vs[0].label
      vs.each do |v|
        v.label = label
      end
    end
  end
  
  def simplify(reports)
    labels = {}
    reports.each do |r|
      r.each do |v|
        next if v.has_label?
        
        if labels.include?(v.label)
          v.label = labels[v.label]
        else
          new_label = "?" + (labels.length + 1).to_s
          v.label = new_label
          labels[v.label] = new_label
        end
      end
    end
  end
  
  protected
  
  def add_to_dictionary(label, val)
    if !@dictionary.has_key?(val)
      @dictionary[val] = {}
    end
    
    entry = @dictionary[val]
    if !entry.has_key?(label)
      entry[label] = 0
    end
    
    entry[label] += 1
  end
  
  def add_to_types(label, val)
    if @types.has_key?(label)
      old_type = @types[label]
      new_type = get_type(val)
      
      if old_type != new_type
        if (old_type == :string && (new_type == :integer || new_type == :decimal)) ||
          (new_type == :string && (old_type == :integer || old_type == :decimal))
          @types[label] = :mixed
        elsif (old_type == :integer && new_type == :decimal) ||
          (new_type == :integer && old_type == :decimal)
          @types[label] = :decimal
        end
      end
    else
      @types[label] = get_type(val)
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
  
  def push_to_list_in_hash(hash, key, value)
    if hash.include?(key)
      hash[key].push value
    else 
      hash[key] = [value]
    end
  end

end