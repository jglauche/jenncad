module JennCad
  class Color < Transformation
    attr_accessor :color
    def initialize(args)
      @color = args
    end
  end
end
