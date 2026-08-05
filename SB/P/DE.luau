for i=1,2000 do
print(" scroll down")
end
for i=1,100 do
print(" ")
end

local TestSettings = {
    ["Minimum slaps to detect"] = 1000; -- Glove must have minimum 1000 slaps to get detected
    ["Slaps Detection"] = 2.5; -- Trigger will be equal to player's slaps divided by 2.5
    ["Test Halloween Gloves"] = true; -- May be wrongful sometimes
}

function TestForExploits(plr)
local plr = plr or game:GetService("Players").LocalPlayer
print("----- ⚙ testing player '"..plr.Name.."' ⚙ -----")
local function parsetable(str)
    local tbl = {}
    for num in str:gmatch("(%d+)") do
        tbl[#tbl+1] = tostring(num)
    end
    return tbl
end
local DetectedGloves = {}
local function TestGloves()
local gloves = plr:WaitForChild("_unlockedGloves")
local crg = tostring(plr:WaitForChild("leaderstats"):WaitForChild("Glove").Value)
local crs = tonumber(plr:WaitForChild("leaderstats"):WaitForChild("Slaps").Value)
local bqp = game:GetService("HttpService"):JSONDecode(game:GetService("ReplicatedStorage").PlayerData:WaitForChild(plr.Name):WaitForChild("BadgeQuestProgress").Value)
local plaintable = game:GetService("ReplicatedStorage").PlayerData:WaitForChild(plr.Name):WaitForChild("UnlockedBadges").Value
local rentval = game:GetService("ReplicatedStorage").PlayerData:WaitForChild(plr.Name):WaitForChild("GloveRentSessions").Value
if gloves[crg].Value==false and rentval=="[]" then
DetectedGloves[crg]="Infinite rent violation ; missing '"..crg.."' | bug abusing"
end
if gloves.Shard.Value==false and gloves.Frostbite.Value==true then
DetectedGloves["Frostbite"]="Frostbite violation [ straight teleport to PlaceId '17290438723' ; missing 'Shard' | exploits ]"
end
if gloves.Rage.Value==false and gloves.Hybrid.Value==true then
DetectedGloves["Hybrid"]="Hybrid violation [ exploitation of remote 'GRRRRR' ; missing 'Rage' | exploits ]"
end
if gloves.Reverse.Value==false and gloves.Recall.Value==true then
DetectedGloves["Recall"]="Recall violation [ exploitation of remotes 'RecallReset', 'RecallLastInteractionSteps' ; missing 'Reverse' | exploits ]"
end
if (gloves.Recall.Value==false or gloves.Reverse.Value==false) and gloves.Admin.Value==true then
DetectedGloves["Admin"]="Admin violation [ exploitation of replicated assets ; missing 'Recall'/'Reverse' | exploits ]"
end
if gloves.Alchemist.Value==false and gloves.Firework.Value==true then
DetectedGloves["Firework"]="Firework violation [ exploitation of remote 'AlchemistEvent' ; missing 'Alchemist' | exploits ]"
end
if gloves.Extended.Value==false and gloves.Glovel.Value==true then
DetectedGloves["Glovel"]="Glovel violation [ exploitation of remotes 'DigEvent', 'OpenRemote' ; missing 'Extended' | exploits ]"
end
if not string.find(plaintable,"2124775097") and gloves.Fan.Value==true then
DetectedGloves["Fan"]="Fan violation [ straight teleport to PlaceId '7234087065' | exploits ]"
end
if not string.find(plaintable,"2124775097") and gloves.Boxer.Value==true then
DetectedGloves["Boxer"]="Boxer violation [ straight teleport to PlaceId '7234087065' | exploits ]"
end
if not string.find(plaintable,"2124775097") and gloves.Riftshot.Value==true then
DetectedGloves["Riftshot"]="Riftshot violation [ straight teleport to PlaceId '7234087065' | exploits ]"
end
if not string.find(plaintable,"2124775097") and gloves["Untitled Tag Glove"].Value==true then
DetectedGloves["Untitled Tag Glove"]="Untitled Tag Glove violation [ straight teleport to PlaceId '7234087065' | exploits ]"
end
if not string.find(plaintable,"2124775097") and gloves.Clock.Value==true then
DetectedGloves["Clock"]="Clock violation [ straight teleport to PlaceId '7234087065' | exploits ]"
end
if not string.find(plaintable,"2124775097") and gloves.Metaverse.Value==true then
DetectedGloves["Metaverse"]="Metaverse violation [ straight teleport to PlaceId '7234087065' | exploits ]"
end
if not string.find(plaintable,"2124775097") and gloves.Dave.Value==true then
DetectedGloves["Dave"]="Dave violation [ straight teleport to PlaceId '7234087065' | exploits ]"
end
if not string.find(plaintable,"2124775097") and gloves.mortis.Value==true then
DetectedGloves["mortis"]="mortis violation [ straight teleport to PlaceId '7234087065' | exploits ]"
end
if gloves.Alchemist.Value==false and gloves.Bind.Value==true then
DetectedGloves["Bind"]="Bind violation [ straight teleport to PlaceId '74169485398268' ; missing 'Alchemist' | exploits ]"
end
if plr.AccountAge<271 and gloves.Poltergeist.Value==true and TestSettings["Test Halloween Gloves"] then
DetectedGloves["Poltergeist"]="Poltergeist violation [ straight teleport to PlaceId '103505724406848' ; wasn't in halloween event | exploits ]"
end
if plr.AccountAge<271 and gloves.Poltergeist.Value==true and TestSettings["Test Halloween Gloves"] then
DetectedGloves["Harvester"]="Harvester violation [ straight teleport to PlaceId '92483185275059' ; wasn't in halloween event | exploits ]"
end
if gloves.Retro.Value==false and gloves.Swordfighter.Value==true then
DetectedGloves["Retro"]="Retro violation [ exploitation of remote 'RetroAbility' ; missing 'Retro' | exploits ]"
end
if bqp._questFourSeasons.completed==false and gloves.Penguin.Value==true then
DetectedGloves["Penguin"]="Penguin violation [ straight teleport to PlaceId '78804514423551' ; missing completed quest 'Four Seasons' | exploits ]"
end
if bqp._questFourSeasons.completed==false and gloves.Lotus.Value==true then
DetectedGloves["Lotus"]="Lotus violation [ straight teleport to PlaceId '78804514423551' ; missing completed quest 'Four Seasons' | exploits ]"
end
if bqp._questFourSeasons.completed==false and gloves.Conker.Value==true then
DetectedGloves["Conker"]="Conker violation [ straight teleport to PlaceId '78804514423551' ; missing completed quest 'Four Seasons' | exploits ]"
end
-- Apparently you can get it without elude
--[[if gloves.Elude.Value==false and gloves.Doorkeeper.Value==true then
DetectedGloves["Doorkeeper"]="Doorkeeper violation [ straight teleport to PlaceId '125845699717230' ; missing 'Elude' | exploits ]"
end]]
if gloves.Ghost.Value==false and gloves.Camera.Value==true then
DetectedGloves["Camera"]="Camera violation [ exploitation of remote 'IsPhotoValid' ; missing 'Ghost' | exploits ]"
end
end
local DetectedSlaps = {}
local function TestSlaps()
local gloves = plr:WaitForChild("_unlockedGloves")
local crg = tostring(plr:WaitForChild("leaderstats"):WaitForChild("Glove").Value)
local crs = tonumber(plr:WaitForChild("leaderstats"):WaitForChild("Slaps").Value)
local pgs = game:GetService("HttpService"):JSONDecode(game:GetService("ReplicatedStorage").PlayerData:WaitForChild(plr.Name):WaitForChild("PerGloveSlaps").Value)
local plaintable = game:GetService("ReplicatedStorage").PlayerData:WaitForChild(plr.Name):WaitForChild("UnlockedBadges").Value
for key,value in pairs(pgs) do
if value > TestSettings["Minimum slaps to detect"] and value > (crs/TestSettings["Slaps Detection"]) then
if key == "Snow" or key == "Replica" or key == "Reverse" or key == "el gato" or key == "Baller" or key == "Blink" or key == "Boxer" or key == "Mace" or key == "Clock" or key == "Tycoon" or key == "God's Hand" or key == "Reaper" or key=="Lag" then
if key == "Snow" then
DetectedSlaps["Snow"]="Snow violation [ exploitation of remote 'SnowHit' ; serverhop method ; total farmed: "..tostring(value).." slaps | exploits ]"
end
if key == "Replica" or key == "Baller" or key == "Blink" then
DetectedSlaps[key]=""..key.." violation [ exploitation of remote 'b' ; manual farming ; total farmed: "..tostring(value).." slaps | exploits ]"
end
if key == "Tycoon" or key == "God's Hand" then
DetectedSlaps[key]=""..key.." violation [ exploitation of multiple remotes ; manual farming at bob's bossfight ; total farmed: "..tostring(value).." slaps | exploits ]"
end
if key == "Reaper" and (crs-value)>11749 then
DetectedSlaps["Reaper"]="Reaper violation [ exploitation of remote 'ReaperHit' and 'Reversed' property ; manual farming ; total farmed: "..tostring(value).." slaps | exploits ]"
end
if key == "Lag" then
DetectedSlaps["Lag"]="Lag violation [ exploitation of remote 'GeneralHit' and it's infinite range ; manual farming ; total farmed: "..tostring(value).." slaps | exploits ]"
end
if key == "Boxer" then
DetectedSlaps["Boxer"]="Boxer violation [ exploitation of remote 'Boxing' ; manual farming ; total farmed: "..tostring(value).." slaps | exploits ]"
end
if key == "Mace" or key == "Clock" then
DetectedSlaps[key]=""..key.." violation [ exploitation of remote 'GeneralHit' ; manual farming ; total farmed: "..tostring(value).." slaps | exploits ]"
end
if key == "Reverse" or key == "el gato" then
DetectedSlaps[key]=""..key.." violation [ exploitation of 'Reversed' property and duplicates ; manual farming ; total farmed: "..tostring(value).." slaps | exploits ]"
end
end
end
end
end
local DetectedMasteries = {}
local function TestMasteries()
local gloves = plr:WaitForChild("_unlockedGloves")
local crg = tostring(plr:WaitForChild("leaderstats"):WaitForChild("Glove").Value)
local crs = tonumber(plr:WaitForChild("leaderstats"):WaitForChild("Slaps").Value)
local gmp = game:GetService("HttpService"):JSONDecode(game:GetService("ReplicatedStorage").PlayerData:WaitForChild(plr.Name):WaitForChild("GloveMasteryProgress").Value)
if gmp.Stalker~=nil and gmp.Stalker.AmbushStreak~=nil and gmp.Stalker.AmbushStreak>100 then
DetectedMasteries["Stalker"]="Stalker violation [ A near impossible streak ("..tostring(gmp.Stalker.AmbushStreak)..") | slap farming/exploits ]"
end
if gmp.Glovel~=nil and gmp.Glovel.CritStreak~=nil and gmp.Glovel.CritStreak>100 then
DetectedMasteries["Glovel"]="Glovel violation [ A near impossible streak ("..tostring(gmp.Glovel.CritStreak)..") | mastery farming/slap farming/exploits ]"
end
if gmp.Wormhole~=nil and gmp.Wormhole.Placements~=nil and gmp.Wormhole.Placements>3000 then
DetectedMasteries["Wormhole"]="Wormhole violation [ A near impossible placement value ("..tostring(gmp.Wormhole.Placements)..") | exploits ]"
end
if gmp.Fort~=nil and gmp.Fort.Smashes~=nil and gmp.Fort.BuildWalls~=nil and gmp.Fort.BuildWalls>1200 and (gmp.Fort.BuildWalls-gmp.Fort.Smashes)<20 then
DetectedMasteries["Fort"]="Fort violation [ A near impossible smashes and wall creations ratio ("..tostring(gmp.Fort.BuildWalls-gmp.Fort.Smashes)..") | mastery farming/exploits ]"
end
end
local passedtests = 0
-- Testing Gloves
TestGloves()
if next(DetectedGloves)~=nil then
print("gloves test: failed ⛔")
for i,v in next, DetectedGloves do
warn("⚠ "..i.." ⚠", v)
end
else
passedtests = passedtests + 1
print("gloves test: passed ✅")
end
-- Testing Slaps
TestSlaps()
if next(DetectedSlaps)~=nil then
print("slaps test: failed ⛔")
for i,v in next, DetectedSlaps do
warn("⚠ "..i.." ⚠", v)
end
else
passedtests = passedtests + 1
print("slaps test: passed ✅")
end
-- Testing Masteries
TestMasteries()
if next(DetectedMasteries)~=nil then
print("masteries test: failed ⛔")
for i,v in next, DetectedMasteries do
warn("⚠ "..i.." ⚠", v)
end
else
passedtests = passedtests + 1
print("masteries test: passed ✅")
end

print("----- ⚙ testing is over. tests passed: "..passedtests.."/3 ⚙ -----")
end


for i,v in next, game:GetService("Players"):GetPlayers() do
TestForExploits(v)
for i=1,5 do
print(" ")
end
end
