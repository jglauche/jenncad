require 'rubygems'
require 'jenncad'
include JennCad

# cubes are centered in x,y and flat to z=0 by default
res = cube(40,30,20)
# if symbols are omitted first argument of cylinder is d (diameter), second is height
# if height is omitted, it will assume height of first suitable parent object. This only works for z direction
# if height is omitted, it will also reward you with automatic z-fighting. For other cuts it'll try to do the same but is not so smart
res -= cylinder(5)

res.openscad("cube.scad")
