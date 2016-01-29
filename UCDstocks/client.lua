GUI = {gridlist = {}, window = {}, button = {}, label = {}}
buyGUI = {button = {}, window = {}, label = {}, edit = {}}

addEvent("onClientStockMarketUpdate", true)
addEventHandler("onClientStockMarketUpdate", root, 
	function ()
		exports.UCDdx:new("The stock market has updated", 255, 255, 255)
		if (GUI.window.visible or buyGUI.window.visible) then
			buyGUI.window.visible = false
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		buyGUI.window = GuiWindow(571, 342, 285, 143, "UCD | Stock Market - Purchase", false)
		buyGUI.window.sizable = false
		buyGUI.window.visible = false
		buyGUI.window.alpha = 1
		exports.UCDutil:centerWindow(buyGUI.window)
		
		buyGUI.edit = GuiEdit(9, 52, 266, 35, "", false, buyGUI.window)
		buyGUI.button[1] = GuiButton(9, 97, 122, 37, "Buy", false, buyGUI.window)
		buyGUI.button[2] = GuiButton(152, 97, 122, 37, "Close", false, buyGUI.window)
		buyGUI.label = GuiLabel(9, 25, 265, 17, "Buying stock options of ", false, buyGUI.window)
		guiLabelSetHorizontalAlign(buyGUI.label, "center", false)

		GUI.window = GuiWindow(447, 150, 560, 511, "UCD | Stock Market", false)
		GUI.window.alpha = 1
		GUI.window.sizable = false
		GUI.window.visible = false
		exports.UCDutil:centerWindow(GUI.window)

		-- All stocks
		GUI.gridlist["all"] = GuiGridList(10, 42, 253, 315, false, GUI.window)
		guiGridListAddColumn(GUI.gridlist["all"], "Name", 0.3)
		guiGridListAddColumn(GUI.gridlist["all"], "Value", 0.2)
		guiGridListAddColumn(GUI.gridlist["all"], "Change", 0.4)
		GUI.label["all.share_name"] = GuiLabel(10, 367, 253, 16, "Name: ", false, GUI.window)
		GUI.label["all.total_worth"] = GuiLabel(10, 383, 253, 16, "Total Worth: ", false, GUI.window)
		GUI.label["all.total_shares"] = GuiLabel(10, 399, 253, 16, "Total Shares: ", false, GUI.window)
		GUI.label["all.available_shares"] = GuiLabel(10, 415, 253, 16, "Available Shares: ", false, GUI.window)
		GUI.label["all.shareholders"] = GuiLabel(10, 431, 253, 16, "Shareholders: ", false, GUI.window)
		GUI.label["all.minimum_investment"] = GuiLabel(10, 447, 253, 16, "Minimum Investment: ", false, GUI.window)
		GUI.button["all.buy_shares"] = GuiButton(10, 473, 123, 27, "Buy Shares", false, GUI.window)
		GUI.button["all.view_history"] = GuiButton(140, 472, 123, 28, "View History", false, GUI.window)
		
		GUI.button["all.buy_shares"].enabled = false
		GUI.button["all.view_history"].enabled = false
		
		-- Misc labels
		GUI.label["all_shares"] = GuiLabel(12, 23, 251, 15, "All shares:", false, GUI.window)
		guiLabelSetHorizontalAlign(GUI.label["all_shares"], "center", false)
		GUI.label["divider"] = GuiLabel(263, 20, 34, 492, "|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|", false, GUI.window)
		guiLabelSetHorizontalAlign(GUI.label["divider"], "center", false)
		GUI.label["own_shares"] = GuiLabel(297, 23, 251, 15, "My shares:", false, GUI.window)
		guiLabelSetHorizontalAlign(GUI.label["own_shares"], "center", false)

		-- Own stocks
		GUI.gridlist["own"] = GuiGridList(296, 43, 252, 314, false, GUI.window)
		guiGridListAddColumn(GUI.gridlist["own"], "Name", 0.45)
		guiGridListAddColumn(GUI.gridlist["own"], "Shares", 0.45)
		GUI.label["own.share_name"] = GuiLabel(297, 367, 253, 16, "Name: ", false, GUI.window)
		GUI.label["own.worth"] = GuiLabel(297, 383, 253, 16, "Worth of own shares: ", false, GUI.window)
		GUI.label["own.worth_at_pur"] = GuiLabel(297, 399, 253, 16, "Worth at purchase: ", false, GUI.window)
		GUI.label["own.my_shares"] = GuiLabel(297, 415, 253, 16, "My shares: ", false, GUI.window)
		GUI.label["own.percentage"] = GuiLabel(297, 431, 253, 16, "Stakeholder percentage: ", false, GUI.window)
		GUI.label["own.min_sell"] = GuiLabel(297, 447, 253, 16, "Minimum Sellout: ", false, GUI.window)
		GUI.button["own.sell_shares"] = GuiButton(297, 474, 123, 28, "Sell Shares", false, GUI.window)
		GUI.button["own.sell_shares"].enabled = false

		-- Close button
		GUI.button["close"] = GuiButton(427, 474, 123, 28, "Close", false, GUI.window)
		
		addEventHandler("onClientGUIClick", GUI.button["close"], toggleGUI, false)
		addEventHandler("onClientGUIClick", GUI.gridlist["all"], onClickStock, false)
		addEventHandler("onClientGUIClick", GUI.gridlist["own"], onClickStock, false)
		addEventHandler("onClientGUIClick", GUI.button["all.buy_shares"], onClickBuyStock, false)
		addEventHandler("onClientGUIClick", buyGUI.button[2], onClickBuyStock, false)
		addEventHandler("onClientGUIClick", buyGUI.button[1], onBuyStock, false)
		addEventHandler("onClientGUIChanged", buyGUI.edit, onClientGUIChanged, false)
	end
)

