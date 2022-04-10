module JennCad::Primitives
  attr_accessor :cut, :convexity
  class RotateExtrude < JennCad::Thing
    def initialize(part, args)
      @transformations = []
      @parts = [part]
      @angle = args[:angle]
      @cut = args[:cut]
      @fn = args[:fn]
    end

    def openscad_params
      res = {}
      [:cut, :angle, :convexity, :fn].each do |n|
        res[n] = self.send n
      end
      res
    end
  end
end
