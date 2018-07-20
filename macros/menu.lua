--<<
-- get input from each player
local _random_id = "item_choice_random"

local helper = wesnoth.require "lua/helper.lua"
local T = helper.set_wml_tag_metatable {}
local _ = wesnoth.textdomain "wesnoth"

local _items_taken
local _side_number

function get_global_variable(namespace, name, side)
	wesnoth.wml_actions.get_global_variable {
		namespace=namespace,
		from_global=name,
		to_local="RR_global_variable",
		side=side,
		immediate=true,
	}
	local r =  wesnoth.get_variable("RR_global_variable")
	wesnoth.set_variable("RR_global_variable", nil)
	return r
end

function set_global_variable(namespace, name, side, value)
	wesnoth.set_variable("RR_global_variable", value)
	wesnoth.wml_actions.set_global_variable {
		namespace=namespace,
		to_global=name,
		from_local="RR_global_variable",
		side=side,
		immediate=true,
	}
	wesnoth.set_variable("RR_global_variable", nil)
end

function clear_global_variable(namespace, name, side)
	wesnoth.wml_actions.set_global_variable {
		namespace=namespace,
		to_global=name,
		side=side,
		immediate=true,
	}
end

-- TODO remake this list when its different side
-- scroll_type rand mb,mp,mi,mf,mc,ma,rb,rp,ri,rf,rc,ra
local names = {}
local icons = {}
local variables = {}

local _names = {
	"<b>A sack of gold. Contains 25 gold coins.</b>",
	"<b>Ayleid Crown. An inheritable crown. (Transfers leadership to another unit)</b>",
	"<b>Ring of Midas. Transform things into gold (1 killed enemy unit: 10 gold, Income: +2)</b>",
	"<b>Blind Monk's Ring. Develops a healing aura (New ability: regenerates, heals +4)</b>",
	"<b>Health Remedy. Restores health (Heal full, poison cured)</b>",
	"<b>Tears of Martyrs. Increases resilience (Total HP: +20% + 8)</b>",
	"<b>Blood of Hercules. Enhances combat expertise (All attacks: +2 damage)</b>",
	"<b>Elusive Fluid. Enhances defense skills (Defenses: +10%)</b>",
	"<b>Grey Essence. Increases resistances (Resistances: +10%)</b>",
	"<b>Elixir of Experience. Makes one more intelligent (XP needed to advance: -50%)</b>",
	"<b>Imperial Drops. Dramatically increases charisma (New ability: charisma +25%, Units upkeep: 0)</b>",
	"<b>Potion of Penetration. Adds skill to move more freely (new ability: skirmisher, movement: doubled)</b>",
	"<b>Spirit Blade Attack scroll (single use): 14-3 melee blade magical</b>",
	"<b>Spirit Stabs Attack scroll (single use): 6-7 melee pierce magical</b>",
	"<b>Tomb Crushes Attack scroll (single use): 14-3 melee impact magical</b>",
	"<b>Burning Grasps Attack scroll (single use): 21-2 melee fire magical</b>",
	"<b>Frigid Aura Attack scroll (single use): 18-2 melee cold magical</b>",
	"<b>Mystic Hand Attack scroll (single use): 21-2 melee arcane magical</b>",
	"<b>Flying Swords Attack scroll (single use): 7-6 ranged blade magical</b>",
	"<b>Inner Thorns Attack scroll (single use): 6-7 ranged pierce magical</b>",
	"<b>Cosmic Impact Attack scroll (single use): 21-2 ranged impact magical</b>",
	"<b>Blazing Spirits Attack scroll (single use): 7-6 ranged fire magical</b>",
	"<b>Frost Strikes Attack scroll (single use): 12-3 ranged cold magical</b>",
	"<b>Magi Spirits Attack scroll (single use): 14-3 ranged arcane magical</b>"
}
local _icons = {
	"items/gold-coins-small.png",
	"items/ayleidcrown.png",
	"items/ring-gold.png",
	"items/ring-silver.png",
	"items/whitepotion.png",
	"items/potion-blue.png",
	"items/potion-red.png",
	"items/purplepotion.png",
	"items/greypotion.png",
	"items/emeraldpotion.png",
	"items/potion-yellow.png",
	"items/blackpotion.png",
	"items/scroll.png",
	"items/scroll.png",
	"items/scroll.png",
	"items/scroll.png",
	"items/scroll.png",
	"items/scroll.png",
	"items/scroll.png",
	"items/scroll.png",
	"items/scroll.png",
	"items/scroll.png",
	"items/scroll.png",
	"items/scroll.png"
}
local _variables = {
	"_goldsack",
	"_ayleidcrown",
	"_goldring",
	"_silverring",
	"_whitepotion",
	"_bluepotion",
	"_redpotion",
	"_purplepotion",
	"_greypotion",
	"_emeraldpotion",
	"_yellowpotion",
	"_blackpotion",
	"_scrollmb",
	"_scrollmp",
	"_scrollmi",
	"_scrollmf",
	"_scrollmc",
	"_scrollma",
	"_scrollrb",
	"_scrollrp",
	"_scrollri",
	"_scrollrf",
	"_scrollrc",
	"_scrollra"
}

