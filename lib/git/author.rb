module Git
  class Author < Ident
    def self.parse_author line
      parse_ident line, 'author'
    end
  end # class Author
end # module Git
