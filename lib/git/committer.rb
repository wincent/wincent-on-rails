module Git
  class Committer < Ident
    def self.parse_committer line
      parse_ident line, 'committer'
    end
  end # class Committer
end # module Git
