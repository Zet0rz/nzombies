nz.Display_PaPNames = {
	-- You can use both class names and display names, class names take priority but display names can apply to multiple weapons
	["fas2_glock20"] = "Glock-115c",
	["Ray Gun"] = "Porter's X2 Ray Gun",
	["Raygun"] = "Porter's X2 Ray Gun",
	["fas2_ak12"] = "AK-12EAPER",
	["fas2_ak47"] = "AK-4TW",
	["fas2_ak74"] = "AK74FU2",
	["fas2_an94"] = "Actuated Neutralizer 94000",
	["fas2_famas"] = "F4M3-A55",
	["fas2_g36c"] = "GL-HF36",
	["fas2_g3"] = "G3T-GUD",
	["fas2_deagle"] = "Desert Hawk",
	["fas2_galil"] = "Gabig",
	["fas2_uzi"] = "Uncle Gal",
	["fas2_ks23"] = "K1LL-ST34L",
	["fas2_mac11"] = "Big Mac",
	["fas2_m14"] = "M8-YUDODIZ",
	["fas2_m1911"] = "M9-K11L",
	["fas2_m21"] = "M21GHT",
	["fas2_m24"] = "M2ATH",
	["fas2_m3s90"] = "M30 Ultra 9000",
	["fas2_m4a1"] = "M4A115",
	["fas2_m82"] = "M8-U2",
	["fas2_mp5a5"] = "M115 A55",
	["fas2_mp5k"] = "M115 Kollider",
	["fas2_mp5sd6"] = "M115 S4D",
	["fas2_ots33"] = "Ostrich-33",
	["fas2_p226"] = "P-4U2",
	["fas2_pp19"] = "PP20 Buffalo",
	["fas2_ragingbull"] = "Furious Bull",
	["fas2_rem870"] = "REM-3MB3R M3",
	["fas2_rpk"] = "RPK-4TW",
	["fas2_rk95"] = "Sa-KO 9500",
	["fas2_sg550"] = "SG 11500",
	["fas2_sg552"] = "SG 11502",
	["fas2_sks"] = "Seeking Kill Steals",
	["fas2_sr25"] = "SR3KT",
	
	-- CW 2 weapons
<<<<<<< HEAD
=======
	["cw_ak74"] = "AK-4TW",
	["cw_ar15"] = "All-Right15",
	["cw_auggsm"] = "AUG-SOM3",
	["cw_g3a3"] = "G3T-B3TTER",
	["cw_mp5"] = "MP115",
	["cw_deagle"] = "Desert Hawk",
	["cw_l115"] = "L-Emnt 115",
	["cw_lr300"] = "Liberator 115x2",
	["cw_mr96"] = "Mr.Rekker 96",
	["UMP45"] = "Unified Material Penetrator 4D5",
	["cw_c7a1"] = "C7-KILL7",
	["cw_kimber_kw"] = "Kimber Knight Warlord",
	["cw_mk11"] = "Mr.Kill 115",
	["cw_ppsh-41"] = "The Reaper",
	["cw_xm1014"] = "XTREME1015",
	["cw_dz_ru556"] = "Codename Rul3R-5000",
	
	
>>>>>>> 772d73f4761c2b2028e709d286e32e8d14b2a2ae
}

function AddPackAPunchName(class, papname) -- The function also works with display names just like above
	nz.Display_PaPNames[class] = papname
end