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
    local game_coords = Game.index_to_game(index)
    Renderer.add_operator(
      gameoperator.id,
      gameoperator.is_friendly,
      gameoperator.class,
      game_coords
      )
    
    Renderer.add_arrowtile(gameoperator.id, gameoperator.is_friendly, game_coords)
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
  -- Fix screen centre to (0, 0)
  love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  FSM.draw_state(0)
  
  -- Draw Background lines
  Renderer.draw_background()
  FSM.draw_state(1)
  
  -- Draw stage
  Renderer.draw_stage_tiles()
  FSM.draw_state(2)
  
  Renderer.draw_arrowtiles()
  FSM.draw_state(3)
  
  -- Draw operators
  Renderer.draw_operators()
  FSM.draw_state(4)
end