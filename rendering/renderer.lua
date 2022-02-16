-- This is not a class
-- All operations regarding drawing are implemented as interfaces here
--[[
There are three coordinate systems:
- game = [1, stage_size], game logic only, x and z
- world = [-stage_size, stage_size], renderer only, x, y, and z
- screen = on-screen coords, renderer only, x and y
]]--

local Tile = require "rendering.tile"
local SideTile = require "rendering.sidetile"
local BGline = require "rendering.bgline"
local ArrowTile = require "rendering.arrowtile"
local Operator = require "rendering.operator"
local AssetMapping = require "assets.assetmapping"

local Renderer = {}

local tiles = {}
local sides = {}
local bg_lines = {}
local arrowtiles = {}
local operator_sprites = {}
local attackers = {}
local victims = {}

local skeleton_renderer;

local stage_size;
local screen_width;
local screen_height;
local screen_diag;
local screen_diag_angle;
local screen_diag_perpendicular;
local unit_length;
local angle = 0
local operator_scale = 1
local operator_goal_scale = 1
local active_attacks = 0

local operator_flip_time = 0.12

local stage_elevation = 1.5 -- Stage elevation goes DOWN from the stage (y=0)

--[[ cos (30) is approx. (1.7 / 2). (1 / 2) is military projection.
  Use something in between if you like.]]--
local isometric_coefficient = 1.6

local light_angle = 65 -- 0 to 90 inclusive.

local bg_colour = {r = 0.878, g = 0.878, b = 0.910}
local bg_line_colour = {r = 0, g = 0, b = 0}
local stage_edge_colour = {r = 0.157, g = 0.157, b = 0.157}
local stage_base_fill_colour = {r = 0.9, g = 0.9, b = 0.9} -- This is the lightest colour
local operator_colour = {r = 1, g = 1, b = 1, a = 1}
local shadow_colour = {r = 0, g = 0, b = 0, a = 0.25}
local slide_start_colour = {r = 0, g = 0, b = 0, a = 0.15}
local slide_end_colour = {r = 0, g = 0, b = 0, a = 0.6}
local friendly_arrowtile_colour = {r = 0.251, g = 0.659, b = 0.847, a = 0.8}
local enemy_arrowtile_colour = {r = 0.851, g = 0.255, b = 0.212, a = 0.8}

-- Public functions
function Renderer.get_screen_info()
  return {
    width = screen_width,
    height = screen_height,
    diag = screen_diag,
    unit_length = unit_length
  }
end

function Renderer.init(_stage_size)
  stage_size = _stage_size
  screen_width = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()
  screen_diag = math.sqrt(screen_width ^ 2 + screen_height ^ 2)
  screen_diag_angle = math.atan(screen_height / screen_width)
  screen_diag_perpendicular = screen_width / math.cos(screen_diag_angle)

  -- VERY important for preventing 'spiky' side tiles
  love.graphics.setLineJoin("bevel")
  love.graphics.setLineStyle("smooth")

  if (screen_width < screen_height) then
    -- Divide by stage_size * 2 because one edge of a tile is length=2
    unit_length = (screen_width / 2) / (stage_size * 2)
  else
    unit_length = screen_height / isometric_coefficient / (stage_size * 2)
  end

  -- Generate tiles
  for i = -(stage_size - 1), (stage_size - 1), 2 do
    for j = -(stage_size - 1), (stage_size - 1), 2 do
      local tile = Tile:new({x = i, z = j}, stage_base_fill_colour)
      table.insert(tiles, tile)
    end
  end

  -- Generate sides
  sides.n = SideTile:new("n", stage_size, stage_elevation, stage_base_fill_colour)
  sides.s = SideTile:new("s", stage_size, stage_elevation, stage_base_fill_colour)
  sides.w = SideTile:new("w", stage_size, stage_elevation, stage_base_fill_colour)
  sides.e = SideTile:new("e", stage_size, stage_elevation, stage_base_fill_colour)

  -- Generate BG
  local units_horizontal = math.ceil(screen_width / unit_length
                                    * isometric_coefficient / 2)
  local units_vertical = math.ceil(screen_height / unit_length)

  -- Choose the larger one because the stage ROTATES
  local units_max = math.max(units_horizontal, units_vertical)

  -- Whether or not to draw at the centre of the screen
  local start_index = 1
  if stage_size % 2 == 0 then start_index = 0 end

  -- Add horizontal lines
  for i = start_index, units_max, 2 do
    local pos_line = BGline:new(-units_max, i, units_max, i, stage_elevation)
    local neg_line = BGline:new(-units_max, -i, units_max, -i, stage_elevation)
    table.insert(bg_lines, pos_line)
    table.insert(bg_lines, neg_line)
  end

  -- Add vertical lines
  for i = start_index, units_max, 2 do
    local pos_line = BGline:new(i, -units_max, i, units_max, stage_elevation)
    local neg_line = BGline:new(-i, -units_max, -i, units_max, stage_elevation)
    table.insert(bg_lines, pos_line)
    table.insert(bg_lines, neg_line)
  end
    
  -- Generate Spine2D skeleton renderer for operator sprites
  skeleton_renderer = spine.SkeletonRenderer.new(true)
