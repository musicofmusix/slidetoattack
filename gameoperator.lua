-- This is a class
-- A game logic version of the operator class; stores info used for gameplay

local GameOperator = {}

function GameOperator:new(id, is_friendly)
  -- Class operations done here
	local instance = {
    id = id,
    is_friendly = is_friendly,
  }
	self.__index = self
	setmetatable(instance, self)
  
  return instance
end

return GameOperator