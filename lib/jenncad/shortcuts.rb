module JennCad
  def circle(args)
    Circle.new(args)
  end

  def cylinder(*args)
    Cylinder.new(args)
  end

  def sphere(args)
    Sphere.new(args)
  end

  def polygon(args)
    Polygon.new(args)
  end

  def slot(*args)
    Slot.new(args)
  end

  def cube(*args)
    Cube.new(args)
  end

  # import/use OpenScad library
  def import(import,name,args)
    OpenScadImport.new(import, name, args)
  end

  def extrude(args)
    LinearExtrude.new(self, args)
  end

  def rotate_extrude(args={})
    RotateExtrude.new(self, args)
  end

  def to_2d(args={})
    Projection.new(self, args)
  end

  def union(*args)
    UnionObject.new(*args)
  end

  def +(args)
    return args if self == nil
    if self.kind_of?(UnionObject) && self.transformations.size == 0
      self.add(args)
      return self
    else
      UnionObject.new(self,args)
    end
  end

  def subtraction(*args)
    SubtractObject.new(*args)
  end

  def -(args)
    if self.kind_of?(SubtractObject) && self.transformations.size == 0
      self.add(args)
      return self
    else
      SubtractObject.new(self,args)
    end
  end

  def intersection(*args)
    IntersectionObject.new(*args)
  end

  def *(args)
    if self.kind_of?(IntersectionObject) && self.transformations.size == 0
      self.add(args)
      return self
    else
      IntersectionObject.new(self,args)
    end
  end

  def hull(*args)
    HullObject.new(*args)
  end

  def &(args)
    if self.kind_of?(HullObject) && self.transformations.size == 0
      self.add(args)
      return self
    else
      HullObject.new(self,args)
    end
  end

  def assemble(partlib=nil, z_skip = false, z=0, &block)
    block.yield.assemble(partlib, z_skip, z)
  end
end
