require "geo3d"
require "deep_merge"
require "fileutils"
require "observr"
require "hanami/cli"
require "active_support"

include Math
include Geo3d

Colors = %w(
  Teal
  DarkOliveGreen
  Aquamarine
  SteelBlue
  LightCoral
  OrangeRed
  MediumVioletRed
  DarkOrchid
  HotPink
)


require "jenncad/patches/array"
require "jenncad/version"
require "jenncad/thing"
require "jenncad/part"
require "jenncad/project"
require "jenncad/commands"

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





require "jenncad/transformation/transformation"
require "jenncad/transformation/move"
require "jenncad/transformation/rotate"
require "jenncad/transformation/scale"
require "jenncad/transformation/mirror"
require "jenncad/transformation/color"
require "jenncad/transformation/multmatrix"





require "jenncad/extras/hardware"
require "jenncad/extras/din912"
require "jenncad/extras/din933"
require "jenncad/extras/din934"
require "jenncad/extras/iso7380"




require "jenncad/register"
require "jenncad/shortcuts"
require "jenncad/jenncad"
require "jenncad/openscad"
