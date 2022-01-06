-- This is a class
local SideTile = {}

-- Minimum coefficient value
local coefficient_min = 0.3

function SideTile:new(dir, stage_size, stage_elevation, initial_colour)
  -- Class operations done here
  local instance = {base_colour = initial_colour}
	self.__index = self
	setmetatable(instance, self)

  -- Settings for left/right
  local start
  local finish
  local angle_offset

  if dir == "n" then
    start = {x = -stage_size, z = -stage_size}
    finish = {x = stage_size, z = -stage_size}
    angle_offset = 270
  elseif dir == "s" then
    start = {x = stage_size, z = stage_size}
    finish = {x = -stage_size, z = stage_size}
    angle_offset = 90
  elseif dir == "w" then
    start = {x = -stage_size, z = stage_size}
    finish = {x = -stage_size, z = -stage_size}
    angle_offset = 180
  elseif dir == "e" then
    start = {x = stage_size, z = -stage_size}
    finish = {x = stage_size, z = stage_size}
    angle_offset = 0
  end

  -- Generate world-coord vertices
  instance.vertices = {
    {x = start.x, y = stage_elevation, z = start.z},
    {x = start.x, y = 0, z = start.z},
    {x = finish.x, y = 0, z = finish.z},
    {x = finish.x, y = stage_elevation, z = finish.z}
  }

  instance.angle_offset = angle_offset

	return instance
end

function SideTile:generate_colour(angle, light_angle)
  local pointing_angle = (angle + self.angle_offset) % 360
  local diff = math.abs(pointing_angle - light_angle)
  local small_diff = math.min(diff, 360 - diff)

  local coeff = (90 - small_diff) / 90 * (1 - coefficient_min) + coefficient_min

  return {r = self.base_colour.r * coeff,
          g = self.base_colour.g * coeff,
          b = self.base_colour.b * coeff}
end

return SideTile