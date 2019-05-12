module JennCad::Primitives
  attr_accessor :center_bool, :convexity, :twist, :slices, :height
  class LinearExtrude < JennCad::Thing
    def initialize(part, args)
      @transformations = []
      @parts = [part]
      @height = args[:h] || args[:height]
      @center_bool = args[:center]
      @convexity = args[:convexity]
      @twist = args[:twist]
      @slices = args[:slices]
      @fn = args[:fn]
    end

    def openscad_params
      res = {}
      [:height, :convexity, :twist, :slices, :fn].each do |n|
        res[n] = self.send n
      end
      res[:center] = @center_bool
      res
    end
  end

end
