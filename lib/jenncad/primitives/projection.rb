module JennCad::Primitives
  class Projection < JennCad::Thing
    def initialize(part, args)
      @transformations = []
      @cut = args[:cut]
      @parts = [part]
   end
 end
end
