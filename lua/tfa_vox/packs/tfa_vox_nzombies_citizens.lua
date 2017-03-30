TFAVOX_Models = TFAVOX_Models or {}

--[[CONVENIENCE FUNCTIONS, DO NOT EDIT FROM THIS POINT UNTIL CLEAR ]]--

local model = "models/player/group01/female01.mdl"

local tmptbl = string.Split(model,"/")
local mdlprefix = tmptbl[#tmptbl] or model
mdlprefix = string.Replace(mdlprefix,".mdl","")
if model == "models/player/player.mdl" then return end

--[[CLEAR]]--

--[[
--To give VOX sound paths, I recommend TFAVOX_GenerateSound.
--TFAVOX_GenerateSound( mdlprefix, "sound_event_here", { "path/to/sound1.wav", "path/to/sound2.wav", "path/to/sound3.wav" }
--You may have as many sounds as you want in the GenerateSound table ^^
--Please have at least one.

--If you insist on doing things manually, ['sound'] can be a TABLE | { "sound1.wav", "sound2.wav", "sound3.wav" } | or a STRING  | "snd" |
--Manual sounds require soundscripts.

--TFA VOX will now automatically calculate delays.
--If you need to manually override, feed ['delay'] with a TABLE | {min,max} | or a NUMBER | 999 |
]]--



-- FEMALES
local femaletbl = {
	['perk'] = { -- When you get a perk
		['generic'] = { -- Generic is run if there isn't any voice for the perk bought
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "generic", {
				"vo/npc/female01/fantastic01.wav",
				"vo/npc/female01/fantastic02.wav",
				"vo/npc/female01/yeah02.wav",
				"vo/npc/female01/squad_follow03.wav",
				"vo/npc/female01/letsgo01.wav",
				"vo/npc/female01/letsgo02.wav"
			})
		},
		['jugg'] = { -- Which perk ID. These include custom perks added.
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "jugg", {
				"vo/npc/female01/answer37.wav",
				"vo/npc/female01/evenodds.wav",
				"vo/npc/female01/answer28.wav"
			} )
		},
		['speed'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "speed", {
				"vo/npc/female01/gottareload01.wav",
				"vo/npc/female01/coverwhilereload01.wav",
				"vo/npc/female01/coverwhilereload02.wav"
			} )
		},
		['dtap'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "dtap", {
				"vo/npc/female01/answer33.wav",
				"vo/npc/female01/answer32.wav"
			} )
		},
		['dtap2'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "dtap2", {
				"vo/npc/female01/answer33.wav",
				"vo/npc/female01/answer32.wav",
			} )
		},
		['mulekick'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "mulekick", { "vo/npc/female01/answer05.wav" } )
		},
		['revive'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "revive", {
				"vo/npc/female01/answer08.wav",
				"vo/npc/female01/answer21.wav",
				"vo/npc/female01/answer27.wav"
			} )
		},
		['cherry'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "cherry", {
				"vo/npc/female01/vquestion02.wav"
			} )
		},
		['deadshot'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "deadshot", {
				"vo/npc/female01/hacks01.wav",
				"vo/npc/female01/hacks02.wav",
				"vo/npc/female01/thehacks01.wav",
				"vo/npc/female01/thehacks02.wav"
			} )
		},
		['phd'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "phd", {
				"vo/npc/female01/vanswer13.wav",
				"vo/npc/female01/vanswer10.wav"
			} )
		},
		['tombstone'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "tombstone", {
				"vo/npc/female01/answer11.wav",
				"vo/npc/female01/squad_affirm06.wav",
				"vo/npc/female01/squad_affirm05.wav"
			} )
		},
		['whoswho'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "whoswho", {
				"vo/npc/female01/vanswer01.wav",
				"vo/npc/female01/vanswer03.wav",
				"vo/npc/female01/vanswer09.wav"
			} )
		},
		['widowswine'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "widowswine", {
				"vo/npc/female01/vanswer07.wav",
				"vo/npc/female01/vanswer06.wav",
				"vo/npc/female01/vanswer04.wav"
			} )
		},
	},
	['power'] = {
		['on'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "on", {
				"vo/npc/female01/finally.wav",
				"vo/npc/female01/likethat.wav",
				"vo/npc/female01/nice01.wav",
				"vo/npc/female01/nice02.wav"
			} )
		},
		['off'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "off", {
				"vo/npc/female01/gordead_ans03.wav",
				"vo/npc/female01/gordead_ans15.wav",
				"vo/npc/female01/gordead_ques01.wav"
			} )
		},
	},
	['revive'] = {
		['downed'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "downed", {
				"vo/npc/female01/help01.wav",
				"vo/npc/female01/imhurt01.wav",
				"vo/npc/female01/imhurt02.wav",
				"vo/npc/female01/mygut02.wav",
				"vo/npc/female01/myarm01.wav",
				"vo/npc/female01/myarm02.wav",
				"vo/npc/female01/myleg01.wav",
				"vo/npc/female01/myleg02.wav",
			} )
		},
		['otherdowned'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "otherdowned", {
				"vo/npc/female01/gordead_ans01.wav",
				"vo/npc/female01/gordead_ans02.wav",
				"vo/npc/female01/gordead_ans03.wav",
				"vo/npc/female01/gordead_ans09.wav",
				"vo/npc/female01/gordead_ans15.wav",
				"vo/npc/female01/gordead_ans18.wav"
			} )
		},
		['reviving'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "reviving", {
				"vo/npc/female01/health05.wav",
				"vo/npc/female01/health04.wav",
				"vo/npc/female01/health03.wav",
				"vo/npc/female01/health02.wav",
				"vo/npc/female01/health01.wav"
			} )
		},
		['revived'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "revived", {
				"vo/npc/female01/thislldonicely01.wav",
				"vo/npc/female01/squad_follow03.wav",
				"vo/npc/female01/squad_affirm04.wav",
				"vo/streetwar/tunnel/female01/d3_c17_06_post_det04.wav",
				"vo/npc/female01/okimready01.wav",
				"vo/npc/female01/okimready02.wav",
				"vo/npc/female01/okimready03.wav",
			})
		},
		['dead'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "dead", {
				"vo/npc/female01/gordead_ques14.wav",
				"vo/npc/female01/gordead_ques10.wav",
				"vo/npc/female01/gordead_ques07.wav",
				"vo/npc/female01/gordead_ques06.wav",
				"vo/npc/female01/gordead_ques02.wav",
				"vo/npc/female01/gordead_ans20.wav",
				"vo/npc/female01/gordead_ans16.wav",
				"vo/npc/female01/gordead_ans08.wav",
				"vo/npc/female01/gordead_ans07.wav"
			} )
		}
	},
	['round'] = {
		['prepare'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "prepare", { 
				"vo/npc/female01/question01.wav",
				"vo/npc/female01/question02.wav",
				"vo/npc/female01/question03.wav",
				"vo/npc/female01/question04.wav",
				"vo/npc/female01/question05.wav",
				"vo/npc/female01/question07.wav",
				"vo/npc/female01/question12.wav",
				"vo/npc/female01/question13.wav",
				"vo/npc/female01/question17.wav",
				"vo/npc/female01/question18.wav",
				"vo/npc/female01/question19.wav",
				"vo/npc/female01/question20.wav",
				"vo/npc/female01/question21.wav",
				"vo/npc/female01/question23.wav",
				"vo/npc/female01/question25.wav",
				"vo/npc/female01/question29.wav",
				"vo/npc/female01/likethat.wav"
			})
		},
		['preparereply'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "preparereply", { 
				"vo/npc/female01/answer01.wav",
				"vo/npc/female01/answer02.wav",
				"vo/npc/female01/answer03.wav",
				"vo/npc/female01/answer04.wav",
				"vo/npc/female01/answer05.wav",
				"vo/npc/female01/answer06.wav",
				"vo/npc/female01/answer07.wav",
				"vo/npc/female01/answer08.wav",
				"vo/npc/female01/answer09.wav",
				"vo/npc/female01/answer10.wav",
				"vo/npc/female01/answer11.wav",
				"vo/npc/female01/answer12.wav",
				"vo/npc/female01/answer13.wav",
				"vo/npc/female01/answer14.wav",
				"vo/npc/female01/answer15.wav",
				"vo/npc/female01/answer16.wav",
				"vo/npc/female01/answer17.wav",
				"vo/npc/female01/answer18.wav",
				"vo/npc/female01/answer19.wav",
				"vo/npc/female01/answer20.wav",
				"vo/npc/female01/answer21.wav",
				"vo/npc/female01/answer22.wav",
				"vo/npc/female01/answer23.wav",
				"vo/npc/female01/answer24.wav",
				"vo/npc/female01/answer25.wav",
				"vo/npc/female01/answer26.wav",
				"vo/npc/female01/answer27.wav",
				"vo/npc/female01/answer28.wav",
				"vo/npc/female01/answer29.wav",
				"vo/npc/female01/answer30.wav",
				"vo/npc/female01/answer31.wav",
				"vo/npc/female01/answer32.wav",
				"vo/npc/female01/answer33.wav",
				"vo/npc/female01/answer34.wav",
				"vo/npc/female01/answer35.wav",
				"vo/npc/female01/answer36.wav",
				"vo/npc/female01/answer37.wav",
				"vo/npc/female01/answer38.wav",
				"vo/npc/female01/answer39.wav",
				"vo/npc/female01/answer40.wav",
				
			})
		},
		['special'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "special", { 
				"vo/npc/female01/question11.wav",
				"vo/npc/female01/question16.wav",
				"vo/npc/female01/uhoh.wav",
				"vo/npc/female01/youdbetterreload01.wav",
				"vo/npc/female01/okimready01.wav",
				"vo/npc/female01/okimready02.wav",
				"vo/npc/female01/okimready03.wav",
				"vo/npc/female01/ohno.wav",
				"vo/npc/female01/incoming02.wav",
				"vo/npc/female01/holddownspot01.wav",
				"vo/npc/female01/holddownspot02.wav",
				"vo/npc/female01/heretheycome01.wav",
				"vo/npc/female01/headsup01.wav",
				"vo/npc/female01/headsup02.wav"
			})
		}
	},
	['powerup'] = {
		['generic'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "generic", {
				"vo/coast/odessa/female01/nlo_cheer01.wav",
				"vo/coast/odessa/female01/nlo_cheer02.wav",
				"vo/coast/odessa/female01/nlo_cheer03.wav"
			} )
		},
		['maxammo'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "maxammo", {
				"vo/npc/female01/ammo03.wav",
				"vo/npc/female01/ammo04.wav",
				"vo/npc/female01/ammo05.wav",
				"vo/npc/female01/gottareload01.wav",
				"vo/npc/female01/youdbetterreload01.wav"
			} )
		},
		['carpenter'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "carpenter", {
				"vo/trainyard/female01/cit_window_use01.wav",
				"vo/trainyard/female01/cit_window_use02.wav",
				"vo/trainyard/female01/cit_window_use03.wav",
				"vo/trainyard/female01/cit_window_use04.wav",
				"vo/canals/female01/gunboat_moveon.wav"
			})
		}
	},
	['facility'] = {
		['randombox'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "randombox", { 
				"vo/npc/female01/question06.wav",
				"vo/npc/female01/question07.wav",
				"vo/npc/female01/question08.wav",
				"vo/npc/female01/question09.wav",
				"vo/npc/female01/question14.wav",
				"vo/npc/female01/question16.wav",
				"vo/npc/female01/question17.wav",
				"vo/npc/female01/question21.wav",
				"vo/npc/female01/question26.wav",
				"vo/npc/female01/question28.wav",
				"vo/npc/female01/question31.wav",
				"vo/npc/female01/squad_affirm05.wav",
				"vo/npc/female01/squad_affirm06.wav",
				"vo/npc/female01/waitingsomebody.wav",
			})
		},
		['packapunch'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "packapunch", { 
				"vo/streetwar/tunnel/female01/c17_06_det02.wav",
				"vo/npc/female01/answer29.wav",
				"vo/npc/female01/answer33.wav",
				"vo/npc/female01/busy02.wav",
				"vo/npc/female01/doingsomething.wav",
				"vo/npc/female01/evenodds.wav",
				"vo/npc/female01/holddownspot01.wav",
				"vo/npc/female01/holddownspot02.wav",
				"vo/npc/female01/illstayhere.wav",
				"vo/npc/female01/imstickinghere01.wav",
				"vo/npc/female01/letsgo02.wav",
				"vo/npc/female01/letsgo01.wav",
				"vo/npc/female01/littlecorner01.wav",
				"vo/npc/female01/readywhenyouare01.wav",
				"vo/npc/female01/readywhenyouare02.wav",
				"vo/npc/female01/waitingsomebody.wav",
				"vo/npc/female01/zombies02.wav",
			})
		},
		['wunderfizz'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "wunderfizz", { 
				"vo/npc/female01/question06.wav",
				"vo/npc/female01/question07.wav",
				"vo/npc/female01/question08.wav",
				"vo/npc/female01/question09.wav",
				"vo/npc/female01/question14.wav",
				"vo/npc/female01/question16.wav",
				"vo/npc/female01/question17.wav",
				"vo/npc/female01/question21.wav",
				"vo/npc/female01/question26.wav",
				"vo/npc/female01/question28.wav",
				"vo/npc/female01/question31.wav",
				"vo/npc/female01/squad_affirm05.wav",
				"vo/npc/female01/squad_affirm06.wav",
				"vo/npc/female01/waitingsomebody.wav",
			})
		},
	}
}

