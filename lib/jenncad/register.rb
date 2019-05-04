module JennCad

  class Register
    def initialize
      @objects = {}
    end

    def register(cl, args)
      if @objects[cl] == nil || @objects[cl][args] == nil
        register_new(cl, args)
      end
      return @objects[cl][args]
    end

    def register_new(cl,args)
       @objects[cl] ||= {}
       @objects[cl][args] = cl.send :new, args
    end
  end

  $parts = Register.new

end
