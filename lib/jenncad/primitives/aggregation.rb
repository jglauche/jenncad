module JennCad::Primitives
  class Aggregation < Primitive
    attr_accessor :part

    def initialize(name, part)
      @name = name
      @part = part
    end
  end
end
