module JennCad
  class Thing
    attr_accessor :opts
    attr_accessor :parts
    attr_accessor :transformations, :name
    attr_accessor :x, :y, :diameter
    attr_accessor :calc_x, :calc_y, :calc_z, :calc_h
    attr_accessor :shape
    attr_accessor :angle, :fn

    def initialize(args={})
      @transformations = []
      # calculated origin; only works for move atm
      @calc_x = 0
      @calc_y = 0
      @calc_z = 0
      @calc_h = args[:z] || 0
      @opts ||= args
    end

    def option(key)
      @opts ||= {}
      @opts[key]
    end

    def set_option(key, val)
      @opts ||= {}
      @opts[key] = val
    end

    def rotate(args)
      @transformations ||= []
      @transformations << Rotate.new(args)
      self
    end
    alias :rt :rotate

    def rx(v)
      rt(x:v)
    end

    def ry(v)
      rt(y:v)
    end

    def rz(v)
      rt(z:v)
    end

    def flip(direction)
      case self
      when UnionObject
        ref = self.parts.first
        rz = self.z.to_f + self.calc_h.to_f
      when BooleanObject
        ref = self.parts.first
        rz = ref.calc_z + ref.calc_h
      else
        ref = self
        rz = self.z + self.calc_h
      end

      case direction
      when :x
        self.ry(90).mh(x: -rz, z: ref.x)
      when :y
        self.rx(90).mh(y: rz, z: ref.y)
      end
    end

    def flip_x
      flip(:x)
    end
    alias :fx :flip_x

    def flip_y
      flip(:y)
    end
    alias :fy :flip_y

    def radians(a)
      a.to_f/180.0*PI
    end

    # experiment
    def calculate_center_rotation(oldcenter, args)
      x,y,z = oldcenter
      v = Vector.point x,y,z
      rot_x = Matrix.rotation_x(radians(args[:x] || 0))
      rot_y = Matrix.rotation_y(radians(args[:y] || 0))
      rot_z = Matrix.rotation_z(radians(args[:z] || 0))
      v = rot_x*v
      v = rot_y*v
      v = rot_z*v

      [v.x,v.y,v.z]
    end

    def rotate_around(point,args)
      x,y,z= point[:x], point[:y], point[:z]
      self.move(x:-x,y:-y,z:-z).rotate(args).move(x:x,y:y,z:z)
    end

    def parse_xyz_shortcuts(args)
      [:x, :y, :z].each do |key|
        args[key] ||= 0.0
      end

      if args[:xy]
        args[:x] += args[:xy]
        args[:y] += args[:xy]
      end
      if args[:xyz]
        args[:x] += args[:xyz]
        args[:y] += args[:xyz]
        args[:z] += args[:xyz]
      end
      if args[:xz]
        args[:x] += args[:xz]
        args[:z] += args[:xz]
      end
      if args[:yz]
        args[:y] += args[:yz]
        args[:z] += args[:yz]
      end
      return args
    end

    def move(args)
      if args.kind_of? Array
        x,y,z = args
        return move(x:x, y:y, z:z)
      end
      args = parse_xyz_shortcuts(args)

      @transformations ||= []
      if args[:prepend]
        @transformations.prepend(Move.new(args))
      else
        @transformations << Move.new(args)
      end
      @calc_x += args[:x].to_f
      @calc_y += args[:y].to_f
      @calc_z += args[:z].to_f
      self
    end
    alias :translate :move
    alias :m :move

    def mx(v)
      move(x:v)
    end

    def my(v)
      move(y:v)
    end

    def mz(v)
      move(z:v)
    end

    # move half
    def moveh(args)
      if args.kind_of? Array
        x,y,z = args
        args = {x: x, y: y, z: z}
      end
      [:x, :y, :z, :xy, :xyz, :xz, :yz].each do |key|
        args[key] = args[key] / 2.0 unless args[key] == nil
      end

      move(args)
    end
    alias :mh :moveh

    def mhx(v)
      moveh(x:v)
    end

    def mhy(v)
      moveh(y:v)
    end

    def mhz(v)
      moveh(z:v)
    end

    def mirror(args)
      @transformations ||= []
      @transformations << Mirror.new(args)
      self
    end
    alias :mi :mirror

    def scale(args)
      if args.kind_of? Numeric or args.kind_of? Array
          args = {v:args}
      end
      @transformations ||= []
      @transformations << Scale.new(args)
      self
    end
    alias :sc :scale

    # copies the transformation of obj to self
    def transform(obj)
      @transformations ||= []
      @transformations += obj.transformations
      self
    end

    def multmatrix(args)
      @transformations ||= []
      @transformations << Multmatrix.new(args)
      self
    end

    def skew(args)
      xy = args[:xy] || 0
      x = args[:x] || 0
      yx = args[:yx] || 0
      y = args[:y] || 0
      zx = args[:zx] || 0
      zy = args[:zy] || 0

      multmatrix([
        [1, xy, x, 0],
        [yx, 1, y, 0],
        [zx, zy, 1, 0],
        [0, 0, 0, 1]
      ])
    end

    def top_of(other_object)
      self.move(z:other_object.z+other_object.calc_z.to_f)
    end

    def on_top_of(other_object)
      self.top_of(other_object) + other_object
    end

    def children_list(stop_at=nil)
      get_children(self, stop_at).flatten
    end

    def get_children(item, stop_at)
      res = [item]
      if item.respond_to?(:parts) && item.parts != nil
        item.parts.each do |part|
          unless stop_at != nil && part.kind_of?(stop_at)
            res << get_children(part, stop_at)
          end
        end
      end
      res
    end

    def make_openscad_compatible
      make_openscad_compatible!(self)
    end

    def make_openscad_compatible!(item)
      if item.respond_to?(:parts) && item.parts != nil
        item.parts.each_with_index do |part, i|
          if part.respond_to? :to_openscad
            item.parts[i] = part.to_openscad
          else
            item.parts[i] = part.make_openscad_compatible
          end
        end
      elsif item.respond_to? :part
        item = item.part.make_openscad_compatible
      end
      if item.respond_to? :to_openscad
        item = item.to_openscad
      end
      item
    end

    def has_explicit_color?
      if option(:auto_color) == false
        return true
      end
      return false
    end

    def only_color?(parts, lvl=0)
      return true if parts == nil

      parts.each do |part|
