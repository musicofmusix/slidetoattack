-- This is a state module, not a class
-- Show a smooth slide retraction upon exiting SlideState
-- progress variable reaches 0 -> idle

local SlideCooldownState = {}

local FSM, Renderer;
function SlideCooldownState.init(fsm, game, renderer)
  FSM, Renderer = fsm, renderer
end

local progress;
local initial_progress;
local fixed_dir;
local operator_movelist;
local overlay_opacity;
local overlay_opacity;
local rotation_coeff;

-- The speed in which cooldown should take place
local cooldown_coeff = 6

function SlideCooldownState.enter(args)
  -- Assume progress and fixed_dir ~= nil as we're coming from SlideState
  progress = args.progress
  initial_progress = progress
  fixed_dir = args.fixed_dir
  operator_movelist = args.operator_movelist
  overlay_progress = nil
  overlay_opacity = nil
  if fixed_dir.isn ~= fixed_dir.ise then rotation_coeff = -1 else rotation_coeff = 1 end
end

function SlideCooldownState.update(dt)
  -- Maintain consistent cooldown time
  -- Don't let progress become negative
  progress = math.max(0, progress - dt * cooldown_coeff)
  
  -- initial_progress < 1 -> Rotate stage, retract slide overlay and operators
  if initial_progress < 1 then 
    Renderer.rotate_stage(false, Renderer.lerp(0, 45 * rotation_coeff, progress))
    
    overlay_progress = progress
    
    for _, parameters in pairs(operator_movelist) do
      Renderer.move_operator(
        parameters.id,
        parameters.origin,
        parameters.destination,
        progress)
      
      Renderer.update_arrowtile(parameters.id, nil, nil, progress)
    end
    
    if progress == 0 then FSM.change_state(FSM.states.IdleState) end
  
  -- initial_progress == 1 -> Fix stage and operators, fade out slide overlay
  else
    overlay_opacity = progress
    
    -- Change IdleState to AttackState after implementation
    if progress == 0 then FSM.change_state(FSM.states.IdleState) end
  end
end

local function draw_slide_overlay()
  Renderer.draw_slide_overlay(fixed_dir, overlay_progress, overlay_opacity)
end

-- Overlay is drawn on layer 1 (after BGlines)
SlideCooldownState.draw = {[1] = draw_slide_overlay}

return SlideCooldownState