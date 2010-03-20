# Allows gathering knowledge about a set of reports.
class Knowledge

  # A dictionary where each key is a Value's value in a report,
  # and each value is a list of labels applied to that value.
  attr_reader :dictionary
  
  # A Set of distinct labels found in the reports.
  attr_reader :labels
  
  # A dictionary where each key is a label and each value is
  # the type of the label. The type is a symbol and
  # can be :string, :integer, :decimal or :mixed
  attr_reader :types
  
  # A dictionary where each key is a position (number) and
  # each value is a dictionary of labels and quantities (how many
  # times that label appears in that position)
  attr_reader :label_positions

  # Creates a Knowlege from the given reports.
  def initialize(reports)
    @dictionary = Hash.new{|h, k| h[k] = Hash.new 0}
    @labels = Set.new
    @types = {}
    @label_positions = Hash.new{|h, k| h[k] = Hash.new 0}
    
    reports.each do |rep|
      position = -1
    
      rep.each do |value|
        position += 1
      
        next unless value.has_label?
        val = value.value_downcase
        label = value.label_downcase
        @dictionary[val][label] += 1
        @labels.add label
        @label_positions[position][label] += 1
        add_to_types label, val
      end
    end
  end
  
  # Applied this knowledge to the given report. This might modify the
  # report based on the accumulated knowledge. If the knowledge grows
  # (something was learned from the given report), this method returns
  # true. Else, this method returns false.
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
    
    # Remove found labels from @labels
    unlabelled = report.unlabelled
    remaining_labels = @labels - report.labels
    
    if unlabelled.length == 0
      return false
    end
    
    # For each value, we see if it's different from other values.
    # If so, and if a single label is found for that type, we apply and learn.
    # For this, we make a dictionary of type -> labels, and type -> values.
    type2labels = Hash.new {|h, v| h[v] = []}
    type2values = Hash.new {|h, v| h[v] = []}
    
    remaining_labels.each{|label| type2labels[@types[label]] << label}
    unlabelled.each{|un| type2values[get_type un.value] << un}
    
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
      @dictionary[val][labels[0]] += 1
      add_to_types labels[0], val
      learned = true
    end
    
    # For each unlabelled value, match according to position
    # (best match according) to position
    # TODO missing learn from here, and probably learn to position dictionary
    # in previous code (when we learn)
    position = -1
    report.each do |v|
      position += 1
      next if v.has_label?
      
      val = v.value_downcase
      type = get_type(val)
      
      label_amounts = @label_positions[position]
      max = label_amounts.select{|x, y| type_matches(type, @types[x])}.max{|x, y| x[1] <=> y[1]}
      next if max.nil?
      
      # We don't learn by position
      v.label = max[0]
    end
    
    return learned
  end
  
  # Applied this knowledge recursively to the given reports. This simply
  # invoked apply_to to each report until nothing more is learned.
  def apply_recursively_to(reports)
    learned = true
    while learned
      learned = false
      reports.each{|rep| learned |= apply_to(rep)}
    end
  end
  
  # For each set of unlabelled Value's with the same value,
  # use the same label. For example, if two values in different reports
  # are "?1: something" and "?2: something", the values will be transformed
  # to "?1: something" and "?1: something" (same label for same value).
  def unify_labels(reports)
    dict = Hash.new {|h, v| h[v] = []}
    reports.each do |r|
      r.each do |v|
        dict[v.value_downcase] << v if !v.has_label?
      end
    end
    
    dict.each_pair{|k,vs| vs.each{|v| v.label = vs[0].label}}
  end
  
  # By default, unlabelled Values are a question mark followed by a Guid.
  # This transforms those guids into natural numbers.
  def simplify(reports)
    labels = {}
    reports.each do |r|
      r.each do |v|
        next if v.has_label?
        
        if labels.include?(v.label)
          v.label = labels[v.label]
        else
          new_label = "?#{labels.length + 1}"
          v.label = new_label
          labels[v.label] = new_label
        end
      end
    end
  end
  
  # Returns a CSV for the given reports.
  def to_csv(reports)
    all_labels = Set.new
    reports.each{|r| r.each{|v| all_labels << v.label_downcase}}
    all_labels = all_labels.to_a
    all_labels.sort! do |a, b|
      if a[0].chr == '?'
        b[0].chr == '?' ? a <=> b : 1
      else
        b[0].chr == '?' ? -1 : a <=> b
      end
    end
    
    csv = all_labels.join(', ')
    csv << "\r\n"
    
    reports.each do |r|
      all_labels.each_index do |i|
        csv << ', ' unless i == 0
        v = r[all_labels[i]]
        csv << v.value.to_s unless v.nil?
      end
      csv << "\r\n"
    end
    
    csv
  end
  
  private
  
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
  
  def type_matches(from, to)
    # This handles string, decimal and mixed cases.
    # Also handles the case where from is :integer and to is :integer
    return true if from == to or to == :mixed
    # The only missing case (handled below) is when to is :integer
    # and from is :decimal
    return to == :decimal
  end

end
