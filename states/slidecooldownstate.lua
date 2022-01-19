-- This is a state module, not a class
-- Show a smooth slide retraction upon exiting SlideState
-- progress variable reaches 0 -> idle

local SlideCooldownState = {draw_layer = 1}

local FSM, Renderer;
function SlideCooldownState.init(fsm, game, renderer)
  FSM, Renderer = fsm, renderer
end

local progress;
local fixed_dir;
local rotation_coeff;

-- The speed in which cooldown should take place
local cooldown_coeff = 6

function SlideCooldownState.enter(args)
  -- Assume progress and fixed_dir ~= nil as we're coming from SlideState
  progress = args.progress
  fixed_dir = args.fixed_dir
  if fixed_dir.isn ~= fixed_dir.ise then rotation_coeff = -1 else rotation_coeff = 1 end
end

function SlideCooldownState.update(dt)
  -- Maintain consistent cooldown time
  -- Don't let progress become negative
  progress = math.max(0, progress - dt * cooldown_coeff)
  
  Renderer.rotate_stage(false, Renderer.lerp(0, 45 * rotation_coeff, progress))
  
  if progress == 0 then FSM.change_state(FSM.states.IdleState) end
end

function SlideCooldownState.draw()
  Renderer.draw_slide_overlay(fixed_dir, progress)
end

return SlideCooldownState