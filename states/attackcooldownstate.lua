-- This is a state module, not a class
-- Allow smooth stage rotation after attack
-- Fixed-time stage rotation finished -> idle

local AttackCooldownState = {}

local FSM, Renderer;
function AttackCooldownState.init(fsm, game, renderer)
  FSM, Renderer = fsm, renderer
end

local progress;
-- The speed in which cooldown should take place
local cooldown_coeff = 7
local fixed_dir;
local rotation_coeff;

function AttackCooldownState.enter(args)
  progress = 1
  fixed_dir = args.fixed_dir
  if fixed_dir.isn ~= fixed_dir.ise then rotation_coeff = -1 else rotation_coeff = 1 end
end

function AttackCooldownState.update(dt)
  -- Maintain consistent cooldown time
  -- Don't let progress become negative
  progress = math.max(0, progress - dt * cooldown_coeff)
  
  Renderer.rotate_stage(false, Renderer.lerp(0, 45 * rotation_coeff, progress))
  
  if progress == 0 then FSM.change_state(FSM.states.IdleState) end
end

return AttackCooldownState