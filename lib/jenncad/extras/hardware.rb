module JennCad::Extras
  class Hardware
    attr_accessor :z_fight
    def initialize(args)
      @z_fight = args[:z_fight] || 0.01
      @height += @z_fight*2
      @options ||= {}
    end

    def option_string
      str =""
      @options.each do |k,v|
        str << "#{k}#{v}"
      end
      str.gsub(".","_")
    end
  end
end
