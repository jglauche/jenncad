module JennCad

  class Register
    def initialize
      @counts = {}
      @objects = {}
    end

    def register(cl, args)
      if @objects[cl] == nil || @objects[cl][args] == nil
        register_new(cl, args)
      end
      return @objects[cl][args]
    end

    def register_new(cl,args)
       @counts[cl] ||= {}
       @objects[cl] ||= {}
       if  @counts[cl][args]
         @counts[cl][args] += 1
       else
         @counts[cl][args] = 1
       end

       @objects[cl][args] = cl.send :new, args
    end
  end

  $parts = Register.new

end
