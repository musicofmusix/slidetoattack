-- This is a class
local SpineLib = require "spinelib"
local Operator = {}

function Operator:new(id, spine_name, world_coords, unit_length, renderer_callbacks)
  -- Class operations done here
	local instance = {id = id, world_coords = world_coords, renderer_callbacks = renderer_callbacks}
	self.__index = self
	setmetatable(instance, self)
  
  local sprite_scale = unit_length * 0.00615 -- A result of experimentation
  local spine_skel = SpineLib:new(instance, spine_name, "Idle", sprite_scale)
  
  instance.spine_skel = spine_skel
  
  return instance
end

function Operator:onAttack()
  local renderer_callback = self.renderer_callbacks.onHit
  renderer_callback(self.id)
end

function Operator:onComplete(animation_name)
  if animation_name == "Attack" then
    local renderer_callback = self.renderer_callbacks.onAttackEnd
    renderer_callback(self.id)
  elseif animation_name == "Die" then
    local renderer_callback = self.renderer_callbacks.onDieEnd
    renderer_callback(self.id)
  end
end

return Operator