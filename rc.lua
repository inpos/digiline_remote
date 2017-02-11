--[[

_______   ____
\_  __ \_/ ___\
 |  | \/\  \___
 |__|    \___  >
             \/
--]]

local rightclick = function(itemstack, user, pointed_thing)
	local meta = itemstack:get_meta()
	local metat = meta:to_table().fields or {}
	if metat.channel == nil then
		metat.channel = ""
	end
	if metat.msg == nil then
		metat.msg = ""
	end
	if metat.radius == nil then
		metat.radius = 3
	end
	if metat.send_nodes ~= "true" then
		metat.send_nodes = "false"
	end
	if metat.send_entities ~= "true" then
		metat.send_entities = "false"
	end
	minetest.show_formspec(user:get_player_name(),
			"digiline_remote_rc"..user:get_player_name(),
				"size[7,3.5]"..
				"field[0.75,1;6,1;channel;Channel;"..metat.channel.."]"..
				"field[0.75,2;6,1;msg;Message;"..metat.msg.."]"..
				"field[0.75,3;1,1;radius;Radius;"..tostring(metat.radius).."]"..
				"label[5,2.5;send to:]"..
				"checkbox[5,2.6;send_nodes;nodes;"..metat.send_nodes.."]"..
				"checkbox[5,3;send_entities;entities;"..metat.send_entities.."]"..
				"button_exit[1.9,2.7;3,1;save;Save]"
		)
end

minetest.register_craftitem("digiline_remote:rc",{
	description = "Remote Control",
	inventory_image = "digiline_remote_rc.png",
	stack_max = 1,
	on_secondary_use = function(itemstack, user, pointed_thing)
		rightclick(itemstack, user, pointed_thing)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		rightclick(itemstack, placer, pointed_thing)
	end,
	on_use = function(itemstack, user, pointed_thing)
		local meta = itemstack:get_meta()
		if meta:get_string("send_nodes") == "true" then
			digiline_remote:send_to_node(
					user:getpos(),
					meta:get_string("channel"),
					meta:get_string("msg"),
					meta:get_float("radius")--[[,
					{"digiline_remote:antenna"}]]
				)
		end
		if meta:get_string("send_entities") == "true" then
			digiline_remote:send_to_entity(
					user:getpos(),
					meta:get_string("channel"),
					meta:get_string("msg"),
					meta:get_float("radius")
				)
		end
	end,
})

minetest.register_on_player_receive_fields(
	function(player, formname, fields)
		if formname ~= "digiline_remote_rc"..player:get_player_name() then
			return
		end
		if fields.send_entities ~= nil then
			local item = player:get_wielded_item()
			local meta = item:get_meta()
			meta:set_string("send_entities", fields.send_entities)
			player:set_wielded_item(item)
		end
		if fields.send_nodes ~= nil then
			local item = player:get_wielded_item()
			local meta = item:get_meta()
			meta:set_string("send_nodes", fields.send_nodes)
			player:set_wielded_item(item)
		end
		if not (fields.save or fields.key_enter) then
			return
		end
		local item = player:get_wielded_item()
		local meta = item:get_meta()
		meta:set_string("channel", fields.channel)
		meta:set_string("msg", fields.msg)
		if fields.radius and fields.radius ~= "" then
			if tonumber(fields.radius) then
				meta:set_float("radius", tonumber(fields.radius))
			else
				minetest.chat_send_player(player:get_player_name(),
						"The radius has to be a number.")
			end
		end
		player:set_wielded_item(item)
	end
)
