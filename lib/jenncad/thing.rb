module JennCad
  class Thing
    attr_accessor :color, :fallback_color
    attr_accessor :parts
    attr_accessor :transformations, :name
    attr_accessor :calc_x, :calc_y, :calc_z, :calc_h
    attr_accessor :shape
    attr_accessor :angle, :cut, :fn

    def initialize(args=nil)
      @transformations = []
      @name = args[:name] || ""
      # calculated origin; only works for move atm
      @calc_x = 0
      @calc_y = 0
      @calc_z = 0
      @calc_h = args[:h] || 0
    end

    def rotate(args)
      @transformations ||= []
      @transformations << Rotate.new(args)
      self
    end

    def center
      return @center if @center
      case shape.to_s
        when "cube"
          [@x/2.0,@y/2.0,@z/2.0]
        when "cylinder"
          [0,0,@z/2.0]
      else
        [0,0,0]
      end
    end

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

    # todo: check if that works
    def rotate_around(point,args)
      x,y,z= point.x, point.y, point.z
      self.move(x:-x,y:-y,z:-z).rotate(args).move(x:x,y:y,z:z)
    end

    def move(args)
      @transformations ||= []
      @transformations << Move.new(args)
      @calc_x += args[:x].to_f
      @calc_y += args[:y].to_f
      @calc_z += args[:z].to_f
      self
    end
    alias :translate :move

    def mirror(args)
      @transformations ||= []
      @transformations << Mirror.new(args)
      self
    end

    def scale(args)
      if args.kind_of? Numeric or args.kind_of? Array
          args = {v:args}
      end
      @transformations ||= []
      @transformations << Scale.new(args)
      self
    end

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

    def color(args=nil)
      return @color if args == nil
      @color = args
      self
    end

    def color_or_fallback
      return @fallback_color if @color == nil
      @color
    end

    def openscad(file)
      if @parts == nil
        if self.respond_to? :part
          @parts = [part]
        else
          puts "[Error in openscad export] Could not find @parts or part for #{self}"
          exit
        end
      end

      OpenScad.new(self).save(file)
    end
  end
end
