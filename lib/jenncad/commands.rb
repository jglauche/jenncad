require "dry/cli"
module JennCad
  module Commands
    extend Dry::CLI::Registry
    MAGIC = "jenncad-append-project-magic"

    class Run < Dry::CLI::Command
      argument :name, required: false

      def guess_executable(dir=Dir.pwd)
        dir.split("/").last.to_s + ".rb"
      end

      def check_executable(file)
        return true if File.exists?(file)
        # this is not too smart at the moment
        puts "cannot find executable #{file}"
        nil
      end

      def observe(exec)
        execute(exec)
        script = Observr::Script.new
        Dir.glob("**/**.rb").each do |file|
          script.watch(file) do
            execute(exec)
          end
        end
        contr = Observr::Controller.new(script, Observr.handler.new)
        puts "JennCad running, refreshing on file changes. Press ctrl+c to exit"
        contr.run
      end

      def execute(file)
        print "refreshing..."
        r = system("./#{file}")
        case r
        when true
          $jenncad_profile.on_success(file)
        when false
          $jenncad_profile.on_error(file)
        end
      end

      def build
        admesh_installed = system("admesh --version > /dev/null")
        unless admesh_installed
          puts "Warning: cannot find admesh, stl export will be in ASCII"
        end

        Dir.glob("output/**/*.scad").each do |file|
          stl = file.gsub(".scad",".stl")
          build_stl(file, stl)
          convert_to_binary(stl) if admesh_installed
        end
      end

      def build_stl(scad, stl)
        puts "building #{stl}"
        system("openscad #{scad} -o #{stl}")
      end

      def convert_to_binary(stl)
        system("admesh #{stl} -b #{stl}")
      end

    end

    class Build < Run
      def call(name: nil, **)
        unless name
          name = guess_executable
        end
        if check_executable(name)
          execute(name)
          build
        end
      end
    end

    class Observe < Run
      def call(name: nil, **)
        unless name
          name = guess_executable
        end
        if check_executable(name)
          observe(name)
        end
      end
    end

    class NewPart < Dry::CLI::Command
      include ActiveSupport::Inflector
      desc "creates a new part in a project"
      argument :name, required: true
      def call(name:, **)
        dir = Dir.pwd.split("/").last
        executable = underscore(dir)+".rb"
        executable_class = camelize(dir)
        unless File.exists?(executable)
          puts "Could not find #{executable}. Are you in a JennCad project directory?"
          exit
        end
        FileUtils.mkdir_p("parts")
        name = underscore(name)
        classname = camelize(name)
        filename = "parts/#{name}.rb"
        if File.exists?(filename)
          puts "File #{filename} already exists."
          exit
        end
        File.open(filename, "w") do |f|
          f.puts "class #{classname} < Part"
          f.puts "  def initialize(opts={})"
          f.puts "    @opts = {"
          f.puts "      x: 10,"
          f.puts "      y: 10,"
          f.puts "      z: 5,"
          f.puts "    }.merge(opts)"
          f.puts "  end"
          f.puts ""
          f.puts "  def part"
          f.puts "    cube(@opts)"
          f.puts "  end"
          f.puts "end"
        end

        lines  = File.readlines(executable)
        magic_line = nil;
        lines.each_with_index do |l, i|
          if l.rindex(MAGIC)
            magic_line = i
          end
        end
        puts "part #{filename} created."
        if !magic_line
          puts "In your #{executable} add to class #{executable_class}:"
          puts "  def #{name}"
          puts "    #{classname}.new(config)"
          puts "  end"
          puts ""
          puts "For jenncad to insert this line automatically, add this line to your project file before the \"end\"-statement of your class:"
          puts "##{MAGIC}"
        else
          data  = "\n"
          data += "  def #{name}\n"
          data += "    #{classname}.new(config)\n"
          data += "  end\n"
          lines.insert(magic_line, data)
          f = File.open(executable, "w")
          f.write(lines.join)
          f.close
        end


      end

    end

    class NewProject < Dry::CLI::Command
      include ActiveSupport::Inflector
      desc "generates a new project"
      argument :name, required: true

      def call(name:, **)
        name = underscore(name)
        filename = name+".rb"
        Dir.mkdir(name)
        Dir.chdir(name)
        classname = camelize(name)
        File.open(filename, "w") do |f|
          f.puts "#!/usr/bin/env ruby"
          f.puts "require \"jenncad\""
          f.puts "include JennCad"
          f.puts ""
          f.puts "class #{classname} < Project"
          f.puts "  def config"
          f.puts "    {}"
          f.puts "  end"
          f.puts ""
          f.puts "  # #{MAGIC}"
          f.puts "end"
          f.puts ""
          f.puts "#{classname}.new.run"
        end
        File.chmod(0755, filename)

        puts "created new project #{name}"
      end
    end

  end
end