#        puts "  " * lvl + "[only_color?] #{part}"
        if part.has_explicit_color?
#          puts "  " * lvl + "found explicit color here"
          return false
        end
        if !only_color?(part.parts, lvl+1)
          return false
        end
      end
      true
    end

    def set_auto_color_for_children(col, parts, lvl=0)
      return if parts == nil

      parts.each do |part|
        unless part.has_explicit_color?
          if only_color?(part.parts, lvl+1)
#            puts "  " * lvl + "children have no explicit color, setting it here"
            part.set_auto_color(col)
          else
#            puts "  " * lvl + "[set_auto_color_for_children] #{part}"
            set_auto_color_for_children(col, part.parts, lvl+1)
          end
        else
#          puts "  " * lvl + "[set_auto_color_for_children] this part has a color, ignoring their children"
        end

      end
    end

    def set_auto_color(col)
      set_option :color, col
      set_option :auto_color, true
    end

    def color(args=nil)
      if args == nil
        return option(:color)
      end

      if args == :auto
        ac = auto_color
        unless ac.nil?
          #puts "auto color to #{ac}"
          if only_color?(self.parts)
            set_option :color, ac
            set_option :auto_color, true
          else
            set_auto_color_for_children(ac, self.parts)
          end

        end
        return self
      end

      c = color_parse(args)
      unless c.nil?
        set_option :color, c
        set_option :auto_color, false
      end

      self
    end

    def color_parse(args=nil)
      case args
      when :none
        set_option :no_auto_color, true
      when :random
        return Color.random
      when Array
        return Color.parse(args)
      when /(?<=#)(?<!^)(\h{6}|\h{3})/
        return args
      when /(?<!^)(\h{6}|\h{3})/
        return "##{args}"
      when String
        return args
      end
      nil
    end

    def auto_color
      if option(:color) == nil && !option(:no_auto_color)
        return auto_color!
      end
      nil
    end

    def auto_color!
      color_parse($jenncad_profile.colors.pop)
    end

    def color_or_fallback
      return option(:fallback_color) if option(:color) == nil
      option(:color)
    end

    def openscad(file)
      if @parts == nil
        if self.respond_to? :part
          @parts = [part]
        end
      end

      JennCad::Exporters::OpenScad.new(self).save(file)
    end

    def referenced_z
     return false if @z.to_f != 0.0
     return option(:zref) if option(:zref)
     return false
    end

    def z=(args)
      set_option(:z, args)
      @z = args
    end

    def z
      case ref = referenced_z
      when nil, false
        @z + z_margin
      else
        ref.z.to_f + ref.z_margin.to_f
      end
    end

    def z_margin
      case m = option(:margins)
      when nil, {}
        0.0
      else
        m[:z].to_f
      end
    end

  end
end
