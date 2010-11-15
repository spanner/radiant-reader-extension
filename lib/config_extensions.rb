module ConfigExtensions    # for inclusion into Radiant::Config
  def boolean?
    key.ends_with? "?"
  end
end
