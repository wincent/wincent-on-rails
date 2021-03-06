module Sham
  def self.method_missing(method, *args, &block)
    if args.any?
      raise ArgumentError, "Sham.#{method} called with #{args.inspect}"
    end

    if block_given? # defining a Sham
      FactoryGirl.define do
        sequence method, &block
      end
    else # using a Sham
      FactoryGirl.generate method
    end
  end
end

# Generate a string of 10 random lowercase letters
Sham.random do |n|
  chars = ('a'..'z').to_a
  length = chars.length
  Array.new(10) { chars[rand(length)] }.join
end

Sham.random_first_name do |n|
  names = %w{Jacob Isabella Ethan Emma Michael Olivia Alexander Sophia William
    Ava Joshua Emily Daniel Madison Jayden Abigail Noah Chloe Anthony Mia}
  length = names.length
  names[rand(length)]
end

Sham.random_last_name do |n|
  names = %w{Lee Smith Long Martin Brown Roy Tremblay McGraw Gagnon Wilson
    Clark Johnson White Williams Taylor Campbell Anderson Chan Jones}
  length = names.length
  names[rand(length)]
end

Sham.lorem_ipsum do |n|
  text = <<-TEXT
    Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
    tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
    veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
    commodo consequat. Duis aute irure dolor in reprehenderit in voluptate
    velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat
    cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id
    est laborum.
  TEXT
  text.gsub(/\s+/, ' ').strip
end

Sham.email_address do |n|
  "#{Sham.random_first_name.downcase}#{rand(1000)}@example.com"
end
