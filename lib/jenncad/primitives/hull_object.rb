module JennCad::Primitives
  class HullObject < BooleanObject
    def after_add
      @parts.flatten!
      @parts.compact!
      @z = @parts.map(&:z).compact.max
      inherit_zref
    end
  end
end
