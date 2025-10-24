local module = {}

--[[ numbers obfuscation ]]--
function ObfuscateNumbers(Code)
    local function ReplaceNumber(Match)
        local Number = tonumber(Match)
        if not Number then return Match end
        math.randomseed(Number)
        if math.floor(Number) == Number then
            local Method = Number % 28    
            if Method == 0 then
                local A = Number * math.random(2, 8428902)
                return "math.floor((" .. A .. "/" .. (A/Number) .. "))"
            elseif Method == 1 then
                local Offset = math.random(1, 7289017)
                return "math.ceil((" .. (Number + Offset) .. "-" .. Offset .. "))"
            elseif Method == 2 then
                local Factor = math.random(2, 5928471)
                return "math.floor((" .. (Number * Factor) .. "/" .. Factor .. "))"
            elseif Method == 3 then
                local A = Number + math.random(1000, 8928471)
                local B = math.random(1000, 4928471)
                return "math.abs((" .. A .. "+" .. B .. "-" .. (A + B - Number) .. "))"
            elseif Method == 4 then
                local A = Number * math.random(2, 8928471)
                local B = math.random(2, 3928471)
                return "math.floor((" .. A .. "*" .. B .. "/" .. (A * B / Number) .. "))"
            elseif Method == 5 then
                local A = Number * math.random(100, 7928471)
                local B = A - math.random(1, 6928471)
                return "math.ceil((" .. A .. "-" .. B .. "+" .. (Number - (A - B)) .. "))"
            elseif Method == 6 then
                local A = math.random(100000, 9928471)
                local B = A - Number
                return "math.floor((" .. A .. "-" .. B .. "))"
            elseif Method == 7 then
                local A = Number * math.random(3, 4829471)
                local B = math.random(2, 5829471)
                local C = A * B
                return "math.floor((" .. C .. "/" .. B .. "/" .. (C / B / Number) .. "))"
            elseif Method == 8 then
                local A = Number + math.random(500, 7829471)
                local B = math.random(100, 8829471)
                return "math.abs((" .. A .. "-" .. B .. "+" .. (B - (A - Number)) .. "))"
            elseif Method == 9 then
                local A = Number * math.random(20, 6729471)
                local B = math.random(5, 7729471)
                return "math.floor((" .. A .. "/" .. B .. "*" .. (B * Number / A) .. "))"
            elseif Method == 10 then
                local A = math.random(10000, 8629471)
                local B = A + Number
                return "math.ceil((" .. B .. "-" .. A .. "))"
            elseif Method == 11 then
                local A = Number * math.random(25, 8928471)
                local B = math.random(8, 3928471)
                return "math.tointeger(math.max((" .. A .. "*" .. B .. "/" .. (A * B / Number) .. "),0))"
            elseif Method == 12 then
                local A = math.random(5000, 7429471)
                local B = A * Number
                return "math.floor((" .. B .. "/" .. A .. "))"
            elseif Method == 13 then
                local A = Number + math.random(10000, 8329471)
                local B = math.random(5000, 9229471)
                return "math.abs((" .. A .. "-" .. B .. "+" .. (B - (A - Number)) .. "))"
            elseif Method == 14 then
                local A = Number * math.random(25, 6129471)
                local B = math.random(4, 7129471)
                local C = A * B
                return "math.floor((" .. C .. "/" .. (C / Number) .. "))"
            elseif Method == 15 then
                local A = math.random(20000, 8029471)
                local B = A - Number
                return "math.ceil((" .. A .. "-" .. B .. "))"
            elseif Method == 16 then
                local A = Number * math.random(8, 4729471)
                local B = math.random(2, 5729471)
                return "math.floor((" .. A .. "/" .. B .. "/" .. (A / B / Number) .. "))"
            elseif Method == 17 then
                local A = math.random(30000, 6829471)
                local B = A + Number * 2
                return "math.abs((" .. B .. "-" .. A .. "-" .. Number .. "))"
            elseif Method == 18 then
                local A = Number * math.random(15, 7529471)
                local B = math.random(6, 8529471)
                return "math.floor((" .. A .. "*" .. B .. "/" .. (A * B / Number) .. "))"
            elseif Method == 19 then
                local A = math.random(40000, 7929471)
                local B = A - Number * 3
                return "math.ceil((" .. A .. "-" .. B .. "-" .. (Number * 2) .. "))"
            elseif Method == 20 then
                local A = Number * math.random(12, 6329471)
                local B = math.random(7, 7329471)
                return "math.floor((" .. A .. "/" .. B .. "*" .. (B * Number / A) .. "))"
            elseif Method == 21 then
                local A = math.random(60000, 8929471)
                local B = A + Number * 4
                return "math.abs((" .. B .. "-" .. A .. "-" .. (Number * 3) .. "))"
            elseif Method == 22 then
                local A = Number * math.random(50, 8928471)
                return "math.tointeger((" .. A .. "/" .. (A/Number) .. "))"
            elseif Method == 23 then
                local A = math.random(100000, 9928471)
                local B = A - Number
                return "math.floor(math.max((" .. A .. "-" .. B .. "),0))"
            elseif Method == 24 then
                local A = Number * math.random(30, 7828471)
                local B = math.random(10, 5828471)
                return "math.floor(math.min((" .. A .. "/" .. B .. "*" .. (B * Number / A) .. "),9999999))"
            elseif Method == 25 then
                local A = math.random(50000, 8728471)
                local B = A + Number
                return "math.ceil(math.abs((" .. B .. "-" .. A .. ")))"
            elseif Method == 26 then
                local A = Number * math.random(18, 6928471)
                local B = math.random(9, 4928471)
                return "math.floor(math.sqrt((" .. A .. "/" .. B .. ")*(" .. A .. "/" .. B .. ")*" .. (B * B * Number / (A * A)) .. "))"
            else
                local A = Number * math.random(25, 8928471)
                local B = math.random(8, 3928471)
                return "math.tointeger(math.max((" .. A .. "*" .. B .. "/" .. (A * B / Number) .. "),0))"
            end
        else
            return "math.floor((" .. (Number * math.random(2, 8928471)) .. "/" .. math.random(2, 8928471) .. "))"
        end
    end
    local Result = ""
    local I = 1
    while I <= #Code do
        local Char = Code:sub(I, I)
        
        if Char == '"' or Char == "'" then
            local Quote = Char
            local Start = I
            I = I + 1
            
            while I <= #Code do
                if Code:sub(I, I) == Quote and Code:sub(I-1, I-1) ~= "\\" then
                    break
                end
                I = I + 1
            end
            
            local StringContent = Code:sub(Start + 1, I - 1)
            local ProcessedString = ""
            local J = 1
            
            while J <= #StringContent do
                local StringChar = StringContent:sub(J, J)
                
                if StringChar:match("%d") then
                    local NumStart = J
                    while J <= #StringContent and StringContent:sub(J, J):match("%d") do
                        J = J + 1
                    end
                    local NumStr = StringContent:sub(NumStart, J - 1)
                    ProcessedString = ProcessedString .. "\" .. " .. ReplaceNumber(NumStr) .. " .. \""
                else
                    ProcessedString = ProcessedString .. StringChar
                    J = J + 1
                end
            end
            
            Result = Result .. Quote .. ProcessedString .. Quote
            I = I + 1
        else
            local TextStart = I
            while I <= #Code and Code:sub(I, I) ~= '"' and Code:sub(I, I) ~= "'" do
                I = I + 1
            end
            local Text = Code:sub(TextStart, I - 1)
            Text = Text:gsub("%d+%.?%d*", ReplaceNumber)
            Result = Result .. Text
        end
    end
    return Result