local dialog = {
  T.tooltip { id = "tooltip_large" },
  T.helptip { id = "tooltip_large" },
  
  T.linked_group { id = 'description', fixed_width = true }, 
  T.linked_group { id = 'icon', fixed_width = true},
  
  T.grid { T.row {
    T.column { T.grid {
      T.row { T.column { T.grid { id = "top_row", T.row {
        T.column { T.label { id = "top_message", use_markup = true } },
        T.column { T.label { id = "top_message_2", use_markup = true } }
      } } } },
      T.row { T.column { horizontal_grow = true, T.listbox { id = "the_list",
        T.list_definition { T.row { T.column { horizontal_grow = true,
          T.toggle_panel { T.grid { T.row {
            T.column { horizontal_alignment = "left", T.label { id = "the_label", linked_group = 'description',  use_markup = true } },
            T.column { T.image { id = "the_icon",  linked_group = 'icon' } }
          } } }
        } } }
      } } },
      T.row { T.column { T.grid { T.row {
        T.column { T.button { id = "ok", label = _"OK" } },
        T.column { T.button { id = "cancel", label = _"4 Random items (max 2 scrolls, but 2 scrolls is very likely) (discard seleced)" } }
      } } } }
    } },
    T.column { T.image { id = "the_image" } }
  } }
}

local function preshow()

    -- local t = { "Ancient Lich", "Ancient Wose", "Elvish Avenger" }
    local function select()
        local i = wesnoth.get_dialog_value "the_list"
        wesnoth.set_dialog_value("misc/new-battle.png", "the_image")
    end
    wesnoth.set_dialog_callback(select, "the_list")
    for i,v in ipairs(names) do
        wesnoth.set_dialog_value(v, "the_list", i, "the_label")
        wesnoth.set_dialog_value(icons[i], "the_list", i, "the_icon")
    end
	-- wesnoth.set_dialog_value(string.format("I am side %d, I have selected %d/3 items.", _g_side, _g_item), "top_row", 1, "top_message")
	-- wesnoth.set_dialog_value("Putting label here", "top_row", 1, "top_message")
	wesnoth.set_dialog_value(string.format("I am side %d, I have selected %d/3 items.", _side_number, _items_taken), "top_row", "top_message")
    wesnoth.set_dialog_value(1, "the_list") -- default selection
    select()
end

local li = 0
local function postshow()
    li = wesnoth.get_dialog_value "the_list"
end

local function do_nothing() end

