require 'rubygems'
require 'jenncad'
include JennCad
include JennCad::Extras
Nut = Din934

res = cube([30,30,10]).center_xy
# at this moment, res is a cube
res.color = "Blue"

res += cylinder(d:10,h:20)
# with the += operator, res is now a union boolean object
res.color [120,20,13,200]

# everything added to the union will remain this color
res += cylinder(d:6,h:25)

# unless specified otherwise
res += cylinder(d:5, h:30).color("red")



# subtracting will change res to a subtraction object
res -= cylinder(d:4, h:30)
res += cylinder(d:2, h:40)
res.color("green")



a = OpenScad.new(res)
a.save("examples/test5.scad")
