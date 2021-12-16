-- This is a class
local SideTile = {}

function SideTile:new (dir, stage_size, stage_elevation, initial_colour)
  -- Class operations done here
  local instance = {colour = initial_colour}
	self.__index = self
	setmetatable(instance, self)

  -- Settings for left/right
  local start
  local finish

  if dir == "n" then
    start = {x = -stage_size, z = -stage_size}
    finish = {x = stage_size, z = -stage_size}
  elseif dir == "s" then
    start = {x = stage_size, z = stage_size}
    finish = {x = -stage_size, z = stage_size}
  elseif dir == "w" then
    start = {x = -stage_size, z = stage_size}
    finish = {x = -stage_size, z = -stage_size}
  elseif dir == "e" then
    start = {x = stage_size, z = -stage_size}
    finish = {x = stage_size, z = stage_size}
  end

  -- Generate vertices
  instance.vertices = {
    {x = start.x, y = stage_elevation, z = start.z},
    {x = start.x, y = 0, z = start.z},
    {x = finish.x, y = 0, z = finish.z},
    {x = finish.x, y = stage_elevation, z = finish.z}
  }

	return instance
end

return SideTile