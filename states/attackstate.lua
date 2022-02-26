-- This is a state module, not a class
-- Perform attack animations for operators and apply HP changes
-- Attack animation finished -> attackcooldown

local AttackState = {}

local FSM, Game, Renderer;
function AttackState.init(fsm, game, renderer)
  FSM, Game, Renderer = fsm, game, renderer
end

local fixed_dir;

function AttackState.enter(args)
  fixed_dir = args.fixed_dir -- fixed_dir is not used here but is needed in AttackCooldownState
  local attacklist = AttackState.extract_attacklist(args.operator_movelist)
  local victimlist = {}
  for _, attack in pairs(attacklist) do
    local attacker_id = Game.get_gameoperator(attack.attacker_coords).id
    local victim_id = Game.get_gameoperator(attack.victim_coords).id
    Renderer.add_attack_pair(attacker_id, victim_id)
    
    victimlist[victim_id] = true
  end
  
  --[[All operators being attacked (victims) are removed immediately from logic,
  albeit going through a death animation visually]]--
  Game.remove_gameoperators(victimlist)
  
  Renderer.start_attack()
end

function AttackState.finish()
  -- Clear all attack-related state variables in Renderer
  Renderer.clear_attacks()
end

function AttackState.update(dt)
  -- AttackState is finished when all attacks are finished in Renderer
  if Renderer.get_active_attacks() == 0 then
    FSM.change_state(FSM.states.AttackCooldownState, {fixed_dir = fixed_dir})
  end
end

local function draw_status_text()
  Renderer.draw_text("Attack")
end

AttackState.draw = {[3] = draw_status_text}

-- operator_movelist contains both move and attack data, extract the latter
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