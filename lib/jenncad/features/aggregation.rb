module JennCad::Features
  class Aggregation < Feature
    attr_accessor :parts

    def initialize(name=nil, part=nil)
      super({})
      @name = name.gsub(".","_")
      @parts = [part]
      @zref = part
    end

    def z
      return 0 unless part
      part.z
    end

    def part
      @parts.first
    end

  end
end
