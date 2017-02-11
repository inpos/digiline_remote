--[[

_______   ____
\_  __ \_/ ___\
 |  | \/\  \___
 |__|    \___  >
             \/
--]]

local rightclick = function(itemstack, user, pointed_thing)
	local meta = minetest.deserialize(itemstack:get_metadata()) or {}
	if meta.channel == nil then
		meta.channel = ""
	end
	if meta.msg == nil then
		meta.msg = ""
	end
	if meta.radius == nil or meta.radius == "" then
		meta.radius = "3"
	end
	if meta.send_nodes == nil then
		meta.send_nodes = false
	end
	if meta.send_entities == nil then
		meta.send_entities = false
	end
	minetest.show_formspec(
		user:get_player_name(),
		"digiline_remote_rc"..user:get_player_name(),
		"size[7,3.5]"..
		"field[0.75,1;6,1;channel;Channel;"..meta.channel.."]"..
		"field[0.75,2;6,1;msg;Message;"..meta.msg.."]"..
		"field[0.75,3;1,1;radius;Radius;"..meta.radius.."]"..
		"label[5,2.5;send to:]"..
		"checkbox[5,2.6;send_nodes;nodes;"..tostring(meta.send_nodes).."]"..
		"checkbox[5,3;send_entities;entities;"..tostring(meta.send_entities).."]"..
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
		local meta = minetest.deserialize(itemstack:get_metadata())
		if meta.send_nodes == true then
			digiline_remote:send_to_node(user:getpos(), meta.channel, meta.msg, tonumber(meta.radius)--[[, {"digiline_remote:antenna"}]])
		end
		if meta.send_entities == true then
			digiline_remote:send_to_entity(user:getpos(), meta.channel, meta.msg, tonumber(meta.radius))
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
			local t = minetest.deserialize(item:get_metadata())
			t.send_entities = fields.send_entities == "true"
			item:set_metadata(minetest.serialize(t))
			player:set_wielded_item(item)
		end
		if fields.send_nodes ~= nil then
			local item = player:get_wielded_item()
			local t = minetest.deserialize(item:get_metadata())
			t.send_nodes = fields.send_nodes == "true"
			item:set_metadata(minetest.serialize(t))
			player:set_wielded_item(item)
		end
		if not (fields.save or fields.key_enter) then
			return
		end
		local item = player:get_wielded_item()
		local t = minetest.deserialize(item:get_metadata())
		t.channel = fields.channel
		t.msg = fields.msg
		if fields.radius ~= nil and fields.radius ~= "" then
			if tonumber(fields.radius) then
				t.radius = fields.radius
			else
				minetest.chat_send_player(player:get_player_name(), "The radius has to be a number.")
			end
		end
		item:set_metadata(minetest.serialize(t))
		player:set_wielded_item(item)
	end
)
