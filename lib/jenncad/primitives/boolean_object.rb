module JennCad::Primitives
  class BooleanObject < Primitive
    def initialize(*parts)
      @transformations = []
      if parts.first.kind_of? Array
        @parts = parts.first
      else
        @parts = parts
      end
      after_add
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
      @z = 0
      @calc_z = parts.first.calc_z.to_f
      @parts.each do |p|
        if p.z.to_f > @z && @calc_z == p.calc_z.to_f
          @z = p.z
        end
      end
    end

    def inherit_zref
      return if @parts.first == nil
      return if @parts.first.z.to_f == 0.0
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


  end
end
