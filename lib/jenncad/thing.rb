module JennCad
  class Thing
    def openscad(file)
      OpenScad.new(self).save(file)
    end
  end
end
