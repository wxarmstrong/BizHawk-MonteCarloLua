function new_node(n)
	return { name = n, state = nil, parent = nil, children = nil, value = 0, visits = 0 } 
end

function selection(node)
	topChild = nil
	topScore = -999
	topVisits = -999
	
	c = math.sqrt(2)
	
	for i, kid in pairs(node.children) do
		score = (kid.value / (kid.visits + 1) ) + c * math.sqrt( ( math.log(node.visits) ) / (kid.visits + 1) )
		if score > topScore then
			topChild = kid
			topScore = score
		end
	end
	return topChild.name
end

function MonteCarlo(game, iterations)

	for i, trigger in ipairs(game.winTriggers) do
		event.onmemoryexecute(game.setWinFlag, trigger)
	end

	for i, trigger in ipairs(game.loseTriggers) do
		event.onmemoryexecute(game.setLoseFlag, trigger)
	end

	root = new_node(nil)
	root.state = memorysavestate.savecorestate()
	
	for i=1,iterations,1
	do
		curNode = root;
		while (curNode.children ~= nil) do
			nextAct = selection(curNode)
			nextNode = curNode.children[nextAct]
			if (nextNode.visits == 0) then
				memorysavestate.loadcorestate(curNode.state)
				game.perform(nextAct)
				nextNode.state = memorysavestate.savecorestate()
			end
			nextNode.parent = curNode
			curNode = nextNode
		end

		kids = game.expand(curNode)
		curNode.children = kids
		
		game.perform(
		game.rollout()
		score = game.score()
		
		if game.loseFlag then
			score = 0
			game.loseFlag = false
		end
		
		while (curNode ~= nil) do
			curNode.value = curNode.value + score;
			curNode.visits = curNode.visits + 1
			curNode = curNode.parent
		end
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
		print("setWinFlag")
		winFlag = true
	end,
	
	loseFlag = false,
	loseTriggers = 
	{
		0xB269 -- PlayerDeath
	},
	setLoseFlag = function()
		print("setLoseFlag")
		loseFlag = true
	end,
	
	expand = function()
		acts = {"R", "A"}
		kids = {}
		for i, act in ipairs(acts) do
			kids[act] = new_node(act)
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
	
	score = function()
		total = 0
		for i = 0,4,1 do
			total = total + math.pow(10,i) * mainmemory.readbyte(0x7DC - i)
		end 
		return total	
	end,
	
	rollout = function()
		for i=1,60,1 do
				joypad.set({B = true, Right = true}, 1)
				emu.frameadvance()			
		end
	end,
}

MonteCarlo(SuperMarioBros, 1000000)