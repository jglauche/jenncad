module JennCad::Primitives
  include ZIsh
  attr_accessor :center_bool, :convexity, :twist, :slices

  class LinearExtrude < JennCad::Thing
    def initialize(part, args={})
      @transformations = []
      @parts = [part]
      if args.kind_of? Numeric
        args = {h: args}
      end
      @z = args[:h] || args[:height] || args[:z]
      @csize = Size.new(z: @z).add(part.csize)

      @center_bool = args[:center]
      @convexity = args[:convexity]
      @twist = args[:twist]
      @slices = args[:slices]
      @fn = args[:fn]
      @opts = {
        center_z: false,
        margins: {
          z: 0,
        }
      }.deep_merge(args)
      set_anchors_z

      @x = part.x
      @y = part.y
    end

    def height
      @z.to_d + z_margin
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
