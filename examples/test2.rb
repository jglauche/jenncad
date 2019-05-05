require 'jenncad'
include JennCad

res = import("involute_gears","bevel_gear",number_of_teeth:13, bore_diameter:10)
res += import("involute_gears","bevel_gear",number_of_teeth:6, bore_diameter:5).rotate(x:90).translate(y:50,z:30)


a = OpenScad.new(res)
a.save("examples/test2.scad")
