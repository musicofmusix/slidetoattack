-- This is not a class
-- Provide main and all states an interface for switching states

local FSM = {}

local state; -- This stores the state table/module, not the name

FSM.states = {
  IdleState = require "states.idlestate",
  SlideState = require "states.slidestate",
  SlideCooldownState = require "states.slidecooldownstate"
}

-- Methods are only called when they are defined in each respective state module

-- Pass Game and Renderer instances from main to all states
function FSM.init(game, renderer)
  for _, state in pairs(FSM.states) do state.init(FSM, game, renderer) end
end

function FSM.update_state(dt)
  if state.update then state.update(dt) end
end

function FSM.get_draw_layer()
  -- Default is to draw last, after stage, operators, etc. have been drawn
  if state.draw_layer then return state.draw_layer else return 99 end
end

function FSM.draw_state()
  if state.draw then state.draw() end  
end

-- args is an optional table for a previous state to pass onto the next
function FSM.change_state(new_state, args)
  if state and state.finish then state.finish() end
  state = new_state
  if state.enter then state.enter(args) end
end

function love.mousepressed(x, y, button, istouch, presses)
  if state.mousepressed then state.mousepressed(x, y, button) end
end

function love.mousemoved(x, y, dx, dy, istouch)
  if state.mousemoved then state.mousemoved(dx, dy) end
end

function love.mousereleased(x, y, button, istouch, presses)
  if state.mousereleased then state.mousereleased(button) end
end

return FSM