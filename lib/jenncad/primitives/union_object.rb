module JennCad::Primitives
  class UnionObject < BooleanObject
    def initialize(*parts)
      super(*parts)

      blacklist = [SubtractObject, IntersectionObject]

      # @size = Size.new(@parts.first.x, @parts.first.y, @parts.first.z)
      @parts[1..-1].each do |part|
        blacklist.each do |b|
          if part.kind_of? b
            next
          end
        end
        @csize = part.csize
      end

    end

  end
end
