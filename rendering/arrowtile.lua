-- This is a class
local ArrowTile = {}

function ArrowTile:new(id, is_friendly, initial_origin)
  -- Class operations done here
  local instance = {id = id, is_friendly = is_friendly}
	self.__index = self
	setmetatable(instance, self)

  -- These are world coordinates; y is ommited as it's added later
  instance.origin = initial_origin
  instance.dest = initial_origin
  instance.progress = 0
  instance.depth = 0
  -- Looks identical to a regular stage Tile
  instance.default_vertices = {
    {x = instance.origin.x + 1, y = 0, z = instance.origin.z - 1},
    {x = instance.origin.x - 1, y = 0, z = instance.origin.z - 1},
    {x = instance.origin.x - 1, y = 0, z = instance.origin.z + 1},
    {x = instance.origin.x + 1, y = 0, z = instance.origin.z + 1}
  }
  
  instance.vertices = instance:generate_vertices()
  
	return instance
end

-- Use self.origin, dest, and progress to generate vertices
function ArrowTile:generate_vertices()
  if self.origin.x == self.dest.x and self.origin.z == self.dest.z then
    return self.default_vertices
  end
  
  local sign = {
    x = math.sign(self.dest.x - self.origin.x),
    z = math.sign(self.dest.z - self.origin.z)
  }

  local offset = {
    x = (self.dest.x - self.origin.x) * self.progress,
    z = (self.dest.z - self.origin.z) * self.progress
  }
  
  local offset_magnitude = math.abs(offset.x + offset.z)
  
  -- When the centre of the operator is within the bounds of the tile
  if offset_magnitude < 1 then return self.default_vertices end
  
  -- The tip shares same coordinates with operator
  local tip = {
      x = self.origin.x + offset.x,
      y = 0,
      z = self.origin.z + offset.z
    }
  
  local fix1 = {
    x = self.origin.x - sign.x + sign.z,
    y = 0,
    z = self.origin.z - sign.z + sign.x
  }
  
  local fix2 = {
    x = self.origin.x - sign.x - sign.z,
    y = 0,
    z = self.origin.z - sign.z - sign.x
  }
  
  -- Draw a house-shaped pentagon, but the tip is not 90 degrees
  if offset_magnitude < 2 then
    local fix3 = {
      x = self.origin.x + sign.x + sign.z,
      y = 0,
      z = self.origin.z + sign.z + sign.x
    }
    
    local fix4 = {
      x = self.origin.x + sign.x - sign.z,
      y = 0,
      z = self.origin.z + sign.z - sign.x
    }
    
    local move1 = {
      x = self.origin.x + sign.x + (offset.z - sign.z),
      y = 0,
      z = self.origin.z + sign.z + (offset.x - sign.x)
    }
      
    local move2 = {
      x = self.origin.x + sign.x - (offset.z - sign.z),
      y = 0,
      z = self.origin.z + sign.z - (offset.x - sign.x)
    }
    
    return {tip, move1, fix3, fix1, fix2, fix4, move2}
  end
  
  -- Draw a house-shaped pentagon with a tip of 90 degrees
  local move1 = {
    x = fix1.x + offset.x,
    y = 0,
    z = fix1.z + offset.z
  }
  local move2 = {
    x = fix2.x + offset.x,
    y = 0,
    z = fix2.z + offset.z
  }
  
  return {tip, move1, fix1, fix2, move2}
end

function math.sign(x)
   if x < 0 then return -1
   elseif x > 0 then return 1
   else return 0
   end
end

return ArrowTile