module JennCad
  class Project

    def output_dir
      "output"
    end

    def outputs
      self.class.instance_methods(false) - [:config, :outputs, :output_dir]
    end

    def profile_dir
      File.expand_path(["~", ".config", "jenncad"].join("/"))
    end

    def profile_path
      [profile_dir, "profile.rb"].join("/")
    end

    def load_profile
      if File.exists?(profile_path)
        require profile_path
      end
    end

    def run
      load_profile
      # load all files in subdirectories
      Dir.glob("*/**/*.rb").each do |file|
        require "./#{file}"
      end
      FileUtils.mkdir_p(output_dir)
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
