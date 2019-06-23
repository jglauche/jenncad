module JennCad
  # Part should be inherited from the user when making parts
  class Part < Thing

    def make_openscad_compatible
      auto_color
      a = Aggregation.new(self.class.to_s, make_openscad_compatible!(self.part))
      a.transformations = @transformations
      a.color(color)
      a
    end

  end
end
