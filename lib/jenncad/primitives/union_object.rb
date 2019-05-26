module JennCad::Primitives
  class UnionObject < BooleanObject
    def after_add
      @parts.compact!
      @z = @parts.map(&:z).compact.max
    end
  end
end
