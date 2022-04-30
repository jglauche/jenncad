module JennCad::Primitives
  class SubtractObject < BooleanObject
    def inherit_z
      @z = 0
      @calc_z = parts.first.calc_z.to_f

      only_additives_of(@parts).each do |p|
        if option(:debug)
          $log.debug "inherit_z checks for: #{p}"
        end
        z = p.z.to_f
        @z = z if z > @z
      end
      $log.debug "inherit_z called, biggest z found: #{@z}" if option(:debug)

    end

    def get_heights(obj)
      res = []
      obj.each do |part|
        if part.respond_to? :calc_h
          res << part.calc_h
        end
      end
      res
    end

    def get_z(obj)
      res = []
      obj.each do |part|
        if part.respond_to? :calc_z
          res << part.calc_z
        end
      end
      res
    end

    def analyze_z_fighting
      first = get_primitives(@parts.first).flatten
      others = get_primitives(@parts[1..-1]).flatten

      first_h = get_heights(first).uniq
      first_z = get_z(first).uniq
      #puts first.inspect
      if first_h.size > 1
#        puts "first item has multiple heights: #{first_h.inspect}"
        first_h.each do |h|
          compare_z(others, h, first_z.first)
        end
      else
        compare_z(others, first_h.first, first_z.first)
      end
      self
    end

    def compare_z(others,compare_h,compare_z)
      others.each do |part|
        #puts part.inspect
        #puts "#{part.calc_z+part.calc_h} ; #{compare_h}"
        if part.respond_to? :z
          part.opts[:margins] ||= {}
          if part.referenced_z && part.z != 0.0
            case part
            when JennCad::Circle
            when JennCad::BooleanObject
            else
              $log.debug part if part.opts[:debug]
              part.opts[:margins][:z] ||= 0.0
              unless part.opts[:margins][:z] == 0.2
                part.opts[:margins][:z] = 0.2
                part.mz(-0.1)
              end
            end
          elsif part.z == compare_h
            $log.debug "fixing possible z fighting: #{part.class} #{part.z}" if part.opts[:debug]
            part.opts[:margins][:z] += 0.008
            part.mz(-0.004)
          elsif part.calc_z == compare_z
#            puts "z fighting at bottom: #{part.calc_z}"
            part.opts[:margins][:z] += 0.004
           # part.z+=0.004
            part.mz(-0.002)
          elsif part.calc_z.to_f+part.calc_h.to_f == compare_h
#            puts "z fighting at top: #{compare_h}"
            #part.z+=0.004
            part.opts[:margins][:z] += 0.004
            part.mz(0.002)
          end
        end
      end
    end

  end
end
