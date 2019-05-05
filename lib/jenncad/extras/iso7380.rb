module JennCad::Extras
  class Iso7380 < Hardware
    attr_accessor :height

		def initialize(size,length,args={})
			super(args)
      @args = args
			# options for output only:
			@args[:additional_length] ||= 0
			@args[:additional_diameter] ||= 0.3
			@args[:head_margin] ||= 0.0

		#	if @args[:washer] == true
		#		@washer = Washer.new(size,{:material => @args[:material], :surface => @args[:surface]})
		#	end

			@size = size
			@length = length
			@transformations ||= []
		end

		def cut
      res = bolt_7380(@args[:additional_length], @args[:additional_diameter], @args[:head_margin])
	    Aggregation.new("iso7380c#{@size}#{option_string}", res)
    end

		def show
			res = bolt_7380(0,0)
			#if @washer
			#	res += @washer.show
		#		res = res.move(z:-@washer.height)
	#		end
			res
		  Aggregation.new("iso7380s#{@size}#{option_string}", res)
    end

    # ISO 7380
  	def bolt_7380(additional_length=0, addtional_diameter=0, head_margin=0)
	    if head_margin.to_f != 0
				puts "[warning] :head_margin is not implemented for 7380 bolts"
			end
			chart_iso7380 = {
	                    3 => {head_dia:5.7,head_length:1.65},
	                    4 => {head_dia:7.6,head_length:2.2},
	                    5 => {head_dia:9.5,head_length:2.75},
	                    6 => {head_dia:10.5,head_length:3.3},
	                    8 => {head_dia:14,head_length:4.4},
	                    10=> {head_dia:17.5,head_length:5.5},
	                    12=> {head_dia:21,head_length:6.6},


	    }
	  	res = cylinder(d1:chart_iso7380[@size][:head_dia]/2.0,d2:chart_iso7380[@size][:head_dia],h:chart_iso7380[@size][:head_length]).move(z:-chart_iso7380[@size][:head_length]).color("Gainsboro")
      total_length = @length + additional_length
      res+= cylinder(d:@size+addtional_diameter, h:total_length).color("DarkGray")
	  end
  end
end
