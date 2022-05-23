module JennCad::Primitives
  class Text < Primitive
    attr_accessor :text, :font, :valign, :halign, :size, :spacing, :script, :fn, :direction, :language

    def initialize(args)
      @text = args[:text]
      @size = args[:size]
      @font = args[:font]
      @valign = args[:valign]
      @halign = args[:halign]
      @spacing = args[:spacing]
      @script = args[:script]
      @direction = parse_dir(args[:dir] || args[:direction])
      case @direction
        when "btt", "ttb"
          @valign ||= :top
          @halign ||= :left
      end

      @language = args[:language]
      @fn = args[:fn]

      init(args)
    end

    def parse_dir(dir)
      case dir.to_s
        when "x", "ltr"
          "ltr"
        when "-x", "xn", "nx", "xi", "rtl"
          "rtl"
        when "y", "btt"
          "btt"
        when "-y", "yn", "ny", "yi", "ttb"
          "ttb"
        else
          nil
      end
    end

    def openscad_params
      res = {}
      [:text, :font, :valign, :halign, :size, :spacing, :script, :direction, :language, :fn].each do |n|
        res[n] = self.send n
      end
      res
    end

  end
end
