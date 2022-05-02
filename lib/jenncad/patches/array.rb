class Array
  # Assembles things on top of each other
  def assemble(partlib=nil, skip_z=false, z=0)
    map do |part|
      case part
      when Array
        res = part.assemble(partlib, true)
      when String, Symbol
        res = partlib[part].yield
      when Proc
        res = part.yield
      else
        res = part
      end
      res, z = res.mz(z), z + res.z.to_d unless skip_z
      res
    end
    .union
  end

  def union
    UnionObject.new(self)
  end
  alias u union

  def subtraction
    SubtractObject.new(self)
  end
  alias subtract subtraction
  alias sub subtraction
  alias s subtraction

  def intersection
    IntersectionObject.new(self)
  end
  alias intersect intersection
  alias i intersection

  def hull
    HullObject.new(self)
  end
  alias h hull


  def random
    self[Random.rand(size)]
  end

end
