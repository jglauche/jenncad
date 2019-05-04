module JennCad
  class Transformation
    attr_accessor :x,:y,:z, :coordinates
    def initialize(*args)
      puts args.inspect
      args = args.flatten
      @x = args[:x]
      @y = args[:y]
      @z = args[:z]
    end

    def coordinates
      [@x,@y,@z]
    end
  end
end
