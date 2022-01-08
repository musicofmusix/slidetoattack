-- slidetoattack

local Game = require "game"
local Renderer = require "rendering.renderer"
local FSM = require "fsm"

local stage_size = 5
local stage_representation;

function love.load()
  love.window.setMode(800, 480, {resizable = false, msaa = 4})
  
  Game.init(stage_size)
  Renderer.init(stage_size)
  
  for i, rows in pairs(Game.representation) do
    for j, gameoperator in pairs(rows) do
      -- This section goes hand-in-hand with Game's implementation of stage rep
      Renderer.add_operator(gameoperator.id, gameoperator.class, {x = i, z = j})
    end
  end
  
  FSM.init(Game, Renderer)
  FSM.change_state(FSM.states.IdleState)
end

function love.update(dt)
  FSM.update_state(dt)
  Renderer.update_operators(dt)
end

function love.draw()
  -- Fix screen centre to (0, 0)
  love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

  -- Draw Background lines
  Renderer.draw_background()
  
  -- Draw stage
  Renderer.draw_stage_tiles()
  
  -- Draw operators
  Renderer.draw_operators()
  
  FSM.draw_state()
end