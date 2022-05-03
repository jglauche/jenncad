class Integer
  def of(part=nil, anchor=:top_face)
    return nil if part.nil?
    num = self - 1

    res = part.fix
    num.times do
      res += part.movea(anchor)
    end
    res
  end
end


