--[[
               __
_____    _____/  |_  ____   ____   ____ _____
\__  \  /    \   __\/ __ \ /    \ /    \\__  \
 / __ \|   |  \  | \  ___/|   |  \   |  \/ __ \_
(____  /___|  /__|  \___  >___|  /___|  (____  /
     \/     \/          \/     \/     \/     \/
--]]

minetest.register_node("digiline_remote:antenna", {
	description = "antenna",
	tiles = {"default_steel_block.png^digiline_remote_waves.png"},
	groups = {cracky=3, stone=1, digiline_remote_receive = 1},
	sounds = default.node_sound_stone_defaults(),
	digilines = {
		receptor = {action = function() end},
		effector = {
			action = function(pos, node, channel, msg)
				local meta = minetest.get_meta(pos)
				local radius = tonumber(meta:get_string("radius"))
				digiline_remote.send_to_entity(pos, channel, msg, radius)
			end
		},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[radius;radius;${radius}]")
		meta:set_string("radius", "3")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		if fields.radius and fields.radius ~= "" then
			if tonumber(fields.radius) then
				meta:set_string("radius", fields.radius)
			else
				minetest.chat_send_player(sender:get_player_name(),
						"The radius has to be a number.")
			end
		end
	end,
	_on_digiline_remote_receive = function(pos, channel, msg)
		digilines.receptor_send(pos, digilines.rules.default, channel, msg)
	end,
})
