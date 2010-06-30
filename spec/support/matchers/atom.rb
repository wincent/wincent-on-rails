require 'mkdtemp'
require 'pathname'

# https://wincent.com/wiki/Testing_validity_of_Rails_feeds_with_RSpec
module RSpec
  module Matchers
    module Atom
      # don't really like hardcoding this path,
      # but "whereis" behaves differently on Mac OS X and Linux,
      # making it hard to use
      def self.java_path
        '/usr/bin/java'
      end

      def self.has_java?
        File.exist? java_path
      end

      def self.jing_path
        Pathname.new(__FILE__).dirname + 'jing' + 'bin' + 'jing.jar'
      end

      def self.schema_path
        # RNG schema created from RNC schema with:
        # java -jar trang.jar atom.rnc atom.rng
        Pathname.new(__FILE__).dirname + 'atom-latest.rng'
      end

      # writes the contents of the rendered feed to a temporary file, returning the full path to the file
      # (necessary because Jing can only read from files, not from the standard input)
      def self.write_to_temp_file rendered
        temp_dir  = Pathname.new(Dir.mkdtemp)
        temp_file = temp_dir + 'feed.atom'
        temp_file.open 'w' do |f|
          f.write rendered
        end
        temp_file
      end
    end # module Atom

    def can_validate_feeds?
      Spec::Rails::Matchers::Atom.has_java?
    end

    # allows us to do:
    # render('foo').should be_valid_atom
    def be_valid_atom
      BeValidAtom.new
    end

    class BeValidAtom
      def matches? string
        # java -jar jing.jar atom.rng feed.atom
        java    = Spec::Rails::Matchers::Atom.java_path
        jing    = Spec::Rails::Matchers::Atom.jing_path
        schema  = Spec::Rails::Matchers::Atom.schema_path
        @path   = Spec::Rails::Matchers::Atom.write_to_temp_file string
        `#{java} -jar #{jing} #{schema} #{@path}`
        $?.exitstatus == 0
      end

      def failure_message
        "expected feed #{@path} to pass Atom validation but it failed"
      end

      def negative_failure_message
        "expected feed #{@path} to fail Atom validation but it passed"
      end

      def description
        'pass Atom validation'
      end
    end # class BeValidAtom
  end # module Matchers
end # module RSpec
