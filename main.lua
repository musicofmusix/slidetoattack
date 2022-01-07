local Game = require "game"
local Renderer = require "rendering.renderer"

DEBUG = true

local stage_size = 5
local stage_representation;

function love.load()
  love.window.setMode(800, 480, {resizable = false, msaa = 4})
  
  stage_representation = Game.init(stage_size)
  Renderer.init(stage_size)
  
  for index, gameoperator in pairs(stage_representation) do
    -- This section goes hand-in-hand with Game's implementation of stage rep
    Renderer.add_operator(gameoperator.id, gameoperator.class, {
      x = (index - 1) % stage_size + 1,
      z = math.floor((index - 1) / stage_size) + 1
    })
  end
end

function love.update(dt)
  if love.keyboard.isDown("left") then
    Renderer.rotate(true, -1)
  elseif love.keyboard.isDown("right") then
    Renderer.rotate(true, 1)
  end
  
  Renderer.update_operators(dt)
end

function love.draw()
  if DEBUG then
    love.graphics.setColor(1,0,0)
    love.graphics.line(love.graphics.getWidth() / 2, 0 , love.graphics.getWidth() / 2 , love.graphics.getHeight())
    love.graphics.line(0, love.graphics.getHeight() / 2 , love.graphics.getWidth(), love.graphics.getHeight() / 2)
  end

  -- Fix screen centre to (0, 0)
  love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

  -- Draw Background lines
  Renderer.draw_background()

  -- Draw stage
  Renderer.draw_stage_tiles()
  
  -- Draw operators
  Renderer.draw_operators()
end