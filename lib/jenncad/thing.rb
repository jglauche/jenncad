module JennCad
  class Thing
    attr_accessor :opts
    attr_accessor :parts
    attr_accessor :transformations, :name
    attr_accessor :x, :y, :diameter
    attr_accessor :calc_x, :calc_y, :calc_z, :calc_h
    attr_accessor :shape
    attr_accessor :angle, :fn
    attr_accessor :anchors
    attr_accessor :parent

    def initialize(args={})
      @transformations = []
      # calculated origin; only works for move atm
      @calc_x = 0
      @calc_y = 0
      @calc_z = 0
      @calc_h = args[:z] || 0
      @anchors = {}
      @parent = args[:parent]
      @opts ||= args
      @cache = nil
    end

    def option(key)
      @opts ||= {}
      @opts[key]
    end

    def set_option(key, val)
      @opts ||= {}
      @opts[key] = val
    end

    def set_flag(key)
      set_option(key, true)
      self
    end

    def unset_flag(key)
      set_option(key, false)
      self
    end


    def cut_to(face, part=nil, args={})
      an = anchor(face, part)
      unless an
        $log.error "Cannot find anchor to cut_to"
        return self
      end
      if an[:z].to_d == 0.0
        $log.error "cut_to only supports cuts to an anchor with Z set. This anchor: #{an}"
        return self
      end
      modify_values(self, z: an[:z].to_d)
      self.name="#{self.class}_cut_to_#{an[:z].to_f}"
      self
    end

    def modify_values(parts, value, opts = {})
      case parts
       when Array
          parts.each do |pa|
            modify_values(pa, value, opts)
          end
        else
          if parts.kind_of?(BooleanObject)
            modify_values(parts.only_additives_of(parts), value, opts)
          elsif parts.kind_of?(Part)
            modify_values(parts.part, value, opts)
            modify_values(parts.get_contents, value, opts)
            parts.modify_values!(value, opts)
          elsif parts.kind_of?(Primitive)
            parts.modify_values!(value, opts)
          end
      end
    end

    def modify_values!(values, opts)
      $log.info "Modify value! #{self.class} #{values}" if self.debug?
      values.each do |key, val|
        if @opts
          case opts[:mode]
            when :add
              @opts[key] = @opts[key].to_d + val.to_d
            when :sub
              @opts[key] = @opts[key].to_d - val.to_d
            else
              @opts[key] = val
          end
        end
        if self.respond_to? key
          self.send("#{key}=", @opts[key])
        end
      end
      $log.info "Modified value now: #{self.inspect}" if self.debug?
    end


    def debug?
      option(:debug) || false
    end

    def fixate
      Marshal.load(Marshal.dump(self))
    end
    alias :fix :fixate

    def set_parent(parent)
      @parent = parent
      self
    end

    def anchor(name, thing=nil, args={})
      if thing
        res = thing.anchor(name, nil, args)
        return res unless res.nil?
      end
      @anchors ||= {}
      if anch = @anchors[name]
        return anch
      elsif args[:fail_quick] && args[:fail_quick] == true
        return
      elsif @parent
        return @parent.anchor(name)
      elsif self.respond_to? :get_contents
        con = get_contents
        if con.respond_to? :anchor
          con.anchor(name, nil, fail_quick: true)
        end
      end
    end
    alias :a :anchor

    def set_anchor(name, args={})
      @anchors ||= {}
      @anchors[name] = args
      self
    end
    alias :sa :set_anchor

    def set_anchor_from(name, new_name, args={})
      unless name.kind_of? Symbol or name.kind_of? String
        $log.error "set_anchor_from: name must be a string or symbol. Supplied: #{name}"
        return
      end
      unless new_name.kind_of? Symbol or new_name.kind_of? String
        $log.error "set_anchor_from: new_name must be a string or symbol. Supplied: #{new_name}"
        return
      end


      a = anchor(name, args[:from]).dup
      if !a
        $log.error "set_anchor_from couldn't find anchor #{name}"
        return
      end

      [:x, :y, :z, :xy, :xz, :xyz, :yz].each do |key|
        a[key] ||= 0.to_d
        args[key] ||= 0.to_d
        a[key] += args[key]
      end
      set_anchor new_name, a
    end
    alias :saf :set_anchor_from

    def auto_extrude
      ret = self.extrude
      ret.set_option(:auto_extrude, true)
      ret
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
        rz = self.z.to_d + self.calc_h.to_d
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
      a.to_d/180.0*PI
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
      unless args.kind_of? Hash
        $log.warn "parse_xyz_shortcuts called for type #{args.class} #{args.inspect}"
        return args
      end
      [:x, :y, :z].each do |key|
        args[key] ||= 0.0
      end

      if args[:debug]
        $log.debug "Args: #{args}"
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
      if args[:debug]
        $log.debug "After xyz shortcuts #{args}"
      end

     return args
    end

    # reset last move
    def reset_last_move
      lt = @transformations.last
      unless lt.class == Move
        $log.error "Tried to call rst_move but last object is a #{lt.class}"
        return self
      end
      @transformations.delete_at(-1)

      self
    end
    alias :rstlm :reset_last_move

    # resets all transformations
    def reset
      @transformations = []
      self
    end
    alias :rst :reset


    def move(args={})
      return self if args.nil? or args.empty?

      if args.kind_of? Array
        x,y,z = args
        return move(x:x, y:y, z:z)
      end
      args = parse_xyz_shortcuts(args)

      if args[:x].to_d == 0.0 && args[:y].to_d == 0.0 && args[:z].to_d == 0.0
        return self
      end

      @transformations ||= []
      if args[:prepend]
        @transformations.prepend(Move.new(args))
      else
        lt = @transformations.last

        chain = if args[:chain]
          args[:chain]
        else
          $jenncad_profile.chain_moves
        end

        if lt && lt.class == Move && chain == false
          $log.debug "#{self} at move: Adding to previous move #{lt.inspect} , args: #{args}" if self.debug?
          lt.x += args[:x].to_d
          lt.y += args[:y].to_d
          lt.z += args[:z].to_d
        else
          $log.debug "#{self} at move: Adding move of #{args} to transformations" if self.debug?
          @transformations << Move.new(args)
        end
      end
      @calc_x += args[:x].to_d
      @calc_y += args[:y].to_d
      @calc_z += args[:z].to_d
      self
    end
    alias :translate :move
    alias :m :move

    def mx(v=0)
      move(x:v)
    end

    def my(v=0)
      move(y:v)
    end

    def mz(v=0)
      move(z:v)
    end

    # move to anchor
    def movea(key, thing=nil, args={})
      if thing.kind_of? Hash # if you leave out thing, args may be interpreted as thing
        args = thing
        thing = nil
      end

      an = anchor(key, thing, args)

      unless an
        $log.error "Error: Anchor #{key} not found"
        $log.error "Available anchors: #{@anchors}"
        return self
      else
        m = an.dup
        if args[:chain]
          m[:chain] = args[:chain]
        end
        if args[:inverted]
          self.movei(m)
        else
          self.move(m)
        end
      end
    end
    alias :ma :movea

    # move to anchor - inverted
    def moveai(key, thing=nil, args={})
      if thing.kind_of? Hash # if you leave out thing, args may be interpreted as thing
        args = thing
        thing = nil
      end
      args[:inverted] = true
      movea(key, thing, args)
    end
    alias :mai :moveai

    # move half
    def moveh(args={})
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

    def mhx(v=0)
      moveh(x:v)
    end

    def mhy(v=0)
      moveh(y:v)
    end

    def mhz(v=0)
      moveh(z:v)
    end

    def movei(args={})
      to = {}
      [:x, :y, :z, :xy, :xz, :yz, :xyz].each do |key|
        if args[key]
          to[key] = args[key]*-1
        end
      end
      to[:chain] = args[:chain]
      move(to)
    end

    def mirror(args={})
      @transformations ||= []
      @transformations << Mirror.new(args)
      self
    end
    alias :mi :mirror

    def miz
      mirror(z:1)
    end

    def miy
      mirror(y:1)
    end

    def miz
      mirror(z:1)
    end


    def scale(args={})
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
      self.move(z:other_object.z+other_object.calc_z.to_d)
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
        item.parts.each do |pa|
          unless stop_at != nil && pa.kind_of?(stop_at)
            res << get_children(pa, stop_at)
          end
        end
      end
      res
    end

    def inherit_color(other)
      self.set_option(:color, other.option(:color))
      self.set_option(:auto_color, other.option(:auto_color))
    end

    def has_explicit_color?
      if option(:auto_color) == false
        return true
      end
      return false
    end

    def only_color?(parts, lvl=0)
      return true if parts == nil
      unless parts.kind_of? Array
        parts = [parts]
      end

      parts.each do |part|
        #puts "  " * lvl + "[only_color?] #{part}"
        if part.has_explicit_color?
          #puts "  " * lvl + "found explicit color here: #{part.color}"
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
            #puts "  " * lvl + "children have no explicit color, setting it here"
            part.set_auto_color(col)
          else
            #puts "  " * lvl + "[set_auto_color_for_children] #{part}"
            set_auto_color_for_children(col, part.parts, lvl+1)
          end
        else
          #puts "  " * lvl + "[set_auto_color_for_children] this part has a color #{part.color}, ignoring their children"
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
          if only_color?(get_contents)
            set_option :color, ac
            set_option :auto_color, true
          else
            set_auto_color_for_children(ac, get_contents)
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
      when Symbol
        return args.to_s
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

    def get_contents
      return @parts unless @parts.nil?

      if @cache
        return @cache unless option(:no_cache) == true
      end

      if self.respond_to? :part
        # cache things to prevent calling the code in #part multiple times
        @cache = part
        return @cache
      end
    end

    def calculated_h
      return @z unless @z.nil? || @z == 0
      return @h unless @h.nil? || @h == 0
      return @calc_h unless @calc_h.nil? || @calc_h == 0
      return @calc_z unless @calc_z.nil? || @calc_z == 0
    end

    def find_calculated_h(parts)
      return if parts == nil
      unless parts.kind_of? Array
        parts = [parts]
      end
      parts.each do |part|
        if z = calculated_h
          return z
        end
        get_calculated_h(part.get_contents)
      end
    end

    def set_heights_for_auto_extrude(parts, parent=nil)
      return if parts.nil?
      unless parts.kind_of? Array
        parts = [parts]
      end

      parts.each do |part|
        if part.option(:auto_extrude)
          part.z = parent.calculated_h
        end
        set_heights_for_auto_extrude(part.get_contents, part)
      end
    end

    def openscad(file)
      set_heights_for_auto_extrude(get_contents)

      @parts = get_contents

      JennCad::Exporters::OpenScad.new(self).save(file)
    end

    def ghost
      set_option :ghost, true
      set_option :no_auto_color, true
      set_option :color, nil
      set_option :auto_color, false
      self
    end

    def hide
      set_option :hide, true
      self
    end

    def only
      set_option :only, true
      self
    end

    def hl
      set_option :highlight, true
      self
    end

    def openscad_modifier
      return "%" if option(:ghost)
      return "#" if option(:highlight)
      return "!" if option(:only)
      return "*" if option(:hide)
      nil
    end

    def referenced_z
     return false if @z.to_d != 0.0
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
        ref.z.to_d + ref.z_margin.to_d
      end
    end

    def z_margin
      case m = option(:margins)
      when nil, {}
        0.0
      else
        m[:z].to_d
      end
    end


    def to_mod(name)
      a = Aggregation.new(name, self)
      a.transformations = @transformations
      a
    end

  end
end
