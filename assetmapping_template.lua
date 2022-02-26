-- Rename this file to assetmapping.lua and place it inside /assets
-- Everything here assumes the root directory is /assets

local AssetMapping = {}

local friendly_prefix = "subdirectory"
local enemy_prefix = "subdirectory"

local friendlies = {
"Soldier/SniperRifle",
}

local enemies = {
  "EnemySoldier/SMG"
}

local font_dir = "font/some_font.ttf"

function AssetMapping.get_name(is_friendly)
  if is_friendly then
    local index = math.random(#friendlies)
    return friendly_prefix .. friendlies[index]
  else
    local index = math.random(#enemies)
    return enemy_prefix .. enemies[index]
  end
end

function AssetMapping.get_font()
  return "assets/" .. font_dir
end

return AssetMapping