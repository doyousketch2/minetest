function basic_dump2(o)
	if type(o) == "number" then
		return tostring(o)
	elseif type(o) == "string" then
		return string.format("%q", o)
	elseif type(o) == "boolean" then
		return tostring(o)
	elseif type(o) == "function" then
		return "<function>"
	elseif type(o) == "userdata" then
		return "<userdata>"
	elseif type(o) == "nil" then
		return "nil"
	else
		error("cannot dump a " .. type(o))
		return nil
	end
end

function dump2(o, name, dumped)
	name = name or "_"
	dumped = dumped or {}
	io.write(name, " = ")
	if type(o) == "number" or type(o) == "string" or type(o) == "boolean"
			or type(o) == "function" or type(o) == "nil"
			or type(o) == "userdata" then
		io.write(basic_dump2(o), "\n")
	elseif type(o) == "table" then
		if dumped[o] then
			io.write(dumped[o], "\n")
		else
			dumped[o] = name
			io.write("{}\n") -- new table
			for k,v in pairs(o) do
				local fieldname = string.format("%s[%s]", name, basic_dump2(k))
				dump2(v, fieldname, dumped)
			end
		end
	else
		error("cannot dump a " .. type(o))
		return nil
	end
end

function dump(o, dumped)
	dumped = dumped or {}
	if type(o) == "number" then
		return tostring(o)
	elseif type(o) == "string" then
		return string.format("%q", o)
	elseif type(o) == "table" then
		if dumped[o] then
			return "<circular reference>"
		end
		dumped[o] = true
		local t = {}
		for k,v in pairs(o) do
			t[#t+1] = "" .. k .. " = " .. dump(v, dumped)
		end
		return "{" .. table.concat(t, ", ") .. "}"
	elseif type(o) == "boolean" then
		return tostring(o)
	elseif type(o) == "function" then
		return "<function>"
	elseif type(o) == "userdata" then
		return "<userdata>"
	elseif type(o) == "nil" then
		return "nil"
	else
		error("cannot dump a " .. type(o))
		return nil
	end
end

print("omg lol")
print("minetest dump: "..dump(minetest))

-- Global environment step function
function on_step(dtime)
end

local TNT = {
	-- Maybe handle gravity and collision this way? dunno
	physical = true,
	weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"tnt_top.png","tnt_bottom.png","tnt_side.png","tnt_side.png","tnt_side.png","tnt_side.png"},
	--visual = "single_sprite",
	--textures = {"mese.png^[forcesingle"},
	-- Initial value for our timer
	timer = 0,
	-- List names of state variables, for serializing object state
	state_variables = {"timer"},
}

-- Called periodically
function TNT:on_step(dtime)
	--print("TNT:on_step()")
end

-- Called when object is punched
function TNT:on_punch(hitter)
	print("TNT:on_punch()")
	self.object:remove()
	hitter:add_to_inventory("CraftItem testobject1 1")
end

-- Called when object is right-clicked
function TNT:on_rightclick(clicker)
	pos = self.object:getpos()
	pos = {x=pos.x, y=pos.y+0.1, z=pos.z}
	self.object:moveto(pos, false)
end
--[[
function TNT:on_rightclick(clicker)
	print("TNT:on_rightclick()")
	print("self: "..dump(self))
	print("getmetatable(self): "..dump(getmetatable(self)))
	print("getmetatable(getmetatable(self)): "..dump(getmetatable(getmetatable(self))))
	pos = self.object:getpos()
	print("TNT:on_rightclick(): object position: "..dump(pos))
	pos = {x=pos.x+0.5+1, y=pos.y+0.5, z=pos.z+0.5}
	--minetest.env:add_node(pos, 0)
end
--]]

print("TNT dump: "..dump(TNT))

print("Registering TNT");
minetest.register_entity("TNT", TNT)

--print("minetest.registered_entities: "..dump(minetest.registered_entities))
print("minetest.registered_entities:")
dump2(minetest.registered_entities)

--[=[

register_block(0, {
	textures = "stone.png",
	makefacetype = 0,
	get_dig_duration = function(env, pos, digger)
		-- Check stuff like digger.current_tool
		return 1.5
	end,
	on_dig = function(env, pos, digger)
		env:remove_node(pos)
		digger.inventory.put("MaterialItem2 0");
	end,
})

register_block(1, {
	textures = {"grass.png","mud.png","mud_grass_side.png","mud_grass_side.png","mud_grass_side.png","mud_grass_side.png"},
	makefacetype = 0,
	get_dig_duration = function(env, pos, digger)
		-- Check stuff like digger.current_tool
		return 0.5
	end,
	on_dig = function(env, pos, digger)
		env:remove_node(pos)
		digger.inventory.put("MaterialItem2 1");
	end,
})

-- Consider the "miscellaneous block namespace" to be 0xc00...0xfff = 3072...4095
register_block(3072, {
	textures = {"tnt_top.png","tnt_bottom.png","tnt_side.png","tnt_side.png","tnt_side.png","tnt_side.png"},
	makefacetype = 0,
	get_dig_duration = function(env, pos, digger)
		-- Cannot be dug
		return nil
	end,
	-- on_dig = function(env, pos, digger) end, -- Not implemented
	on_hit = function(env, pos, hitter)
		-- Replace with TNT object, which will explode after timer, follow gravity, blink and stuff
		env:add_object("tnt", pos)
		env:remove_node(pos)
	end,
})
--]=]

