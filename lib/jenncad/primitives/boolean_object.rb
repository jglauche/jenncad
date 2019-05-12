module JennCad::Primitives
  class BooleanObject < Primitive
    def initialize(*parts)
      @transformations = []
      if parts.first.kind_of? Array
        @parts = parts.first
      else
        @parts = parts
      end
    end

    def add(part)
      @parts << part
    end
  end
end
