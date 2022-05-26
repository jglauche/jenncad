module JennCad
  class Rotate < Transformation
    def initialize(args)
      super(args)
    end

    def coordinates
      [@x, @y, @z]
    end
  end
end
