module JennCad
  def cylinder(args)
    Cylinder.new(args)
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

  def +(args)
    return args if self == nil
    if self.kind_of? UnionObject
      self.add(args)
      return self
    else
      UnionObject.new(self,args)
    end
  end

  def -(args)
    if self.kind_of? SubtractObject
      self.add(args)
      return self
    else
      SubtractObject.new(self,args)
    end
  end

  def *(args)
    if self.kind_of? IntersectionObject
      self.add(args)
      return self
    else
      IntersectionObject.new(self,args)
    end
  end

  def &(args)
    if self.kind_of? HullObject
      self.add(args)
      return self
    else
      HullObject.new(self,args)
    end
  end


end
