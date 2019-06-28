module JennCad::Exporters
  class OpenScadObject
    def initialize(cmd, args, children=[])
      @command = cmd
      @args = args
      case children
      when Array
        @children = children
      else
        @children = [children]
      end
    end

    def nl
      "\n"
    end

    def to_s
      case @command
      when nil
        ""
      when :head
        res = "$fn=64;"+nl
        @children.each do |c|
          res += c.to_s+nl
        end
        res
      when :module
        handle_module
      when String, Symbol
        handle_command
      else
      end
    end

    def handle_module
      res = "module #{@args}(){"+nl
      res += tabs(1, @children.map{|c| c.handle_command(2) })
      res += "}"
      res
    end

    def handle_command(i=1)
      case @children.size
      when 0
        "#{@command}(#{handle_args});"
      when 1
        "#{@command}(#{handle_args})#{@children.first.handle_command(i+1)}"
      when (1..)
        res = "#{@command}(#{handle_args}){"
        res += nl
        inner = @children.map do |c|
          next if c == nil
          c.handle_command(i+1)
        end
        res += tabs(i, inner.compact)
        res += nl
        res += tabs(i-1,["}"])+nl
        res
      end
    end

    def tabs(i,a)
      a.map{ |l|
        "  " * i + l
      }.join(nl)
    end

    def handle_args
      case @args
      when String, Symbol
        return "\"#{@args}\""
      when Array
        return @args.map do |l|
          if l == nil
            0
          elsif l.kind_of? Array
            l # skipping check of 2-dmin Arrays for now (used in multmatrix)
          elsif l.to_i == l.to_f
            l.to_i
          else
            l.to_f
          end
        end
      when Hash
        res = []
        @args.each do |k,v|
          if k.to_s == "fn"
            k = "$fn"
          end
          if v == nil
            next
          end
          if !v.kind_of?(Array) && !v.kind_of?(TrueClass) && !v.kind_of?(FalseClass) && v == v.to_i
            v = v.to_i
          end
          res << "#{k}=#{v}"
        end
        res.join(",").gsub("size=","")
      else
        ""
      end
    end
  end

  class OpenScad
    include ActiveSupport::Inflector
    def initialize(part)
      @modules = {}
      @global_fn = 64
      @object_tree = OpenScadObject.new(:head, nil, parse(part))
    end

    def save(file)
      File.open(file,"w") do |f|
        @modules.each do |key, val|
          f.puts val.to_s
        end
        f.puts @object_tree.to_s
      end
    end

    def parse(part)
      if part.respond_to? :to_openscad
        part = part.to_openscad
      end

      if part.respond_to? :analyze_z_fighting
        part = part.analyze_z_fighting
      end


      case part
      when Array
        part.map{ |p| parse(p) }
      when JennCad::OpenScadImport
        # FIXME handle_import(part)
      when JennCad::Aggregation
        handle_aggregation(part)
      when JennCad::UnionObject
        bool('union', part)
      when JennCad::SubtractObject
        bool('difference', part)
      when JennCad::IntersectionObject
        bool('intersection', part)
      when JennCad::HullObject
        bool('hull', part)
      when JennCad::Primitives::Circle
        prim('circle', part)
      when JennCad::Primitives::Cylinder
        prim('cylinder', part)
      when JennCad::Primitives::Sphere
        prim('sphere', part)
      when JennCad::Primitives::Cube
        prim('cube', part)
      when JennCad::Primitives::LinearExtrude
        new_obj(part, :linear_extrude, part.openscad_params, parse(part.parts))
      when JennCad::Primitives::RotateExtrude
        new_obj(part, :rotate_extrude, part.openscad_params, parse(part.parts))
      when JennCad::Primitives::Projection
        new_obj(part, :projection, collect_params(part), parse(part.parts))
      when JennCad::Primitives::Polygon
        new_obj(part, :polygon, collect_params(part))
      when JennCad::Part
        parse(part.part)
      when nil
        new_obj(part, nil)
      else
        puts "unknown part #{part.class}"
        OpenScadObject.new(nil,nil)
      end
    end

    def new_obj(part, cmd, args=nil, children=[])
      transform(part) do
        apply_color(part) do
          OpenScadObject.new(cmd, args, children)
        end
      end
    end

    def bool(type, part)
      new_obj(part, type, nil, parse(part.parts))
    end

    def prim(type, part)
      new_obj(part, type, collect_params(part))
    end

    def collect_params(part)
      res = {}
      [:d, :h, :d1, :d2, :size, :fn, :points].each do |var|
        if part.respond_to? var
          res[var] = part.send var
        end
      end
      case res[:fn]
      when @global_fn
        res[:fn] = nil
      else
      end
      res
    end

    def apply_color(part, &block)
      return block.yield if part.nil? or part.color_or_fallback.nil?
      OpenScadObject.new("color", part.color_or_fallback, block.yield)
    end


    def transform(part, &block)
      return block.yield if part.transformations.nil?

      case t = part.transformations.pop
      when nil, []
        block.yield
      when JennCad::Move
        OpenScadObject.new(:translate, t.coordinates, transform(part, &block))
      when JennCad::Rotate, JennCad::Mirror
        OpenScadObject.new(demodulize(t.class).downcase, t.coordinates, transform(part, &block))
      when JennCad::Multmatrix
        OpenScadObject.new(:multmatrix, t.m, transform(part, &block))
      else
        puts "unknown transformation #{t}"
      end
    end

    def handle_aggregation(part, tabindex=0)
      register_module(part) unless @modules[part.name]
      transform(part) do
        new_obj(part, part.name, nil)
      end
    end

    # accept aggregation
    def register_module(part)
      @modules[part.name] = OpenScadObject.new(:module,part.name, parse(part.part))
    end

  end
end
