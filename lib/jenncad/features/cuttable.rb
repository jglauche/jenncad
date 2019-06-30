module JennCad::Features
  module Cuttable
    def cut(args, &block)
      if args[:x]
        l = args[:x].min * @opts[:y] / 2.0
        r = args[:x].max * @opts[:y] / 2.0
        prepare_cut(l, r, &block).flip_x
      elsif args[:y]
        l = args[:y].min * @opts[:y] / 2.0
        r = args[:y].max * @opts[:y] / 2.0
        prepare_cut(l, r, &block).flip_y
      elsif args[:z]
        raise "cut for Z is not implemented yet"
      end
    end

    def prepare_cut(l, r, &block)
      part = block.call
      if part.z.to_f > 0.0
        part.opts[:margins][:z] = 0.2
        if l == 0.0
          part.mz(r+0.1)
        else
          part.mz(l+part.z.to_f-0.2)
        end
      else
        part.opts[:margins][:z] = 0.2
        part.z = l.abs + r.abs + 0.2
        part.mz(-0.1)
      end
    end


  end
end
