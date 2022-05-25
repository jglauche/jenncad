module JennCad::Primitives
  class Square < Primitive
    attr_accessor :corners, :sides

    def initialize(args)
      @opts = {
        x: 0,
        y: 0,
        margins: {
          x: 0,
          y: 0,
        },
        center: true,
        center_y: false,
        center_x: false,
      }
      if args.kind_of? Array
        args.each do |a|
          feed_opts(parse_xyz_shortcuts(a))
        end
      else
        feed_opts(parse_xyz_shortcuts(args))
      end
      init(args)

      handle_margins
      set_anchors
      @x = args[:x]
      @y = args[:y]
      @dimensions = [:x, :y]
      @sits_on = :bottom
      @size = Size.new(x: @opts[:x], y: @opts[:y])
    end


    # used for openscad export
    def size
      [@x, @y]
    end

    def set_anchors
      set_anchors_2d
    end

    def set_anchors_2d
      @anchors = {} # this resets anchors
      @corners = [:top_right, :top_left, :bottom_right, :bottom_left]
      @sides = [:left, :right, :top, :bottom]

      if @opts[:center] || @opts[:center_x]
        left = -@opts[:x] / 2.0
        right = @opts[:x] / 2.0
        mid_x = 0
      else
        left = 0
        right =  @opts[:x]
        mid_x = @opts[:x] / 2.0
      end
      if @opts[:center] || @opts[:center_y]
        bottom = -@opts[:y] / 2.0
        top = @opts[:y] / 2.0
        mid_y = 0
      else
        bottom = 0
        top = @opts[:y]
        mid_y = @opts[:y] / 2.0
      end

      set_anchor :left, x: left, y: mid_y
      set_anchor :right, x: right, y: mid_y
      set_anchor :top, x: mid_x, y: top
      set_anchor :bottom, x: mid_x, y: bottom
      set_anchor :top_left, x: left, y: top
      set_anchor :top_right, x: right, y: top
      set_anchor :bottom_left, x: left, y: bottom
      set_anchor :bottom_right, x: right, y: bottom

      # we need to re-do the inner ones, if they were defined
      if @inner_anchor_defs && @inner_anchor_defs.size > 0
        @inner_anchor_defs.each do |anch|
         inner_anchors(anch[:dist], anch[:prefix], true)
        end
      end

      self
    end

    def inner_anchors(dist, prefix=:inner_, recreate=false)
      if dist.nil?
        $log.error "Distance of nil passed to inner anchors. Please check the variable name you passed along"
        return self
      end

      @inner_anchor_defs ||= []
      @inner_anchor_defs << { "dist": dist, "prefix": prefix } unless recreate

#      $log.info "dist: #{dist}, prefix: #{prefix}"
      sides = {
        left: {x: dist, y: 0},
        right: {x: -dist, y: 0},
        top: {x: 0, y: -dist},
        bottom: {x: 0, y: dist},
      }
      corners = {
        top_left: {x: dist, y: -dist},
        top_right: {x: -dist, y: -dist},
        bottom_left: {x: dist, y: dist},
        bottom_right: {x: -dist, y: dist},
      }
      new_sides = []
      new_corners = []

      sides.merge(corners).each do |key, vals|
        new_dist = anchor(key).dup
        new_dist[:x] += vals[:x]
        new_dist[:y] += vals[:y]
        name = [prefix, key].join.to_sym
#        $log.info "Set anchor #{name} , new dist #{new_dist}"
        set_anchor name, new_dist
        if sides.include? key
          new_sides << name
        end
        if corners.include? key
          new_corners << name
        end
      end

      sides_name = [prefix, "sides"].join
      corners_name = [prefix, "corners"].join
      all_name = [prefix, "all"].join
      self.class.__send__(:attr_accessor, sides_name.to_sym)
      self.class.__send__(:attr_accessor, corners_name.to_sym)
      self.class.__send__(:attr_accessor, all_name.to_sym)
      self.__send__("#{sides_name}=", new_sides)
      self.__send__("#{corners_name}=", new_corners)
      self.__send__("#{all_name}=", new_corners+new_sides)


      self
    end



    def not_centered
      @opts[:center] = false
      set_anchors
      self
    end
    alias :nc :not_centered

    def cx
      nc
      @opts[:center_x] = true
      set_anchors
      self
    end
    alias :center_x :cx

    def cy
      nc
      @opts[:center_y] = true
      set_anchors
      self
    end
    alias :center_y :cy

    def centered_axis
      return [:x, :y] if @opts[:center]
      a = []
      a << :x if @opts[:center_x]
      a << :y if @opts[:center_y]
      a << :z if @opts[:center_z]
      a
    end

    def to_openscad
      self.mh(centered_axis.to_h{|a| [a, -@opts[a]] }) # center cube
    end

  end
end
