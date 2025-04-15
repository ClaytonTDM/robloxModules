--!optimize 2
--!strict
local module = {}

local TextService = game:GetService("TextService")

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

-- Creates a <code>Frame</code> from a <code>TextLabel</code> for easy manipulation of letters.
-- Intended to be used with <code>InsertLetter(listFrame: Frame, letter: string, index: number): Frame?</code>
function module.CreateFrameFromLabel(labelTemplate: TextLabel): Frame
	local originalText = labelTemplate.Text
	local originalSize = labelTemplate.Size
	local originalPosition = labelTemplate.Position
	local originalAnchorPoint = labelTemplate.AnchorPoint
	local originalRotation = labelTemplate.Rotation
	local originalName = labelTemplate.Name
	local originalBackgroundColor3 = labelTemplate.BackgroundColor3
	local originalBackgroundTransparency = labelTemplate.BackgroundTransparency
	local originalXAlignment = labelTemplate.TextXAlignment
	local originalYAlignment = labelTemplate.TextYAlignment

	local listFrame = Instance.new("Frame")
	listFrame.Name = originalName
	listFrame.Size = originalSize
	listFrame.Position = originalPosition
	listFrame.AnchorPoint = originalAnchorPoint
	listFrame.Rotation = originalRotation
	listFrame.BorderSizePixel = 0
	listFrame.BackgroundTransparency = 1
	listFrame.ClipsDescendants = true
	listFrame:SetAttribute("OriginalBackgroundColor3", originalBackgroundColor3)
	listFrame:SetAttribute(
		"OriginalBackgroundTransparency",
		originalBackgroundTransparency
	)
	listFrame:SetAttribute("OriginalText", originalText)

	local layout = Instance.new("UIListLayout")
	layout.Name = "LetterLayout"
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Wraps = true
	layout.HorizontalAlignment =
		X_ALIGNMENT_MAP[originalXAlignment] or Enum.HorizontalAlignment.Left
	layout.VerticalAlignment =
		Y_ALIGNMENT_MAP[originalYAlignment] or Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = listFrame

	return listFrame
end

-- Transforms a <code>TextLabel</code> into a <code>Frame</code> for easy manipulation of letters.
-- Letter index is stored in <code>LayoutOrder</code> for each <code>Frame</code>.
-- Stores necessary style information as attributes on the returned <code>Frame</code>.
function module.TransformText(labelToTransform: TextLabel): Frame
	local originalText = labelToTransform.Text
	local originalParent = labelToTransform.Parent
	local originalFontFace = labelToTransform.FontFace
	local originalTextSize = labelToTransform.TextSize
	local originalTextColor = labelToTransform.TextColor3
	local originalTextTransparency = labelToTransform.TextTransparency
	local originalTextStrokeColor = labelToTransform.TextStrokeColor3
	local originalTextStrokeTransparency =
		labelToTransform.TextStrokeTransparency
	local originalXAlignment = labelToTransform.TextXAlignment
	local originalBackgroundColor3 = labelToTransform.BackgroundColor3
	local originalBackgroundTransparency = labelToTransform.BackgroundTransparency

	local listFrame = module.CreateFrameFromLabel(labelToTransform)
	listFrame.BackgroundColor3 = originalBackgroundColor3
	listFrame.BackgroundTransparency = originalBackgroundTransparency

	listFrame:SetAttribute("LetterFontFace", originalFontFace)
	listFrame:SetAttribute("LetterTextSize", originalTextSize)
	listFrame:SetAttribute("LetterTextColor3", originalTextColor)
	listFrame:SetAttribute("LetterTextTransparency", originalTextTransparency)
	listFrame:SetAttribute("LetterTextStrokeColor3", originalTextStrokeColor)
	listFrame:SetAttribute(
		"LetterTextStrokeTransparency",
		originalTextStrokeTransparency
	)
	listFrame:SetAttribute("LetterTextXAlignment", originalXAlignment)

	local spaceParams = Instance.new("GetTextBoundsParams")
	spaceParams.Font = originalFontFace
	spaceParams.Size = originalTextSize
	spaceParams.Text = " "
	local success, spaceSize: Vector2 = pcall(function()
		return TextService:GetTextBoundsAsync(spaceParams)
	end)
	if success then
		listFrame:SetAttribute("SpaceSizeX", spaceSize.X)
		listFrame:SetAttribute("SpaceSizeY", spaceSize.Y)
	else
		listFrame:SetAttribute("SpaceSizeX", 10)
		listFrame:SetAttribute("SpaceSizeY", 10)
	end

	local charParams = Instance.new("GetTextBoundsParams")
	charParams.Font = originalFontFace
	charParams.Size = originalTextSize

	local textLength = utf8.len(originalText) :: number
	local childrenToParent: { Frame } = table.create(textLength) :: { Frame }
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
			charLabel.Name = "CharLabel"
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

