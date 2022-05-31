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

    # By default, jenncad will add coordinates of subsequent moves in the output
    # i.e.
    #   .move(x: 10, y: 20).move(x: 10) would result depending on the value of this option:
    #
    #   true = translate([10,20, 0])translate([10, 0, 0])
    #   false = translate([20, 20, 0])
    #
    # defaults to false
    def chain_moves
      false
    end

    def colors
      case @colors
      when nil, []
        @colors = auto_colors
      end
      @colors
    end

    # add your custom colors here, in RGBA format
    def custom_colors
      {
        # example:
        # myblue: [0, 0, 255, 255],
      }
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
