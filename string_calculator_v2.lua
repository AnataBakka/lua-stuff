--Personal implementation of the shunting yard algorithm
local gsub = string.gsub
local find = string.find
local sub = string.sub

local getmath = {
["^"] = function (a,b) return a^b end,
["/"] = function (a,b) return a/b end,
["*"] = function (a,b) return a*b end,
["%"] = function (a,b) return a%b end,
["+"] = function (a,b) return a+b end,
["-"] = function (a,b) return a-b end
}

local symbol={
["^"]=1,
["/"]=2,
["*"]=2,
["%"]=2,
["+"]=3,
["-"]=3,
[")"]=4,
["("]=4
}

local function expr(val)
    if find(val, "[0-9]") == nil then
        return val
    end

    val = gsub(val," ","")

	local symbolstack = {}
	local numberstack = {}
	local term=""
	local closed
	local len_number, len_symbol = 0,0
	local len_val = #val

	for i=1,len_val do
		local temp_term = sub(val,i,i)

		if symbol[temp_term] == nil or ((temp_term == "-" or temp_term == "+") and (symbol[sub(val,i-1,i-1)] or i-1 == 0) and sub(val,i-1,i-1) ~= ")")  then
			if symbol[sub(val,i+1,i+1)] or i == len_val then
				len_number = len_number + 1
				numberstack[len_number] = term .. temp_term
				term = ""
			else
				term = term .. temp_term
			end
        else
			if symbolstack[len_symbol] and symbol[symbolstack[len_symbol]] <= symbol[temp_term] and temp_term ~= "(" and temp_term ~= ")" then
				len_number = len_number + 1
				numberstack[len_number] = symbolstack[len_symbol]
				symbolstack[len_symbol] = temp_term
			else
				len_symbol = len_symbol + 1
				symbolstack[len_symbol] = temp_term
			end

			if temp_term == ")" then
				closed = true
			end
		end

		if closed then
			len_symbol = len_symbol - 1

			while symbolstack[len_symbol] ~= "(" and len_symbol > 0 do
				len_number = len_number + 1
				numberstack[len_number] = symbolstack[len_symbol]
				len_symbol = len_symbol - 1
			end
			
			if len_symbol == 0 then
				error("Brackets are unlinked.")
			end

			closed = false
			len_symbol = len_symbol - 1
		end
	end

	for i = len_symbol, 1, -1 do
		len_number = len_number + 1
		numberstack[len_number] = symbolstack[i]
	end

	local tempstack = {}
	local len_temp = 0

	for i = 1, len_number do
		if symbol[numberstack[i]] then
			tempstack[len_temp - 1] = getmath[numberstack[i]](tempstack[len_temp - 1], tempstack[len_temp])
			len_temp = len_temp - 1
		else
			len_temp = len_temp + 1
			tempstack[len_temp] = numberstack[i]
		end
	end

    if tempstack[1] * 2 then
        return tonumber(tempstack[1])
    end
end