-- Inserts a new letter (<code>Frame</code>) into the <code>listFrame</code> at the specified index.
-- Adjusts <code>LayoutOrder</code> of subsequent letters.
-- Returns the newly created letter <code>Frame</code> or <code>nil</code> if attributes are missing.
function module.InsertLetter(
	listFrame: Frame,
	letter: string,
	index: number
): Frame?
	local fontFace = listFrame:GetAttribute("LetterFontFace") :: Font?
	local textSize = listFrame:GetAttribute("LetterTextSize") :: number?
	local textColor = listFrame:GetAttribute("LetterTextColor3") :: Color3?
	local textTransparency =
		listFrame:GetAttribute("LetterTextTransparency") :: number?
	local textStrokeColor =
		listFrame:GetAttribute("LetterTextStrokeColor3") :: Color3?
	local textStrokeTransparency =
		listFrame:GetAttribute("LetterTextStrokeTransparency") :: number?
	local textXAlignment =
		listFrame:GetAttribute("LetterTextXAlignment") :: Enum.TextXAlignment?
	local spaceSizeX = listFrame:GetAttribute("SpaceSizeX") :: number?
	local spaceSizeY = listFrame:GetAttribute("SpaceSizeY") :: number?

	if not (
			fontFace
				and textSize
				and textColor
				and textTransparency
				and textStrokeColor
				and textStrokeTransparency
				and textXAlignment
				and spaceSizeX
				and spaceSizeY
	) then
		warn(
			"Cannot InsertLetter: listFrame is missing required style attributes."
		)
		return nil
	end

	local spaceSize = Vector2.new(spaceSizeX, spaceSizeY)

	local currentLetters: { Frame } = {}
	for _, child in ipairs(listFrame:GetChildren()) do
		if child:IsA("Frame") then
			table.insert(currentLetters, child)
		end
	end

	index = math.clamp(index, 0, #currentLetters)

	for _, childFrame in ipairs(currentLetters) do
		if childFrame.LayoutOrder >= index then
			childFrame.LayoutOrder += 1
		end
	end

	local charSize: Vector2
	local isWhitespace = string.match(letter, "%s")

	if isWhitespace then
		charSize = spaceSize
	else
		local charParams = Instance.new("GetTextBoundsParams")
		charParams.Font = fontFace
		charParams.Size = textSize
		charParams.Text = letter
		charSize = TextService:GetTextBoundsAsync(charParams)
	end

	local textContainer = Instance.new("Frame")
	textContainer.Name = letter
	textContainer.BackgroundTransparency = 1
	textContainer.BorderSizePixel = 0
	textContainer.Size = UDim2.fromOffset(charSize.X, charSize.Y)
	textContainer.LayoutOrder = index

	if not isWhitespace then
		local charLabel = Instance.new("TextLabel")
		charLabel.Name = "CharLabel"
		charLabel.FontFace = fontFace
		charLabel.TextSize = textSize
		charLabel.TextColor3 = textColor
		charLabel.TextTransparency = textTransparency
		charLabel.TextStrokeColor3 = textStrokeColor
		charLabel.TextStrokeTransparency = textStrokeTransparency
		charLabel.BackgroundTransparency = 1
		charLabel.Size = UDim2.fromScale(1, 1)
		charLabel.Text = letter
		charLabel.TextXAlignment = textXAlignment
		charLabel.TextYAlignment = Enum.TextYAlignment.Center
		charLabel.Parent = textContainer
	end

	textContainer.Parent = listFrame

	return textContainer
end

return module
