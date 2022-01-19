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
local Operator = require "rendering.operator"
local AssetMapping = require "assets.assetmapping"

local Renderer = {}

local tiles = {}
local sides = {}
local bg_lines = {}
local operator_sprites = {}

local skeleton_renderer;

local stage_size;
local screen_width;
local screen_height;
local screen_diag;
local screen_diag_angle;
local screen_diag_perpendicular;
local unit_length;
local angle = 0
local stage_elevation = 1.5 -- Stage elevation goes DOWN from the stage (y=0)

--[[ cos (30) is approx. (1.7 / 2). (1 / 2) is military projection.
  Use something in between if you like.]]--
local isometric_coefficient = 1.6

local bg_colour = {r = 0.878, g = 0.878, b = 0.910} -- #E0E0E8
local bg_line_colour = {r = 0, g = 0, b = 0}
local stage_edge_colour = {r = 0.157, g = 0.157, b = 0.157} -- #282828
local stage_base_fill_colour = {r = 0.9, g = 0.9, b = 0.9} -- This is the lightest colour
local operator_colour = {r = 1, g = 1, b = 1}
local shadow_colour = {r = 0, g = 0, b = 0, a = 0.25}
local slide_start_colour = {r = 0, g = 0, b = 0, a = 0.15}
local slide_end_colour = {r = 0, g = 0, b = 0, a = 0.6}

local light_angle = 65 -- 0 to 90 inclusive.

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

-- Add a new operator Spine2D sprite
-- Not part of init() as new operators can be added mid-game
function Renderer.add_operator(id, class, game_coords)
  local available_assets = AssetMapping[class]
  math.randomseed(os.time())
  local random_index = math.random(#available_assets)
  local spine_name = available_assets[random_index]
  
  operator_sprites[id] =
    Operator:new(spine_name, Renderer.game_to_world(game_coords), unit_length)
end

-- Update Spine2D sprites
function Renderer.update_operators(dt)
  -- Update the state with the delta time and update world transforms
	for _, operator_sprite in pairs(operator_sprites) do
		operator_sprite.spine_skel:update(dt)
	end
end

-- Render all Spine2D sprites
function Renderer.draw_operators()
	local draw_queue = {}
	for _, operator_sprite in pairs(operator_sprites) do
	  local screenx = Renderer.xprime(operator_sprite.world_coords)
	  local screeny = Renderer.yprime(operator_sprite.world_coords)
	  -- screeny can be used as depth. smaller = top of screen = deeper
	  table.insert(draw_queue, {skel = operator_sprite.spine_skel, x = screenx, y = screeny})
	  
	  -- Draw shadows here, before any sprites
	  Renderer.set_colour(shadow_colour)
	  love.graphics.ellipse( "fill", screenx, screeny,
	    unit_length, unit_length / 3, 32) -- 32 Segments for smoothness
	end
	
	Renderer.set_colour(operator_colour)
	table.sort(draw_queue, function(a, b) return a.y < b.y end)
	for _, draw_item in pairs(draw_queue) do
	  draw_item.skel:draw(skeleton_renderer, draw_item.x, draw_item.y)
	end
end

-- Methods for moving, removing, etc. operator sprites come here
-- Lerp between two game_coords and position an operator there
function Renderer.move_operator(id, game_orgin, game_destination, progress)
  -- origin and desitnation are both game_coords; progress is a [0, 1] float.
  local lerp_gamex = Renderer.lerp(game_orgin.x, game_destination.x, progress)
  local lerp_gamez = Renderer.lerp(game_orgin.z, game_destination.z, progress)
  local lerp_world_coords =
    Renderer.game_to_world({x = lerp_gamex, z = lerp_gamez})
  
  operator_sprites[id].world_coords = lerp_world_coords
end

function Renderer.attack_operator() end
function Renderer.remove_operator() end

-- Draw slide overlay
function Renderer.draw_slide_overlay(dir, progress)
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
    a = Renderer.lerp(slide_start_colour.a, slide_end_colour.a, progress),
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
function Renderer.game_to_world(vertex)
  local direct_conversion = {
    x = vertex.x * 2 - stage_size - 1,
    y = 0, -- This conversion function is for on-stage stuff only
    z = vertex.z * 2 - stage_size - 1
  }
  
  -- direct_conversion does not account for rotation, so...
  return Renderer.rotate_clockwise(direct_conversion, angle)
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

-- Lerp
function Renderer.lerp(start, finish, progress)
  return (finish - start) * progress + start
end

return Renderer