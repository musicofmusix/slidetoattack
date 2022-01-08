-- This is a state module, not a class
-- Mouse/touch down -> slide

local IdleState = {}

local FSM;

function IdleState.init(fsm) FSM = fsm end

function IdleState.mousepressed(button)
  if button == 1 then FSM.change_state(FSM.states.SlideState) end
end

return IdleState