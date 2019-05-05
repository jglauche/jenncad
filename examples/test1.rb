require 'rubygems'
require 'jenncad'
include JennCad
include JennCad::Extras
Nut = Din934

res = cylinder(d:40,h:20)

n = Nut.new(4)
res -= n.cut

n = Nut.new(4)
res -= n.cut.translate(x:20)
res += n.show.translate(x:20)



a = OpenScad.new(res)
a.save("examples/test1.scad")
