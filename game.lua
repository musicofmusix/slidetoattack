-- This is not a class
-- This modifies stage/game representations provided by main.
-- No data is stored here, only methods.

local GameOperator = require "gameoperator"
local Game = {}

function Game.init(stage_size)
  local representation = {}
  
  -- Operator placement algorithm goes here.
  -- For the time being though...
  representation[1] = GameOperator:new(1, true, 3, "melee")
  representation[24] = GameOperator:new(2, true, 3, "ranged")
  representation[7] = GameOperator:new(3, false, 3, "melee")
  representation[23] = GameOperator:new(4, false, 3, "melee")
  
  return representation
end

return Game