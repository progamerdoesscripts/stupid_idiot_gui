-- Loadstring: loadstring(game:HttpGet("https://pastebin.com/raw/96XzjEiK"))()
-- Note: Since this script relied on network ownership vulnerability of this game to work, you should keep a closer distance to unanchored parts than other players so the script can capture the network ownership of those parts.

local naturalDisasterSurvivalGravityInversionGui = Instance.new("ScreenGui")
naturalDisasterSurvivalGravityInversionGui.Name = tostring(math.random())
naturalDisasterSurvivalGravityInversionGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
naturalDisasterSurvivalGravityInversionGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
naturalDisasterSurvivalGravityInversionGui.ResetOnSpawn = false
naturalDisasterSurvivalGravityInversionGui.IgnoreGuiInset = true
naturalDisasterSurvivalGravityInversionGui.ClipToDeviceSafeArea = false
naturalDisasterSurvivalGravityInversionGui.DisplayOrder = -1e+09

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.FontFace = Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
toggleButton.TextColor3 = Color3.new(0.49, 0.49, 0.49)
toggleButton.Text = "(G) Gravity Inversion: ..."
toggleButton.AnchorPoint = Vector2.new(0, 1)
toggleButton.BackgroundColor3 = Color3.new(0.176, 0.176, 0.176)
toggleButton.Position = UDim2.new(0, 10, 1, -10)
toggleButton.BorderSizePixel = 0
toggleButton.BorderColor3 = Color3.new()
toggleButton.TextSize = 16
toggleButton.Size = UDim2.new(0, 175, 0, 25)
toggleButton.Parent = naturalDisasterSurvivalGravityInversionGui

local uIStroke = Instance.new("UIStroke")
uIStroke.Name = "UIStroke"
uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uIStroke.Color = Color3.new(0.49, 0.49, 0.49)
uIStroke.Thickness = 2
uIStroke.Parent = toggleButton

local uICorner = Instance.new("UICorner")
uICorner.Name = "UICorner"
uICorner.CornerRadius = UDim.new(0, 4)
uICorner.Parent = toggleButton

local uIScale = Instance.new("UIScale")
uIScale.Name = "UIScale"
uIScale.Parent = naturalDisasterSurvivalGravityInversionGui

local Players = game:GetService("Players")

local client = Players.LocalPlayer
local inversionEnabled = false

client.ReplicationFocus = workspace
if typeof(sethiddenproperty) == "function" then
	game:GetService("RunService").Heartbeat:Connect(function()
		if inversionEnabled then
			sethiddenproperty(client, "SimulationRadius", math.huge)
		end
	end)
else
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Warning",
		Text = `"sethiddenproperty" isn't supported; this may prevent you from controlling parts that are too far away`,
		Icon = "rbxasset://textures/StudioSharedUI/alert_error@2x.png",
		Button1 = "Close",
		Duration = 5
	})
end

local structureFolder

repeat
	for _, child in pairs(workspace:GetChildren()) do
		if child:IsA("Folder") and child.Name == "Structure" then
			structureFolder = child
		end
	end
	if not structureFolder then
		task.wait()
	end
until structureFolder

local instances = {}

function applyForce(instance)
	if
		inversionEnabled and
		instance:IsA("BasePart") and
		not instance.Anchored
	then
		local attachment = Instance.new("Attachment", instance)
		table.insert(instances, attachment)

		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.MaxForce = math.huge
		linearVelocity.VectorVelocity = Vector3.new(0, 35, 0)
		linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		linearVelocity.Attachment0 = attachment
		linearVelocity.Parent = instance
		table.insert(instances, linearVelocity)

		--instance.CanCollide = false
	end
end

local connection
local thread

function toggle()
	inversionEnabled = not inversionEnabled

	local color = Color3.new(1, 0, 0)
	if inversionEnabled then
		color = Color3.new(0, 1, 0)
		toggleButton.Text = "(G) Gravity Inversion: ON"
	else
		toggleButton.Text = "(G) Gravity Inversion: OFF"
	end
	toggleButton.TextColor3 = color
	uIStroke.Color = color

	if thread then
		task.cancel(thread)
	end

	thread = task.spawn(function()
		if connection then
			connection:Disconnect()
		end

		for _, instance in pairs(instances) do
			instance:Destroy()
		end

		table.clear(instances)

		if inversionEnabled then
			connection = structureFolder.DescendantAdded:Connect(applyForce)
			for _, descendant in pairs(structureFolder:GetDescendants()) do
				applyForce(descendant)
			end
		end
	end)
end

toggleButton.Activated:Connect(toggle)
game:GetService("ContextActionService"):BindAction(
	"toggleGravityInversion",
	function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			toggle()
		end
	end,
	false,
	Enum.KeyCode.G
)

toggle()

function updateUIScale()
	uIScale.Scale = naturalDisasterSurvivalGravityInversionGui.AbsoluteSize.Y / 400
end

naturalDisasterSurvivalGravityInversionGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateUIScale)
updateUIScale()

naturalDisasterSurvivalGravityInversionGui.Parent = game:GetService("CoreGui")
