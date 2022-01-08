-- This is not a class

local FSM = {}

local state; -- This stores the state table/module, not the name

FSM.states = {
  IdleState = require "states.idlestate",
  SlideState = require "states.slidestate"
}

function FSM.init(game, renderer)
  for _, state in pairs(FSM.states) do state.init(FSM, game, renderer) end
end

function FSM.update_state(dt)
  if state.update then state.update() end
end

function FSM.draw_state()
  if state.draw then state.draw() end  
end

function FSM.change_state(new_state)
  if state and state.finish then state.finish() end
  state = new_state
  if state.enter then state.enter() end
end

function love.mousepressed(x, y, button, istouch, presses)
  if state.mousepressed then state.mousepressed(button) end
end

function love.mousemoved(x, y, dx, dy, istouch)
  if state.mousemoved then state.mousemoved(dx, dy) end
end

function love.mousereleased(x, y, button, istouch, presses)
  if state.mousereleased then state.mousereleased(button) end
end

return FSM