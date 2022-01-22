-- Rename this file to assetmapping.lua and place it inside /assets

local AssetMapping = {}

local friendlies = {}
local enemies = {}

friendlies.melee = {
  "spine2d_sprite_subdirectory/filename_without_extension"
}
friendlies.ranged = {}

enemies.melee = {}
enemies.ranged = {}

function AssetMapping.get_name(is_friendly, class)
  if is_friendly then
    local index = math.random(#friendlies[class])
    return friendlies[class][index]
  else
    local index = math.random(#enemies[class])
    return enemies[class][index]
  end
end

return AssetMapping