module JennCad
  class Project
    def output_dir
      "output"
    end

    def outputs
      self.class.instance_methods(false) - [:config, :outputs, :output_dir]
    end

    def run
      # load all files in subdirectories
      Dir.glob("*/**/*.rb").each do |file|
        require "./#{file}"
      end
      FileUtils.mkdir_p(output_dir)
      run_exports
    end

    def run_export!(part, file)
      part.openscad([output_dir,file].join("/"))
    end

    def run_exports
      outputs.each do |name|
        part = self.send(name)
        run_export!(part, "#{name}.scad")
        if part.respond_to? :print
          part = self.send(name).print
          run_export!(part, "#{name}_print.scad")
        end
      end
    end

  end
end