end

--[[ base64 handler ]]--
--setup, created by someone in roblox dev forum cuz im too lazy to make it myself
local alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/"
local base = {}

for i = 0, 63 do
	base[i] = alphabet:sub(i+1,i+1)
	base[alphabet:sub(i+1,i+1)] = i
end

local S1 = {}  --B64 Character 1-2 for ASCII character 1-2
local S2 = {}  --B64 Character 3-4 for ASCII character 2-3
local S3 = {}  --ASCII Character 1 for B64 characters 1-2
local S4 = {}  --ASCII Character 2 for B64 characters 2-3
local S5 = {}  --ASCII Character 3 for B64 characters 3-4
local C1 = 0
local C2 = 0
local C3 = 0

for C1 = 0, 255 do
	for C2 = 0, 255 do
		local Sum = C3 * 65536 + C2 * 256 + C1
		
		local B1 = base[ bit32.extract(Sum, 0,6) ]
		local B2 = base[ bit32.extract(Sum, 6,6) ]
		
		S1[string.char(C1, C2)] = B1 .. B2
		S3[B1 .. B2] = string.char(C1)
	end
end

for C2 = 0, 255 do
	for C3 = 0, 255 do
		local Sum = C3 * 65536 + C2 * 256 + C1
		
		local B3 = base[ bit32.extract(Sum,12,6) ]
		local B4 = base[ bit32.extract(Sum,18,6) ]

		S2[string.char(C2, C3)] = B3 .. B4
		S5[B3 .. B4] = string.char(C3)
	end
