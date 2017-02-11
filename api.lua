--[[
              .__
_____  ______ |__|
\__  \ \____ \|  |
 / __ \|  |_> >  |
(____  /   __/|__|
     \/|__|
--]]

function digiline_remote:send_to_node(pos, channel, msg, radius--[[, nodenames]])
	if not tonumber(radius) then
		return
	end
	--~ if not nodenames then
		local nodenames = {"group:digiline_remote_receive"}
	--~ end
	local minp, maxp = vector.sort(
		vector.add(pos, {x = -radius, y = -radius, z = -radius}),
		vector.add(pos, {x = radius, y = radius, z = radius}))
	local nodes = minetest.find_nodes_in_area(minp, maxp, nodenames)
	for i = 1, #nodes do
		local f = minetest.registered_nodes[minetest.get_node(nodes[i]).name]._on_digiline_remote_receive
		if f then
			f(nodes[i], channel, msg)
		end
	end
end

function digiline_remote:send_to_entity(pos, channel, msg, radius)
	if not tonumber(radius) then
		return
	end
	if radius < 0 then
		radius = -radius
	end
	local e = minetest.get_objects_inside_radius(pos, radius)	--digiline_remote:receptor_send_to_node() doesn't use an euclidean metric :/
	for i = 1, #e do
		if e[i]:is_player() == false then
			local f = e[i]:get_luaentity()._on_digiline_remote_receive
			if f then
				f(e[i], channel, msg)
			end
		end
	end
end
