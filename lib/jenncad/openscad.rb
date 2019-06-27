module JennCad

  class OpenScad
    def initialize(part, fn=64)
      @imports = []
      @modules = {}
      part = part.make_openscad_compatible
      @main = root(part, "$fn=#{fn};\n")

      @export = ""
      @imports.uniq.each do |val|
        @export += "use <#{val}.scad>\n"
      end
      @modules.each do |key, val|
        @export += val
      end
      @export += @main
    end

    def save(file)
      File.open(file,"w") do |f|
        f.puts @export
      end
    end

    def root(part, head="", tabindex=0)
      res = head

      res += transform(part) do
        parse(part, tabindex)
      end
      res
    end

    def transform(part, &block)
      res += handle_color(part)
      if part.transformations
        part.transformations.reverse.each do |trans|
          res += transformation(trans)
        end
      end
      res += block.yield
    end

    def print_tree(part, level=0)
      arr = []
      arr << parse(part) unless level == 0
      if part.respond_to?(:parts)
        part.parts.each do |p|
          arr << print_tree(p,level+1)
        end
      end
      arr
    end


    def parse(part, tabindex=0)
      case part
      when JennCad::OpenScadImport
        handle_import(part)
      when JennCad::Aggregation
        handle_aggregation(part)
      when JennCad::UnionObject
        cmd('union', nil, part.parts, tabindex)
      when JennCad::SubtractObject
        part.analyze_z_fighting
        cmd('difference', nil, part.parts, tabindex)
      when JennCad::IntersectionObject
        cmd('intersection', nil, part.parts, tabindex)
      when JennCad::HullObject
        cmd('hull', nil, part.parts, tabindex)
      when JennCad::Primitives::Circle
        cmd('circle', collect_params(part), nil, tabindex)
      when JennCad::Primitives::Cylinder
        cmd('cylinder', collect_params(part), nil, tabindex)
      when JennCad::Primitives::Sphere
        cmd('sphere', collect_params(part), nil, tabindex)
      when JennCad::Primitives::Cube
        handle_cube(part, tabindex)
      when JennCad::Primitives::LinearExtrude
        cmd('linear_extrude', part.openscad_params, part.parts, tabindex)
      when JennCad::Primitives::RotateExtrude
        cmd('rotate_extrude', part.openscad_params, part.parts, tabindex)
      when JennCad::Primitives::Projection
        cmd('projection', collect_params(part), part.parts, tabindex)
      when JennCad::Primitives::Polygon
        cmd('polygon', collect_params(part), nil, tabindex)
      else
        if part.respond_to?(:parts) && part.parts != nil && !part.parts.empty?
          res = ""
          part.parts.each do |p|
              res += root(p, "", tabindex)
            end
          return res
        elsif part.respond_to?(:part)
          return root(part.part, "", tabindex)
        end
        puts "no idea what to do with #{part.inspect}"
        return ""
      end
    end

    def fmt_params(args)
      case args
      when String, Symbol
        return "\"#{args}\""
      when Array
        return args.map do |l|
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
        args.each do |k,v|
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

    def cmd(name, args, items, tabindex = 0)
      items ||= []
      res = cmd_call(name,args)
      case items.size
      when 1
        item = items.first
        res << transform(item) do
          parse(item, tabindex)
        end
        res << ";\n"
      when (1..)
        res << "\n"
        res << tabs(tabindex) { "{\n" }
        items.each do |item|
          res << tabs(tabindex+1) do
            transform(item) do
              parse(item, tabindex+1)
            end
          end
        end
        res << tabs(tabindex) { "}\n" }
      else
        res << ";\n"
      end
      return res
    end

    def tabs(i, &block)
      "  " * i + block.yield
    end

    def handle_import(part, tabindex=0)
      @imports << part.import
      return tabs(tabindex){ "#{part.name}(#{fmt_params(part.args)});\n" }
    end

    def handle_aggregation(part, tabindex=0)
      register_module(part) unless @modules[part.name]
      use_module(part.name, tabindex)
    end

    # check children for color values
      # if none of the children has a color value, we can apply color to this object and all children
    # if any of the children (excluding children of the kind of BooleanObject) has a color value (that is different from ours), we will apply a fallback color to all children that do not have a color value themselves.

    def handle_color(part)
      if part && part.respond_to?(:color) && part.color
        if part.respond_to?(:parts)
          if part.children_list(JennCad::Aggregation).map{|l| l.color != nil && l.color != part.color}.include?(true)
            part.children_list(JennCad::Aggregation).each do |child|
              if child.color == nil && child.color != part.color && !child.kind_of?(BooleanObject)
                child.set_option :fallback_color, part.color
              end
            end
            return ""
          end
        end
      end
      return apply_color(part)
    end

    def apply_color(part)
      case part
      when Thing
        cmd_call_unless_nil("color", part.color_or_fallback)
      else
        ""
      end
    end

    def register_module(part)
      # can only accept aggregation
      @modules[part.name] = "module #{part.name}(){\n"
      @modules[part.name] += root(part.part)
      @modules[part.name] += "}\n"
    end

    def use_module(name, tabindex)
      tabs(tabindex){ cmd_call(name, nil).to_s+";" }
    end

    def cmd_call_unless_nil(name,args)
      args.nil? ? "" : cmd_call(name, args)
    end

    def cmd_call(name, args)
      args = fmt_params(args)
      return "#{name}(#{args})"
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

    def transformation(trans)
      case trans
      when JennCad::Move
        cmd_call("translate",trans.coordinates)
      when JennCad::Rotate
        cmd_call("rotate",trans.coordinates)
      when JennCad::Mirror
        cmd_call("mirror",trans.coordinates)
      when JennCad::Multmatrix
        cmd_call("multmatrix",trans.m)
      else
        puts "[openscad exporter] Unkown transformation #{trans.class}"
        ""
      end
    end

    # cubes are now centered in xy by default in jenncad
    # TODO: should this not be to_openscad in Cube?
    def handle_cube(part, tabindex)
      res = ""
      if part.option(:center)
        res += transformation(Move.new(x: -part.x/2.0, y: -part.y/2.0))
      else
        if part.option(:center_x)
          res += transformation(Move.new(x: -part.x/2.0))
        end
        if part.option(:center_y)
          res += transformation(Move.new(y: -part.y/2.0))
        end
        if part.option(:center_z)
          res += transformation(Move.new(z: -part.z/2.0))
        end
      end

      res += cmd('cube', collect_params(part), nil)
    end

  end
end
