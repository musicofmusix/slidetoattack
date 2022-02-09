--[[
This module provides an interface for accessing Spine-Love's essential features
]]--

local spine = require "spine-love.spine"

local SpineLib = {assetdir = "assets"}
local renderer_instance;

function SpineLib:new(chardir, default_animation, scale)
	-- Class operations done here
	local instance = {default_animation = default_animation, scale = scale}
	self.__index = self
	setmetatable(instance, self)

	local loader = function () return love.graphics.newImage(self.assetdir .. "/" .. chardir .. ".png") end
	local atlas = spine.TextureAtlas.new(spine.utils.readFile(self.assetdir .. "/" .. chardir .. ".atlas"), loader)

	local json = spine.SkeletonJson.new(spine.AtlasAttachmentLoader.new(atlas))
	json.scale = scale

	local skeleton_data = json:readSkeletonDataFile(self.assetdir .. "/" .. chardir .. ".json")
	instance.skeleton = spine.Skeleton.new(skeleton_data)

	instance.skeleton.scaleY = -1 -- Need this or things are flipped upside down

	instance.skeleton:setToSetupPose()

	instance.state = spine.AnimationState.new(spine.AnimationStateData.new(skeleton_data))

	instance.state:setAnimationByName(0, default_animation, true)

	instance.state.onEvent = function (entry, event)
	  if event.data.name == "something" then
      -- do something
	  end
	end

	-- Implement when needed
	instance.state.onStart = function(entry) end
	instance.state.onEnd = function(entry) end
	instance.state.onComplete = function(entry) end

	instance.state:apply(instance.skeleton)

	return instance
end

function SpineLib:set_pose(pose_name, loop)
    self.state:setAnimationByName(0, pose_name, loop)
end

function SpineLib:set_xscale(new_scale)
  self.skeleton.scaleX = new_scale
end

function SpineLib:update(dt)
	self.state:update(dt)
	self.state:apply(self.skeleton)

	self.skeleton:updateWorldTransform()
end

function SpineLib:draw(skeleton_renderer, x, y) -- We only need one renderer
	if skeleton_renderer then
	  self.skeleton.x, self.skeleton.y = x, y
	  skeleton_renderer:draw(self.skeleton)
	  end
end

function SpineLib.new_renderer() -- No need for self; hence the single colon
	if not renderer_instance then
		renderer_instance = spine.SkeletonRenderer.new(true)
	end
	return renderer_instance
end

return SpineLib