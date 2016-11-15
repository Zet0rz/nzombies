nzEE.Major.Steps = nzEE.Major.Steps or {}
nzEE.Major.CurrentStep = nzEE.Major.CurrentStep or 1

function nzEE.Major:AddStep(func, step)
	if step and tonumber(step) then
		nzEE.Major.Steps[step] = func
	else
		table.insert(nzEE.Major.Steps, func)
	end
end

function nzEE.Major:SetCurrentStep(step)
	nzEE.Major.CurrentStep = step
end

function nzEE.Major:CompleteStep(step, ...)
	if nzEE.Major.CurrentStep == step then
		if nzEE.Major.Steps[step] then
			print("Completed step "..step)
			local args = {...}
			nzEE.Major.Steps[step](args) -- Varargs passable if you call Complete Step with more stuff
		end
		nzEE.Major.CurrentStep = nzEE.Major.CurrentStep + 1
	end
end

util.AddNetworkString("nzMajorEEEndScreen")

function nzEE.Major:Reset()
	nzEE.Major.CurrentStep = 1
end

function nzEE.Major:Cleanup()
	nzEE.Major.CurrentStep = 1
	nzEE.Major.Steps = {}
end