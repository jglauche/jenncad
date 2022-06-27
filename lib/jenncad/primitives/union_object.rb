module JennCad::Primitives
  class UnionObject < BooleanObject
    def initialize(*parts)
      super(*parts)

      blacklist = [SubtractObject, IntersectionObject, OpenScadImport]

      @parts[1..-1].each do |part|
        blacklist.each do |b|
          if part.kind_of? b
            next
          end
        end
        @csize = part.csize
#        @csize.union(part.csize.clone) if part.csize
      end

    end

  end
end