end

-- Stage rendering
function Renderer.draw_stage_tiles()
  love.graphics.setLineWidth(2.5)

  for _, tile in pairs(tiles) do
    local screen_vertices = Renderer.world_to_screen(tile.vertices)
    Renderer.set_colour(tile.colour)
    love.graphics.polygon("fill", screen_vertices)
    Renderer.set_colour(stage_edge_colour)
    love.graphics.polygon("line", screen_vertices)
  end

  -- SideTile rendering
  local dirs = {"s", "e", "n", "w"}
  local viewable_side_index = math.floor((angle + 45) / 90)

  for i = viewable_side_index, viewable_side_index + 1 do
    local side = sides[dirs[(i) % 4 + 1]]
    local screen_vertices = Renderer.world_to_screen(side.vertices)
    local side_colour = side:generate_colour(angle, light_angle)

    Renderer.set_colour(side_colour)
    love.graphics.polygon("fill", screen_vertices)
    Renderer.set_colour(stage_edge_colour)
    love.graphics.polygon("line", screen_vertices)
  end
end

-- BGline rendering
function Renderer.draw_background()
  love.graphics.setBackgroundColor(bg_colour.r, bg_colour.g, bg_colour.b)
  Renderer.set_colour(bg_line_colour)
  love.graphics.setLineWidth(0.8)

  for _, line in pairs(bg_lines) do
    local screen_vertices = Renderer.world_to_screen(line.vertices)
    love.graphics.line(screen_vertices)
  end
end

-- Add an ArrowTile
function Renderer.add_arrowtile(id, is_friendly, initial_game_origin)
  local initial_world_coords = Renderer.game_to_world(initial_game_origin, false)
  local arrowtile = ArrowTile:new(id, is_friendly, initial_world_coords)
  arrowtiles[id] = arrowtile
end

-- Update an ArrowTile with a new origin, destination, or progress
-- Note: Always update both origin and dest!
function Renderer.update_arrowtile(id, game_origin, game_dest, progress, is_retraction)
  if game_origin and game_dest then
    arrowtiles[id].origin = Renderer.game_to_world(game_origin, false)
    arrowtiles[id].dest = Renderer.game_to_world(game_dest, false)
    
    -- Smaller depth -> deeper; this depends on slide direction
    local dir_sign = (game_dest.x - game_origin.x + game_dest.z - game_origin.z)
    if dir_sign > 0 then arrowtiles[id].depth = -(game_dest.x + game_dest.z)
    else arrowtiles[id].depth = (game_dest.x + game_dest.z)
    end
  end
  if progress then arrowtiles[id].progress = progress end
  
  local vertices_norot = arrowtiles[id]:generate_vertices(is_retraction)
  arrowtiles[id].vertices = Renderer.batch_rotate_clockwise(vertices_norot, angle)
