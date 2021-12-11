-- This is a class
local Tile = {}

function Tile:new (centre, initial_colour)
  -- Class operations done here
  local instance = {centre = centre, colour = initial_colour}
	self.__index = self
	setmetatable(instance, self)

  -- Generate vertices
  instance.vertices = {
    {x = centre.x - 1, y = 0, z = centre.z + 1},
    {x = centre.x - 1, y = 0, z = centre.z - 1},
    {x = centre.x + 1, y = 0, z = centre.z - 1},
    {x = centre.x + 1, y = 0, z = centre.z + 1}}

	return instance
end

return Tile