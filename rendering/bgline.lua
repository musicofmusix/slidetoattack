-- This is a class
local BGline = {}

function BGline:new (x1, z1, x2, z2, stage_elevation)
  -- Class operations done here
  local instance = {}
	self.__index = self
	setmetatable(instance, self)

  -- Generate world-coord vertices
  instance.vertices = {
    {x = x1, y = stage_elevation, z = z1},
    {x = x2, y = stage_elevation, z = z2}}

	return instance
end

return BGline