end

-- Draw all ArrowTiles
function Renderer.draw_arrowtiles()
 
end

-- Remove a single ArrowTile
function Renderer.remove_arrowtile(id)
  arrowtiles[id] = nil
end

-- Add a new operator Spine2D sprite
-- Not part of init() as new operators can be added mid-game
function Renderer.add_operator(id, is_friendly, class, game_coords)
  local spine_name = AssetMapping.get_name(is_friendly, class)
  
  local callbacks = {
    onHit = Renderer.callback_on_hit,
    onAttackEnd = Renderer.callback_on_attack_end,
    onDieEnd = Renderer.callback_on_die_end,
    onFadeEnd = Renderer.callback_on_fade_end
  }
  
  operator_sprites[id] =
    Operator:new(id, spine_name, Renderer.game_to_world(game_coords, true), unit_length, operator_colour, callbacks)
end

function Renderer.remove_operator(id)
  operator_sprites[id] = nil
end

-- Update Spine2D sprites
function Renderer.update_operators(dt)
  if operator_scale ~= operator_goal_scale then
    operator_scale = math.min(1, math.max(-1, operator_scale + dt * operator_goal_scale * 2 / operator_flip_time))
  end
  
  -- Update the state with the delta time and update world transforms
	for _, operator_sprite in pairs(operator_sprites) do
		operator_sprite.spine_skel:set_xscale(operator_scale)
		
		operator_sprite.spine_skel:update(dt)
		operator_sprite:update_fade(dt)
	end
end

-- Render all Spine2D sprites and ArrowTiles
function Renderer.draw_operators()
  local draw_queue = {}
	for id, operator_sprite in pairs(operator_sprites) do
	  local screenx = Renderer.xprime(operator_sprite.world_coords)
	  local screeny = Renderer.yprime(operator_sprite.world_coords)
	  
	  local arrowtile = arrowtiles[id]
	  local arrowtile_vertices = Renderer.world_to_screen(arrowtile.vertices)
	  local arrowtile_colour;
	  if arrowtile.is_friendly then arrowtile_colour = friendly_arrowtile_colour
    else arrowtile_colour = enemy_arrowtile_colour end
	  
	  -- screeny can be used as depth; smaller = top of screen = deeper = draw first
	  table.insert(draw_queue, {
	    operator_skel = operator_sprite.spine_skel,
	    operator_colour = operator_sprite.colour,
	    x = screenx,
	    y = screeny,
	    arrowtile_vertices = arrowtile_vertices,
	    arrowtile_depth = arrowtile.depth,
	    arrowtile_colour = arrowtile_colour
	  })
	end
	
	-- Draw ArrowTiles
	table.sort(draw_queue, function(a, b) return a.arrowtile_depth < b.arrowtile_depth end)
	for _, draw_item in pairs(draw_queue) do
	  Renderer.set_colour(Renderer.multiply_colour(
	    draw_item.arrowtile_colour, draw_item.operator_colour))
	  -- Use triangluation to break down concave polygons
	  if #draw_item.arrowtile_vertices >= 14 then -- 7 * 2
	    local triangles = love.math.triangulate(draw_item.arrowtile_vertices)
      for _, triangle in pairs(triangles) do
        love.graphics.polygon("fill", triangle)
      end
      
    -- Polygons with less than 7 vertices are convex by default, can draw directly
    else love.graphics.polygon("fill", draw_item.arrowtile_vertices)
    end
    
    Renderer.set_colour(stage_edge_colour)
    love.graphics.polygon("line", draw_item.arrowtile_vertices)
	end
	
	-- Draw operators
	table.sort(draw_queue, function(a, b) return a.y < b.y end)
	for _, draw_item in pairs(draw_queue) do
	  -- Draw shadows here, before any sprites
	  Renderer.set_colour(Renderer.multiply_colour(shadow_colour, draw_item.operator_colour))
	  love.graphics.ellipse( "fill", draw_item.x, draw_item.y,
	    unit_length, unit_length / 3, 32) -- 32 Segments for smoothness
	  
	  Renderer.set_colour(draw_item.operator_colour)
	  draw_item.operator_skel:draw(skeleton_renderer, draw_item.x, draw_item.y)
	end
