--!optimize 2
--!strict
local TextService = game:GetService("TextService")
local module = {}

local X_ALIGNMENT_MAP = {
	[Enum.TextXAlignment.Left] = Enum.HorizontalAlignment.Left,
	[Enum.TextXAlignment.Center] = Enum.HorizontalAlignment.Center,
	[Enum.TextXAlignment.Right] = Enum.HorizontalAlignment.Right,
}
local Y_ALIGNMENT_MAP = {
	[Enum.TextYAlignment.Top] = Enum.VerticalAlignment.Top,
	[Enum.TextYAlignment.Center] = Enum.VerticalAlignment.Center,
	[Enum.TextYAlignment.Bottom] = Enum.VerticalAlignment.Bottom,
}

-- Transforms a <code>TextLabel</code> into a <code>Frame</code> with many children for easy manipulation of letters. Letter index is stored in <code>LayoutOrder</code> for each <code>Frame</code>.
function module.TransformText(labelToTransform: TextLabel): Frame
	local originalText = labelToTransform.Text
	local originalSize = labelToTransform.Size
	local originalPosition = labelToTransform.Position
	local originalAnchorPoint = labelToTransform.AnchorPoint
	local originalRotation = labelToTransform.Rotation
	local originalParent = labelToTransform.Parent
	local originalName = labelToTransform.Name
	local originalFontFace = labelToTransform.FontFace
	local originalTextSize = labelToTransform.TextSize
	local originalTextColor = labelToTransform.TextColor3
	local originalTextTransparency = labelToTransform.TextTransparency
	local originalTextStrokeColor = labelToTransform.TextStrokeColor3
	local originalTextStrokeTransparency =
		labelToTransform.TextStrokeTransparency
	local originalXAlignment = labelToTransform.TextXAlignment
	local originalYAlignment = labelToTransform.TextYAlignment
	local originalBackgroundColor3 = labelToTransform.BackgroundColor3
	local originalBackgroundTransparency = labelToTransform.BackgroundTransparency

	local listFrame = Instance.new("Frame")
	listFrame.Name = originalName
	listFrame.Size = originalSize
	listFrame.Position = originalPosition
	listFrame.AnchorPoint = originalAnchorPoint
	listFrame.Rotation = originalRotation
	listFrame.BorderSizePixel = 0
	listFrame.BackgroundTransparency = 1
	listFrame.ClipsDescendants = true
	listFrame.BackgroundColor3 = originalBackgroundColor3
	listFrame.BackgroundTransparency = originalBackgroundTransparency

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Wraps = true
	layout.HorizontalAlignment =
		X_ALIGNMENT_MAP[originalXAlignment] or Enum.HorizontalAlignment.Left
	layout.VerticalAlignment =
		Y_ALIGNMENT_MAP[originalYAlignment] or Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = listFrame -- Parent layout immediately

	local spaceParams = Instance.new("GetTextBoundsParams")
	spaceParams.Font = originalFontFace
	spaceParams.Size = originalTextSize
	spaceParams.Text = " " -- Single space character
	local spaceSize: Vector2 = TextService:GetTextBoundsAsync(spaceParams)

	local charParams = Instance.new("GetTextBoundsParams")
	charParams.Font = originalFontFace
	charParams.Size = originalTextSize

	local textLength = utf8.len(originalText)
	local childrenToParent = table.create(textLength) -- Pre-allocate table
	local childIndex = 0

	for char in string.gmatch(originalText, ".") do
		local charSize: Vector2
		local isWhitespace = string.match(char, "%s")

		if isWhitespace then
			charSize = spaceSize
		else
			charParams.Text = char
			charSize = TextService:GetTextBoundsAsync(charParams)
		end

		local textContainer = Instance.new("Frame")
		textContainer.Name = char
		textContainer.BackgroundTransparency = 1
		textContainer.BorderSizePixel = 0
		textContainer.Size = UDim2.fromOffset(charSize.X, charSize.Y)
		textContainer.LayoutOrder = childIndex

		if not isWhitespace then
			local charLabel = Instance.new("TextLabel")
			charLabel.FontFace = originalFontFace
			charLabel.TextSize = originalTextSize
			charLabel.TextColor3 = originalTextColor
			charLabel.TextTransparency = originalTextTransparency
			charLabel.TextStrokeColor3 = originalTextStrokeColor
			charLabel.TextStrokeTransparency =
				originalTextStrokeTransparency
			charLabel.BackgroundTransparency = 1
			charLabel.Size = UDim2.fromScale(1, 1)
			charLabel.Text = char
			charLabel.TextXAlignment = originalXAlignment
			charLabel.TextYAlignment = Enum.TextYAlignment.Center
			charLabel.Parent = textContainer
		end

		childIndex += 1
		childrenToParent[childIndex] = textContainer
	end

	for i = 1, childIndex do
		childrenToParent[i].Parent = listFrame
	end

	table.clear(childrenToParent)

	listFrame.Parent = originalParent
	labelToTransform:Destroy()

	return listFrame
end

return module
