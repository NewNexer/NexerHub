local key = "cheeseburger"

local module = {}

function module:GetKey()
return key
end

function module:GetAnimationTriggers(killer)
if killer == "Badware" then
return {
["Rift"] = "rbxassetid://110344161345188"; -- Badware Rift;
["BoltStartup"] = "rbxassetid://135746886198865"; -- Badware BoltStartup;
["Swing"] = "rbxassetid://108527178823496"; -- Badware Swing;
}
elseif killer == "Pursuer" then
return {
["Cleave"] = "rbxassetid://89729648321106"; -- Pursuer Cleave
["Swing1"] = "rbxassetid://78618685223511"; -- Pursuer Swing 1
["Swing2"] = "rbxassetid://84565422738230"; -- Pursuer Swing 2
["Swing3"] = "rbxassetid://130037883107006"; -- Pursuer Swing 3
["Swing4"] = "rbxassetid://100896558622404"; -- Pursuer Swing 4
["Swing5"] = "rbxassetid://71896478910022"; -- Pursuer Swing 5
}
elseif killer == "Artful" then
return {
["RepurposeSwing1"] = "rbxassetid://112076293590914"; -- Artful RepurposeSwing 1
["RepurposeSwing2"] = "rbxassetid://110762388652484"; -- Artful RepurposeSwing 2
["Swing"] = "rbxassetid://80787680522855"; -- Artful Swing
}
elseif killer == "Harken" then
return {
["Swing1"] = "rbxassetid://77146551800119"; -- Harken Swing 1
["Swing2"] = "rbxassetid://99333140295180"; -- Harken Swing 2
}
elseif killer == "Killdroid" then
return {["Eject"] = "rbxassetid://84850475824455"} -- Killdroid Eject
elseif killer == "MR.O.B." then
return {["Swing"] = "rbxassetid://78618685223511"} -- MR.O.B. Swing
elseif killer == "Paranoy" then
return {["Swing"] = "rbxassetid://90169934219103"} -- Paranoy Swing
end
end

function module:GetWalkSpeedModData(killer)
if killer == "Badware" then
return {-100, 4, 8, 12, 16, 20}
elseif killer == "Pursuer" then
return {4, 6}
elseif killer == "Artful" then
return {-100, 4, 9}
elseif killer == "Harken" then
return {4, 7.5, 10, 13.5}
elseif killer == "Killdroid" then
return {-4}
elseif killer == "MR.O.B." then
return {4}
elseif killer == "Paranoy" then
return {4}
end
end

return module