end

function Renderer.set_operator_scale(new_scale)
  operator_goal_scale = new_scale
end

-- Methods for moving, removing, etc. operator sprites come here
-- Lerp between two game_coords and position an operator there
function Renderer.move_operator(id, game_orgin, game_dest, progress)
  -- origin and desitnation are both game_coords; progress is a [0, 1] float.
  local lerp_gamex = Renderer.lerp(game_orgin.x, game_dest.x, progress)
  local lerp_gamez = Renderer.lerp(game_orgin.z, game_dest.z, progress)
  local lerp_world_coords =
    Renderer.game_to_world({x = lerp_gamex, z = lerp_gamez}, true)
  
  operator_sprites[id].world_coords = lerp_world_coords
end

-- Operator animations
function Renderer.add_attack_pair(attacker_id, victim_id)
  attackers[victim_id] = attacker_id
  victims[attacker_id] = victim_id
  
  active_attacks = active_attacks + 1
end

function Renderer.clear_attacks()
  attackers = {}
  victims = {}
  active_attacks = 0
end

function Renderer.start_attack()
  -- The "starter victims" are those who are victims but are not attackers
  for attacker_id, victim_id in pairs(victims) do
    if not victims[victim_id] then
      Renderer.play_animation(attacker_id, "Attack", false)
    end
  end
end

function Renderer.callback_on_hit(id) end

function Renderer.callback_on_attack_end(attacker_id)
  Renderer.play_animation(attacker_id, "Idle", true)
  
  local victim_id = victims[attacker_id]
  Renderer.play_animation(victim_id, "Die", false)
  
  local next_attacker_id = attackers[attacker_id]
  if next_attacker_id then
    Renderer.play_animation(next_attacker_id, "Attack", false)
    end
end

function Renderer.callback_on_die_end(victim_id)
  operator_sprites[victim_id]:start_fade()
end

function Renderer.callback_on_fade_end(victim_id)
  -- Remove operator visually, make sure removal is done logically as well
  Renderer.remove_operator(victim_id)
  Renderer.remove_arrowtile(victim_id)
  
  active_attacks = active_attacks - 1
end

function Renderer.get_active_attacks()
  return active_attacks
end

function Renderer.play_animation(id, animation_name, is_loop)
  operator_sprites[id].spine_skel:set_pose(animation_name, is_loop)
end

-- Draw slide overlay
function Renderer.draw_slide_overlay(dir, _progress, opacity)
  local progress = (_progress or 1)
  local angle_coefficient;
  local rectanglex_coefficient
  local angle_coeff;
  
  if dir.isn ~= dir.ise then angle_coeff = 1 else angle_coeff = -1 end
  if dir.ise then x_coeff, x_offset = -1, 0 else x_coeff, x_offset = 1, 1 end
  
  love.graphics.push()
	love.graphics.rotate(angle_coeff * screen_diag_angle)
	
	local rectangle_width = screen_diag * progress
	local rectangle_height = screen_diag_perpendicular * 2
	
	local rectanglex = x_coeff * screen_diag / 2 - x_offset * rectangle_width
  local rectangley = -screen_diag_perpendicular
  
  Renderer.set_colour({
    r = Renderer.lerp(slide_start_colour.r, slide_end_colour.r, progress),
    g = Renderer.lerp(slide_start_colour.g, slide_end_colour.g, progress),
    b = Renderer.lerp(slide_start_colour.b, slide_end_colour.b, progress),
    a = Renderer.lerp(slide_start_colour.a, slide_end_colour.a, progress) * (opacity or 1),
  })
	love.graphics.rectangle('fill', rectanglex, rectangley, rectangle_width, rectangle_height)
	love.graphics.pop()
