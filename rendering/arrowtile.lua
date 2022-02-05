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
  instance.vertices = instance:generate_vertices()
  
	return instance
end

local function generate_default(centre)
  return {
    {x = centre.x + 1, y = 0, z = centre.z - 1},
    {x = centre.x - 1, y = 0, z = centre.z - 1},
    {x = centre.x - 1, y = 0, z = centre.z + 1},
    {x = centre.x + 1, y = 0, z = centre.z + 1}
  }
end

-- Use self.origin, dest, and progress to generate vertices
function ArrowTile:generate_vertices(is_retraction)
  if self.origin.x == self.dest.x and self.origin.z == self.dest.z then
    return generate_default(self.origin)
  end
  
  local sign = {
    x = math.sign(self.dest.x - self.origin.x),
    z = math.sign(self.dest.z - self.origin.z)
  }
  
  -- Vertices during slide, not retraction
  if not is_retraction then
    local offset = {
      x = (self.dest.x - self.origin.x) * self.progress,
      z = (self.dest.z - self.origin.z) * self.progress
    }
    
    local offset_magnitude = math.abs(offset.x + offset.z)
    
    -- When the centre of the operator is within the bounds of the tile
    if offset_magnitude < 1 then return generate_default(self.origin) end
    
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
  
  -- ArrowTile retraction
  else
    local offset = {
      x = (self.dest.x - self.origin.x) * (1 - self.progress),
      z = (self.dest.z - self.origin.z) * (1 - self.progress)
    }
    
    local tail_start = {
      x = self.origin.x - sign.x,
      z = self.origin.z - sign.z
    }
    local tail1 = {
      x = tail_start.x + offset.x + sign.z,
      y = 0,
      z = tail_start.z + offset.z + sign.x
    }
    local tail2 = {
      x = tail_start.x + offset.x - sign.z,
      y = 0,
      z = tail_start.z + offset.z - sign.x
    }
    
   local head_start = {
     x = self.dest.x - sign.x,
     z = self.dest.z - sign.z
   }
   local head_offset = {
     x = (1 - self.progress) * 2 * sign.x,
     z = (1 - self.progress) * 2 * sign.z
   }
   local head1 = {
     x = head_start.x + head_offset.x + sign.z,
     y = 0,
     z = head_start.z + head_offset.z + sign.x
   }
   local head2 = {
     x = head_start.x + head_offset.x - sign.z,
     y = 0,
     z = head_start.z + head_offset.z - sign.x
   }
   
   local head_offset_magnitude = math.abs(head_offset.x + head_offset.z)
   if head_offset_magnitude < 1 then
     local head_tip = {
       x = self.dest.x + head_offset.x,
       y = 0,
       z = self.dest.z + head_offset.z
     }
     
     return {head_tip, head1, tail1, tail2, head2}
   end
   
  if head_offset_magnitude < 2 then
    local head_tip1 = {
      x = self.dest.x + sign.x + head_offset.z - sign.z,
      y = 0,
      z = self.dest.z + sign.z + head_offset.x - sign.x
    }
    local head_tip2 = {
      x = self.dest.x + sign.x - head_offset.z + sign.z,
      y = 0,
      z = self.dest.z + sign.z - head_offset.x + sign.x
    }
    
    return {head_tip1, head1, tail1, tail2, head2, head_tip2}
  end
  
  return generate_default(self.dest)
  end
end

function math.sign(x)
   if x < 0 then return -1
   elseif x > 0 then return 1
   else return 0
   end
end

return ArrowTile