module ZIsh

  def set_anchors_z
    if @opts[:center_z]
      set_anchor :bottom_face, z: -z/2.0
      set_anchor :top_face, z: z/2.0
      set_anchor :center, x: 0
    else
      set_anchor :bottom_face, z: 0
      set_anchor :top_face, z: z
      set_anchor :center,  zh: z
    end
  end

  def cz
    if self.respond_to? :nc
      nc
    end
    @opts[:center_z] = true
    set_anchors_z
    self
  end
  alias :center_z :cz

  def flip_axis(dir)
    case dir
      when :bottom
        nil
      when :top
        :z
      when :left, :right
        :x
      when :front, :back
        :y
    end
  end

  def flip_rotation(dir)
    case dir
      when :bottom
        {}
      when :left
        {y: 270}
      when :top
        {x: 180}
      when :right
        {y: 90}
      when :front
        {x: 90}
      when :back
        {x: 270}
    end
  end

end
