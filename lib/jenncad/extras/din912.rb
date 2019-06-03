module JennCad::Extras
  class Din912 < Hardware
    Data = {2 => {head_dia:3.8,head_length:2,thread_length:16},
          2.5=> {head_dia:4.5,head_length:2.5,thread_length:17},
          3 => {head_dia:5.5,head_length:3,thread_length:18},
          4 => {head_dia:7.0,head_length:4,thread_length:20},
          5 => {head_dia:8.5,head_length:5,thread_length:22},
          6 => {head_dia:10,head_length:6,thread_length:24},
          8 => {head_dia:13,head_length:8,thread_length:28},
          10=> {head_dia:16,head_length:10,thread_length:32},
          12=> {head_dia:18,head_length:12,thread_length:36},
          14=> {head_dia:21,head_length:14,thread_length:40},
          16=> {head_dia:24,head_length:16,thread_length:44},
          18=> {head_dia:27,head_length:18,thread_length:48},
          20=> {head_dia:30,head_length:20,thread_length:52},
          22=> {head_dia:33,head_length:22,thread_length:56},
          24=> {head_dia:36,head_length:24,thread_length:60},
          30=> {head_dia:45,head_length:30,thread_length:72},
          36=> {head_dia:54,head_length:36,thread_length:84},
         }


    attr_accessor :height

    def initialize(size,length,args={})
      super(args)
      @args = args
      # options for output only:
      @args[:additional_length] ||= 0
      @args[:additional_diameter] ||= 0.2
      @args[:head_margin] ||= 0.3
      @face = args[:face] || "bottom"
      @flush = args[:flush] || nil

#     if @args[:washer] == true
#       @washer = Washer.new(size,{:material => @args[:material], :surface => @args[:surface]})
#     end

      @size = size
      @length = length
      @transformations ||= []
    end

    def cut
      Aggregation.new("din912f#{@face}c#{@size}l#{@length}#{option_string}", bolt_912(false, @args[:additional_length], @args[:additional_diameter], @args[:head_margin])
)
    end

    def show
      res = bolt_912(true, 0,0)
#     if @washer
#       res += @washer.show
#       res = res.move(z:-@washer.height)
#     end
#     res
      Aggregation.new("din912f#{@face}s#{@size}l#{@length}#{option_string}", res)
    end

    def bolt_912(show, additional_length=0, addtional_diameter=0, head_margin=0)

      res = cylinder(d:Data[@size][:head_dia]+head_margin,h:Data[@size][:head_length]).move(z:-Data[@size][:head_length])
      total_length = @length + additional_length

      if show
        res.color("Gainsboro")
        thread_length=Data[@size][:thread_length]
        if total_length.to_f <= thread_length
          res+= cylinder(d:@size+addtional_diameter, h:total_length).color("DarkGray")
        else
          res+= cylinder(d:@size+addtional_diameter, h:total_length-thread_length)
          res+= cylinder(d:@size+addtional_diameter, h:thread_length).move(z:total_length-thread_length).color("DarkGray")
        end
      else
        res+= cylinder(d:@size+addtional_diameter, h:total_length)
      end
      if @flush
        if @face == :top
          @flush*=-1
        end
        res.move(z:Data[@size][:head_length] + @flush) # this needs to be fixed, need to tell it cut height to surface + margin for openscad mess
      end
      case @face
        when :top
          res = res.mirror(z:1)
      end
      res
    end
  end
end
