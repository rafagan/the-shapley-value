--[[/******************************************************************************
*
* COPYRIGHT Ráfagan Sebástian de Abreu ALL RIGHTS RESERVED.
*
* This software can be copied, stored, distributed for any purpose. Just let the author know about it.
*
* This file was made available on https://github.com/rafagan and it is free 
* to be restributed or used under Creative Commons license 2.5 br: 
* http://creativecommons.org/licenses/by-sa/2.5/br/
*
--]]


-- Iterates over all elements in a set, applying the function f
-- Special returns:
-- a) BREAK: stop the foreach and returns nil
-- b) CONTINUE: go to next step of the loop
function forEach(A, f)
	for k,v in pairs(A) do 
		local r = f(k,v)

		if r ~= nil then
			if type(r) == "string" then
				if string.upper(r) == "BREAK" then return end
				if string.upper(r) ~= "CONTINUE" then return r end
			end
			return r
		end
	end
end

-- Swap index i to j of the array
function swap(array, i, j)
	local t = array[i]
	array[i] = array[j]
	array[j] = t
end

-- Clone the array
function copyArray(array)
	local newArray = {}
	for _,v in ipairs(array) do
		table.insert(newArray, v) 
	end
	return newArray
end

-- Iterates over all elements in a set, applying the function f and summing its return
function sum(A, f)
	local s = 0
	forEach(A, function(k) s = s + f(k) end)
	return s
end

-- Returns the fatorial of n (n!)
function fatorial(n)
	return n <= 1 and 1 or n * fatorial(n - 1)
end

-- Converts a set to array. Subsets are transformed in inner-arrays
function setToArray(A)
	local array = {}
	forEach(A, function(e)
		if type(e) == "table" then
			table.insert(array, setToArray(e))
		else
			table.insert(array, e)
		end
	end)

	table.sort(array, function(a, b) return a < b end)
	return array
end

-- Converts a set to string
function setToString(A)
	local str = "{"
	forEach(A, function(e)
		if type(e) == "table" then
			str = str .. setToString(e) .. ","
		else
			str = str .. e .. ","
		end
	end)

	if #str > 1 then str = str:sub(1, #str-1) end
	str = str .. "}"

	return str
end

-- Create a set, with smart print and contains elements operation in a lua style and easy usage
function set(t)
	-- PRIVATE: Checks if two subsets are equal
	local compareSubsets = function(subA, subE)
		local result = true

		if size(subA) ~= size(subE) then return false end

		forEach(subE, function(subEElem)
			if type(subBElem) == "table" then
				forEach(subA, function(subAElem)
					if type(subAElem) == "table" then
						local r = compareSubsets(subAElem, e)
						if r == false then 
							result = false
							return "BREAK"
						end
					end
				end)
			elseif not subA[subEElem] then
				result = false
				return "BREAK"
			end
		end)

		return result
	end

	-- Check if two elements are equal, and start the recursive function compareSubsets if the element is a subset
	local contains = function(A, e)
		if type(e) == "table" then
			local result = false
			forEach(A, function(aElement)
				if type(aElement) == "table" then
					local r = compareSubsets(aElement, e)
					if r == true then 
						result = true
						return "BREAK"
					end
				end
			end)
			return result
		end

		return rawget(A, e)
	end

	-- Configure the set metatable custom print (__tostring), in operator (__index) and element insertion (__newindex)
	local A = setmetatable({}, {
		__tostring = function(t) return setToString(t) end,
		__index = function (t, k) return contains(t, k) end,
      	__newindex = function (t, k, v) rawset(t, k, v == nil and nil or true) end
	})

	-- Initializes the set with values from constructor
	forEach(t, function(_, v) A[v] = true end)
	
	return A
end

-- Returns the module of set A
function size(A)
	local c = 0
	forEach(A, function(k) c = c + 1 end)
	return c
end

-- Compare two sets
function equals(A, B)
	local r = forEach(A, function(e)
		if not B[e] then return false end
	end)
	if r == false then return false end

	r = forEach(B, function(e)
		if not A[e] then return false end
	end)
	if r == false then return false end

	return true
end

-- A is subset of B?
function isSubset(A, B)
	local similarity = 0
	local r = forEach(A, function(e)
		if not B[e] then return false end
		similarity = similarity + 1
	end)
	if r == false then return false end

	if size(A) == similarity then
		print("WARN: A is equal to B in isSubset")
		return false
	end

	return true
end

-- A is subset or equals of B?
function isSubsetOrEquals(A, B)
	r = forEach(A, function(e)
		if not B[e] then return false end
	end)
	if r == false then return false end

	return true
end

-- Subtract two sets and returns a new one
function subtract(A, B)
	local C = set{}
	forEach(A, function(e) 
		if not B[e] then 
			C[e] = A[e] 
		end 
	end)
	return C
end

-- Put all the elements from both sets in a new one and return
function union(A, B)
	local C = set{}
	forEach(A, function(e) C[e] = true end)
	forEach(B, function(e) C[e] = true end)
	return C
end

-- Returns all the subsets from set A (2^A). You can ignore the empty set insertion in power setting ignoreEmptySet param as true
function powerSet(A, ignoreEmptySet)
	local emptySet = set{}
	local P = set{emptySet}
	
	forEach(A, function(e)
		forEach(P, function(p)
			P = union(P, set{union(set{e}, p)})
		end)
	end)

	if ignoreEmptySet then
		P[emptySet] = nil
	end
	return P
end

-- Return all the possible permutations from array (|array|!)
function permutations(array)
	-- Recursive function
	local rec = function(array, result, index)
		if index == #array then
			table.insert(result, array)
			return
		end

		for j=index,#array do
			swap(array, index, j)
			rec(copyArray(array), result, index+1)
			swap(array, index, j)
		end
	end

	if #array == 1 then
		return array
	elseif #array == 2 then
		return {{array[1], array[2]}, {array[2], array[1]}}
	else
		local result = {}
		rec(array, result, 1)
		return result
	end
end

-- Returns the set which will be iterated in sum in shapley value algorithm
function shapleyValueActionSet(N, i)
	local permutations = permutations(setToArray(N))
	local R = set{}

	forEach(permutations, function(_, p)
		local newSet = set{}

		forEach(p, function(_, v)
			if v == i then
				R = union(R, set{newSet})
				return "BREAK"
			end
			newSet[v] = true
		end)
	end)

	print(R)

	return R
end

-- Calculates the shapley value (phi), given the player agent (i), grand coalition (N) and payoff function (v)
function shapleyValue(i, N, v)
	local modN = size(N)
	local oneOverFatN = 1 / fatorial(modN)

	local r = sum(shapleyValueActionSet(N, i), function(S)
		local modS = size(S)

		print("Weight", oneOverFatN * fatorial(modS) * fatorial(modN - modS - 1))
		print(union(S, set{i}), v(union(S, set{i})), "-", S, v(S), "=", v(union(S, set{i})) - v(S))
		print("Result", fatorial(modS) * fatorial(modN - modS - 1) * (v(union(S, set{i})) - v(S)))

		return oneOverFatN * fatorial(modS) * fatorial(modN - modS - 1) * (v(union(S, set{i})) - v(S))
	end)

	return r
end

-- Return all the subsets from N, subtracted by i (If you wanna try, replace shapleyValueActionSet by that call)
function shapleyValueActionSetTest(N, i)
	local P = powerSet(N)
	local R = set{}
	forEach(P, function(p)
		R = union(R, set{subtract(p, set{i})})
	end)

	return R
end

-- Function payoff (v) for 4 players
function votingGamePayoff(S)
	local payoff = 0
	local dict = {A = 45, B = 25, C = 15, D = 15}
	forEach(S, function(k, v) payoff = payoff + dict[k] end)
	return payoff
end

-- Function payoff (v) for 3 players
function testPayoffThreePlayers(S)
	if equals(S, set{1}) then return 0
	elseif equals(S, set{2}) then return 0 
	elseif equals(S, set{3}) then return 0 
	elseif equals(S, set{1,2}) then return 90 
	elseif equals(S, set{1,3}) then return 80 
	elseif equals(S, set{2,3}) then return 70 
	elseif equals(S, set{1,2,3}) then return 120
	else return 0 end
end

-- Function payoff (v) for 2 players
function testPayoffTwoPlayers(S)
	if equals(S, set{1}) then return 1
	elseif equals(S, set{2}) then return 2
	elseif equals(S, set{1,2}) then return 4
	else return 0 end
end

-- local phi = shapleyValue(3, set{1, 2, 3}, testPayoff)
-- print(phi)

-- local phi = shapleyValue('D', set{'A', 'B', 'C', 'D'}, votingGamePayoff)
-- print(phi)

local phi = shapleyValue(1, set{1, 2}, testPayoffTwoPlayers)
print(phi)