module JennCad
  class Project

    def output_dir
      "output"
    end

    def outputs
      self.class.instance_methods(false) - [:config, :outputs, :output_dir]
    end

    def run(&block)
      # load all files in subdirectories
      Dir.glob("*/**/*.rb").each do |file|
        require "./#{file}"
      end
      base_dir = Dir.pwd
      # check if output directories exist
      output_dir.split("/").each do |dir|
        Dir.mkdir(dir) unless Dir.exists?(dir)
        Dir.chdir(dir)
      end
      Dir.chdir(base_dir)
      run_exports
    end

    def run_exports
      outputs.each do |name|
        part = self.send(name)
        part.openscad([output_dir,"#{name}.scad"].join("/"))
      end
    end

  end
end
