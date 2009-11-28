Given /^the following (\w+):$/ do |model, table|
  table.hashes.each do |hash|
    hash.keys.each do |key|
      case key
      when 'created_at'
        begin
          hash[key] = DateTime.parse hash[key]  # Fri, 20 Nov 2009 12:58:10 +0100
        rescue ArgumentError # invalid date
          hash[key] = eval(hash[key])           # 3.years.ago
        end
      else
        # accept default
      end
    end
    send("create_#{model.singularize}", hash)
  end
end
