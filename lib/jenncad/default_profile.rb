module JennCad
  class DefaultProfile
    attr_accessor :colors
    AutoColors =
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


    def colors
      @colors ||= []
      if @colors.empty?
        @colors = AutoColors
      end
      @colors
    end

    # called by the command line interface when receiving normal exit status
    def on_success
      puts "ok"
    end

    # called by the command line interface when receiving error exit status
    def on_error
      puts "error"
    end

  end
end
