local defaultvalues = {
	{"hl1_sv_itemrespawntime", 23},
	{"hl1_sv_mprules", 0},
	{"hl1_sv_gauss_tracebackwards", 1},
	{"hl1_sv_glock_extrabullet", 1},
	{"hl1_sv_loadout", 0},
	{"hl1_sv_cmodels", 1},
	{"hl1_sv_clampammo", 0},
	{"hl1_sv_unlimitedammo", 0},
	{"hl1_sv_unlimitedclip", 0},
	{"hl1_sv_replaceitems", 1},
	{"hl1_sv_explosionshake", 0},
	{"hl1_cl_firelight", 1},
	{"hl1_cl_muzzleflash", 1},
	{"hl1_cl_muzzlesmoke", 1},
	{"hl1_cl_ejectshells", 1},
	{"hl1_cl_crosshair", 1},
	{"hl1_cl_crosshair_scale", 1},
	{"hl1_cl_crosshair_gsrchud", 1},
	{"hl1_cl_fixchrome", 1},
	{"hl1_cl_viewmodelfov", 90}	
}

local defaultbobvalues = {
	{"hl1_cl_hl2bob", 0},
	{"hl1_cl_viewbob", 1},
	{"hl1_cl_bob_won", 0},
	{"hl1_cl_bob", 0.01},
	{"hl1_cl_bobcycle", 0.8},
	{"hl1_cl_bobup", 0.5},
	{"hl1_cl_rollangle", 2},
	{"hl1_cl_rollspeed", 200}
}

local defaultdmgvalues = {
	{"Crowbar", "hl1_sk_plr_dmg_crowbar", 10},
	{"9mm Bullet", "hl1_sk_plr_dmg_9mm_bullet", 8},
	{".357 Bullet", "hl1_sk_plr_dmg_357_bullet", 40},
	{"Buckshot", "hl1_sk_plr_dmg_buckshot", 5},
	{"MP5 Bullet", "hl1_sk_plr_dmg_mp5_bullet", 5},
	{"MP5 Grenade", "hl1_sk_plr_dmg_mp5_grenade", 100},
	{"RPG", "hl1_sk_plr_dmg_rpg", 100},
	{"Crossbow (player)", "hl1_sk_plr_dmg_xbow_bolt_plr", 10},
	{"Crossbow (NPC)", "hl1_sk_plr_dmg_xbow_bolt_npc", 50},
	--{"", "hl1_sk_plr_dmg_egon_narrow", 6},
	{"Gluon Gun", "hl1_sk_plr_dmg_egon_wide", 14},
	{"Tau Cannon", "hl1_sk_plr_dmg_gauss", 20},
	{"Grenade", "hl1_sk_plr_dmg_grenade", 100},
	{"Hornet", "hl1_sk_plr_dmg_hornet", 7},
	{"Tripmine", "hl1_sk_plr_dmg_tripmine", 150},
	{"Satchel", "hl1_sk_plr_dmg_satchel", 150}
}

