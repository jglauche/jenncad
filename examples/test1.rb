require 'rubygems'
require 'jenncad'
include JennCad
include JennCad::Extras
Nut = Din934

h1 = 10
h2 = 20
res = cube([10,20,h1]).center_xy
res += cylinder(d:40,h:h2).move(z:h1)
#res -= cylinder(d:10,h:5)
#res -= cylinder(d:10,h:5).translate(z:15)


n = Nut.new(4)
res -= n.cut

n = Nut.new(4)
res -= n.cut.translate(z:h1+h2-n.height)



a = OpenScad.new(res)
a.save("examples/test1.scad")
