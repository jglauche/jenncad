require "jenncad/primitives/primitive"
require "jenncad/primitives/aggregation"
require "jenncad/primitives/openscad_include"
require "jenncad/primitives/circle"
require "jenncad/primitives/cylinder"
require "jenncad/primitives/sphere"
require "jenncad/primitives/cube"
require "jenncad/primitives/rounded_cube"
require "jenncad/primitives/polygon"
require "jenncad/primitives/slot"
require "jenncad/primitives/boolean_object"
require "jenncad/primitives/union_object"
require "jenncad/primitives/subtract_object"
require "jenncad/primitives/hull_object"
require "jenncad/primitives/intersection_object"
require "jenncad/primitives/projection"
require "jenncad/primitives/linear_extrude"
require "jenncad/primitives/rotate_extrude"

module JennCad
  include Primitives
end