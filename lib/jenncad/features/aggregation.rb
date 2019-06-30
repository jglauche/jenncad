module JennCad::Primitives
  class Aggregation < Primitive
    attr_accessor :part

    def initialize(name=nil, part=nil)
      super({})
      @name = name
      @part = part
    end

  end
end
