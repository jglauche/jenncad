module JennCad::Primitives
  class Aggregation < Primitive
    attr_accessor :part

    def initialize(name, part)
      super({})
      @name = name
      @part = part
    end

    def parts
      [@part]
    end
  end
end
