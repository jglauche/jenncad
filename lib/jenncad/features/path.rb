module JennCad
  class RoundCorner
    attr_accessor :start_point, :end_point, :input_a, :output_a, :a, :l, :od, :id, :thing, :angle, :current_angle, :direction, :from, :ccw
    def initialize(args, &thing)
      @start_point = args[:start_point]
      @end_point = args[:end_point]
      @a = args[:a]
      @ccw = args[:ccw] || false
      @l = args[:l]
      @od = args[:od]
      @id = args[:id]
      @input_a = args[:input_a] || 0
      @output_a = args[:output_a] || 0
      @thing = thing
      @angle = args[:angle]
      @current_angle = args[:current_angle]
      @direction = args[:direction]
      @to = args[:to]
      @from = args[:from]

      if @a < 0
        @from = case @from
          when :left
            :right
          when :right
            :left
          when :top, :up
            :bottom
          when :down, :bottom
            :up
          else
            # // unimplemented
            @from
        end
      end

    end

    def set_angles(cur, total, direction)
      @current_angle = cur
      @angle = normalize(total)
      @direction = direction
    end

    def normalize(angle)
      if angle < 0
        angle += 360
      end
      if angle >= 360
        angle -= 360
      end
      angle
    end

    def margin
      return @od
    end

    def positions
      l = thing.yield.d + @id
      l2 = thing.yield.d / 2.0 + @id / 2.0
      r = 0
      ox = 0
      oy = 0
      cr = 180
      case @from
        when :left
          r = 0
          oy = -l
        when :top, :up
          r = -90
          ox = -l
          cr = 0
        when :right
          r = 180
          oy = l
        when :bottom, :down
          cr = 0
          r = 90
          ox = l
        # TODO: so this doesn't work yet,
        #       need to figure out the maths to translate this
        when 0..360
          r = 180-@from
          cr = @a
      end

      r2 = cr + r + @a   # 180+@a
      x = - l2 * Math::sin((r2/180.0)*Math::PI)
      y = - l2 * Math::cos((r2/180.0)*Math::PI)



      return r, ox/2.0, oy/2.0, x, y

    end

    def part
      d = thing.yield.d
      len = d * 2 + @id
      x = Math::sin((@a/180.0)*Math::PI)*len
      y = Math::cos((@a/180.0)*Math::PI)*len

      res  = circle(d: len)
      res -= circle(d: @id)
      points = [[0,0]]
      points << [0, len]
      points << [x, y]

      res *= polygon(points:points)

      r, ox, oy, x, y = positions
      res = res.rotate(z: r).move(x: ox, y: oy)
      res = res.auto_extrude#.color("red")

      #res += slot(d: 1.2, y: len/2.0, h: 10).rotate(z: r_midpoint).color("red")
      #res += cylinder(d: 1, h: 10).move(x: x+ox,y: y+oy)

      #res.moveh(x: thing.yield.d, y: -thing.yield.d)
      res.move(x: @start_point[:x], y: @start_point[:y])

      #res += cylinder(d: 1, h: 15).color("red").move(x: @start_point[:x], y: @start_point[:y]).move(z:-1)


      res

    end

  end

  class Line
    attr_accessor :start_point, :end_point, :l, :thing, :angle, :current_angle, :direction
    def initialize(args, &thing)
      @start_point = args[:start_point]
      @end_point = args[:end_point]
      @angle = args[:angle]
      @current_angle = args[:current_angle]
      @direction = args[:direction]
      @l = args[:l]
      @thing = thing
    end

    def sp_margin(margin)
      @start_point[:x] -= margin[:x]
      @start_point[:y] -= margin[:y]
    end

    def ep_margin(margin)
      @end_point[:x] -= margin[:x]
      @end_point[:y] -= margin[:y]
    end

    def shrink_ep(len)
      sx, sy = @start_point[:x], @start_point[:y]
      ex, ey = @end_point[:x], @end_point[:y]
      vx = ex-sx
      vy = ey-sy
      l = Math::sqrt(vx**2 + vy**2)
      factor = len / l
      @end_point[:x] -= vx * factor
      @end_point[:y] -= vy * factor
      #puts "#{sx} x #{sy}  => #{ex} x #{ey} , shrink #{factor} "
    end

    def shrink_sp(len)
      sx, sy = @start_point[:x], @start_point[:y]
      ex, ey = @end_point[:x], @end_point[:y]
      vx = ex-sx
      vy = ey-sy
      l = Math::sqrt(vx**2 + vy**2)
      factor = len / l
      @start_point[:x] -= vx * factor
      @start_point[:y] -= vy * factor
    end


    def part
      hull(
        @thing.yield.move(x: @start_point[:x], y: @start_point[:y]),
        @thing.yield.move(x: @end_point[:x], y: @end_point[:y])
      )
    end
  end

  class Path < Thing

    attr_accessor :elements, :lpos, :thing, :angle, :current_angle, :direction
    def initialize(args)
      @thing = args[:part] #// cylinder(d: @d, z: @z)
      @part = new_thing
      @angle = args[:a] || 0
      @current_angle = args[:a] || 0
      @direction = 0
      @name = args[:name] || "Path"
      @calc_h = @part.z
      @dir = 0
      @lpos = {x: 0, y: 0, l: 0, a: 0}
      @coords = []
      @steps = []
      @parts = [new_thing]

      super(args)
    end

    def new_thing
      r = @thing.clone
      r.transformations = []
      r
    end

    def corner(args)
      od = args[:od]
      id = args[:id]
      if id.nil? && od
        id = new_thing.d
        #puts "od: #{od} , thing d #{new_thing.d} new id #{id}"
      end
      if od.nil? && id
        od = id + new_thing.d
      end
      rc = RoundCorner.new(
        start_point: { x: @lpos[:x], y: @lpos[:y] },
        end_point: { x: @lpos[:x], y: @lpos[:y] },
        od: od,
        id: id,
        ccw: args[:ccw],
        from: args[:from],
        to: args[:to],
        a: args[:a],
        direction: @direction
      ){ new_thing }

      _, ox, oy, x, y = rc.positions
      @lpos[:x] += x + ox
      @lpos[:y] += y + oy

      @steps << rc
    end

    def line(args)
      if args[:l]
        args[:a] ||= 0
        if args[:a] > 0
          @direction = 1
        elsif args[:a] < 0
          @direction = -1
        else
          @direction = 0
        end

        @angle += args[:a]
        @current_angle = args[:a]

        l = args[:l]
        gamma = 90
        alpha = @angle
        beta = gamma - alpha

        case
        when alpha == 90, alpha == -270
          x = l
          y = 0
        when alpha == 180, alpha == -180
          x = 0
          y = -l
        when alpha == 270, alpha == -90
          x = -l
          y = 0
        when alpha == 360, alpha == 0
          x = 0
          y = l
        else
          y = l/Math::sin(radians(gamma)) * Math::sin(radians(beta))
          x = y/Math::sin(radians(beta)) * Math::sin(radians(alpha))
        end
      elsif args[:x] || args[:y]
        x = args[:x] || 0
        y = args[:y] || 0

        dx = @lpos[:x] - x
        dy = @lpos[:y] - y

        l = Math::sqrt(dx*dx + dy*dy)
        alpha = Math::atan2(x, y)*180/Math::PI
      else
        puts "Error in line(): Please specify either :l, :x or :y"
        return
      end

      @steps << Line.new(start_point: { x: @lpos[:x], y: @lpos[:y] }, end_point: { x: @lpos[:x] + x, y: @lpos[:y] + y  }, angle: @angle, current_angle: @current_angle, direction: @direction, l: l){ new_thing }

      add_lpos({x: x, y: y})
    end

    def add_lpos(lpos)
      #puts "x: #{lpos[:x]}, y: #{lpos[:y]}"
      [:x, :y].each do |key|
        @lpos[key] += lpos[key]
      end
      @coords << lpos
    end

    def pos
      [@lpos[:x], @lpos[:y]]
    end

    def center
      @steps << Move.new(x: @lpos[:x] * -1, y: @lpos[:y] * -1)
      self
    end

    def assemble
      @steps.each_with_index do |step, i|
        if @steps[i+1] && @steps[i+1].class == Line && step.class == RoundCorner
          step.set_angles(@steps[i+1].current_angle, @steps[i+1].angle, @steps[i+1].direction)
        end
      end
      res = nil
      @steps.each do |step|
        if step.kind_of? Transformation
          res.transformations << step
        else
          res += step.part
        end
      end
      set_heights_for_auto_extrude([res], self)
      res.transformations << @transformations
      Aggregation.new(@name, res)
    end

  end
end


