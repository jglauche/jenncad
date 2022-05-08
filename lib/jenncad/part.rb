module JennCad
  # Part should be inherited from the user when making parts
  class Part < Thing

    # this function both gets and defines hardware
    def hardware(hw_type=nil, args={})
      @_hw ||= {}
      if hw_type == nil
        return @_hw
      end

      anchors = args[:anchor] || args[:anchors]
      unless anchors.kind_of? Array
        anchors = [anchors]
      end

      anchors.each do |a|
        @_hw[a] = {
          hw_type: hw_type,
          size: args[:size],
          d: args[:d],
          len: args[:len],
          pos: anchor(a, args[:from]),
        }
      end
      self
    end
    alias :hw :hardware


    def to_openscad
      name = @name || self.class.to_s
      a = Aggregation.new(name, self.get_contents)
      a.transformations = @transformations
      if self.has_explicit_color?
        a.color(self.color)
      else
        a.color(:auto)
      end
      a
    end

    def part
    end

  end
end
