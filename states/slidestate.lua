-- This is a state module, not a class
-- Handle and provide feedback to slide input
-- Mouse/touch release before deadzone -> idle
-- Mouse/touch release after deadzone -> slidecooldown

local SlideState = {}

local FSM, Game, Renderer;
function SlideState.init(fsm, game, renderer)
  FSM, Game, Renderer = fsm, game, renderer
end

--[[
Distance (a portion of the screen's diagonal length) required to
determine a slide direction and trigger a slide finish event, respectively
]]--
local deadzone = 0.035;
local threshold = 0.25;

-- x and y variables separated for easy readablity
local screen_info;
local startx;
local starty;
local currentx;
local currenty;
local moved_length;
local fixed_dir;
local progress;
local operator_movelist;
local is_fixed_initial;

function SlideState.enter(args)
  screen_info = Renderer.get_screen_info()
  startx, starty = args.x, args.y
  currentx, currenty = 0, 0
  fixed_dir = nil
  moved_length = 0
  progress = 0
  operator_movelist = nil
  is_fixed_initial = false
end

local function draw_slide_overlay()
  if fixed_dir then Renderer.draw_slide_overlay(fixed_dir, progress) end
end

-- Overlay is drawn on layer 1 (after BGlines)
SlideState.draw = {[1] = draw_slide_overlay}

-- Only called upon mouse movement
function SlideState.mousemoved(dx, dy)
  currentx = currentx + dx
  currenty = currenty + dy
  
  moved_length = math.sqrt(currentx ^ 2 + currenty ^ 2)
  
  -- Fix slide direction until the end of this state
  if moved_length >= screen_info.diag * deadzone and not fixed_dir then
    fixed_dir = SlideState.get_dir(currentx, currenty)
  end
  
  if fixed_dir then
    -- Get the end vertex of the screen where this direction is pointing
    local endx_coeff, endy_coeff;
    if fixed_dir.isn then endy_coeff = 0 else endy_coeff = 1 end
    if fixed_dir.ise then
      endx_coeff = 1
      Renderer.set_operator_scale(1)
    else
      endx_coeff = 0
      Renderer.set_operator_scale(-1)
    end
    local endx = screen_info.width * endx_coeff
    local endy = screen_info.height * endy_coeff
  
    -- Calculate the distance slided towards the above vertex
    -- The dot product allows for a UI slider-like behaviour
    local dot = currentx * (endx - startx) + currenty * (endy - starty)
    local start_to_end = math.sqrt((endx - startx) ^ 2 + (endy - starty) ^ 2)
    
    -- Subtract distance moved within deadzone
    -- Minimum moved length is 0, and maximum progress is 1
    local valid_moved_length = math.max(0, dot / start_to_end - screen_info.diag * deadzone)
    progress = math.min(valid_moved_length / (screen_info.diag * (threshold - deadzone)), 1)
    
    local rotation_coeff;
    if fixed_dir.isn ~= fixed_dir.ise then rotation_coeff = -1 else rotation_coeff = 1 end
    
    -- Apply progress
    Renderer.rotate_stage(false, Renderer.lerp(0, 45 * rotation_coeff, progress))
    
    -- Only generate movelist once per state entry
    if not is_fixed_initial then
      operator_movelist = Game.get_slide_moves(fixed_dir)
    end
    
    -- Move operators and update ArrowTiles
    for _, parameters in pairs(operator_movelist) do
      Renderer.move_operator(
        parameters.id,
        parameters.origin,
        parameters.destination,
        progress)
      
      if not is_fixed_initial then 
        Renderer.update_arrowtile(
          parameters.id,
          parameters.origin,
          parameters.destination,
          progress)
      
      else Renderer.update_arrowtile(parameters.id, nil, nil, progress)
      end
    end
    
    if not is_fixed_initial then is_fixed_initial = true end
  end
end

function SlideState.mousereleased(button)
  if button == 1 then
    if fixed_dir then
      FSM.change_state(FSM.states.SlideCooldownState, {
          fixed_dir = fixed_dir,
          progress = progress, -- If 1 (100%), threshold is met
          operator_movelist = operator_movelist
        })
    else
      FSM.change_state(FSM.states.IdleState)
    end
  end
end

function SlideState.get_dir(x, y)
  -- isn = is north, ise = is east
  if x >= 0 and y < 0 then return {isn = true, ise = true}
  elseif x < 0 and y <= 0 then return {isn = true, ise = false}
  elseif x <= 0 and y > 0 then return {isn = false, ise = false}
  elseif x > 0 and y >= 0 then return {isn = false, ise = true}
  end
end

return SlideState