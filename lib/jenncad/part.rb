module JennCad
  # Part should be inherited from the user when making parts
  class Part < Thing

    def to_openscad
      a = Aggregation.new(self.class.to_s, self.get_contents)
      a.transformations = @transformations
      if self.has_explicit_color?
        a.color(self.color)
      else
        a.color(:auto)
      end
      a
    end

    def part
    end

  end
end
