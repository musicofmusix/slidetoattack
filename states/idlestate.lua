-- This is a state module, not a class
-- Mouse/touch down -> slide

local IdleState = {}

local FSM, Renderer;
function IdleState.init(fsm, game, renderer)
  FSM = fsm
  Renderer = renderer
end

local function draw_status_text()
  Renderer.draw_text("Slide")
end

IdleState.draw = {[3] = draw_status_text}

function IdleState.mousepressed(x, y, button)
  if button == 1 then
    FSM.change_state(FSM.states.SlideState, {x = x, y = y})
  end
end

return IdleState