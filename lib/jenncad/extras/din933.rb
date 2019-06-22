module JennCad::Extras
  class Din933 < Hardware
    attr_accessor :height

    def initialize(size,length,args={})
      super(args)
      @args = args
      # options for output only:
      @args[:additional_length] ||= 0
      @args[:additional_diameter] ||= 0.3
      @args[:head_margin] ||= 0.0

      #if @args[:washer] == true
    #   @washer = Washer.new(size,{:material => @args[:material], :surface => @args[:surface]})
      #end

      @size = size
      @length = length
      @transformations ||= []
    end

    def cut
      res = bolt_933(@args[:additional_length], @args[:additional_diameter], @args[:head_margin])
      Aggregation.new("din933c#{@size}#{option_string}", res)
    end

    def show
      res = bolt_933(0,0)
      #if @washer
      # res += @washer.show
      # res = res.move(z:-@washer.height)
      #end
      res.color("DarkGray")
      Aggregation.new("din933s#{@size}#{option_string}", res)
    end

    def bolt_933(additional_length=0, addtional_diameter=0, head_margin=0)

      chart        = {2 => {head_side_to_side:4,head_length:1.4},
                      2.5=> {head_side_to_side:5,head_length:1.7},
                      3 => {head_side_to_side:5.5,head_length:2},
                      4 => {head_side_to_side:7,head_length:2.8},
                      5 => {head_side_to_side:8,head_length:3.5},
                      6 => {head_side_to_side:10,head_length:4},
                      8 => {head_side_to_side:13,head_length:5.5},
                      10=> {head_side_to_side:17,head_length:7},
                      12=> {head_side_to_side:19,head_length:8},
                      14=> {head_side_to_side:22,head_length:9},
                      16=> {head_side_to_side:24,head_length:10},
                     }
      head_dia = chart[@size][:head_side_to_side].to_f + head_margin.to_f
      res = cylinder(d:(head_dia/Math.sqrt(3))*2,fn:6,h:chart[@size][:head_length]).move(z:-chart[@size][:head_length])
      total_length = @length + additional_length
      res+= cylinder(d:@size+addtional_diameter, h:total_length)
    end




  end



end