model = "models/player/group01/male01.mdl"

tmptbl = string.Split(model,"/")
mdlprefix = tmptbl[#tmptbl] or model
mdlprefix = string.Replace(mdlprefix,".mdl","")

-- MALES
local maletbl = {
	['perk'] = { -- When you get a perk
		['generic'] = { -- Generic is run if there isn't any voice for the perk bought
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "generic", {
				"vo/npc/male01/fantastic01.wav",
				"vo/npc/male01/fantastic02.wav",
				"vo/npc/male01/oneforme.wav",
				"vo/npc/male01/yeah02.wav",
				"vo/npc/male01/squad_follow03.wav",
				"vo/npc/male01/letsgo01.wav",
				"vo/npc/male01/letsgo02.wav"
			})
		},
		['jugg'] = { -- Which perk ID. These include custom perks added.
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "jugg", {
				"vo/npc/male01/answer36.wav",
				"vo/npc/male01/evenodds.wav",
				"vo/npc/male01/answer28.wav"
			} )
		},
		['speed'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "speed", {
				"vo/npc/male01/gottareload01.wav",
				"vo/npc/male01/coverwhilereload01.wav",
				"vo/npc/male01/coverwhilereload02.wav"
			} )
		},
		['dtap'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "dtap", {
				"vo/npc/male01/answer33.wav",
				"vo/npc/male01/answer32.wav"
			} )
		},
		['dtap2'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "dtap2", {
				"vo/npc/male01/answer33.wav",
				"vo/npc/male01/answer32.wav",
			} )
		},
		['mulekick'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "mulekick", { "vo/npc/male01/answer05.wav" } )
		},
		['revive'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "revive", {
				"vo/npc/male01/answer08.wav",
				"vo/npc/male01/answer21.wav",
				"vo/npc/male01/answer27.wav"
			} )
		},
		['cherry'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "cherry", {
				"vo/npc/male01/vquestion02.wav"
			} )
		},
		['deadshot'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "deadshot", {
				"vo/npc/male01/hacks01.wav",
				"vo/npc/male01/hacks02.wav",
				"vo/npc/male01/thehacks01.wav",
				"vo/npc/male01/thehacks02.wav"
			} )
		},
		['phd'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "phd", {
				"vo/npc/male01/vanswer13.wav",
				"vo/npc/male01/vanswer10.wav"
			} )
		},
		['tombstone'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "tombstone", {
				"vo/npc/male01/answer11.wav",
				"vo/npc/male01/squad_affirm06.wav",
				"vo/npc/male01/squad_affirm05.wav"
			} )
		},
		['whoswho'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "whoswho", {
				"vo/npc/male01/vanswer01.wav",
				"vo/npc/male01/vanswer03.wav",
				"vo/npc/male01/vanswer09.wav"
			} )
		},
		['widowswine'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "widowswine", {
				"vo/npc/male01/vanswer07.wav",
				"vo/npc/male01/vanswer06.wav",
				"vo/npc/male01/vanswer04.wav"
			} )
		},
	},
	['power'] = {
		['on'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "on", {
				"vo/npc/male01/finally.wav",
				"vo/npc/male01/likethat.wav",
				"vo/npc/male01/nice.wav"
			} )
		},
		['off'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "off", {
				"vo/npc/male01/gordead_ans03.wav",
				"vo/npc/male01/gordead_ans15.wav",
				"vo/npc/male01/gordead_ques16.wav"
			} )
		},
	},
	['revive'] = {
		['downed'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "downed", {
				"vo/npc/male01/help01.wav",
				"vo/npc/male01/imhurt01.wav",
				"vo/npc/male01/mygut02.wav",
				"vo/npc/male01/myarm01.wav",
				"vo/npc/male01/myleg01.wav",
				"vo/npc/male01/myleg02.wav",
				"vo/streetwar/sniper/male01/c17_09_help01.wav",
				"vo/streetwar/sniper/male01/c17_09_help02.wav",
				"vo/streetwar/sniper/male01/c17_09_help03.wav",
			} )
		},
		['otherdowned'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "otherdowned", {
				"vo/npc/male01/gordead_ans01.wav",
				"vo/npc/male01/gordead_ans02.wav",
				"vo/npc/male01/gordead_ans03.wav",
				"vo/npc/male01/gordead_ans09.wav",
				"vo/npc/male01/gordead_ans15.wav",
				"vo/npc/male01/gordead_ans18.wav"
			} )
		},
		['reviving'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "reviving", {
				"vo/npc/male01/health05.wav",
				"vo/npc/male01/health04.wav",
				"vo/npc/male01/health03.wav",
				"vo/npc/male01/health02.wav",
				"vo/npc/male01/health01.wav"
			} )
		},
		['revived'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "revived", {
				"vo/npc/male01/thislldonicely01.wav",
				"vo/npc/male01/squad_follow03.wav",
				"vo/npc/male01/squad_affirm04.wav",
				"vo/coast/barn/male01/youmadeit.wav",
				"vo/streetwar/tunnel/male01/d3_c17_06_post_det04.wav",
			})
		},
		['dead'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "dead", {
				"vo/npc/male01/gordead_ques14.wav",
				"vo/npc/male01/gordead_ques10.wav",
				"vo/npc/male01/gordead_ques07.wav",
				"vo/npc/male01/gordead_ques06.wav",
				"vo/npc/male01/gordead_ques02.wav",
				"vo/npc/male01/gordead_ans20.wav",
				"vo/npc/male01/gordead_ans16.wav",
				"vo/npc/male01/gordead_ans08.wav",
				"vo/npc/male01/gordead_ans07.wav"
			} )
		}
	},
	['round'] = {
		['prepare'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "prepare", { 
				"vo/npc/male01/question01.wav",
				"vo/npc/male01/question02.wav",
				"vo/npc/male01/question03.wav",
				"vo/npc/male01/question04.wav",
				"vo/npc/male01/question07.wav",
				"vo/npc/male01/question12.wav",
				"vo/npc/male01/question13.wav",
				"vo/npc/male01/question17.wav",
				"vo/npc/male01/question18.wav",
				"vo/npc/male01/question19.wav",
				"vo/npc/male01/question20.wav",
				"vo/npc/male01/question21.wav",
				"vo/npc/male01/question23.wav",
				"vo/npc/male01/question25.wav",
				"vo/npc/male01/question29.wav",
				"vo/npc/male01/question31.wav",
				"vo/npc/male01/likethat.wav"
			})
		},
		['preparereply'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "preparereply", { 
				"vo/npc/male01/answer01.wav",
				"vo/npc/male01/answer02.wav",
				"vo/npc/male01/answer03.wav",
				"vo/npc/male01/answer04.wav",
				"vo/npc/male01/answer05.wav",
				"vo/npc/male01/answer06.wav",
				"vo/npc/male01/answer07.wav",
				"vo/npc/male01/answer08.wav",
				"vo/npc/male01/answer09.wav",
				"vo/npc/male01/answer10.wav",
				"vo/npc/male01/answer11.wav",
				"vo/npc/male01/answer12.wav",
				"vo/npc/male01/answer13.wav",
				"vo/npc/male01/answer14.wav",
				"vo/npc/male01/answer15.wav",
				"vo/npc/male01/answer16.wav",
				"vo/npc/male01/answer17.wav",
				"vo/npc/male01/answer18.wav",
				"vo/npc/male01/answer19.wav",
				"vo/npc/male01/answer20.wav",
				"vo/npc/male01/answer21.wav",
				"vo/npc/male01/answer22.wav",
				"vo/npc/male01/answer23.wav",
				"vo/npc/male01/answer24.wav",
				"vo/npc/male01/answer25.wav",
				"vo/npc/male01/answer26.wav",
				"vo/npc/male01/answer27.wav",
				"vo/npc/male01/answer28.wav",
				"vo/npc/male01/answer29.wav",
				"vo/npc/male01/answer30.wav",
				"vo/npc/male01/answer31.wav",
				"vo/npc/male01/answer32.wav",
				"vo/npc/male01/answer33.wav",
				"vo/npc/male01/answer34.wav",
				"vo/npc/male01/answer35.wav",
				"vo/npc/male01/answer36.wav",
				"vo/npc/male01/answer37.wav",
				"vo/npc/male01/answer38.wav",
				"vo/npc/male01/answer39.wav",
				"vo/npc/male01/answer40.wav",
			})
		},
		['special'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "special", { 
				"vo/npc/male01/question11.wav",
				"vo/npc/male01/question16.wav",
				"vo/npc/male01/uhoh.wav",
				"vo/npc/male01/youdbetterreload01.wav",
				"vo/npc/male01/okimready01.wav",
				"vo/npc/male01/okimready02.wav",
				"vo/npc/male01/okimready03.wav",
				"vo/npc/male01/ohno.wav",
				"vo/npc/male01/incoming02.wav",
				"vo/npc/male01/holddownspot01.wav",
				"vo/npc/male01/holddownspot02.wav",
				"vo/npc/male01/heretheycome01.wav",
				"vo/npc/male01/headsup01.wav",
				"vo/npc/male01/headsup02.wav"
			})
		}
	},
	['powerup'] = {
		['generic'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "generic", {
				"vo/coast/odessa/male01/nlo_cheer01.wav",
				"vo/coast/odessa/male01/nlo_cheer02.wav",
				"vo/coast/odessa/male01/nlo_cheer03.wav",
				"vo/coast/odessa/male01/nlo_cheer04.wav"
			} )
		},
		['maxammo'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "maxammo", {
				"vo/npc/male01/ammo03.wav",
				"vo/npc/male01/ammo04.wav",
				"vo/npc/male01/ammo05.wav",
				"vo/npc/male01/gottareload01.wav",
				"vo/npc/male01/youdbetterreload01.wav"
			} )
		},
		['carpenter'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "carpenter", {
				"vo/trainyard/male01/cit_window_use01.wav",
				"vo/trainyard/male01/cit_window_use02.wav",
				"vo/trainyard/male01/cit_window_use03.wav",
				"vo/trainyard/male01/cit_window_use04.wav",
				"vo/canals/male01/gunboat_moveon.wav"
			})
		}
	},
	['facility'] = {
		['randombox'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "randombox", { 
				"vo/npc/male01/question06.wav",
				"vo/npc/male01/question07.wav",
				"vo/npc/male01/question08.wav",
				"vo/npc/male01/question09.wav",
				"vo/npc/male01/question14.wav",
				"vo/npc/male01/question16.wav",
				"vo/npc/male01/question17.wav",
				"vo/npc/male01/question21.wav",
				"vo/npc/male01/question26.wav",
				"vo/npc/male01/question28.wav",
				"vo/npc/male01/question31.wav",
				"vo/npc/male01/squad_affirm05.wav",
				"vo/npc/male01/squad_affirm06.wav",
				"vo/npc/male01/waitingsomebody.wav",
			})
		},
		['packapunch'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "packapunch", { 
				"vo/streetwar/tunnel/male01/c17_06_det02.wav",
				"vo/npc/male01/answer29.wav",
				"vo/npc/male01/answer33.wav",
				"vo/npc/male01/busy02.wav",
				"vo/npc/male01/doingsomething.wav",
				"vo/npc/male01/evenodds.wav",
				"vo/npc/male01/holddownspot01.wav",
				"vo/npc/male01/holddownspot02.wav",
				"vo/npc/male01/illstayhere.wav",
				"vo/npc/male01/imstickinghere01.wav",
				"vo/npc/male01/letsgo02.wav",
				"vo/npc/male01/letsgo01.wav",
				"vo/npc/male01/littlecorner01.wav",
				"vo/npc/male01/readywhenyouare01.wav",
				"vo/npc/male01/readywhenyouare02.wav",
				"vo/npc/male01/waitingsomebody.wav",
				"vo/npc/male01/zombies02.wav",
			})
		},
		['wunderfizz'] = {
			['delay'] = nil,
			['sound'] = TFAVOX_GenerateSound( mdlprefix, "wunderfizz", { 
				"vo/npc/male01/question06.wav",
				"vo/npc/male01/question07.wav",
				"vo/npc/male01/question08.wav",
				"vo/npc/male01/question09.wav",
				"vo/npc/male01/question14.wav",
				"vo/npc/male01/question16.wav",
				"vo/npc/male01/question17.wav",
				"vo/npc/male01/question21.wav",
				"vo/npc/male01/question26.wav",
				"vo/npc/male01/question28.wav",
				"vo/npc/male01/question31.wav",
				"vo/npc/male01/squad_affirm05.wav",
				"vo/npc/male01/squad_affirm06.wav",
				"vo/npc/male01/waitingsomebody.wav",
			})
		},
	}
}

local function inject(model, tbl)
	-- Inject into any already existant model tables
	if not TFAVOX_Models[model] then TFAVOX_Models[model] = {} end
	TFAVOX_Models[model].nzombies = tbl
end

-- Inject into all male citizen models
for i = 1, 9 do
	local mdl = "models/player/group01/male_0"..i..".mdl"
	inject(mdl, maletbl)
end
for i = 10, 18 do
	local mdl = "models/player/group01/male_"..i..".mdl"
	inject(mdl, maletbl)
end
for i = 1, 9 do
	local mdl = "models/player/group01/medic_0"..i..".mdl"
	inject(mdl, maletbl)
end
for i = 1, 4 do
	local mdl = "models/player/group01/refugee_0"..i..".mdl"
	inject(mdl, maletbl)
end

-- Inject into all female citizen models
for i = 1, 9 do
	local mdl = "models/player/group01/female_0"..i..".mdl"
	inject(mdl, femaletbl)
end
for i = 10, 12 do
	local mdl = "models/player/group01/female_"..i..".mdl"
	inject(mdl, femaletbl)
end
for i = 10, 15 do
	local mdl = "models/player/group01/medic_"..i..".mdl"
	inject(mdl, femaletbl)
end

