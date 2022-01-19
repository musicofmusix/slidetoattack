-- This is a state module, not a class
-- Mouse/touch down -> slide

local IdleState = {}

local FSM;

-- Game and Renderer instances are not needed
function IdleState.init(fsm) FSM = fsm end

function IdleState.mousepressed(x, y, button)
  if button == 1 then
    FSM.change_state(FSM.states.SlideState, {x = x, y = y})
  end
end

return IdleState