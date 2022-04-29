require "logger"
$log = Logger.new(STDOUT)

require "geo3d"
require "deep_merge"
require "fileutils"
require "observr"
require "hanami/cli"
require "active_support"

include Math
include Geo3d

require "jenncad/version"
require "jenncad/default_profile"
require "jenncad/profile_loader"
JennCad::ProfileLoader.new


require "jenncad/patches/array"
require "jenncad/thing"
require "jenncad/part"
require "jenncad/project"
require "jenncad/commands"

require "jenncad/features"
require "jenncad/primitives"


require "jenncad/transformation/transformation"
require "jenncad/transformation/move"
require "jenncad/transformation/rotate"
require "jenncad/transformation/scale"
require "jenncad/transformation/mirror"
require "jenncad/transformation/color"
require "jenncad/transformation/multmatrix"


# TODO: extras need be split from the package to external hardware lib
require "jenncad/extras/hardware"
require "jenncad/extras/din912"
require "jenncad/extras/din933"
require "jenncad/extras/din934"
require "jenncad/extras/iso7380"



require "jenncad/register"
require "jenncad/shortcuts"
require "jenncad/exporters/openscad"

