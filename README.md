# the-shapley-value
Source code of the algorithm (in lua) to calculate the Shapley Value, one of the main concepts from Cooperative Game Theory.

Understand how it works: https://en.wikipedia.org/wiki/Shapley_value

The algorithm is defined by the given formula:


![alt tag](https://upload.wikimedia.org/math/d/2/8/d2831c6c752aa555486580008c6fe86c.png)


Take care with the sum set notation, because it actually iterates over all permutations from the grand coalition. 
All the S subsets from N \ {i} generated from permutation respects this rule, but you don't use all the subsets to calculate the 
shapley value. For example, a power set of set with 3 elements returns 2^3 = 8 subsets, but in shapley value we'll only use 6 
(|N|! = 3! = 6).

Wrong interpretation of set to be iterated in sum:
```lua
-- Return all the subsets from N, subtracted by i (If you wanna try, replace shapleyValueActionSet by that call)
function shapleyValueActionSetTest(N, i)
	local P = powerSet(N)
	local R = set{}
	forEach(P, function(p)
		R = union(R, set{subtract(p, set{i})})
	end)

	return R
end
```

Correct interpretation of set to be iterated in sum:
```lua
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

	return R
end
```

The code try to follow the formula literally as a study case, instead of be the most optimized.
Just let me know if you have some doubts or suggestions. I really would appreciate if you test it in more Coalitional Game cases.
