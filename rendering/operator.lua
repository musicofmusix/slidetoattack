-- This is a class
local SpineLib = require "spinelib"
local Operator = {}

local fade_time = 0.5 -- In seconds

function Operator:new
  (id, spine_name, world_coords, unit_length, default_colour, scale, speed, renderer_callbacks)
  -- Class operations done here
	local instance = {
	  id = id,
	  world_coords = world_coords,
	  renderer_callbacks = renderer_callbacks,
	  colour = default_colour,
	  current_fade_time = 0
	}
	self.__index = self
	setmetatable(instance, self)
  
  local sprite_scale = unit_length * scale
  local spine_skel = SpineLib:new(instance, spine_name, "Idle", sprite_scale, speed)
  spine_skel:set_random_animation_offset()
  
  instance.spine_skel = spine_skel
  
  return instance
end

function Operator:start_fade()
  self.current_fade_time = fade_time
end

function Operator:update_fade(dt)
  if self.current_fade_time > 0 then
    self.current_fade_time = math.max(self.current_fade_time - dt, 0)
    
    self.colour = {
      r = self.colour.r,
      g = self.colour.g,
      b = self.colour.b,
      a = self.current_fade_time / fade_time
    }
    
    if self.current_fade_time == 0 then
      local renderer_callback = self.renderer_callbacks.onFadeEnd
      renderer_callback(self.id)
    end
  end
end

function Operator:onAttack()
  local renderer_callback = self.renderer_callbacks.onHit
  renderer_callback(self.id)
end

function Operator:onComplete(animation_name)
  if animation_name == "Hurt" then
    local renderer_callback = self.renderer_callbacks.onHurtEnd
    renderer_callback(self.id)
  elseif animation_name == "Attack" then
    local renderer_callback = self.renderer_callbacks.onAttackEnd
    renderer_callback(self.id)
  elseif animation_name == "Die" then
    local renderer_callback = self.renderer_callbacks.onDieEnd
    renderer_callback(self.id)
  end
end

return Operator