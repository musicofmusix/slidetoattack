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
  local attacklist = AttackState.extract_attacklist(args.operator_movelist)
  for _, attack in pairs(attacklist) do
    local attacker_id = Game.get_gameoperator(attack.attacker_coords).id
    local victim_id = Game.get_gameoperator(attack.victim_coords).id
    Renderer.add_attack_pair(attacker_id, victim_id)
  end
  
  Renderer.start_attack()
end

function AttackState.finish()
  Renderer.clear_attacks()
end

function AttackState.update(dt)
  count = math.max(count - dt, 0)
  
  if count == 0 then
    -- Disable state change until last operator attack/death detection
    --FSM.change_state(FSM.states.AttackCooldownState, {fixed_dir = fixed_dir})
  end
end

-- operator_movelist contains both move and attack data
function AttackState.extract_attacklist(movelist)
  local attacklist = {}
  for _, parameters in pairs(movelist) do
    if parameters.attack_target then
      table.insert(attacklist,
        {attacker_coords = parameters.destination, victim_coords = parameters.attack_target})
    end
  end
  return attacklist
end

return AttackState