end

for C1 = 0, 192, 64 do
	for C2 = 0, 255 do
		for C3 = 0, 3 do
			local Sum = C3 * 65536 + C2 * 256 + C1
			
			local B2 = base[ bit32.extract(Sum, 6,6) ]
			local B3 = base[ bit32.extract(Sum,12,6) ]
			
			S4[B2 .. B3] = string.char(C2)
		end
	end
end

function module:Encode(method, data)
  if method == "BINARY" then
    local result = ""
    for i = 1, #data do
        local byte = string.byte(data, i)
        local bits = ""
        for j = 7, 0, -1 do
            bits = bits .. (byte // (2^j) % 2)
        end
        result = result .. bits
    end
    return result
  elseif method == "HEX" then
    local result = ""
    for i = 1, #data do
        local byte = string.byte(data, i)
        result = result .. string.format("%02X", byte)
    end
    return result
  elseif method == "BASE64" then
    if data == 0 then return "" end
	  local padding = -#data % 3
	  data ..= string.rep("\0", padding)
	  local result = table.create(#data/3*2+1, "    ")
	  result[1] = base[padding]
	  local index = 2
	  for i = 1, #data, 3 do
		  result[index  ] = S1[data:sub(i,  i+1)]
		  result[index+1] = S2[data:sub(i+1,i+2)]
		  index += 2
	  end
	  return table.concat(result,"")
  elseif method == "NUMBERS" then
    local result = ObfuscateNumbers(data)
	return result
  end
end

function module:Decode(method, data)
  if method == "BINARY" then
    local result = ""
    for i = 1, #data, 8 do
        local byte_str = data:sub(i, i+7)
        local byte = 0
        for j = 0, 7 do
            local bit = byte_str:sub(j+1, j+1)
            if bit == "1" then
                byte = byte + 2^(7-j)
            end
        end
        result = result .. string.char(byte)
    end
    return result
  elseif method == "HEX" then
    local result = ""
    for i = 1, #data, 2 do
        local byte_str = data:sub(i, i+1)
        local byte = tonumber(byte_str, 16)
        if byte then
            result = result .. string.char(byte)
        else
            result = result .. "?"
        end
    end
    return result
  elseif method == "BASE64" then
	  if data == "E" or data == "" then return "" end
	  local padding = base[data:sub(1,1)]
  	local result = table.create((#data-1)/4*3, "   ")
	  local index = 1
	  for i = 2, #data, 4 do
		  result[index  ] = S3[data:sub(i,  i+1)]
	  	result[index+1] = S4[data:sub(i+1,i+2)]
		  result[index+2] = S5[data:sub(i+2,i+3)]
		  index += 3
	  end
	  local concatted = table.concat(result)
	  return concatted:sub(1, #concatted-padding)
  end
end

return module
