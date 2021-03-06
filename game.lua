-- This is not a class
-- This modifies stage/game representations provided by main
-- No data is stored here, only methods

local GameOperator = require "gameoperator"
local Game = {}

local stage_size;
local move_queue = {}

function Game.init(_stage_size, number_of_friendlies, number_of_enemies)
  stage_size = _stage_size
  
  Game.representation = {}
  
  local friendly_rep = {}
  local enemy_rep = {}
  
  for i = 1, stage_size do
    for j = 1, stage_size do
      -- Alternating friendlies and enemies; checkerboard style
      -- First tile/operator is friendly
      local is_friendly = (i % 2 == 0) == (j % 2 == 0)
      if is_friendly then table.insert(friendly_rep, {x = i, z = j})
      else table.insert(enemy_rep, {x = i, z = j}) end
    end
  end
  
  -- Do Fisher-Yates shuffles
  for i = #friendly_rep, 2, -1 do
    local j = math.random(i)
    friendly_rep[i], friendly_rep[j] = friendly_rep[j], friendly_rep[i]
  end
  for i = #enemy_rep, 2, -1 do
    local j = math.random(i)
    enemy_rep[i], enemy_rep[j] = enemy_rep[j], enemy_rep[i]
  end
  
  local id = 1
  for i = 1, number_of_friendlies do
    Game.set_gameoperator(friendly_rep[i], GameOperator:new(id, true))
    id = id + 1
  end
  for i = 1, number_of_enemies do
    Game.set_gameoperator(enemy_rep[i], GameOperator:new(id, false))
    id = id + 1
  end
end

-- For all operators and a slide direction, get start and end game coords
-- Note that this method also returns non-moving operators (e.g. against the end of the stage)
function Game.get_slide_moves(dir)
  local list = {}
  for index, gameoperator in pairs(Game.representation) do
    local coords = Game.index_to_game(index)
    local is_friendly = gameoperator.is_friendly
    local sign, axis;
    if dir.isn then sign = -1 else sign = 1 end
    if dir.isn ~= dir.ise then main_axis, sub_axis = 'x', 'z' else main_axis, sub_axis = 'z', 'x' end
    
    -- Increment or decrement to stage_size or 0
    local count = 0
    local is_attackable = false;
    local axis_end = math.max(stage_size * math.max(0, sign), 1)
    -- Re-checking already checked coords is inefficient
    -- But keeping track of already visited coords is also a hassle
    for i = coords[main_axis] + sign, axis_end, sign do
      local check = {}
      check[main_axis], check[sub_axis] = i, coords[sub_axis]
      
      local check_operator = Game.get_gameoperator(check)
      if check_operator then count = count + 1
        -- If the first operator met is not friendly...
        if check_operator.is_friendly ~= is_friendly and not is_attackable and count <= 1 then
          is_attackable = true -- Mark that operator as the attack target
        end      
      end
    end
    
    local destination = {}
    destination[main_axis] = axis_end - sign * count
    destination[sub_axis] = coords[sub_axis]
    
    local attack_target;
    if is_attackable then
      attack_target = {}
      -- attack_target is simply one position adjacent from destination
      attack_target[main_axis] = destination[main_axis] + sign
      attack_target[sub_axis] = coords[sub_axis]
    end
    
    table.insert(list, {
      id = gameoperator.id,
      origin = {x = coords.x, z = coords.z},
      destination = destination,
      attack_target = attack_target -- Can be nil
    })
  end
  
  return list
end

-- Remove multiple gameoperators from representation by id
function Game.remove_gameoperators(id_list)
  local removelist = {}
  -- We don't remove from representation here has it will mess up the for loop
  for index, gameoperator in pairs(Game.representation) do
    if id_list[gameoperator.id] then table.insert(removelist, index) end
  end
  
  for _, index in pairs(removelist) do Game.representation[index] = nil end
end

-- Get gameoperator by game coordinates
function Game.get_gameoperator(game_coords)
  return Game.representation[Game.game_to_index(game_coords)]
end

-- Set gameoperator by game coordinates
function Game.set_gameoperator(game_coords, gameoperator)
  Game.representation[Game.game_to_index(game_coords)] = gameoperator
end

-- Queue a move action of a single gameoperator from origin to dest
function Game.add_move_queue(game_origin, game_dest)
  local dest_index = Game.game_to_index(game_dest)
  move_queue[dest_index] = Game.get_gameoperator(game_origin)
end

-- Apply all moves in the move queue
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