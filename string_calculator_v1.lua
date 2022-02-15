local gsub = string.gsub
local find = string.find
local sub = string.sub
local reverse = string.reverse

local operations = {" ^ "," / "," * "," - "," + "}
local getmath = {
[" ^ "] = function (a,b) return a^b end,
[" / "] = function (a,b) return a/b end,
[" * "] = function (a,b) return a*b end,
[" - "] = function (a,b) return a-b end,
[" + "] = function (a,b) return a+b end
}
local len_operations = #operations

local function expr(val)
    if find(val, "[0-9]") == nil then
        return val
    end

	val = gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(val,
			" ", ""),
			"(%d+%.*%d*)", " %1 "),
			"%(", " %("),
			"%)", "%) "),
			"([^ ])%- ", "%1 -"),
			"([^ ])%+ ", "%1 "),
			"^%- ", " -"),
			"^%+ ", " ")

    while true do
        local temp = val

        if find(val, ")",1,true) ~= nil then
			temp = sub(val, 1, find(val, ")",1,true) - 1)
            temp = sub(temp, 1 - find(reverse(temp), "(", 1, true))
        end

        local temp2 = temp

        for i = 1, len_operations do
			local operation = operations[i]

			while true do
				if find(temp2, operation, 1, true) == nil then
					break
				end

				local switcher  = sub(temp2, 1, find(temp2, operation, 1, true) - 1)
				local switcher  = sub(switcher, 1 - (find(reverse(switcher), " ", 1 , true) or 0))

				local switcher2 = sub(temp2, find(temp2, operation, 1, true) + 3)
				local switcher2 = sub(switcher2, 1, (find(switcher2, " ", 1, true) or 0) - 1)

				local switcher3 = getmath[operation](switcher,switcher2)
				local switcher  = gsub(switcher, "([%.%-])", "%%%1")
				local switcher2 = gsub(switcher2, "([%.%-])", "%%%1")
				temp2     = gsub(temp2, " " .. switcher .. " %".. sub(operation,2) .. switcher2 .. " ", " " .. switcher3 .. " ")
			end
		end

        if find(val, ")", 1, true) == nil and find(val, "(", 1, true) == nil then
			val = temp2
            break
		end

		temp = gsub(temp, "([%.%-%+%*%/%^])", "%%%1")
		val  = gsub(val, " %(" .. temp .. "%) ", temp2)
    end

    if val * 2 ~= nil then
        return gsub(val, " ", "")
    end
end
