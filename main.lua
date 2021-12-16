local Renderer = require 'rendering.renderer'

DEBUG = true

function love.load()
  love.window.setMode(800, 480, {resizable=false})
  Renderer.init(5) -- stage_size = 5
end

function love.update()
  Renderer.rotate(true, 0.5)
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
end
