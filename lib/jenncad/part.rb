module JennCad
  # Part should be inherited from the user when making parts
  class Part < Thing

    def to_openscad #make_openscad_compatible
      auto_color
      a = Aggregation.new(self.class.to_s, self.part) #make_openscad_compatible!(self.part))
      a.transformations = @transformations
      a.color(color)
      a
    end

    def part
    end

  end
end
