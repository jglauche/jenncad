module JennCad::Primitives
  class BooleanObject < Primitive
    def initialize(*parts)
      @transformations = []
      if parts.first.kind_of? Array
        @parts = parts.first
      else
        @parts = parts
      end
      if parts.first && parts.first.respond_to?(:debug?) && parts.first.debug?
        $log.debug("Creating new #{self.class} for part #{parts}")
      end

      @parent = @parts.first.parent

      after_add
    end

    def add_or_new(part)
      case @transformations
      when nil, []
        $log.debug("adding new part to existing boolean object") if part && part.debug?
        add(part)
        self
      else
        $log.debug("add_or_new: creating new boolean object") if part.debug?
        self.class.new(self, part)
      end
    end

    def add(part)
      return if part.nil?
      @parts << part
      after_add
    end

    def after_add
      @parts.flatten!
      @parts.compact!
      inherit_debug
      inherit_z
      inherit_zref
    end

    def inherit_debug
      if @parts.map{|l| l.option(:debug)}.include? true
        set_option(:debug, true)
      end
    end

    def inherit_z
      heights = @parts.map{|l| l.calc_z.to_d}.uniq
      if heights.size > 1
        total_heights = []
        @parts.each do |p|
          total_heights << p.z.to_d + p.calc_z.to_d
        end
        @z = total_heights.max
        @calc_z = heights.min
      else
        @calc_z = heights.first.to_d
        @z = @parts.map(&:z).compact.max
      end
    end

    def inherit_zref
      return if @parts.first == nil
      #return if @parts.first.z.to_d == 0.0
      get_primitives(@parts[1..-1]).flatten.each do |part|
        if part.z.to_d == 0.0
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
        # include the thing that something was subtracted from to get the Z height if that is behind another layer of SubtractObject
        res << only_additives_of(obj.parts.first)
      when IntersectionObject
      else
        res << obj
      end
      res.flatten
    end

  end
end