function toggleGUI(data, own, show)
	if (not show) then
		show = true
	end
	GUI.gridlist["all"]:clear()
	GUI.gridlist["own"]:clear()
	buyGUI.window.visible = false
	
	if (data and type(data) == "table" and own and type(own) == "table") then
		_stocks = data
		_own = own
		GUI.window.visible = show
		showCursor(show)
		for k, v in pairs(data) do
			local curr = exports.UCDutil:mathround(v[2], 2)
			local prev = exports.UCDutil:mathround(v[3], 2)
			local diff = curr - prev
			local per = exports.UCDutil:mathround((diff / prev) * 100, 2) -- delta over original muliplied by 100%
			
			local row = guiGridListAddRow(GUI.gridlist["all"])
			guiGridListSetItemText(GUI.gridlist["all"], row, 1, tostring(k), false, false)
			guiGridListSetItemText(GUI.gridlist["all"], row, 2, tostring(curr), false, false)
			guiGridListSetItemText(GUI.gridlist["all"], row, 3, tostring(per).."% ("..tostring(diff)..")", false, false)
			
			if (per < 0) then
				guiGridListSetItemColor(GUI.gridlist["all"], row, 1, 255, 0, 0)
				guiGridListSetItemColor(GUI.gridlist["all"], row, 2, 255, 0, 0)
				guiGridListSetItemColor(GUI.gridlist["all"], row, 3, 255, 0, 0)
			elseif (per == 0) then
				guiGridListSetItemColor(GUI.gridlist["all"], row, 1, 255, 187, 0)
				guiGridListSetItemColor(GUI.gridlist["all"], row, 2, 255, 187, 0)
				guiGridListSetItemColor(GUI.gridlist["all"], row, 3, 255, 187, 0)
			else
				guiGridListSetItemColor(GUI.gridlist["all"], row, 1, 0, 255, 0)
				guiGridListSetItemColor(GUI.gridlist["all"], row, 2, 0, 255, 0)
				guiGridListSetItemColor(GUI.gridlist["all"], row, 3, 0, 255, 0)
			end
		end
		for k, v in pairs(own) do
			local row = guiGridListAddRow(GUI.gridlist["own"])
			guiGridListSetItemText(GUI.gridlist["own"], row, 1, tostring(k), false, false)
			guiGridListSetItemText(GUI.gridlist["own"], row, 2, tostring(exports.UCDutil:tocomma(v[1])), false, false)
			
			guiGridListSetItemColor(GUI.gridlist["own"], row, 1, 0, 200, 200)
			guiGridListSetItemColor(GUI.gridlist["own"], row, 2, 0, 200, 200)
		end
		
		-- Set every label blank
		GUI.label["own.share_name"].text = "Name:"
		GUI.label["own.worth"].text = "Worth of own shares: "
		GUI.label["own.worth_at_pur"].text = "Worth at purchase:"
		GUI.label["own.my_shares"].text = "My shares: "
		GUI.label["own.percentage"].text = "Stakeholder percentage: "
		GUI.label["own.min_sell"].text = "Minimum Sellout: "
		GUI.label["all.share_name"].text = "Name: "
		GUI.label["all.total_worth"].text = "Total Worth: "
		GUI.label["all.total_shares"].text = "Total Shares: "
		GUI.label["all.available_shares"].text = "Available Shares: "
		GUI.label["all.shareholders"].text = "Shareholders: "
		GUI.label["all.minimum_investment"].text = "Minimum Investment: "
		GUI.button["own.sell_shares"].enabled = false
		GUI.button["all.buy_shares"].enabled = false
		GUI.button["all.view_history"].enabled = false
	else
		if (GUI.window.visible) then
			GUI.window.visible = false
			showCursor(false)
		else
			triggerServerEvent("UCDstocks.getStocks", localPlayer)
		end
	end
end
addEvent("UCDstocks.toggleGUI", true)
addEventHandler("UCDstocks.toggleGUI", root, toggleGUI)
addCommandHandler("stocks", toggleGUI)

