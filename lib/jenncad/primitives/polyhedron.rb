module JennCad::Primitives
  class Polyhedron < Primitive
    attr_accessor :points, :faces, :convexity
    def initialize(args)
      @opts = args
      @points = args[:points]
      @faces = args[:faces]
      @convexity = args[:convexity] || 10

      super
    end

    def face(i)
      unless @faces[i]
        $log.error "polyhedron: Cannot find face #{i}"
        return self
      end
      face = 0
      poly_faces = []
      poly_points = []
      @faces[i].each do |f|
        point = @points[f]
        if point.nil?
          $log.error "polyhedron: Cannot find point #{f} for face #{i}"
        end
        poly_points << point
        poly_faces << face
        face += 1
        #poly_points << [point[0], point[1]]
      end
      #polygon(points: poly_points)
      polyhedron(points: poly_points, faces: [poly_faces, poly_faces.reverse])
    end
  end
end
