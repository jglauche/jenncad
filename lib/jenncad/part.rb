module JennCad
  # Part should be inherited from the user when making parts
  class Part < Thing
    def make_openscad_compatible
      auto_color
      make_openscad_compatible!(self)
    end
  end
end
