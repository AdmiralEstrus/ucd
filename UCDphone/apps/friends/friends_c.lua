Friends = {}
Friends.open = false

function Friends.create()
	phone.friends = {button = {}, gridlist = {}}
	
	phone.friends.button["friends.players"] = GuiButton(31, 479, 78, 38, "View Players", false, phone.image["phone_window"])
	phone.friends.button["friends.manage"] = GuiButton(117, 479, 78, 38, "Manage", false, phone.image["phone_window"])
	phone.friends.button["friends.blacklist"] = GuiButton(203, 479, 78, 38, "Blacklist", false, phone.image["phone_window"])
	phone.friends.gridlist["friends"] = GuiGridList(31, 98, 250, 375, false, phone.image["phone_window"])
	guiGridListAddColumn(phone.friends.gridlist["friends"], "Friend", 0.5)
	guiGridListAddColumn(phone.friends.gridlist["friends"], "Last Active", 0.4)
	
	Friends.views = {
		friends = {
			phone.friends.button["friends.players"], phone.friends.button["friends.manage"], phone.friends.button["friends.blacklist"], phone.friends.gridlist["friends"]
		},
		players = {
			
		},
		blacklist = {
			
		},
	}

	Friends.all = {
		phone.friends.button["friends.players"], phone.friends.button["friends.manage"], phone.friends.button["friends.blacklist"], phone.friends.gridlist["friends"]
	}
	for _, gui in pairs(Friends.all) do
		gui.visible = false
	end
end
Friends.create()

function Friends.toggle()
	Friends.open = not Friends.open
	-- o = opened
	local o = 0
	for _, gui in pairs(Friends.all) do
		if (gui.visible) then
			o = o + 1
		end
	end
	if (o == 0) then
		Friends.switchView("friends")
		return
	end
	Friends.GUI(false)
end

function Friends.GUI(state)
	for _, gui in pairs(Friends.all) do
		gui.visible = state
	end
	Friends.open = state
end

function Friends.switchView(view)
	if (not Friends.views[view]) then
		outputDebugString("v")
		return
	end
	Friends.open = true	
	for v, t in pairs(Friends.views) do
		for _, gui in pairs(t) do
			if (v == view) then
				gui.visible = true
			else
				gui.visible = false
			end
		end
	end
end

function Friends.onReceivedFriendsList(data)
	phone.friends.gridlist["friends"]:clear()
	for _, ent in ipairs(data) do
		local row = phone.friends.gridlist["friends"]:addRow()
		guiGridListSetItemText(phone.friends.gridlist["friends"], row, 1, tostring(data[2]).." ("..tostring..data[1]..")")
	end
end
addEvent("CSGphone.friends.onReceivedFriendsList", true)
addEventHandler("CSGphone.friends.onReceivedFriendsList", root, Friends.onReceivedFriendsList)
