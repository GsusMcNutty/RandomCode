--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
tick = 0
delay = 15
muzzleVelocity = 1000
myVelocity = 0
gravity = 900

-- Tick function that will be executed every logic tick
function onTick()
    if (tick <= 1) then
        savedX = input.getNumber(1)
        savedZ = input.getNumber(2)
        savedY = input.getNumber(3)
        currentX = input.getNumber(1)
        currentZ = input.getNumber(2)
        currentY = input.getNumber(3)
        muzzleVelocity = input.getNumber(10)
        turretDirection = input.getNumber(12)
    end
    if (tick == delay) then
        myVelocity = input.getNumber(11)
        currentX = input.getNumber(4)
        currentZ = input.getNumber(5)
        currentY = input.getNumber(6)
        myX = input.getNumber(7)
        myZ = input.getNumber(8)
        myY = input.getNumber(9)

    end

    if (tick > delay) then
        output.setNumber(1, AimAngle())
        output.setNumber(2, DropFormula(muzzleVelocity, (currentY), gravity))
    end

    if (tick >= delay * 2) then
        tick = 0
    end

    tick = tick + 1
end
--replace with radar azimuth
function TargetDirection()
    return math.atan((currentX - myX), (currentZ - myZ)) * 180 / math.pi
end
function TargetHeading()
    return math.atan((currentX - savedX ), (currentZ- savedZ)) * 180/math.pi
end
--use x or y not both
function TargetSpeed()
    if (myX < currentX) or (myZ > currentZ) then
        if (currentX > savedX) and (currentZ > savedZ) then
            targetVelocity = math.sqrt(((currentZ - savedZ) * (currentZ - savedZ))) /
                (60)
            return (targetVelocity * -1) - (myVelocity / 60)
        end
        if (currentX < savedX) and (currentZ < savedZ) then
            targetVelocity = math.sqrt(((currentZ - savedZ) * (currentZ - savedZ))) /
                (60)
            return (targetVelocity) - (myVelocity / 60)
        end
    end
    if (myX > currentX) or (myZ < currentZ)then
        if (currentX > savedX) and (currentZ < savedZ)then
            targetVelocity = math.sqrt(((currentZ - savedZ) * (currentZ - savedZ))) /
                (60)
                return targetVelocity * -1 - (myVelocity/60)
        end
        if (currentX < savedX) and (currentZ > savedZ)then
            targetVelocity = math.sqrt(((currentZ - savedZ) * (currentZ - savedZ))) /
                (60)
                return (targetVelocity * -1) - (myVelocity/60)
        end
    end
    return 0
end

function DistanceToTarget()
    return math.sqrt(((currentX - myX) * (currentX - myX)) + ((currentZ - myZ) * (currentZ - myZ)))
end

function t()
    return DistanceToTarget()/(muzzleVelocity/60)
end

function LeadAngle()
    return math.atan(TargetSpeed() * (t() / DistanceToTarget()))* 180/math.pi
end

function AimAngle()
    return TargetDirection() + LeadAngle()
end

function DropFormula(v,h,g)
    drop = v * (math.sqrt((2*h)/g))
    return drop
end