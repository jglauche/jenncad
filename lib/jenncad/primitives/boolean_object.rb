module JennCad::Primitives
  class BooleanObject < Primitive
    def initialize(part1, part2)
      @transformations = []
      @parts = [part1, part2]
    end

    def add(part)
      @parts << part
    end
  end
end
