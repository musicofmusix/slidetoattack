-- This is a class
local SpineLib = require "spinelib"
local Operator = {}

function Operator:new(spine_name, world_coords, unit_length)
  local sprite_scale = unit_length * 0.00615 -- A result of experimentation
  local spine_skel = SpineLib:new(spine_name, "Idle", sprite_scale, false)
  
  -- Class operations done here
	local instance = {spine_skel = spine_skel, world_coords = world_coords}
	self.__index = self
	setmetatable(instance, self)
	
  return instance
end

return Operator