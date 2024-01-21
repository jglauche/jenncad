module JennCad
  class ProfileLoader
    def initialize
      load_profile
    end

    def profile_dir
      File.expand_path(["~", ".config", "jenncad"].join("/"))
    end

    def profile_path
      [profile_dir, "profile.rb"].join("/")
    end

    def load_profile
      if File.exist?(profile_path)
        require profile_path
        check_profile
      else
        load_defaults
      end
    end

    def check_profile
      unless defined?($jenncad_profile)
        load_defaults
      end
    end

    def load_defaults
      $jenncad_profile = JennCad::DefaultProfile.new
    end
  end
end
