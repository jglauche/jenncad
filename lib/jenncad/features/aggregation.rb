module JennCad::Features
  class Aggregation < Feature
    attr_accessor :parts

    def initialize(name=nil, part=nil)
      super({})
      @name = name
      @parts = [part] # NOTE: single length arrayto make checking children easier
    end

    def part
      @parts.first
    end

  end
end
