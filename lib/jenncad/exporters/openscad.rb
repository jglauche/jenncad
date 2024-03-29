module JennCad::Exporters
  class OpenScadObject
    def initialize(cmd, args, children=[], modifier=nil)
      @command = cmd
      @args = args
      @modifier = modifier || ""

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
        "#{@modifier}#{@command}(#{handle_args(@args)});"
      when 1
        "#{@modifier}#{@command}(#{handle_args(@args)})#{@children.first.handle_command(i+1)}"
      when (1..)
        res = "#{@modifier}#{@command}(#{handle_args(@args)}){"
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

    def handle_args(args)
      case args
      when String, Symbol
        return "\"#{args}\""
      when Array
        return args.map do |l|
          if l == nil
            0
          elsif l.kind_of? Array
            l # skipping check of 2-dmin Arrays for now (used in multmatrix)
          elsif l == 0
            0
          elsif l == l.to_i
            l.to_i
          else
            l.to_f
          end
        end
      when Hash
        res = []
        args.each do |k,v|
          if k.to_s == "fn"
            k = "$fn"
          end
          if v == nil
            next
          end
          if v.kind_of?(Symbol)
            v = v.to_s
          end
          if v.kind_of?(Array)
            v = handle_args(v)
          elsif !v.kind_of?(TrueClass) && !v.kind_of?(FalseClass) && v == v.to_i
            v = v.to_i
          elsif v.kind_of? BigDecimal
            v = v.to_f
          end
          if v.kind_of? String
            q = "\""
          else
            q = ""
          end
          res << "#{k}=#{q}#{v}#{q}"
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
      @imports = []
      @modules = {}
      @global_fn = 64
      @object_tree = OpenScadObject.new(:head, nil, parse(part))
    end

    def save(file)
      File.open(file,"w") do |f|
        @imports.uniq.each do |val|
          f.puts "use <#{val}.scad>\n"
        end

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
        handle_import(part)
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
      when JennCad::Primitives::Cylinder
        prim('cylinder', part)
      when JennCad::Primitives::Sphere
        prim('sphere', part)
      when JennCad::Primitives::Cube
        prim('cube', part)
       when JennCad::Primitives::Circle
        prim('circle', part)
      when JennCad::Primitives::Square
        prim('square', part)
      when JennCad::Primitives::Text
        prim('text', part)
      when JennCad::Primitives::LinearExtrude
        new_obj(part, :linear_extrude, part.openscad_params, parse(part.parts))
      when JennCad::Primitives::RotateExtrude
        new_obj(part, :rotate_extrude, part.openscad_params, parse(part.parts))
      when JennCad::Primitives::Projection
        new_obj(part, :projection, collect_params(part), parse(part.parts))
      when JennCad::Primitives::Polygon
        new_obj(part, :polygon, collect_params(part))
      when JennCad::Primitives::Polyhedron
        new_obj(part, :polyhedron, collect_params(part))
      when JennCad::StlImport
        new_obj(part, :import, collect_params(part))
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
          modifier = part.openscad_modifier || nil
          OpenScadObject.new(cmd, args, children, modifier)
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
      if part.respond_to? :openscad_params
        return part.openscad_params
      end
      res = {}
      [:d, :h, :d1, :d2, :size, :fn, :points, :paths, :faces, :convexity, :file].each do |var|
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
      when JennCad::Scale
        OpenScadObject.new(:scale, t.scale, transform(part, &block))
      when JennCad::Multmatrix
        OpenScadObject.new(:multmatrix, t.m, transform(part, &block))
      else
        puts "unknown transformation #{t}"
      end
    end

    def handle_aggregation(part, tabindex=0)
      register_module(part) unless @modules[part.name]
      $log.debug "aggregation #{part.name} transformations: #{part.transformations.inspect}" if part && part.option(:debug)
      transform(part.clone) do
        new_obj(part, part.name, nil)
      end
    end

    # accept aggregation
    def register_module(part)
      @modules[part.name] = OpenScadObject.new(:module, part.name, parse(part.part))
    end

    def handle_import(part)
      @imports << part.import
      new_obj(part, part.name, part.args)
    end
  end
end