local delay_dialog = {
  T.tooltip { id = "tooltip_large" },
  T.helptip { id = "tooltip_large" },
  T.grid { T.row {
    T.column { T.grid {
      T.row { T.column { T.grid { T.row {
        T.column { T.button { id = "ok", label = _"I have seen my leader now" } }
      } } } }
    } },
    T.column { T.image { id = "the_image" } }
  } }
}

local namespace = "RR"

for i,v in ipairs(wesnoth.get_sides()) do
	for t_i, t_v in ipairs(_variables) do
		variables[t_i] = t_v
	end
	for t_i, t_v in ipairs(_icons) do
		icons[t_i] = t_v
	end
	for t_i, t_v in ipairs(_names) do
		names[t_i] = t_v
	end

	if v.controller == "human" and v.is_local then
		items_taken = 1
		_side_number = i
		local u = wesnoth.get_units({ side = i, canrecruit = true })[1]
		wesnoth.fire("remove_shroud", { x=u.x, y=u.y })
		wesnoth.fire("lift_fog", { x=u.x, y=u.y })
		wesnoth.select_hex(u.x, u.y)
		wesnoth.fire("redraw")
		-- wesnoth.show_dialog(delay_dialog, do_nothing, do_nothing)
		while items_taken < 4 do
			_items_taken = items_taken -1
		-- show this multiple times, marking previous selections
			local r = wesnoth.show_dialog(dialog, preshow, postshow)
			-- wesnoth.message(string.format("Button %d pressed. Item %s selected.", r, variables[li]))
			
			
			if r == -2 then
				set_global_variable(namespace, "item_choice_"..tostring(i).."_1", i, _random_id)
				set_global_variable(namespace, "item_choice_"..tostring(i).."_2", i, _random_id)
				set_global_variable(namespace, "item_choice_"..tostring(i).."_3", i, _random_id)
				items_taken = 4
			else
				set_global_variable(namespace, "item_choice_"..tostring(i).."_"..tostring(items_taken), i, variables[li])
				items_taken = items_taken + 1
				table.remove(names, li)
				table.remove(variables, li)
				table.remove(icons, li)
			end
		end
	end
end

for i,v in ipairs(wesnoth.get_sides()) do
	wesnoth.message("RR", "Waiting for input from side " ..  tostring(i))
	items_taken = 1
	while items_taken < 4 do
		r = get_global_variable(namespace, "item_choice_"..tostring(i).."_"..tostring(items_taken), v.side)
		clear_global_variable(namespace, "item_choice_"..tostring(i).."_"..tostring(items_taken), v.side)
		-- wesnoth.message("SYNCED " .. tostring(i) .. tostring(items_taken) .. r)
		if r == _random_id then
			-- pick and set 4 unique value from table
			for t_i, t_v in ipairs(_variables) do
				variables[t_i] = t_v
			end
			random_items = 0
			local scroll_count = 0
			while random_items < 4 do
				wesnoth.fire("set_variable", { name = "LUA_random", rand = string.format("%d..%d", 1, #variables) })
				local rand = wesnoth.get_variable "LUA_random"
				wesnoth.set_variable "LUA_random"

				if variables[rand]:find("scroll") then
					if scroll_count > 1 then
						-- continue
						table.remove(variables, rand)
					else
						-- increment scroll_count, and use selection
						scroll_count = scroll_count + 1
						wesnoth.set_variable(tostring(i)..variables[rand], 1)
						table.remove(variables, rand)
						random_items = random_items + 1
					end
				else
					-- use selection
					wesnoth.set_variable(tostring(i)..variables[rand], 1)
					table.remove(variables, rand)
					random_items = random_items + 1
				end
			end
			items_taken = 4
		else
			wesnoth.set_variable("RR_item_choice"..tostring(i).."_"..tostring(items_taken), r)
			wesnoth.set_variable(tostring(i)..r, 1)
			items_taken = items_taken + 1
		end
	end
	wesnoth.message("RR", "Received input from side " ..  tostring(i))
	wesnoth.set_variable(tostring(i).."_items", 3)
end
-->>
