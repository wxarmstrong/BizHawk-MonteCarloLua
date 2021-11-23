function node(n)
	return { name = n, state = nil, parent = nil, children = nil, cn = 0, value = 0, visits = 0 } 
end

function selection(node)
	topChild = nil
	topScore = -999
	
	c = math.sqrt(2)
	k = 0.5
	
	for i, kid in pairs(node.children) do
		if (kid.visits > 0) then
			score = (kid.value / (kid.visits) ) + c * math.sqrt( ( 2 * math.log(node.visits) ) / (kid.visits) )
		else
			score = k + c * math.sqrt( ( 2 * math.log(node.visits) ) / (node.cn + 1) )
		end
		if score > topScore then
			topChild = kid
			topScore = score
		end
	end
	
	--If unvisited child is chosen, increase the "expanded children" counter
	if topChild.visits == 0 then node.cn = node.cn + 1 end
	
	return topChild
end

function MonteCarloTreeSearch(game, n, root)

	for i=1,n,1 do
		--print(i)
		curNode = root
		curNode.visits = curNode.visits + 1
		
		while (curNode.state ~= nil) do
			--print(curNode)
			if (curNode.children == nil) then
				newkids = game.expand(curNode)
				curNode.children = newkids
			end
			curNode = selection(curNode)
			--print(curNode)
			curNode.visits = curNode.visits + 1
		end
		
		memorysavestate.loadcorestate(curNode.parent.state)
		game.perform(curNode.name)
		curNode.state = memorysavestate.savecorestate()
		
		result = game.rollout()
		
		if game.loseFlag then
			result = 0
			game.loseFlag = false
		end
		
		while (curNode ~= nil) do
			curNode.value = curNode.value + result;
			curNode = curNode.parent
		end
		
	end
	
	topKid = nil
	topScore = -999
	
	for i, kid in pairs(root.children) do
		if (kid.value / kid.visits > topScore) then
			topKid = kid
			topScore = kid.value / kid.visits
		end 
	end
	
	return topKid
end

function simulate(game, N, n)

	for i, trigger in ipairs(game.winTriggers) do
		event.onmemoryexecute(game.setWinFlag, trigger)
	end

	for i, trigger in ipairs(game.loseTriggers) do
		event.onmemoryexecute(game.setLoseFlag, trigger)
	end

	root = node(nil)
	root.state = memorysavestate.savecorestate()
	for i=1,N,1 do
		root = MonteCarloTreeSearch(game, n, root)
		memorysavestate.loadcorestate(root.state)
		root.parent = nil
	end
end

SuperMarioBros = { 
	name = "Super Mario Bros.",
	
	winFlag = false,
	winTriggers = 
	{
		0xB2A4 -- FlagpoleSlide
	},
	setWinFlag = function()
		winFlag = true
	end,
	
	loseFlag = false,
	loseTriggers = 
	{
		0xB269 -- PlayerDeath
	},
	setLoseFlag = function()
		loseFlag = true
	end,
	
	expand = function(p)
		acts = {"L", "R", "LA", "RA"}
		kids = {}
		for i, act in ipairs(acts) do
			kids[act] = node(act)
			kids[act].parent = p
		end
		return kids
	end,
	
	perform = function(act)
		MOTIF_SIZE = 20
		if		(act == "L") then
			for i=1,MOTIF_SIZE,1 do 
				joypad.set({B = true, Left = true}, 1)
				emu.frameadvance()
			end		
		elseif	(act == "R") then 
			for i=1,MOTIF_SIZE,1 do 
				joypad.set({B = true, Right = true}, 1)
				emu.frameadvance()
			end
		elseif (act == "LA") then
			for i=1,MOTIF_SIZE,1 do 
				joypad.set({B = true, Left = true, A = true}, 1)
				emu.frameadvance()
			end
		elseif (act == "RA") then
			for i=1,MOTIF_SIZE,1 do 
				joypad.set({B = true, Right = true, A = true}, 1)
				emu.frameadvance()
			end
		end
	end,
	
	rollout = function()
		for i=1,40,1 do
				joypad.set({B = true, Right = true}, 1)
				emu.frameadvance()			
				joypad.set({B = true, Right = true, A = true}, 1)
				emu.frameadvance()
		end
		--[[
		total = 0
		for i = 0,4,1 do
			total = total + math.pow(10,i) * mainmemory.readbyte(0x7DC - i)
		end 
		--]]
		
		total = 256*mainmemory.readbyte(0x6D) + mainmemory.readbyte(0x3AD)
		return total
	end,
}

OnimushaTactics = { 
	name = "Onimusha Tactics",
	
	winFlag = false,
	winTriggers = 
	{
		
	},
	setWinFlag = function()
		winFlag = true
	end,
	
	loseFlag = false,
	loseTriggers = 
	{
		
	},
	setLoseFlag = function()
		loseFlag = true
	end,
	
	can_move = function(unit)
		return true
	end,
	
	can_act = function(unit)
		return true
	end,
	
	expand = function()

		kids = {}
		
		units = {}
		
		for i, unit in pairs(units) do
			if can_move(unit) then
			end
			if can_act(unit) then
				--attacks
				--special skills
				--items
			end
		end
		
		return kids
	end,
	
	perform = function(act)
		MOTIF_SIZE = 15
		if     (act == "R") then 
			for i=1,MOTIF_SIZE,1 do 
				joypad.set({B = true, Right = true}, 1)
				emu.frameadvance()
			end
		elseif (act == "A") then
			for i=1,MOTIF_SIZE,1 do 
				joypad.set({B = true, Right = true, A = true}, 1)
				emu.frameadvance()
			end
		end
	end,
	
	rollout = function()
		for i=1,30,1 do
				joypad.set({B = true, Right = true}, 1)
				emu.frameadvance()			
		end
		total = 0
		for i = 0,4,1 do
			total = total + math.pow(10,i) * mainmemory.readbyte(0x7DC - i)
		end 
		return total
	end,
}

simulate(SuperMarioBros, 600, 60)