-- This is a class
local SpineLib = require "spinelib"
local Operator = {}

function Operator:new(spine_name, world_coords)
  local spine_skel = SpineLib:new(spine_name, "Idle", 0.24, false)
  
  -- Class operations done here
	local instance = {spine_skel = spine_skel, world_coords = world_coords}
	self.__index = self
	setmetatable(instance, self)
	
  return instance
end

return Operator