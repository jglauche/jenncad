
# jenncad
Create physical objects in Ruby, OpenScad export

This is a successor to my older project CrystalScad. 

# Installation

A packaged release is not yet available, please build your own package in the meantime:

    $ git clone git@github.com:jglauche/jenncad.git
    $ cd jenncad
    $ rake install

This will create a gem and a binary jenncad. 

# Using Jenncad

**To create a new project directory, run:**

    $ jenncad create meow
   



This will generate a directory meow/ and an executable ruby file meow.rb in its directory

    $ cd meow
    $ ./meow

This will generate a dummy project which generates a dummy cube as  OpenSCAD output:

    $ cat output/meow.scad 
> $fn=64;
> translate([-5, -5, 0])cube([10, 10, 10.0]);

**Automatically refresh OpenSCAD output while developing**

Jenncad bundles the observr gem which will check if files were changed while developing. In the project directory run:

    $ jenncad
This should display something like:
> refreshing... 
> ok 
> JennCad running, refreshing on file changes. Press ctrl+c to exit

**Note:** This does not check for new files in the project. You will have to restart it when you create a new part in a new file

**Create new part**

In your project directory, run:

    $ jenncad new cat
    part parts/cat.rb created. In your meow.rb add to class Meow:
    def cat
      Cat.new(config)
    end


You will have to link the part to the project manually into the meow.rb file in your project directory. When you add it, your meow.rb should look like this:

    #!/usr/bin/env ruby
    require "jenncad"
    include JennCad
    
    class Meow < Project
      def config
        {}
      end
    
      def meow
        cube(10,10,10)
      end
    
      def cat
        Cat.new(config)
      end
    
    end
    Meow.new.run

 

