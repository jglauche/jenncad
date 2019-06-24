module JennCad
  class DefaultProfile
    attr_accessor :colors

    def auto_colors
      %w(
        Teal
        DarkOliveGreen
        Aquamarine
        SteelBlue
        LightCoral
        OrangeRed
        MediumVioletRed
        DarkOrchid
        HotPink
      )
    end

    def colors
      case @colors
      when nil, []
        @colors = auto_colors
      end
      @colors
    end

    # called by the command line interface when receiving normal exit status
    def on_success(file)
      system("echo $'\033]30;#{file}: ok\007'")
      puts "ok"
    end

    # called by the command line interface when receiving error exit status
    def on_error(file)
      system("echo $'\033]30;#{file}: error\007'")
      puts "error"
    end

  end
end
