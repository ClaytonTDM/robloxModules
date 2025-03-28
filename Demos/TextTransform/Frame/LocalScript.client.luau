local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = require(ReplicatedStorage.TextTransform)
local db = true

script.Parent.TextButton.MouseButton1Click:Connect(function()
	if not db then
		return
	end
	db = false
	script.Parent.TextButton.Text = "Transforming..."
	module.TransformText(script.Parent.TextLabel)
	script.Parent.TextButton.Text = "Transformed!"
end)