module JennCad::Primitives
  class BooleanObject < Primitive
    def initialize(*parts)
      @transformations = []
      if parts.first.kind_of? Array
        @parts = parts.first
      else
        @parts = parts
      end
      after_add
    end

    def add(part)
      @parts << part
      after_add
    end

    def after_add
      @parts.compact!
    end
  end
end
