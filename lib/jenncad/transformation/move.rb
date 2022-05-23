module JennCad
  attr_accessor :pos
  class Move < Transformation
    def initialize(args)
      @pos = args[:pos]
      super(@pos.to_h)
    end

    def coordinates
# TODO: using @pos doesn't work yet
#      if @pos.to_a[0] != @x.to_d && @pos.to_a[1] != @y.to_d
#        $log.debug  "Export coords: #{[@x, @y, @z]} , pos: #{@pos.to_a}"
#      end
      [@x, @y, @z]
    end
  end
end
