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
      when :head
        res = "$fn=64;"+nl
        @children.each do |c|
          res += c.to_s+nl
        end
        res
      when String
        handle_command
      else
      end
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
        res.join(",")
      else
        ""
      end
    end

  end

  class OpenScad
    include ActiveSupport::Inflector
    def initialize(part)
      @object_tree = OpenScadObject.new(:head, nil, parse(part))
      @modules = {}
    end

    def save(file)
      File.open(file,"w") do |f|
        puts @modules.inspect
        @modules.each do |key, val|
          f.puts val.to_s
        end
        f.puts @object_tree.to_s
      end
    end


    def parse(part)
      case part
      when Array
        part.map{ |p| parse(p) }
      when JennCad::OpenScadImport
        # handle_import(part)
      when JennCad::Aggregation
        handle_aggregation(part)
      when JennCad::UnionObject
        bool('union', part)
      when JennCad::SubtractObject
        part.analyze_z_fighting
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
        # FIXME handle_cube(part)
      when JennCad::Primitives::LinearExtrude
        OpenScadObject.new(:linear_extrude, part.openscad_params, part.parts)
      when JennCad::Primitives::RotateExtrude
        OpenScadObject.new(:rotate_extrude, part.openscad_params, part.parts)
      when JennCad::Primitives::Projection
        OpenScadObject.new(:projection, collect_params(part), part.parts)
      when JennCad::Primitives::Polygon
        OpenScadObject.new(:polygon, collect_params(part), part.parts)
      else
      end
    end

    def bool(type, part)
      transform(part) do
        OpenScadObject.new(type, nil, parse(part.parts))
      end
    end

    def prim(type, part)
      transform(part) do
        OpenScadObject.new(type, collect_params(part))
      end
    end

    def collect_params(part)
      res = {}
      [:d, :h, :d1, :d2, :size, :fn, :points].each do |var|
        if part.respond_to? var
          res[var] = part.send var
        end
      end
      res
    end

    def transform(part, &block)
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
      OpenScadObject.new(part.name, nil)
    end

    # accept aggregation
    def register_module(part)
      @modules[part.name] = OpenScadObject.new(:module, nil, part.part)
    end

    # not used yet
    def make_openscad_compatible!(item)
      if item.respond_to?(:parts) && item.parts != nil
        item.parts.each_with_index do |part, i|
          if part.respond_to? :to_openscaditem.parts[i] = part.to_openscad
          else
            item.parts[i] = part.make_openscad_compatible
          end
        end
      elsif item.respond_to? :part
        item = item.part.make_openscad_compatible
      end
      if item.respond_to? :to_openscad
        item = item.to_openscad
      end
      item
    end

  end
end
