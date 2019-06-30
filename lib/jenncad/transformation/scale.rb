module JennCad
  attr_accessor :scale
  class Scale < Transformation
    def initialize(args)
      super(args)
      @scale = args
    end
  end
end
