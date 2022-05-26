module JennCad
  attr_accessor :pos
  class Move < Transformation
    def initialize(args)
      pos = args[:pos]
      super(args.merge(pos: pos))
    end

    def coordinates
      @pos.to_a
    end
  end
end
