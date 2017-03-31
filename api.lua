--[[
              .__
_____  ______ |__|
\__  \ \____ \|  |
 / __ \|  |_> >  |
(____  /   __/|__|
     \/|__|
--]]

local search_round = minetest.setting_getbool("digiline_remote_euc")

local function find_entities_in_area(minp, maxp)
	local xyz = {"x", "y", "z"}
	local pos = {}
	for i = 1, 3 do
		pos[xyz[i]] = (minp[xyz[i]]+maxp[xyz[i]])/2
	end
	local radius = ((((maxp.x-pos.x)^2+(maxp.y-pos.y)^2)^0.5)+(maxp.z-pos.z)^2)^0.5
	local t = minetest.get_objects_inside_radius(pos, radius)
	for i = 1, #t do
		local p = t[i]:getpos()
		print(dump(p))
		for k = 1, 3 do
			if p[xyz[k]] < minp[xyz[k]] or p[xyz[k]] > maxp[xyz[k]] then
				t[i] = nil
				break
			end
		end
	end
	return t
end

local function get_nodes_inside_radius(pos, radius, nodenames)
	local xyz = {"x", "y", "z"}
	local minp = {}
	local maxp = {}
	for i = 1, 3 do
		minp[xyz[i]] = pos[xyz[i]] - radius
		maxp[xyz[i]] = pos[xyz[i]] + radius
	end
	local t = minetest.find_nodes_in_area(minp, maxp, nodenames)
	for i = 1, #t do
		if (((t[i].x^2+t[i].y^2)^0.5)+t[i].z^2)^0.5 < radius then
			t[i] = nil
		end
	end
	return t
end

function digiline_remote.send_to_node(pos, channel, msg, radius--[[, nodenames]])
	if not tonumber(radius) then
		return
	end
	--~ if not nodenames then
		local nodenames = {"group:digiline_remote_receive"}
	--~ end
	local nodes
	if search_round then
		nodes = get_nodes_inside_radius(pos, radius, nodenames)
	else
		local minp, maxp =
			vector.sort(vector.add(pos, {x = -radius, y = -radius, z = -radius}),
					vector.add(pos, {x = radius, y = radius, z = radius}))
		nodes = minetest.find_nodes_in_area(minp, maxp, nodenames)
	end
	for i = 1, #nodes do
		local n = minetest.registered_nodes[minetest.get_node(nodes[i]).name]
		local f = n._on_digiline_remote_receive
		if f then
			f(nodes[i], channel, msg)
		end
	end
end

function digiline_remote.send_to_entity(pos, channel, msg, radius)
	if not tonumber(radius) then
		return
	end
	if radius < 0 then
		radius = -radius
	end
	local e
	if search_round then
		e = minetest.get_objects_inside_radius(pos, radius)
	else
		local minp, maxp =
			vector.sort(vector.add(pos, {x = -radius, y = -radius, z = -radius}),
					vector.add(pos, {x = radius, y = radius, z = radius}))
		e = find_entities_in_area(minp, maxp)
	end
	for i = 1, #e do
		if not e[i]:is_player() then
			local f = e[i]:get_luaentity()._on_digiline_remote_receive
			if f then
				f(e[i], channel, msg)
			end
		end
	end
end
