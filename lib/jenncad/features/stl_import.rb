module JennCad::Features
  class StlImport < Feature
    attr_accessor :file, :args

    def initialize(file, args={})
      @file = file
      @args = args
    end
  end
end
