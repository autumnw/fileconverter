require 'json'

class Object
  def is_number?
    self.to_f.to_s == self.to_s || self.to_i.to_s == self.to_s
  end
end

class Json2CsvConverter
  
  def get_columns_from_array(array_obj, parent=nil)
    columns = []
    array_obj.each_with_index do |item, index|
      parent_col = parent.nil? ? "#{index}" : [parent, "#{index}"].join('.')
      if item.is_a? Hash
        columns += get_columns_from_hash(item, parent_col)
      elsif item.is_a? Array
        columns += get_columns_from_array(item, parent_col)
      else
        columns << parent_col
      end
    end
    return columns
  end
  
  def get_columns_from_hash(hash_obj, parent=nil)
    columns = []
    hash_obj.each do |key, value|
      parent_col = parent.nil? ? key : [parent, key].join('.')
      if value.is_a? Hash 
        columns += get_columns_from_hash(value, parent_col)
      elsif value.is_a? Array
        columns += get_columns_from_array(value, parent_col)
      else
        columns << parent_col
      end
    end
    return columns
  end
  
  def parse_one_row(obj, columns)
    row = ""
    columns.each do |col|
      if obj.nil?
        row += ','
        next
      end

      sub_cols = col.split('.')
      value = obj
      sub_cols.each do |key|
        break if value.nil?
        if key.is_number?
          value = value[key.to_i]
        else
          #puts "#{key}, #{value}"
          value = value[key]
        end
      end
      row += ",#{value.nil? ? '' : value}"
    end
    return row[1..-1]
  end
  
  def parse_rows(jobj, columns)
    rows = []
    if jobj.is_a? Array
      jobj.each do |obj|
        rows << parse_one_row(obj, columns)
      end
    elsif 
      rows << parse_one_row(jobj, columns)
    end
    return rows
  end
  
  def write_to_file(rows, output)
    File.open(output, 'w') do |file| 
      rows.each { |row| file.write(row + "\n") }
    end
  end
  
  def convert (file, output=nil)
    jobj = JSON.parse(File.read(file))
    columns = []
    if jobj.is_a?(Array)
      columns = get_columns_from_hash(jobj[0])
    elsif jobj.is_a?(Hash)
      columns = get_columns_from_hash(jobj)
    else
      raise "Not supported object type. It MUST be a hash or array."
    end
    rows = parse_rows(jobj, columns)
    rows.unshift(columns.join(','))
    write_to_file(rows, output) if output
  end
end

#########################
# main
if __FILE__ == $0
  converter = Json2CsvConverter.new()
  converter.convert("/Users/autumnwang/tmp/org11.json", "/Users/autumnwang/tmp/test.csv")
end