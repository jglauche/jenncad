require 'rubygems'
require 'jenncad'
include JennCad
include JennCad::Extras
Nut = Din934

res = cylinder(d:40,h:20)
res &= cylinder(d:40,h:20).translate(x:20)
res &= cube([20,20,20]).translate(y:20)

res.skew(y:-0.3)


a = OpenScad.new(res)
a.save("examples/test3.scad")
