-- This is not a class
-- iso vertices = {x1, y1, x2, y2...}, for rendering
-- vertices = {{x=?, y=?, z=?}...}, for calculations
-- y = up for internal world coordinates

local Tile = require "rendering.tile"

local Renderer = {}

local tiles = {}
local unit_length;
local angle = 0

--[[ cos (30) is approx. (1.7 / 2). (1 / 2) is military projection.
  Use something in between if you like.]]--
local isometric_coefficient = 1.6

local stage_edge_colour = {r = 0.157, g = 0.157, b = 0.157} -- #282828
local stage_base_fill_colour = {r = 0.9, g = 0.9, b = 0.9} -- This is the lightest colour


-- Public functions
function Renderer.init(stage_size)
  local screen_width = love.graphics.getWidth()
  local screen_height = love.graphics.getHeight()

  -- VERY important for preventing 'spiky' side tiles
  love.graphics.setLineJoin('bevel')

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
end

-- Stage Tile rendering
function Renderer.draw_stage_tiles()
  love.graphics.setLineWidth(2.5)

  for _, tile in pairs(tiles) do
    local iso_vertices = Renderer.iso_transform(tile.vertices)
    Renderer.set_colour(tile.colour)
    love.graphics.polygon("fill", iso_vertices)
    Renderer.set_colour(stage_edge_colour)
    love.graphics.polygon("line", iso_vertices)
  end
end

-- Rotate stage by some delta or fix it to a specified angle
function Renderer.rotate(is_delta, degrees)
  if not is_delta then
    degrees = degrees - angle
  end

  for _, tile in pairs(tiles) do
    tile.vertices = Renderer.rotate_clockwise(tile.vertices, degrees)
  end

  angle = (angle + degrees) % 360
end

-- Private functions
-- Convert internal world coords into on-screen isometric coords
function Renderer.iso_transform(vertices)
  local iso_vertices = {}

  for _, vertex in pairs(vertices) do
    local iso_x = Renderer.xprime(vertex)
    local iso_z = Renderer.yprime(vertex)
    table.insert(iso_vertices, iso_x)
    table.insert(iso_vertices, iso_z)
  end

  return iso_vertices
end

-- Calculate screen x-coord
function Renderer.xprime(vertex)
  return unit_length * (vertex.x - vertex.z) * (isometric_coefficient / 2)
end

-- Calculate screen y-coord
function Renderer.yprime (vertex)
  return unit_length * (vertex.y + (vertex.x + vertex.z) * math.sin(math.pi / 6))
end

-- Rotate a set of word-coordinates about the y-axis (up)
function Renderer.rotate_clockwise (vertices, theta)
  local radians = math.rad(theta)

  local rot_vertices = {}
  for _, vertex in pairs(vertices) do
    local xprime = vertex.x * math.cos(radians) - vertex.z * math.sin(radians)
    local zprime = vertex.x * math.sin(radians) + vertex.z * math.cos(radians)
    table.insert(rot_vertices, {x = xprime, y = vertex.y, z = zprime})
  end
  return rot_vertices
end

-- Helper for setting colour
function Renderer.set_colour(colour)
  love.graphics.setColor(colour.r, colour.g, colour.b)
end

return Renderer