end

-- Rotate stage by some delta or fix it to a specified angle
function Renderer.rotate_stage(is_delta, degrees)
  if not is_delta then
    degrees = degrees - angle
  end

  for _, tile in pairs(tiles) do
    tile.vertices = Renderer.batch_rotate_clockwise(tile.vertices, degrees)
  end

  for _, side in pairs(sides) do
    side.vertices = Renderer.batch_rotate_clockwise(side.vertices, degrees)
  end

  for _, line in pairs(bg_lines) do
    line.vertices = Renderer.batch_rotate_clockwise(line.vertices, degrees)
  end
  
  for _, arrowtile in pairs(arrowtiles) do
    arrowtile.vertices = Renderer.batch_rotate_clockwise(arrowtile.vertices, degrees)
  end
  
  for _, operator_sprite in pairs(operator_sprites) do
		operator_sprite.world_coords =
		Renderer.rotate_clockwise(operator_sprite.world_coords, degrees)
	end

  angle = (angle + degrees) % 360
end

-- Private functions
-- Convert world coords into screen coords
function Renderer.world_to_screen(vertices)
  local screen_vertices = {}

  for _, vertex in pairs(vertices) do
    local screenx = Renderer.xprime(vertex)
    local screenz = Renderer.yprime(vertex)
    table.insert(screen_vertices, screenx)
    table.insert(screen_vertices, screenz)
  end

  return screen_vertices
end

-- Calculate screen x-coord
function Renderer.xprime(vertex)
  return unit_length * (vertex.x - vertex.z) * (isometric_coefficient / 2)
end

-- Calculate screen y-coord
function Renderer.yprime(vertex)
  return unit_length * (vertex.y + (vertex.x + vertex.z) * math.sin(math.pi / 6))
end

-- Convert game coords to world coords
function Renderer.game_to_world(vertex, rotate)
  local direct_conversion = {
    x = vertex.x * 2 - stage_size - 1,
    y = 0, -- This conversion function is for on-stage stuff only
    z = vertex.z * 2 - stage_size - 1
  }
  
  -- direct_conversion does not account for rotation, so...
  if rotate then return Renderer.rotate_clockwise(direct_conversion, angle)
  else return direct_conversion end
end

-- Rotate a set of world-coordinates about the y-axis (up)
function Renderer.batch_rotate_clockwise(vertices, theta)
  local rot_vertices = {}
  
  for _, vertex in pairs(vertices) do
    table.insert(rot_vertices, Renderer.rotate_clockwise(vertex, theta))
  end
  
  return rot_vertices
end

-- Rotate a single world point about the y-axis
function Renderer.rotate_clockwise(vertex, theta)
  local radians = math.rad(theta)

  local xprime = vertex.x * math.cos(radians) - vertex.z * math.sin(radians)
  local zprime = vertex.x * math.sin(radians) + vertex.z * math.cos(radians)
  
  return {x = xprime, y = vertex.y, z = zprime}
end

-- Helper for setting colour
function Renderer.set_colour(colour)
  love.graphics.setColor(colour.r, colour.g, colour.b, colour.a or 1)
end

function Renderer.multiply_colour(colour1, colour2)
  return {
    r = colour1.r * colour2.r,
    g = colour1.g * colour2.g,
    b = colour1.b * colour2.b,
    a = (colour1.a or 1) * (colour2.a or 1)
  }
end

-- Lerp
function Renderer.lerp(start, finish, progress)
  return (finish - start) * progress + start
end

return Renderer