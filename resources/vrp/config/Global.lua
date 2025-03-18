-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Rolepass = 1724785999
SalaryCooldowns = 1800
GroupsSetCooldown = 259200
ArenaCoords = vec3(-1046.33,-473.2,36.68)
PrisonCoords = vec3(1896.15,2604.44,45.75)
CreatorCoords = vec4(-2006.95,2960.77,31.81,305.82)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVERINFO
-----------------------------------------------------------------------------------------------------------------------------------------
Currency = "$"
DiscordBot = true
BaseMode = "steam"
Whitelisted = false
Liberation = "Token"
ServerName = "Creative Network"
NameDefault = "Indivíduo Indigente"
ServerLink = "https://creativenetwork.dev.br"
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNCOORDS
-----------------------------------------------------------------------------------------------------------------------------------------
SpawnCoords = {
	vec3(895.48,-179.38,73.7)
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
MaxRepair = 1
MinimumWeight = 15
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEXTUREPACK
-----------------------------------------------------------------------------------------------------------------------------------------
TexturePack = {
	"Drop","E","H","Normal","Selected"
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
Theme = {
	currency = Currency,
	main = "#5865f2",
	common = "#6fc66a",
	rare = "#6ac6c5",
	epic = "#c66a75",
	legendary = "#c6986a",
	accept = {
		letter = "#dcffe9",
		background = "#3fa466"
	},
	reject = {
		letter = "#ffe8e8",
		background = "#ad4443"
	},
	shadow = true,
	["main-text"] = "#ffffff",
	loading = {
		mode = "dark", -- [ Opções disponíveis: dark,light ],
		model = 2, -- [ Opções disponíveis: 1,2 ],
		progress = true -- [ Opções disponíveis: true, false ],
	},
	chat = {
		Families = {
			background = "#ff0000",
			letter = "#ffffff"
		},
		Ballas = {
			background = "#00ff00",
			letter = "#ffffff"
		},
		Vagos = {
			background = "#0000ff",
			letter = "#ffffff"
		}
	},
	hud = {
		modes = {
			info = 3, -- [ Opções disponíveis: 1,2,3 ],
			icon = "fill", -- [ Opções disponíveis: fill,line ],
			status = 10, -- [ Opções disponíveis: 1 a 12 ],
			vehicle = 3 -- [ Opções disponíveis: 1,2,3 ]
		},
		percentage = true,
		icons = "#FFFFFF",
		nitro = "#f69d2a",
		rpm = "#FFFFFF",
		fuel = "#f94c54",
		engine = "#ff4c55",
		health = "#76B984",
		armor = "#A66FED",
		hunger = "#F4B266",
		thirst = "#7FC8F8",
		stress = "#E287C9",
		luck = "#F18A7C",
		dexterity = "#E4E76E",
		repose = "#7FCCC7",
		pointer = "#ef4444",
		progress = {
			background = "#FFFFFF",
			circle = "#5865f2",
			letter = "#FFFFFF"
		}
	},
	notifyitem = {
		add = {
			letter = "#dcffe9",
			background = "#3fa466"
		},
		remove = {
			letter = "#ffe8e8",
			background = "#ad4443"
		}
	},
	pause = {
		premium = true,
		store = true,
		battlepass = true,
		boxes = true,
		marketplace = true,
		skinweapon = true,
		map = true,
		settings = true,
		disconnect = true
	},
	scripts = {
		mdt = {
			main = "#5865f2",
			["main-text"] = "#ffffff"
		}
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUPS
-----------------------------------------------------------------------------------------------------------------------------------------
Groups = {
	["Admin"] = {
		["Permission"] = {
			["Admin"] = true
		},
		["Hierarchy"] = { "Administrador","Moderador","Suporte" },
		["RejoinService"] = true,
		["Service"] = {},
		["Client"] = true
	},
	["Premium"] = {
		["Permission"] = {
			["Premium"] = true
		},
		["Hierarchy"] = { "Ouro","Prata","Bronze" },
		["Salary"] = { 3750,2500,1250 },
		["Backpack"] = { 25,15,5 },
		["RejoinService"] = true,
		["Service"] = {},
		["Client"] = true,
		["Block"] = true
	},
	["LSPD"] = {
		["Permission"] = {
			["LSPD"] = true
		},
		["Hierarchy"] = { "Chefe","Capitão","Tenente","Sargento","Oficial","Cadete" },
		["Salary"] = { 3750,3625,3500,3375,3250,3125 },
		["Discord"] = "1236102727369756774",
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true,
		["Markers"] = true,
		["Chat"] = true
	},
	["BCSO"] = {
		["Permission"] = {
			["BCSO"] = true
		},
		["Hierarchy"] = { "Chefe","Capitão","Tenente","Sargento","Oficial","Cadete" },
		["Salary"] = { 3750,3625,3500,3375,3250,3125 },
		["Discord"] = "1236102727369756774",
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true,
		["Markers"] = true,
		["Chat"] = true
	},
	["BCPR"] = {
		["Permission"] = {
			["BCPR"] = true
		},
		["Hierarchy"] = { "Chefe","Capitão","Tenente","Sargento","Oficial","Cadete" },
		["Salary"] = { 3750,3625,3500,3375,3250,3125 },
		["Discord"] = "1236102727369756774",
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true,
		["Markers"] = true,
		["Chat"] = true
	},
	["Paramedico"] = {
		["Permission"] = {
			["Paramedico"] = true
		},
		["Hierarchy"] = { "Chefe","Médico","Enfermeiro","Residente" },
		["Salary"] = { 3750,3625,3500,3375 },
		["Discord"] = "1236103044811456662",
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true,
		["Markers"] = true,
		["Chat"] = true
	},
	["Ballas"] = {
		["Permission"] = {
			["Ballas"] = true
		},
		["Hierarchy"] = { "Líder","Sub-Líder","Membro","Recruta" },
		["Discord"] = "1250080429965316127",
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true
	},
	["Vagos"] = {
		["Permission"] = {
			["Vagos"] = true
		},
		["Hierarchy"] = { "Líder","Sub-Líder","Membro","Recruta" },
		["Discord"] = "1250080465155657860",
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true
	},
	["Families"] = {
		["Permission"] = {
			["Families"] = true
		},
		["Hierarchy"] = { "Líder","Sub-Líder","Membro","Recruta" },
		["Discord"] = "1250080491814523022",
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true
	},
	["Marabunta"] = {
		["Permission"] = {
			["Marabunta"] = true
		},
		["Hierarchy"] = { "Líder","Sub-Líder","Membro","Recruta" },
		["Discord"] = "1250080518507069500",
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true
	},
	["Bennys"] = {
		["Permission"] = {
			["Bennys"] = true
		},
		["Hierarchy"] = { "Líder","Sub-Líder","Membro","Recruta" },
		["Discord"] = "1250080543908036638",
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true
	},
	["Aztecas"] = {
		["Permission"] = {
			["Aztecas"] = true
		},
		["Hierarchy"] = { "Líder","Sub-Líder","Membro","Recruta" },
		["Discord"] = "1250080564049084438",
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true
	},
	["Bahamas"] = {
		["Permission"] = {
			["Bahamas"] = true
		},
		["Hierarchy"] = { "Líder","Sub-Líder","Membro","Recruta" },
		["Discord"] = "1250080611851309107",
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true
	},
	["Restaurante"] = {
		["Permission"] = {
			["Restaurante"] = true
		},
		["Hierarchy"] = { "Chefe","Supervisor","Funcionário" },
		["RejoinService"] = true,
		["Service"] = {},
		["Type"] = "Work",
		["Client"] = true
	},
	["Booster"] = {
		["Permission"] = {
			["Booster"] = true
		},
		["Hierarchy"] = { "Membro" },
		["RejoinService"] = true,
		["Salary"] = { 2500 },
		["Service"] = {}
	},
	["Camera"] = {
		["Permission"] = {
			["Camera"] = true
		},
		["Hierarchy"] = { "Membro" },
		["RejoinService"] = true,
		["Service"] = {},
		["Block"] = true
	},
	["Policia"] = {
		["Permission"] = {
			["LSPD"] = true,
			["BCSO"] = true,
			["BCPR"] = true
		},
		["Hierarchy"] = { "Membro" },
		["Service"] = {},
		["Block"] = true
	},
	["Emergencia"] = {
		["Permission"] = {
			["LSPD"] = true,
			["BCSO"] = true,
			["BCPR"] = true,
			["Paramedico"] = true
		},
		["Hierarchy"] = { "Membro" },
		["Service"] = {},
		["Block"] = true
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERITENS
-----------------------------------------------------------------------------------------------------------------------------------------
CharacterItens = {
	["soda"] = 2,
	["identity"] = 1,
	["hamburger"] = 2
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- BOXES
-----------------------------------------------------------------------------------------------------------------------------------------
Boxes = {
	["treasurebox"] = {
		["Multiplier"] = { ["Min"] = 1, ["Max"] = 1 },
		["List"] = {
			{ ["Item"] = "dollar", ["Chance"] = 100, ["Min"] = 4250, ["Max"] = 6250 }
		}
	},
	["christmas_04"] = {
		["Multiplier"] = { ["Min"] = 1, ["Max"] = 1 },
		["List"] = {
			{ ["Item"] = "christmas_01", ["Chance"] = 100, ["Min"] = 1, ["Max"] = 1 },
			{ ["Item"] = "christmas_02", ["Chance"] = 100, ["Min"] = 1, ["Max"] = 1 },
			{ ["Item"] = "christmas_03", ["Chance"] = 100, ["Min"] = 1, ["Max"] = 1 }
		}
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPPERLEVEL
-----------------------------------------------------------------------------------------------------------------------------------------
UpperLevel = {
	Trucker = { -- Experiência do emprego
		["2"] = { -- Nível que vai receber a recompensa
			{ Item = "bandage", Min = 1, Max = 2 },
			{ Item = "advtoolbox", Min = 1, Max = 1 }
		}
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SKINSHOPINIT
-----------------------------------------------------------------------------------------------------------------------------------------
SkinshopInit = {
	["mp_m_freemode_01"] = {
		["pants"] = { item = 4, texture = 1 },
		["arms"] = { item = 0, texture = 0 },
		["tshirt"] = { item = 15, texture = 0 },
		["torso"] = { item = 273, texture = 0 },
		["vest"] = { item = 0, texture = 0 },
		["shoes"] = { item = 1, texture = 6 },
		["mask"] = { item = 0, texture = 0 },
		["backpack"] = { item = 0, texture = 0 },
		["hat"] = { item = -1, texture = 0 },
		["glass"] = { item = 0, texture = 0 },
		["ear"] = { item = -1, texture = 0 },
		["watch"] = { item = -1, texture = 0 },
		["bracelet"] = { item = -1, texture = 0 },
		["accessory"] = { item = 0, texture = 0 },
		["decals"] = { item = 0, texture = 0 }
	},
	["mp_f_freemode_01"] = {
		["pants"] = { item = 4, texture = 1 },
		["arms"] = { item = 14, texture = 0 },
		["tshirt"] = { item = 3, texture = 0 },
		["torso"] = { item = 338, texture = 2 },
		["vest"] = { item = 0, texture = 0 },
		["shoes"] = { item = 1, texture = 6 },
		["mask"] = { item = 0, texture = 0 },
		["backpack"] = { item = 0, texture = 0 },
		["hat"] = { item = -1, texture = 0 },
		["glass"] = { item = 0, texture = 0 },
		["ear"] = { item = -1, texture = 0 },
		["watch"] = { item = -1, texture = 0 },
		["bracelet"] = { item = -1, texture = 0 },
		["accessory"] = { item = 0, texture = 0 },
		["decals"] = { item = 0, texture = 0 }
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- BARBERSHOPINIT
-----------------------------------------------------------------------------------------------------------------------------------------
BarbershopInit = {
	["mp_m_freemode_01"] = { 13,25,0,3,0,-1,-1,-1,-1,13,38,38,0,0,0,0,0.5,0,0,1,0,10,1,0,1,0.5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
	["mp_f_freemode_01"] = { 13,25,1,3,0,-1,-1,-1,-1,1,38,38,0,0,0,0,1,0,0,1,0,0,0,0,1,0.5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 }
}