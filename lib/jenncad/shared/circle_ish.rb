module CircleIsh

  def radius
    if @opts[:d]
      @opts[:d].to_d / 2.0
    else
      @opts[:r].to_d
    end
  end

  def set_anchors_2d
    @anchors = {} # reset anchors
    rad = radius
    # Similar to cube
    set_anchor :left, x: -rad
    set_anchor :right, x: rad
    set_anchor :top, y: rad
    set_anchor :bottom, y: -rad
  end

  def handle_fn
    case @opts[:fn]
      when nil, 0
        $fn = auto_dn!
      else
        @fn = @opts[:fn]
    end
  end

  def auto_dn!
    case @d
      when (16..)
        @fn = (@d*4).ceil
      else
        @fn = 64
    end
  end

  def handle_radius_diameter
    case @opts[:d]
    when 0, nil
      @r = @opts[:r].to_d + @opts[:margins][:r].to_d
      @d = @r * 2.0
    else
      @d = @opts[:d].to_d + @opts[:margins][:d].to_d
      @r = @d / 2.0
    end

    case @opts[:d1]
    when 0, nil
    else
      @d1 = @opts[:d1].to_d + @opts[:margins][:d].to_d
      @d2 = @opts[:d2].to_d + @opts[:margins][:d].to_d
    end

    case @opts[:r1]
    when 0, nil
    else
      @d1 = 2 * @opts[:r1].to_d + @opts[:margins][:d].to_d
      @d2 = 2 * @opts[:r2].to_d + @opts[:margins][:d].to_d
    end
  end


end
