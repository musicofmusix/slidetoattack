-- slidetoattack main

local Game = require "game"
local Renderer = require "rendering.renderer"
local FSM = require "fsm"

local stage_size = 5
local stage_representation;

function love.load()
  love.window.setMode(800, 480, {resizable = false, msaa = 4})
  math.randomseed(os.time())
  
  Game.init(stage_size)
  Renderer.init(stage_size)
  
  for index, gameoperator in pairs(Game.representation) do
    Renderer.add_operator(
      gameoperator.id,
      gameoperator.is_friendly,
      gameoperator.class,
      Game.index_to_game(index))
  end
  
  -- Pass the above Game and Renderer instances to all states
  FSM.init(Game, Renderer)
  FSM.change_state(FSM.states.IdleState) -- First state is Idle
end

function love.update(dt)
  FSM.update_state(dt)
  Renderer.update_operators(dt)
end

function love.draw()
  -- Get which layer the current state needs to draw on
  local FSM_layer = FSM.get_draw_layer()
  
  -- Fix screen centre to (0, 0)
  love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  if FSM_layer == 0 then FSM.draw_state() end
  
  -- Draw Background lines
  Renderer.draw_background()
  if FSM_layer == 1 then FSM.draw_state() end
  
  -- Draw stage
  Renderer.draw_stage_tiles()
  if FSM_layer == 2 then FSM.draw_state() end
  
  -- Draw operators
  Renderer.draw_operators()
  if FSM_layer >= 3 then FSM.draw_state() end
end