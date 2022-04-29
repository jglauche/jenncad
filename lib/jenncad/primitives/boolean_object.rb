module JennCad::Primitives
  class BooleanObject < Primitive
    def initialize(*parts)
      @transformations = []
      if parts.first.kind_of? Array
        @parts = parts.first
      else
        @parts = parts
      end
      @parent = @parts.first.parent

      after_add
    end

    def add_or_new(part)
      case @transformations
      when nil, []
        add(part)
        self
      else
        self.class.new(self, part)
      end
    end

    def add(part)
      @parts << part
      after_add
    end

    def after_add
      @parts.flatten!
      @parts.compact!
      inherit_z
      inherit_zref
    end

    def inherit_z
      heights = @parts.map{|l| l.calc_z.to_f}.uniq
      if heights.size > 1
        total_heights = []
        @parts.each do |p|
          total_heights << p.z.to_f + p.calc_z.to_f
        end
        @z = total_heights.max
        @calc_z = heights.min
      else
        @calc_z = heights.first.to_f
        @z = @parts.map(&:z).compact.max
      end
    end

    def inherit_zref
      return if @parts.first == nil
      #return if @parts.first.z.to_f == 0.0
      get_primitives(@parts[1..-1]).flatten.each do |part|
        if part.z.to_f == 0.0
          part.set_option :zref, @parts.first
        end
      end
    end

    def get_primitives(obj)
      res = []
      if obj.kind_of? Array
        obj.each do |part|
          res << part.children_list
        end
      else
        res << obj.children_list
      end
      res
    end

    def only_additives_of(obj)
      res = []
      case obj
      when Array
        res << obj.map{|l| only_additives_of(l)}
      when SubtractObject
      when IntersectionObject
      else
        res << obj
      end
      res.flatten
    end

  end
end
