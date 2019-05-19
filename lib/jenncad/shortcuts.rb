module JennCad
  def cylinder(args)
    Cylinder.new(args)
  end

  def sphere(args)
    Sphere.new(args)
  end

  def polygon(args)
    Polygon.new(args)
  end

  def slot(args)
    c1 = cylinder(d:args[:d],r:args[:r],h:args[:h])
    c2 = cylinder(d:args[:d],r:args[:r],h:args[:h])

    if args[:x]
      c2.move(x:args[:x])
    end
    if args[:y]
      c2.move(y:args[:y])
    end

    c1&c2
  end

  def cube(args={}, center=false)
    if args.kind_of? Array
      args = {size:args}
    elsif args.kind_of? Hash
      args[:x] ||= 0
      args[:y] ||= 0
      args[:z] ||= 0
      args = {size:[args[:x],args[:y],args[:z]]}
    end
    if center
      args[:center] = true
    end
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


end
