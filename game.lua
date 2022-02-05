-- This is not a class
-- This modifies stage/game representations provided by main
-- No data is stored here, only methods

local GameOperator = require "gameoperator"
local Game = {}

local stage_size;
local move_queue = {}

function Game.init(_stage_size)
  stage_size = _stage_size
  
  Game.representation = {}
  
  -- Operator placement algorithm goes here
  -- For the time being though...
  Game.set_gameoperator({x = 1, z = 1}, GameOperator:new(1, true, 3, "melee"))
  Game.set_gameoperator({x = 5, z = 2}, GameOperator:new(2, false, 3, "melee"))
  Game.set_gameoperator({x = 3, z = 3}, GameOperator:new(3, true, 3, "melee"))
  Game.set_gameoperator({x = 2, z = 3}, GameOperator:new(4, true, 3, "ranged"))
  Game.set_gameoperator({x = 5, z = 4}, GameOperator:new(5, true, 3, "ranged"))
end

-- For all operators and a slide direction, get start and end game coords
-- Note that this method also returns non-moving operators (e.g. against the end of the stage)
function Game.get_slide_moves(dir)
  local list = {}
  for index, gameoperator in pairs(Game.representation) do
    local coords = Game.index_to_game(index)
    local sign, axis;
    if dir.isn then sign = -1 else sign = 1 end
    if dir.isn ~= dir.ise then main_axis, sub_axis = 'x', 'z' else main_axis, sub_axis = 'z', 'x' end
    
    -- Increment or decrement to stage_size or 0
    local count = 0
    local axis_end = math.max(stage_size * math.max(0, sign), 1)
    -- Re-checking already checked coords is inefficient
    -- But keeping track of already visited coords is also a hassle
    for i = coords[main_axis] + sign, axis_end, sign do
      local check = {}
      check[main_axis], check[sub_axis] = i, coords[sub_axis]
      
      if Game.get_gameoperator(check) then count = count + 1 end
    end
    
    local destination = {}
    destination[main_axis] = axis_end - sign * count
    destination[sub_axis] = coords[sub_axis]
    
    table.insert(list, {
      id = gameoperator.id,
      origin = {x = coords.x, z = coords.z},
      destination = destination})
  end
  
  return list
end

function Game.get_gameoperator(game_coords)
  return Game.representation[Game.game_to_index(game_coords)]
end

function Game.set_gameoperator(game_coords, gameoperator)
  Game.representation[Game.game_to_index(game_coords)] = gameoperator
end

function Game.add_move_queue(game_origin, game_dest)
  local dest_index = Game.game_to_index(game_dest)
  move_queue[dest_index] = Game.get_gameoperator(game_origin)
end

function Game.apply_move_queue()
  local new_representation = {}
  for dest_index, gameoperator in pairs(move_queue) do
    new_representation[dest_index] = gameoperator
  end
  
  -- Overwrite previous representation
  Game.representation = new_representation
  
  -- Clear move_queue
  move_queue = {}
end

-- All because Lua has indices starting at 1...
function Game.game_to_index(game_coords)
  return game_coords.x + (game_coords.z - 1) * stage_size
end

function Game.index_to_game(index)
  return {x = (index - 1) % stage_size + 1, z = math.floor((index - 1) / stage_size) + 1}
end

return Game