function onClickStock()
	local row = guiGridListGetSelectedItem(GUI.gridlist["all"])
	if (row and row ~= -1) then
		local acronym = guiGridListGetItemText(GUI.gridlist["all"], row, 1)
		local data = _stocks[acronym]
		
		--local totalworth = math.floor(data[5] * data[4])
		local totalworth = exports.UCDutil:mathround(data[2] * data[6], 2)
		local available = data[6]
		local sg
		if (data[7] == 1) then
			sg = "option"
		else
			sg = "options"
		end
		
		GUI.label["all.share_name"].text = "Name: "..data[1].." ("..acronym..")"
		GUI.label["all.total_worth"].text = "Total Worth: $"..exports.UCDutil:tocomma(totalworth)
		GUI.label["all.total_shares"].text = "Total Shares: "..exports.UCDutil:tocomma(data[5])
		GUI.label["all.available_shares"].text = "Available Shares: "..exports.UCDutil:tocomma(available)
		GUI.label["all.shareholders"].text = "Shareholders: "..data[4]
		GUI.label["all.minimum_investment"].text = "Minimum Investment: "..data[7].." "..sg
		
		if (available <= data[5] and available ~= 0) then
			GUI.button["all.buy_shares"].enabled = true
		else
			GUI.button["all.buy_shares"].enabled = false
		end
		GUI.button["all.view_history"].enabled = true
	else
		GUI.label["all.share_name"].text = "Name: "
		GUI.label["all.total_worth"].text = "Total Worth: "
		GUI.label["all.total_shares"].text = "Total Shares: "
		GUI.label["all.available_shares"].text = "Available Shares: "
		GUI.label["all.shareholders"].text = "Shareholders: "
		GUI.label["all.minimum_investment"].text = "Minimum Investment: "
		
		GUI.button["all.buy_shares"].enabled = false
		GUI.button["all.view_history"].enabled = false
	end
	local row = guiGridListGetSelectedItem(GUI.gridlist["own"])
	if (row and row ~= -1) then
		local acronym = guiGridListGetItemText(GUI.gridlist["own"], row, 1)
		local data = _own[acronym]
		
		local stake = 100 / (_stocks[acronym][5] / data[1])
		local worth = exports.UCDutil:mathround(data[1] * _stocks[acronym][2], 2)
		
		GUI.label["own.share_name"].text = "Name: "..tostring(_stocks[acronym][1]).." ("..tostring(acronym)..")"
		GUI.label["own.worth"].text = "Worth of own shares: $"..tostring(exports.UCDutil:tocomma(worth))
		GUI.label["own.worth_at_pur"].text = "Worth at purchase: $"..tostring(exports.UCDutil:tocomma(data[2]))
		GUI.label["own.my_shares"].text = "My shares: "..tostring(data[1])
		GUI.label["own.percentage"].text = "Stakeholder percentage: "..tostring(stake).."%"
		GUI.label["own.min_sell"].text = "Minimum Sellout: "..tostring(_stocks[acronym][8])
		
		GUI.button["own.sell_shares"].enabled = true
	else
		GUI.label["own.share_name"].text = "Name:"
		GUI.label["own.worth"].text = "Worth of own shares: "
		GUI.label["own.worth_at_pur"].text = "Worth at purchase:"
		GUI.label["own.my_shares"].text = "My shares: "
		GUI.label["own.percentage"].text = "Stakeholder percentage: "
		GUI.label["own.min_sell"].text = "Minimum Sellout: "
		
		GUI.button["own.sell_shares"].enabled = false
	end
end

function onClickBuyStock()
	buyGUI.window.visible = not buyGUI.window.visible
	buyGUI.edit.text = "1"
	guiBringToFront(buyGUI.window)
	if (buyGUI.window.visible) then
		local row = guiGridListGetSelectedItem(GUI.gridlist["all"])
		if (row and row ~= -1) then
			local acronym = guiGridListGetItemText(GUI.gridlist["all"], row, 1)
			buyGUI.label.text = "Buying stock options of "..acronym
			buyGUI.button[1].text = "Buy ($"..tostring(exports.UCDutil:tocomma(exports.UCDutil:mathround(_stocks[acronym][2], 2)))..")"
			stockBuying = acronym
		end
	else
		stockBuying = nil
	end
end

function onClientGUIChanged()
	if (not stockBuying) then return end
	local text = buyGUI.edit.text
	text = text:gsub(",", "")
	if (not tonumber(text)) then
		return
	end
	buyGUI.edit.text = exports.UCDutil:tocomma(text)
	local available = _stocks[stockBuying][6]
	if (tonumber(text) > available) then
		buyGUI.edit.text = exports.UCDutil:tocomma(available)
	end
	if (not getKeyState("backspace")) then
		guiEditSetCaretIndex(buyGUI.edit, buyGUI.edit.text:len())
	end
	buyGUI.button[1].text = "Buy ($"..tostring(exports.UCDutil:tocomma(exports.UCDutil:mathround(_stocks[stockBuying][2] * tonumber(text), 2)))..")"
end

function onBuyStock()
	local text = buyGUI.edit.text
	text = text:gsub(",", "")
	if (not tonumber(text)) then
		return
	end
	local approxPrice = text * _stocks[stockBuying][2]
	triggerServerEvent("UCDstocks.buyStock", localPlayer, stockBuying, text, approxPrice)
	buyGUI.window.visible = false
	buyGUI.edit.text = "1"
	stockBuying = nil
end
