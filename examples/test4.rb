require 'rubygems'
require 'jenncad'
include JennCad
include JennCad::Extras
Nut = Din934

res = cube([30,30,10]).center_xy

cyl = cylinder(d:10,h:5).translate(z:5)
res -= cyl

puts cyl.calc_z+cyl.calc_h


a = OpenScad.new(res)
a.save("examples/test4.scad")