local function HL1_SettingsPanel(DForm)
	DForm:Help("Server")
	DForm:CheckBox("Enable c_ models", "hl1_sv_cmodels")
	DForm:ControlHelp("requires weapon re-equip to apply")
	if game.SinglePlayer() then
		DForm:CheckBox("Multiplayer rules in singleplayer", "hl1_sv_mprules")
		DForm:ControlHelp("e.g. gauss jumping, colt zoom, explosive bolts")
	else
		-- DForm:CheckBox("Singleplayer rules in multiplayer", "hl1_sv_sprules")
		-- DForm:ControlHelp("no gauss jumping, no colt zoom, normal bolts")
	end
	DForm:CheckBox("Gauss trace backwards", "hl1_sv_gauss_tracebackwards")
	DForm:ControlHelp("tired of killing yourself? disable this!")
	DForm:CheckBox("Glock extra bullet", "hl1_sv_glock_extrabullet")
	DForm:ControlHelp("like early versions")
	DForm:CheckBox("Shake screen on explosions", "hl1_sv_explosionshake")
	DForm:CheckBox("Spawn with HL1 weapons", "hl1_sv_loadout")
	DForm:CheckBox("Limit max ammo", "hl1_sv_clampammo")
	DForm:CheckBox("Unlimited ammo", "hl1_sv_unlimitedammo")
	DForm:CheckBox("Replace entities on Resized Maps", "hl1_sv_replaceitems")
	DForm:ControlHelp("makes Resized Maps playable for sandbox")
	DForm:Help("Client")
	DForm:CheckBox("Fire lighting", "hl1_cl_firelight")
	DForm:CheckBox("Muzzle flash", "hl1_cl_muzzleflash")
	DForm:CheckBox("Muzzle smoke", "hl1_cl_muzzlesmoke")
	if !game.SinglePlayer() then
		DForm:CheckBox("Eject shells", "hl1_cl_ejectshells")
	end
	DForm:CheckBox("Crosshair", "hl1_cl_crosshair")
	if GSRCHUD then
		DForm:CheckBox("Crosshair color uses GSRCHUD theme", "hl1_cl_crosshair_gsrchud")
	end
	DForm:NumSlider("Crosshair scale", "hl1_cl_crosshair_scale", 1, 4, 2)
	DForm:NumSlider("Viewmodel FOV", "hl1_cl_viewmodelfov", 70, 120, 0)
	DForm:Help("View Bobbing")
	DForm:CheckBox("Disable custom bobbing", "hl1_cl_hl2bob")
	DForm:ControlHelp("enables default HL2 (HL:S) bobbing")
	DForm:CheckBox("Enable view (camera) bobbing", "hl1_cl_viewbob")
	DForm:CheckBox("WON style", "hl1_cl_bob_won")
	DForm:NumSlider("bob", "hl1_cl_bob", 0, 0.1)
	DForm:NumSlider("bobcycle", "hl1_cl_bobcycle", 0.3, 2)
	DForm:NumSlider("bobup", "hl1_cl_bobup", 0, 1)
	DForm:NumSlider("rollangle", "hl1_cl_rollangle", 0, 10, 1)
	DForm:NumSlider("rollspeed", "hl1_cl_rollspeed", 100, 800, 0)
	local defaultBob = DForm:Button("Default Bob Values")
	defaultBob.DoClick = function()
		for k, v in ipairs(defaultbobvalues) do
			RunConsoleCommand(v[1], tostring(v[2]))
		end
	end
	local defaultAll = DForm:Button("Default All")
	defaultAll.DoClick = function()
		for k, v in ipairs(defaultvalues) do
			RunConsoleCommand(v[1], tostring(v[2]))
		end
		for k, v in ipairs(defaultbobvalues) do
			RunConsoleCommand(v[1], tostring(v[2]))
		end
	end
end

local function HL1_DamageSettingsPanel(DForm)
	DForm:Help("These values will NOT be saved in your config\nPlease add needed convars in skill.cfg (hl1_sk_plr_dmg_*)")
	local t = {}
	for k, v in ipairs(defaultdmgvalues) do
		local a, b = DForm:NumberWang(v[1], v[2], 0, 999, 0)
		a:SetValue(cvars.Number(v[2], v[3]))
		a:SetHeight(30)
		a:SetWidth(128)
		table.insert(t, a)
	end
	local defaultDmg = DForm:Button("Default")
	defaultDmg.DoClick = function()
		for k, v in ipairs(defaultdmgvalues) do
			RunConsoleCommand(v[2], tostring(v[3]))
			t[k]:SetValue(v[3])
		end
	end
end

local function HL1_PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Half-Life", "HL1Settings", "Settings", "", "", HL1_SettingsPanel)
	spawnmenu.AddToolMenuOption("Utilities", "Half-Life", "HL1DMGSettings", "Damage Values", "", "", HL1_DamageSettingsPanel)
end

hook.Add("PopulateToolMenu", "HL1_PopulateToolMenu", HL1_PopulateToolMenu)