require 'rubygems'
require 'jenncad'
include JennCad

res = cube(30,30,10)

res -= slot(d:10, x:20, a:30).move(x:5)
res -= slot(d:10, x:20, a:-30).move(x:5)

res.openscad("slot.scad")
