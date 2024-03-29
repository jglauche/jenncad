module JennCad
  def circle(args)
    Circle.new(args).set_parent(self)
  end
  alias :ci :circle

  def square(args)
    Square.new(args).set_parent(self)
  end
  alias :sq :square

  def cylinder(*args)
    Cylinder.new(args).set_parent(self)
  end
  alias :cy :cylinder
  alias :cyl :cylinder

  def sphere(args)
    Sphere.new(args).set_parent(self)
  end
  alias :sp :sphere

  def polygon(args)
    Polygon.new(args).set_parent(self)
  end
  alias :pg :polygon

  def polyhedron(args)
    Polyhedron.new(args).set_parent(self)
  end
  alias :phd :polyhedron

  def slot(*args)
    Slot.new(args).set_parent(self)
  end
  alias :sl :slot

  def cube(*args)
    Cube.new(args).set_parent(self)
  end
  alias :cu :cube

  def rounded_cube(*args)
    RoundedCube.new(args).set_parent(self)
  end
  alias :rcube :rounded_cube
  alias :rc :rounded_cube
  alias :rsq :rounded_cube

  # import/use OpenScad library
  def import(import,name,args={})
    OpenScadImport.new(import, name, args)
  end
  alias :use :import

  def stl(file, args={})
    StlImport.new(file, args).set_parent(self)
  end

  def extrude(args={})
    LinearExtrude.new(self, args)
  end
  alias :e :extrude
  alias :ex :extrude

  def rotate_extrude(args={})
    RotateExtrude.new(self, args)
  end
  alias :re :rotate_extrude
  alias :rex :rotate_extrude

  def to_2d(args={})
    Projection.new(self, args)
  end
  alias :as_2d :to_2d

  def text(txt, args={})
    Text.new(args.merge({text: txt}))
  end

  def union(*args)
    UnionObject.new(*args)
  end

  def subtraction(*args)
    SubtractObject.new(*args)
  end

  def intersection(*args)
    IntersectionObject.new(*args)
  end

  def hull(*args)
    HullObject.new(*args)
  end

  def +(part)
    boolean_operation(part, UnionObject)
  end

  def -(part)
    boolean_operation(part, SubtractObject)
  end

  def *(part)
    boolean_operation(part, IntersectionObject)
  end

  def &(part)
    boolean_operation(part, HullObject)
  end

  def assemble(partlib=nil, z_skip = false, z=0, &block)
    block.yield.assemble(partlib, z_skip, z)
  end

  private
  def boolean_operation(part, klass)
    if part.respond_to? :transformations
      # Clone the part in place
      part = part.fix
    end

    case self
    when nil
      part
    when klass
      add_or_new(part)
    else
      own_part = if self.respond_to? :transformations
        self.fix # clone self
      else
        self
      end
      klass.new(own_part,part)
    end
  end
end
