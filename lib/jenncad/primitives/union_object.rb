module JennCad::Primitives
  class UnionObject < BooleanObject
    def after_add
      @parts.compact!
      @z = @parts.map(&:z).compact.max
      inherit_zref
    end
  end
end
