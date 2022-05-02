module JennCad::Features
  class Climb < Feature
    def initialize(opts, block)
      @opts = {
        offset: :auto,
        step: nil,
        steps: nil,
        bottom: nil,
        top: nil,
        z: nil,
      }.deep_merge!(opts)
      if @opts[:step].nil? && @opts[:steps].nil?
        raise "please define at least one of :step or :steps for climb"
      end
      super(@opts)
      @block = block
    end

    def z_or_referenced
      case z = @opts[:z]
      when nil
        referenced_z.z
      else
        z
      end
    end

    def get_step(z)
      case step = @opts[:step]
      when nil, :auto, 0, 0.0
        steps = @opts[:steps]
        (z  / steps).floor
      else
        step.to_d
      end
    end

    def get_offset(z)
      case offset = @opts[:offset]
      when :auto
        step = get_step(z)
        ((z % step) + step) / 2.0
      when nil, 0, 0.0
        0.0
      else
        offset
      end
    end

    def climb_from_bottom(offset, step, n)
      n.times.map{ |i| @block.yield.mz(offset+step*i) }.union
    end

    def climb_from_top(z, offset, step, n)
      n.times.map{ |i| @block.yield.mz(z-offset-step*i) }.union
    end

    def to_openscad
      ref_z = z_or_referenced
      step = get_step(ref_z)
      steps, top, bottom = @opts.values_at(:steps, :top, :bottom)

      offset = get_offset(ref_z)

      lo = (ref_z-offset*2).to_d % step.to_d
      unless lo.to_d == 0.0
        puts "[Warning]: climb has leftover offset #{lo}"
      end

      if steps
        top = steps
        bottom = steps
      end

      unless top or bottom
        climb_from_bottom(offset, step, ((ref_z-offset*2) / step).floor + 1 )
      else
        res = nil
        if top
          res += climb_from_top(ref_z, offset, step, top)
        end
        if bottom
          res += climb_from_bottom(offset, step, bottom)
        end
        res
      end
    end

  end

  def climb(args, &block)
    Climb.new(args, block)
  end

end
