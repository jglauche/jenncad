module JennCad
  class BooleanObject
    attr_accessor :parts
    def initialize(part1, part2)
      @parts = [part1, part2]
    end

    def add(part)
      @parts << part
    end
  end
end
