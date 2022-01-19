-- This is a class
-- A game logic version of the operator class; stores info used for gameplay

local GameOperator = {}

function GameOperator:new(id, is_friendly, hp, class)
  -- Class operations done here
	local instance = {
    id = id,
    is_friendly = is_friendly,
    hp = hp,
    class = class
  }
	self.__index = self
	setmetatable(instance, self)
  
  return instance
end

return GameOperator