module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /the homepage/i
      root_path
    when /the login page/
      login_path
    when /the wiki index/
      articles_path
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
