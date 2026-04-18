local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Gas Tools",
    Icon = 0,
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "by Sirius",
    ShowText = "Rayfield",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "GasHub"
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Главная", 0)

-- Функция телепортации
local function TeleportTo(cframe)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    character.HumanoidRootPart.CFrame = cframe
    return true
end

-- Нажатие клавиши E
local function PressE()
    local virtualInput = game:GetService("VirtualInputManager")
    virtualInput:SendKeyEvent(true, "E", false, game)
    task.wait(0.05)
    virtualInput:SendKeyEvent(false, "E", false, game)
end

-- Клик по кнопке Sell
local function ClickSellButton()
    local player = game.Players.LocalPlayer
    local sellButton = player.PlayerGui:FindFirstChild("Main") and 
                       player.PlayerGui.Main:FindFirstChild("SellGas") and 
                       player.PlayerGui.Main.SellGas:FindFirstChild("Main") and
                       player.PlayerGui.Main.SellGas.Main:FindFirstChild("Sell")
    if sellButton and sellButton:IsA("ImageButton") then
        sellButton:Click()
        return true
    end
    return false
end

-- Целевой CFrame для заправки
local GasStationCFrame = CFrame.new(
    0.162336141, 12.1477346, 147.770447,
    -0.999991536, 8.74220376e-08, -0.00411896547,
    8.70626877e-08, 1, 8.74220376e-08,
    0.00411896547, 8.70626877e-08, -0.999991536
)

-- Выполнить действие на заправке (телепорт + E + Sell)
local function DoGasStationAction()
    TeleportTo(GasStationCFrame)
    task.wait(0.5)
    PressE()
    task.wait(0.3)
    ClickSellButton()
end

-- ========== КНОПКА 1: ручной телепорт к зданию ==========
MainTab:CreateButton({
    Name = "Телепорт к зданию (Plot1)",
    Callback = function()
        local targetBuilding = workspace.Plots.Plot1.Buildings["bd79c21d44b141508a5bfe4e8c3335b6"]
        if not targetBuilding then
            Rayfield:Notify({Title = "Ошибка", Content = "Здание не найдено", Duration = 3})
            return
        end
        local cframe = targetBuilding:IsA("BasePart") and targetBuilding.CFrame or targetBuilding:GetPivot()
        TeleportTo(cframe)
        Rayfield:Notify({Title = "Телепорт", Content = "Телепортировано к зданию", Duration = 2})
    end
})

-- ========== КНОПКА 2: ручной телепорт на заправку + E + Sell ==========
MainTab:CreateButton({
    Name = "Телепорт на заправку (ручной) + E + Sell",
    Callback = function()
        DoGasStationAction()
        Rayfield:Notify({Title = "Готово", Content = "Действие выполнено", Duration = 2})
    end
})

-- ========== TOGGLE 1: авто-телепорт к зданию каждую секунду ==========
local autoTeleportActive = false
local autoTeleportThread = nil

MainTab:CreateToggle({
    Name = "Авто-телепорт к зданию (каждую секунду)",
    CurrentValue = false,
    Flag = "AutoTeleportToggle",
    Callback = function(Value)
        autoTeleportActive = Value
        if autoTeleportActive then
            if autoTeleportThread then task.cancel(autoTeleportThread) end
            autoTeleportThread = task.spawn(function()
                while autoTeleportActive do
                    local targetBuilding = workspace.Plots.Plot1.Buildings["bd79c21d44b141508a5bfe4e8c3335b6"]
                    if targetBuilding then
                        local cframe = targetBuilding:IsA("BasePart") and targetBuilding.CFrame or targetBuilding:GetPivot()
                        TeleportTo(cframe)
                    end
                    task.wait(1)
                end
            end)
            Rayfield:Notify({Title = "Авто-телепорт", Content = "Включён (каждую секунду)", Duration = 2})
        else
            if autoTeleportThread then task.cancel(autoTeleportThread); autoTeleportThread = nil end
            Rayfield:Notify({Title = "Авто-телепорт", Content = "Выключен", Duration = 2})
        end
    end
})

-- ========== TOGGLE 2: автоматическая проверка GasPrice = 15 ==========
local autoGasActive = false
local autoGasThread = nil
local gasTriggered = false  -- чтобы не спамить, пока GasPrice = 15

MainTab:CreateToggle({
    Name = "Авто-проверка GasPrice = 15 (телепорт + E + Sell)",
    CurrentValue = false,
    Flag = "AutoGasToggle",
    Callback = function(Value)
        autoGasActive = Value
        if autoGasActive then
            if autoGasThread then task.cancel(autoGasThread) end
            gasTriggered = false
            autoGasThread = task.spawn(function()
                while autoGasActive do
                    local gasPrice = game:GetService("ReplicatedStorage"):FindFirstChild("GasPrice")
                    if gasPrice and gasPrice.Value == 15 then
                        if not gasTriggered then
                            gasTriggered = true
                            -- Выполняем действие
                            DoGasStationAction()
                            Rayfield:Notify({Title = "Авто-газ", Content = "GasPrice = 15, действие выполнено", Duration = 2})
                        end
                    else
                        -- Если значение изменилось, сбрасываем флаг, чтобы можно было сработать снова
                        gasTriggered = false
                    end
                    task.wait(1)  -- проверяем каждую секунду
                end
            end)
            Rayfield:Notify({Title = "Авто-газ", Content = "Включён (проверка GasPrice каждую секунду)", Duration = 2})
        else
            if autoGasThread then task.cancel(autoGasThread); autoGasThread = nil end
            gasTriggered = false
            Rayfield:Notify({Title = "Авто-газ", Content = "Выключен", Duration = 2})
        end
    end
})
