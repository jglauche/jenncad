module JennCad::Features
  class Aggregation < Feature
    attr_accessor :parts

    def initialize(name=nil, part=nil)
      super({})
      @name = name.gsub(".","_")
      @parts = [part] # NOTE: single length arrayto make checking children easier
    end

    def z
      part.z
    end

    def part
      @parts.first
    end

  end
end
