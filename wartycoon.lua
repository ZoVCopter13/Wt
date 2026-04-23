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

-- Поиск Particle по всем участкам (Plot1 - Plot6)
local function FindParticle()
    local plots = {
        workspace.Plots.Plot1,
        workspace.Plots.Plot2,
        workspace.Plots.Plot3,
        workspace.Plots.Plot4,
        workspace.Plots.Plot5,
        workspace.Plots.Plot6
    }
    
    for _, plot in ipairs(plots) do
        local particle = plot:FindFirstChild("Buildings") and 
                         plot.Buildings:FindFirstChild("f10f961bb2cc4eea9f9a66c79c892ed6") and
                         plot.Buildings["f10f961bb2cc4eea9f9a66c79c892ed6"]:FindFirstChild("Model") and
                         plot.Buildings["f10f961bb2cc4eea9f9a66c79c892ed6"].Model:FindFirstChild("Particle")
        if particle then
            return particle
        end
    end
    return nil
end

-- Нажатие клавиши E
local function PressE()
    local virtualInput = game:GetService("VirtualInputManager")
    virtualInput:SendKeyEvent(true, "E", false, game)
    task.wait(0.05)
    virtualInput:SendKeyEvent(false, "E", false, game)
end

-- Вызов RemoteEvent SellGas
local function SellGasViaRemote()
    local sellGasEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
                        and game.ReplicatedStorage.Packages:FindFirstChild("Knit")
                        and game.ReplicatedStorage.Packages.Knit:FindFirstChild("Services")
                        and game.ReplicatedStorage.Packages.Knit.Services:FindFirstChild("BaseService")
                        and game.ReplicatedStorage.Packages.Knit.Services.BaseService:FindFirstChild("RE")
                        and game.ReplicatedStorage.Packages.Knit.Services.BaseService.RE:FindFirstChild("SellGas")
    
    if sellGasEvent then
        sellGasEvent:FireServer()
        return true
    else
        warn("RemoteEvent SellGas не найден!")
        return false
    end
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
    SellGasViaRemote()
end

-- ========== КНОПКА 1: ручной телепорт к Particle ==========
MainTab:CreateButton({
    Name = "Телепорт к Particle",
    Callback = function()
        local particle = FindParticle()
        if not particle then
            Rayfield:Notify({Title = "Ошибка", Content = "Particle не найден ни на одном участке", Duration = 3})
            return
        end
        local cframe = particle:IsA("BasePart") and particle.CFrame or particle:GetPivot()
        TeleportTo(cframe)
        Rayfield:Notify({Title = "Телепорт", Content = "Телепортировано к Particle", Duration = 2})
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

-- ========== TOGGLE 1: авто-телепорт к Particle каждую секунду ==========
local autoTeleportActive = false
local autoTeleportThread = nil

MainTab:CreateToggle({
    Name = "Авто-телепорт к Particle (каждую секунду)",
    CurrentValue = false,
    Flag = "AutoTeleportToggle",
    Callback = function(Value)
        autoTeleportActive = Value
        if autoTeleportActive then
            if autoTeleportThread then task.cancel(autoTeleportThread) end
            autoTeleportThread = task.spawn(function()
                while autoTeleportActive do
                    local particle = FindParticle()
                    if particle then
                        local cframe = particle:IsA("BasePart") and particle.CFrame or particle:GetPivot()
                        TeleportTo(cframe)
                    end
                    task.wait(1)
                end
            end)
            Rayfield:Notify({Title = "Авто-телепорт", Content = "Включён (Particle каждую секунду)", Duration = 2})
        else
            if autoTeleportThread then task.cancel(autoTeleportThread); autoTeleportThread = nil end
            Rayfield:Notify({Title = "Авто-телепорт", Content = "Выключен", Duration = 2})
        end
    end
})

-- ========== TOGGLE 2: автоматическая проверка GasPrice = 15 ==========
local autoGasActive = false
local autoGasThread = nil
local gasTriggered = false

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
                            DoGasStationAction()
                            Rayfield:Notify({Title = "Авто-газ", Content = "GasPrice = 15, действие выполнено", Duration = 2})
                        end
                    else
                        gasTriggered = false
                    end
                    task.wait(1)
                end
            end)
            Rayfield:Notify({Title = "Авто-газ", Content = "Включён (проверка GasPrice = 15 каждую секунду)", Duration = 2})
        else
            if autoGasThread then task.cancel(autoGasThread); autoGasThread = nil end
            gasTriggered = false
            Rayfield:Notify({Title = "Авто-газ", Content = "Выключен", Duration = 2})
        end
    end
})
