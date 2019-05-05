module JennCad
  class Multmatrix < Transformation
    attr_accessor :m
    def initialize(args)
      @m = args
    end
  end
end

