module JennCad::Extras
  class Din934 < Hardware
    attr_accessor :height

    def initialize(size,args={})
      @size = size
      @options = args.dup
      @support = args[:support] ||= false
      @support_layer_height = args[:support_layer_height] ||= 0.2
      @margin = args[:margin] ||= 0.3 # default output margin

      @slot = args[:slot] || nil
      @slot_margin = args[:slot_margin] || 0.5
      @slot_direction = args[:slot_direction] || "z"
      @cylinder_length = args[:cylinder_length] || 0  # for slot only

      @transformations ||= []
      @args = args

      @direction = args[:direction] || @slot_direction

      @data =   {2.5=> {side_to_side:5,height:2, support_diameter:2.8},
                    3 => {side_to_side:5.5,height:2.4, support_diameter:3.5},
                    4 => {side_to_side:7,height:3.2, support_diameter:4.4},
                    5 => {side_to_side:8,height:4, support_diameter:5.3},
                    6 => {side_to_side:10,height:5, support_diameter:6.3},
                    8 => {side_to_side:13,height:6.5, support_diameter:8.3},
                   10 => {side_to_side:17,height:8, support_diameter:10.3},
                   12 => {side_to_side:19,height:10, support_diameter:12.3},
                  }
      @s = @data[@size][:side_to_side]
      @height = @data[@size][:height]
      @support_diameter = @data[@size][:support_diameter]
      super(args)
    end

    def add_support(layer_height=@support_layer_height)
      res = cylinder(d:@support_diameter,h:@height-layer_height)
      # on very small nuts, add a support base of one layer height, so the support won't fall over
      if @size < 6
        res += cylinder(d:@s-1,h:layer_height)
      end
      res
    end

    def slot
      case @slot_direction
        when "x"
          pos = {x:@slot}
        when "y"
          pos = {y:@slot}
        when "z"
          pos = {z:@slot}
        when "-x"
          pos = {x:-@slot}
        when "-y"
          pos = {y:-@slot}
        when "-z"
          pos = {z:-@slot}
        else
        raise "Invalid slot direction #{@slot_direction}"
      end
      res = hull(
        nut_934(false,@margin,@slot_margin),
        nut_934(false,@margin,@slot_margin).move(pos)
      )
      if @cylinder_length > 0
        res += cylinder(d:@size+@margin,h:@cylinder_length)
      end
      res
    end

    def cut
      Aggregation.new("din934c#{@size}#{option_string}", nut_934(false,@margin))
    end

    def show
      Aggregation.new("din934s#{@size}#{option_string}", nut_934)
    end

    def nut_934(show=true,margin=0,height_margin=0)
      size = @s + margin

      res = cylinder(d:(size/Math.sqrt(3))*2,h:@height+height_margin,fn:6)
      res -= cylinder(d:@size,h:@height) if show == true
      if @support
        res -= add_support
      end
      res.color("Gainsboro") if show
      res
    end

  end



end
