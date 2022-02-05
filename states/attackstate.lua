-- This is a state module, not a class
-- Perform attack animations for operators and apply HP changes
-- Attack animation finished -> attackcooldown

local AttackState = {}

local FSM, Game, Renderer;
function AttackState.init(fsm, game, renderer)
  FSM, Game, Renderer = fsm, game, renderer
end

-- Countdown exists only to emulate AttackState behaviour, will be removed eventually
local countdown = 0 -- seconds
local count;
local fixed_dir;

function AttackState.enter(args)
  count = countdown
  fixed_dir = args.fixed_dir
end

function AttackState.update(dt)
  count = math.max(count - dt, 0)
  
  if count == 0 then
    FSM.change_state(FSM.states.AttackCooldownState, {fixed_dir = fixed_dir})
  end
end

return AttackState