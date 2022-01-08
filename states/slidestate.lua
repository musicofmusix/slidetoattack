-- This is a state module, not a class
-- Mouse/touch release before threshold -> idle
-- Mouse/touch release after threshold -> attack

local SlideState = {}

local FSM, Game, Renderer;

function SlideState.init(fsm, game, renderer)
  FSM, Game, Renderer = fsm, game, renderer
  end

function SlideState.mousereleased(button)
  if button == 1 then FSM.change_state(FSM.states.IdleState) end
end

return SlideState