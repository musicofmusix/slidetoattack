-- This is a class
local SpineLib = require "spinelib"
local Operator = {}

function Operator:new(spinename, is_friendly)
  local spineskel = SpineLib:new("assets/" .. spinename, "pseudo_setup_pose", 0.5, false)

  local instance = {spineskel = spineskel, is_friendly = is_friendly}
  return instance
end

return Operator