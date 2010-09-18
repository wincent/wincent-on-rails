module BranchesHelper
  def branch_name branch
    branch.name.sub %r{\Arefs/heads/}, ''
  end
end # module BranchesHelper
