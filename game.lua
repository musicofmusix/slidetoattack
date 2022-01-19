-- This is not a class
-- This modifies stage/game representations provided by main
-- No data is stored here, only methods

local GameOperator = require "gameoperator"
local Game = {}

Game.representation = {}

function Game.init(stage_size)
  for i = 1, stage_size do
    Game.representation[i] = {}
  end
  
  -- Operator placement algorithm goes here
  -- For the time being though...
  Game.representation[1][1] = GameOperator:new(1, true, 3, "melee")
  Game.representation[5][4] = GameOperator:new(2, true, 3, "ranged")
  Game.representation[1][2] = GameOperator:new(3, false, 3, "melee")
  Game.representation[5][3] = GameOperator:new(4, false, 3, "melee")
end

return Game