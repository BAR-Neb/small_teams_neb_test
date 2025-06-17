# DUST-UP T1

**A Duels and Small Teams Unit Patch for T1**

> **Note:** This is not the [Unofficial Tech Overhaul](https://gist.github.com/BAR-Neb/60b5051685891de93e0d697038ecae94) but an even-less-official-than-that patch. You have stumbled upon a door in time and space, a door to which your mind is the only key, a door to that which came before and shall follow after. Or whatever.

*Beyond All Reason* supports user mods through widgets and tweaks—and this is an entirely tweak-based mod project. You can take these tweakdefs (or tweakunits) and easily make [your own changes](https://gist.github.com/efrec/153081a7d43db3ad7a3c4fc5c9a689f8). Balance packs focus on the community meta so rely on people taking an interest to keep them alive. We hope to make something you'd be willing not just to test but to help evolve.

- Mod support: [neb_](https://discord.com/users/320254986154147841), [encyclopedia.](https://discord.com/users/761830414070579211), and [\[boneless\]](https://discord.com/users/227953252723982338) (Discord)
- Talk about it: [Beyond All Reason](https://discord.com/channels/549281623154229250/1376965918659182764) (Discord)
- Plan a match: [Fight Night](https://discord.com/channels/1295134383250083870/1295170995044487188) (Discord)

This tweak is not *quite* a balance pack, yet, instead pushing toward a larger overhaul. Extensive reworks are given preference over balance-oriented "adjustments" to fit the meta. The meta *itself* needs a tweak—so just buffing or nerfing Grunts won't cut it.

After the v1.0 releases and gets sufficient blessing, then the tweak will be maintained as a balance pack, with weekly reviews and monthly wrap-ups focused on more competitive levels of play.

## How to use this tweak

1. **Boss yourself in the lobby.** Enter `!boss` in the console and hit enter to send the command.

2. **Enable the Legion faction.** You can enable it in the Advanced Options menu on the Experimental options tab.

3. **Apply this tweak.** Copy the encoded tweak from the [bottom of this document](#tweakdefs-encoded-url-safe-base64) and either:
   - enter it in the TweakDef field in the Cheat options tab, or
   - enter `!bset tweakdefs <text>` in the console.

## Patch summary

- **Early raiding and counter-raiding.** Basic economy buildings have more health, basic combat units are faster and cheaper, and the Banshee and Pounder are better at focusing single targets.

  - We wanted to increase the skill required to dish out early eco damage with scout raids.
  - Also, anti-air missiles now target ground units to act as an effective deterrent.

- **Factory costs (modified) test patch.** We liked the patch so much that we stole it. Johannes' test patch got a minor re-patching and fit right in with the rest of our changes.

  - I, uh, dunno what's in this thing.

- **Tech 1.5 units.** Unusually expensive and powerful Basic-tech units now join the likes of Legion's specialized tier-and-a-half unit roster.

  - Armada: Centurion, Janus, Corsair, Chainsaw, and Twilight.
  - Cortex: Thug, Lasher, Oppressor, Eradicator, and Exploiter.
  - Buffs to these units have the seemingly-contradictory effect of posing a game-end threat early in the T1 phase while also extending that threat against any potential T2 transitions and rushes.
  - To deal with the extra threat to commanders, we gave a 30% reduction to the cost to cloak.

- **Faction-unique weapons.** More units have unique weapons. Armada specializes in EMG and Gauss weapons, and Cortex in lasers and explosives.

- **Cortex bot lab.** Bedbug reworked into a fast, low-vision, high-radar scout in T1.

  - Cortex has a *very* limited roster in this T1 lab and two crawling bombs in a single T2 lab. Something had to give. The new Bedbug provides excellent mobile radar and retains just enough punch to be worth using on limited risky raids (or a desperate defense).

### Dev diary

In short, we asked ourselves what changes are desirable to get away from the current game state and decided, kind of, all of them? *Yes?* Dear reader, it was not a very good question. This patch has alternated between a longer and shorter Basic tech phase, more expensive and cheaper Advanced tech, and buffing and nerfing mono-spam in its brief two-and-a-half week long history.

Easy answers haven't been easy to come by.

At high-level play in particular, we face a lot of pain points. Some are born of the indestructible artifacts of BAR's extended lifetime. Some, of the pace of volunteer-driven development. Change in this *ye olde* game is very needed, indeed, but good change isn't easy to come by, either.

Rather, it trickles in over time.

Many of the problems we want to address were taken up by the core developers a long time ago\*. Their solutions are often better than any tweak can hope to achieve, but many remain in that long limbo of being *in progress*. This rework is something we can do, right now, both for fun and for the community. It takes back some agency to "be the change" and hopefully influence the future of the game.

Thank you for attending my TED talk. —🍍

*\* Note: We have access to private forums that are not available to non-contributors. If you think that's unfair or something: Join the development team. The future of BAR is exceedingly bright and, at worst, only inconveniently far away.*

## Tweakdefs

```lua
---small_teams_tweak
local unitDef, weaponDef, cparams, ref
local divisors = { 2, 4, 5, 8, 12, 20, 50, 125, 250 }
local m2e, m2b = 20, 30

local function copy(def, ...)
	for _, property in ipairs({ ... }) do
		def[property] = ref[property]
	end
end

local function neat(value, precision)
	if precision then
		value = value / precision
	else
		precision = 1
	end
	if value <= 30 then
		return math.floor(value + 0.5) * precision
	end
	local values = {}
	for _, v in ipairs(divisors) do
		values[v] = math.floor(value / v + 0.5) * v
	end
	local neatest = values[divisors[1]]
	local fitness = neatest - value
	fitness = fitness * fitness / divisors[1]
	for i = 2, #divisors do
		local divisor = divisors[i]
		local fitness2 = values[divisor] - value
		fitness2 = fitness2 * fitness2 / divisors[i]
		if fitness > fitness2 then
			neatest = values[divisor]
			fitness = fitness2
		end
	end
	return neatest * precision
end

local function costs(mult, base_m, base_e, base_b)
	if not base_m then base_m = 0 end
	if not base_e then
		base_e = base_m * (unitDef.metalcost and unitDef.metalcost > 0 and unitDef.energycost / unitDef.metalcost or m2e)
	end
	if not base_b then
		base_b = base_m * (unitDef.metalcost and unitDef.metalcost > 0 and unitDef.buildtime / unitDef.metalcost or m2b)
	end
	local metal = neat(unitDef.metalcost * mult + base_m, 10)
	local ratio = metal / unitDef.metalcost
	unitDef.metalcost = metal
	unitDef.energycost = neat(unitDef.energycost * mult + base_e, 10)
	unitDef.buildtime = neat(unitDef.buildtime * mult + base_b, 10)
	for name, def in pairs(unitDef.featuredefs or {}) do
		def.metal = math.floor(ratio * def.metal + 0.5)
	end
end

local function damages(mult, base)
	if not base then base = 0 end
	for armor, value in pairs(weaponDef.damage) do
		weaponDef.damage[armor] = neat(value * mult + base)
	end
end

local function unit(name)
	unitDef = UnitDefs[name]
	return unitDef
end

local function weapon(name)
	weaponDef = unitDef.weapondefs[name]
	return weaponDef
end

local function custom(def)
	cparams = def.customparams or {}
	def.customparams = cparams
	return cparams
end

--------------------------------------------------------------------------------
-- Commanders ------------------------------------------------------------------

-- More dangerous Tech 1 units often will force Commanders onto the defensive.
-- Ideally all commanders would have Legion's AA and torpedo weapons, as well.

for _, name in ipairs { "armcom", "corcom", "legcom" } do
	unit(name)
	unitDef.airsightdistance = neat(unitDef.sightdistance * 1.5)
	unitDef.cloakcost = neat(unitDef.cloakcost * 0.7)
	unitDef.cloakcostmoving = neat(unitDef.cloakcostmoving * 0.7)
end

--------------------------------------------------------------------------------
-- Tech level changes ----------------------------------------------------------

-- There are two types of changes, so it is just easier to summarize them first.

local techUp = {
	"armwar", "armjanus", "armroy", "armcir", "armamex",
	"corthud", "cormist", "corroy", "corerad", "corexp",
}

for name, def in pairs(UnitDefs) do
	if custom(def).techlevel == 1.5 then
		techUp[#techUp + 1] = name
	end
end

for _, name in ipairs(techUp) do
	custom(unit(name)).techlevel = 1.5
	cparams.paralyzemultiplier = 0.7
end

custom(unit("corroach")).techlevel = 1

--------------------------------------------------------------------------------
-- Basic economy ---------------------------------------------------------------

-- Scout leaks are not high-APM gameplay but high-attention gameplay.
-- We want you to act strategically early on until you are warmed up.

for name, def in ipairs(UnitDefs) do
	if (custom(def).techlevel or 1) < 1.5 then
		if def.extractsmetal and def.extractsmetal > 0 then
			def.health = neat(unit(name).health * 2, 25)
		elseif def.windgenerator and def.windgenerator > 0 then
			def.health = neat(unit(name).health * 1.1, 25)
		elseif cparams.solar and (def.energyupkeep and def.energyupkeep < -50) or (def.energymake and def.energymake > 50) then
			def.health = neat(unit(name).health * 1.125, 25)
			def.energystorage = neat((def.energystorage or 0) * 1.125)
		elseif next(def.buildoptions) and string.find(def.movementclass or "", "BOT") then
			def.health = neat(unit(name).health * 1.12, 25)
		end
	end
end

--------------------------------------------------------------------------------
-- Raiding and counter-raiding -------------------------------------------------

-- Sturdier economy buildings allow you to chase down leaks using combat units.
-- More combat units being built, in general, acts as its own scout deterrence.

unit("armpw")
costs(1, 0, 0, 132)
unitDef.speed = neat(unitDef.speed * 1.08)

unit("armflash")
unitDef.speed = neat(unitDef.speed * 1.08)

unit("armkam")
weapon("emg")
weaponDef.sprayangle = neat(weaponDef.sprayangle * 0.6)
weaponDef.weaponvelocity = neat(weaponDef.weaponvelocity * 1.1)
weaponDef.firetolerance = 3600

unit("corlevlr")
unitDef.speed = neat(unitDef.speed * 1.1)
weapon("corlevlr_weapon")
weaponDef.range = neat(weaponDef.range * 0.92)

-- This gives ground-to-ground capabilities to AA weapons (though pitifully weak).
-- The true intent is to add a short-range point defense as a swapped weapon load.

-- Air units are the best raiders in the game and often its best counter-raiders.
-- With more ground AA, air, especially air scouts, can be balanced for survival.

for name, wname in pairs { armrl = "armrl_missile", armcir = "arm_cir", corrl = "corrl_missile", corerad = "cor_erad", legrl = "legrl_missile", legrhapsis = "burst_aa_missile" } do
	unit(name)
	unitDef.weapons[1].fastautoretargeting = true
	unitDef.weapons[1].onlytargetcategory = "NOTSUB"
	weapon(wname)
	local salvo = (weaponDef.burst or 1) * (weaponDef.projectiles or 1)
	weaponDef.damage.default = neat((20 + 0.2 * weaponDef.damage.vtol * salvo) / salvo)
end

--------------------------------------------------------------------------------
-- Factory costs test patch ----------------------------------------------------

-- 1. Expensive build power except through factories, which are more efficient.
-- 2. Factories become prohibitively expensive the higher you progress in tech.

for _, name in ipairs { "armmoho", "cormoho", "cormexp", "legmoho", "legmoho", "legmohobp", "legmohocon" } do
	unit(name)
	costs(1, 100, 2000, 900)
end
for name, def in pairs(UnitDefs) do
	if custom(def).techlevel == 2 then
		def.buildtime = neat(unit(name).buildtime * 1.5)
	elseif cparams.techlevel == 3 then
		def.buildtime = neat(unit(name).buildtime * 2)
	end
end
for _, name in ipairs { "armageo", "corageo", "legageo" } do
	unit(name)
	costs(1, 100, 4000, 0)
end

for _, faction in ipairs { "arm", "cor", "leg" } do
	for _, factory in ipairs { "lab", "vp", "ap", "sy" } do
		if unit(faction .. factory) then
			costs(0.5, 300, 900, 4000)
			unitDef.workertime = neat(unitDef.workertime * 2.5, 50)
		end
	end
	for _, factory in ipairs { "plat", "amsub", "amphlab" } do
		if unit(faction .. factory) then
			unitDef.workertime = neat(unitDef.workertime * 3 + 100, 50)
		end
	end
	for _, factory in ipairs { "alab", "avp", "aap", "asy" } do
		if unit(faction .. factory) then
			costs(1, -500, 2000, 5000)
			unitDef.workertime = neat(unitDef.workertime * 5)
		end
	end
	for _, factory in ipairs { "gant", "gantuw", "shltx", "shltxuw" } do
		if unit(faction .. factory) then
			costs(1.5, 1000, 10000, 2000)
			unitDef.workertime = neat(unitDef.workertime * 7.5, 500)
		end
	end

	-- NB: Construction turrets can't be too expensive or cons replace them.
	for _, turret in ipairs { "nanotc", "nanotcplat" } do
		if unit(faction .. turret) then
			costs(1, 50, 500, 1000)
			-- We need ways to justify the expense, then:
			unitDef.metalstorage = 50
			unitDef.energystorage = 50
			if faction == "cor" then
				unitDef.health = neat(unitDef.health * 1.125, 25)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Tech 1.5 --------------------------------------------------------------------

-- T1.5 is not a reified game mechanic but a classification schema for units.
-- They are more expensive, more powerful, and have better resistance to EMP.

unit("armwar")
costs(1.2, 0, 0, 300)
unitDef.health = neat(unitDef.health * 1.25, 25)
unitDef.idleautoheal = 10
unitDef.speed = neat(unitDef.speed * 1.3333)
weapon("armwar_laser")
weaponDef.range = neat(weaponDef.range - 30)
damages(1.25)

unit("armjanus")
costs(1.3333)
unitDef.health = neat(unitDef.health * 1.1667, 25)
unitDef.speed = neat(unitDef.speed * 1.125)
weapon("janus_rocket")
weaponDef.reloadtime = weaponDef.reloadtime * 0.925

unit("armamex")
costs(1.125)
unitDef.health = neat(unitDef.health * 1.25, 25)
unitDef.explodeas = "mediumBuildingExplosionGeneric"
unitDef.energymake = unitDef.cloakcost
unitDef.radardistance = 1000
unitDef.radaremitheight = 24
unitDef.sightdistance = 200

unit("corthud")
costs(2)
unitDef.health = neat(unitDef.health * 2, 25)
unitDef.speed = neat(unitDef.speed * 1.1667)
unitDef.turnrate = unitDef.turnrate * 1.05
weapon("arm_ham")
weaponDef.areaofeffect = neat(weaponDef.areaofeffect * 1.1667)
weaponDef.burst = 2
weaponDef.burstrate = 0.25
weaponDef.reloadtime = weaponDef.reloadtime * 1.5

unit("cormist")
costs(2)
unitDef.health = neat(unitDef.health * 1.3333, 25)
for _, wname in ipairs { "cortruck_aa", "cortruck_missile" } do
	weapon(wname)
	weaponDef.areaofeffect = UnitDefs.corstorm.weapondefs.cor_bot_rocket.areaofeffect + 2
	weaponDef.burst = 3
	weaponDef.burstrate = 0.375
	weaponDef.reloadtime = weaponDef.reloadtime * 2
end

unit("corexp")
costs(1.5)
unitDef.health = neat(unitDef.health * 1.3333, 25)
unitDef.idleautoheal = 10
unitDef.sightdistance = neat(unitDef.sightdistance * 1.5)
weaponDef = unitDef.weapondefs.hllt_bottom
weaponDef.range = neat(weaponDef.range + 50)
damages(1.125)

--------------------------------------------------------------------------------
-- Cortex bots -----------------------------------------------------------------

unit("corak")
costs(0.8888)
unitDef.health = neat(unitDef.health * 0.8888, 25)
weaponDef = unitDef.weapondefs.gator_laser
weaponDef.range = neat(weaponDef.range * 1.05)

unit("corroach")
costs(0.5, 0, -2000, -2000)
unitDef.maxwaterdepth = 16
unitDef.movementclass = "BOT1"
unitDef.radardistance = UnitDefs.armflea.sightdistance + 30
unitDef.radaremitheight = 18
unitDef.speed = neat(unitDef.speed * 1.3333)
unitDef.explodeas = "mediumExplosionGenericSelfd"
unitDef.selfdestructas = "fb_blastsml"
unitDef.customparams.techlevel = nil
for name, def in ipairs(UnitDefs) do
	if def.builder and type(def.buildoptions) == "table" then
		for i, bo in pairs(def.buildoptions) do
			if bo == "corroach" then
				unit(name)
				table.remove(def.buildoptions, i)
			end
		end
	end
end
unit("corlab")
unitDef.buildoptions[#unitDef.buildoptions + 1] = "corroach"

--------------------------------------------------------------------------------
-- Weapon conversions ----------------------------------------------------------

-- These are total conversions that otherwise preserve the stats of the weapon.
-- Overall stat changes (eg total burst size) should be done in other sections.

-- HEMG
ref = UnitDefs.armkam.weapondefs.emg
for name, wname in pairs { armwar = "armwar_laser", armhlt = "arm_laserh1" } do
	unit(name)
	weapon(wname).name = "Heavy EMG"
	copy(weaponDef,
		"weapontype",
		"corethickness", "explosiongenerator", "intensity", "laserflaresize", "rgbcolor", "thickness", "size",
		"soundhitwet", "soundstart",
		"burstrate", "beamburst", "beamtime", "burst",
		"cylindertargeting", "energypershot", "impactonly", "tolerance", "predictboost", "weaponvelocity"
	)
	weaponDef.impulsefactor = 0.8
	damages((weaponDef.burst or 1) / (ref.burst + 1))

	weaponDef.burst = 4
	weaponDef.burstrate = 0.1
	weaponDef.stages = 12
	weaponDef.size = 3
	weaponDef.spread = 
	weaponDef.weaponvelocity = 750
	local ratio = (ref.reloadtime / weaponDef.reloadtime) * (ref.range / weaponDef.range)
	weaponDef.sprayangle = ref.sprayangle * math.sqrt(ratio)
end

-- Gauss
ref = UnitDefs.armmav.weapondefs.armmav_weapon
for name, wname in pairs { armham = "arm_ham" } do
	unit(name)
	costs(1.1) -- Not a neutral conversion.
	weapon(wname).name = "Gauss Plasma Cannon"
	copy(weaponDef, 'impulsefactor', 'weaponvelocity')
	weaponDef.reloadtime = neat(weaponDef.reloadtime * 1.75, 0.01)
	damages(1.75)
end

-- LSFR
for name, wname in pairs { cormist = "cortruck_missile", corstorm = "cor_bot_rocket" } do
	unit(name)
	weapon(wname).name = "Light Solid-Fuel Rocket"
	weaponDef.model = "legsmallrocket.s3o"
	weaponDef.burnblow = false
	weaponDef.mygravity = 0
	weaponDef.tracks = true
	weaponDef.trajectoryheight = 0.25
	weaponDef.turnrate = 8000
	weaponDef.startvelocity = unitDef.speed + 1
	weaponDef.weaponvelocity = neat(weaponDef.weaponvelocity * 2.2)
	weaponDef.weaponacceleration = weaponDef.weaponvelocity - weaponDef.startvelocity
	local accelTime = (weaponDef.weaponvelocity - weaponDef.startvelocity) / weaponDef.weaponacceleration
	local accelDistance = math.min(weaponDef.range,
		accelTime * (weaponDef.startvelocity + weaponDef.weaponvelocity) * 0.5)
	weaponDef.flighttime = accelTime + (weaponDef.range - accelDistance) * 0.9 / weaponDef.weaponvelocity
	weaponDef.dance = 6
	weaponDef.wobble = 600
	custom(weaponDef).overrange_distance = weaponDef.range
	cparams.place_target_on_ground = true
	cparams.projectile_destruction_method = "descend"
end
```

## Tweakunits

```lua
{
    armaak = {
        buildtime = 10500,
    },
    armaap = {
        buildtime = 36350,
        energycost = 31000,
        featuredefs = {
            dead = {
                metal = 1648,
            },
            heap = {
                metal = 824,
            },
        },
        metalcost = 2700,
        workertime = 1000,
    },
    armaas = {
        buildtime = 22500,
    },
    armaca = {
        buildtime = 26625,
    },
    armack = {
        buildtime = 14250,
    },
    armacsub = {
        buildtime = 27000,
    },
    armacv = {
        buildtime = 18600,
    },
    armafus = {
        buildtime = 468750,
    },
    armageo = {
        buildtime = 49950,
        energycost = 31000,
        metalcost = 1700,
    },
    armalab = {
        buildtime = 29300,
        energycost = 17000,
        featuredefs = {
            dead = {
                metal = 1467,
            },
            heap = {
                metal = 734,
            },
        },
        metalcost = 2400,
        workertime = 1500,
    },
    armamb = {
        buildtime = 40500,
    },
    armamd = {
        buildtime = 90000,
    },
    armamex = {
        buildtime = 2020,
        customparams = {
            paralyzemultiplier = 0.69999999,
            techlevel = 1.5,
        },
        energycost = 1680,
        energymake = 12,
        explodeas = "mediumBuildingExplosionGeneric",
        featuredefs = {
            dead = {
                metal = 118,
            },
            heap = {
                metal = 47,
            },
        },
        health = 2000,
        metalcost = 230,
        radardistance = 1000,
        radaremitheight = 24,
        sightdistance = 200,
    },
    armamph = {
        buildtime = 7800,
    },
    armamsub = {
        workertime = 550,
    },
    armanni = {
        buildtime = 78000,
    },
    armantiship = {
        buildtime = 30000,
    },
    armap = {
        buildtime = 7620,
        energycost = 1580,
        featuredefs = {
            dead = {
                metal = 463,
            },
            heap = {
                metal = 185,
            },
        },
        metalcost = 720,
        workertime = 250,
    },
    armarad = {
        buildtime = 12000,
    },
    armaser = {
        buildtime = 7410,
    },
    armason = {
        buildtime = 9225,
    },
    armasy = {
        buildtime = 29000,
        energycost = 11700,
        featuredefs = {
            dead = {
                metal = 1883,
            },
        },
        metalcost = 2700,
        workertime = 1500,
    },
    armatl = {
        buildtime = 13890,
    },
    armavp = {
        buildtime = 32000,
        energycost = 16000,
        featuredefs = {
            dead = {
                metal = 1452,
            },
            heap = {
                metal = 726,
            },
        },
        metalcost = 2400,
        workertime = 1500,
    },
    armawac = {
        buildtime = 19200,
    },
    armbanth = {
        buildtime = 552000,
    },
    armbats = {
        buildtime = 52500,
    },
    armblade = {
        buildtime = 36000,
    },
    armbrawl = {
        buildtime = 20250,
    },
    armbrtha = {
        buildtime = 127500,
    },
    armbull = {
        buildtime = 25800,
    },
    armcarry = {
        buildtime = 30000,
    },
    armcir = {
        customparams = {
            paralyzemultiplier = 0.69999999,
            techlevel = 1.5,
        },
        weapondefs = {
            arm_cir = {
                damage = {
                    default = 55,
                },
            },
        },
        weapons = {
            {
                onlytargetcategory = "NOTSUB",
            },
        },
    },
    armckfus = {
        buildtime = 126600,
    },
    armcom = {
        airsightdistance = 675,
        cloakcost = 70,
        cloakcostmoving = 700,
    },
    armconsul = {
        buildtime = 10200,
    },
    armcroc = {
        buildtime = 24000,
    },
    armcrus = {
        buildtime = 25500,
    },
    armdecom = {
        buildtime = 36000,
    },
    armdf = {
        buildtime = 11250,
    },
    armdfly = {
        buildtime = 24000,
    },
    armdronecarry = {
        buildtime = 30000,
    },
    armemp = {
        buildtime = 118950,
    },
    armepoch = {
        buildtime = 254700,
    },
    armexcalibur = {
        buildtime = 27000,
    },
    armfark = {
        buildtime = 6450,
    },
    armfasp = {
        buildtime = 13650,
    },
    armfast = {
        buildtime = 5940,
    },
    armfatf = {
        buildtime = 14820,
    },
    armfboy = {
        buildtime = 31500,
    },
    armfflak = {
        buildtime = 32850,
    },
    armfgate = {
        buildtime = 88500,
    },
    armfido = {
        buildtime = 9345,
    },
    armflak = {
        buildtime = 28500,
    },
    armflash = {
        speed = 108,
    },
    armfort = {
        buildtime = 1350,
    },
    armfus = {
        buildtime = 105000,
    },
    armgate = {
        buildtime = 82500,
    },
    armgmm = {
        buildtime = 62250,
    },
    armgremlin = {
        buildtime = 10050,
    },
    armham = {
        buildtime = 2420,
        energycost = 1440,
        featuredefs = {
            dead = {
                metal = 85,
            },
            heap = {
                metal = 34,
            },
        },
        metalcost = 140,
        weapondefs = {
            arm_ham = {
                damage = {
                    default = 182,
                    vtol = 36,
                },
                impulsefactor = 1.10000002,
                name = "Gauss Plasma Cannon",
                reloadtime = 3.03999996,
                weaponvelocity = 500,
            },
        },
    },
    armhawk = {
        buildtime = 13350,
    },
    armhlt = {
        weapondefs = {
            arm_laserh1 = {
                beamtime = "nil",
                burst = 4,
                burstrate = 0.1,
                corethickness = "nil",
                cylindertargeting = 1,
                damage = {
                    commanders = 145,
                    default = 96,
                    vtol = 9,
                },
                energypershot = "nil",
                explosiongenerator = "custom:plasmahit-small",
                impactonly = "nil",
                impulsefactor = 0.80000001,
                intensity = 0.66000003,
                laserflaresize = "nil",
                name = "Heavy EMG",
                rgbcolor = "1 0.95 0.4",
                size = 2,
                soundhitwet = "splshbig",
                soundstart = "flashemg",
                sprayangle = 288.154938,
                thickness = "nil",
                tolerance = 5000,
                weapontype = "Cannon",
                weaponvelocity = 880,
            },
        },
    },
    armjam = {
        buildtime = 8895,
    },
    armjanus = {
        buildtime = 4720,
        customparams = {
            paralyzemultiplier = 0.69999999,
            techlevel = 1.5,
        },
        energycost = 3480,
        featuredefs = {
            dead = {
                metal = 196,
            },
            heap = {
                metal = 79,
            },
        },
        health = 1200,
        metalcost = 320,
        speed = 60,
        weapondefs = {
            janus_rocket = {
                reloadtime = 6.9375,
            },
        },
    },
    armkam = {
        weapondefs = {
            emg = {
                firetolerance = 3600,
                sprayangle = 615,
                weaponvelocity = 880,
            },
        },
    },
    armkraken = {
        buildtime = 30000,
    },
    armlab = {
        buildtime = 7250,
        energycost = 1500,
        featuredefs = {
            dead = {
                metal = 437,
            },
            heap = {
                metal = 175,
            },
        },
        metalcost = 620,
        workertime = 250,
    },
    armlance = {
        buildtime = 22650,
    },
    armlatnk = {
        buildtime = 9045,
    },
    armliche = {
        buildtime = 86100,
    },
    armlship = {
        buildtime = 17100,
    },
    armlun = {
        buildtime = 64000,
    },
    armmanni = {
        buildtime = 38550,
    },
    armmar = {
        buildtime = 52200,
    },
    armmark = {
        buildtime = 5700,
    },
    armmart = {
        buildtime = 9750,
    },
    armmav = {
        buildtime = 25500,
    },
    armmercury = {
        buildtime = 42000,
    },
    armmerl = {
        buildtime = 23250,
    },
    armmls = {
        buildtime = 7080,
    },
    armmmkr = {
        buildtime = 52500,
    },
    armmoho = {
        buildtime = 23700,
        energycost = 9700,
        featuredefs = {
            dead = {
                metal = 439,
            },
            heap = {
                metal = 175,
            },
        },
        metalcost = 720,
    },
    armmship = {
        buildtime = 22500,
    },
    armnanotc = {
        buildtime = 6300,
        energycost = 3700,
        energystorage = 50,
        metalcost = 260,
        metalstorage = 50,
    },
    armnanotcplat = {
        buildtime = 6300,
        energycost = 3100,
        energystorage = 50,
        metalcost = 280,
        metalstorage = 50,
    },
    armpb = {
        buildtime = 22500,
    },
    armplat = {
        workertime = 700,
    },
    armpnix = {
        buildtime = 31500,
    },
    armprowl = {
        buildtime = 52200,
    },
    armpw = {
        buildtime = 1780,
        featuredefs = {
            dead = {
                metal = 27,
            },
            heap = {
                metal = 11,
            },
        },
        metalcost = 50,
        speed = 94,
    },
    armraz = {
        buildtime = 177200,
    },
    armrl = {
        weapondefs = {
            armrl_missile = {
                damage = {
                    default = 44,
                },
            },
        },
        weapons = {
            {
                onlytargetcategory = "NOTSUB",
            },
        },
    },
    armroy = {
        customparams = {
            paralyzemultiplier = 0.69999999,
            techlevel = 1.5,
        },
    },
    armsat = {
        buildtime = 19200,
    },
    armscab = {
        buildtime = 60000,
    },
    armsd = {
        buildtime = 17850,
    },
    armseadragon = {
        buildtime = 210000,
    },
    armseer = {
        buildtime = 9300,
    },
    armserp = {
        buildtime = 34155,
    },
    armshltx = {
        buildtime = 186200,
        energycost = 97000,
        featuredefs = {
            armshlt_dead = {
                metal = 7819,
            },
            armshlt_heap = {
                metal = 3128,
            },
        },
        metalcost = 12850,
        workertime = 4500,
    },
    armshltxuw = {
        buildtime = 186200,
        energycost = 97000,
        featuredefs = {
            armshlt_dead = {
                metal = 7819,
            },
            armshlt_heap = {
                metal = 3128,
            },
        },
        metalcost = 12850,
        workertime = 4500,
    },
    armshockwave = {
        buildtime = 22500,
    },
    armsilo = {
        buildtime = 267750,
    },
    armsjam = {
        buildtime = 25500,
    },
    armsnipe = {
        buildtime = 28500,
    },
    armspid = {
        buildtime = 7650,
    },
    armsptk = {
        buildtime = 13200,
    },
    armspy = {
        buildtime = 26400,
    },
    armstil = {
        buildtime = 48000,
    },
    armsubk = {
        buildtime = 33000,
    },
    armsy = {
        buildtime = 7320,
        energycost = 1500,
        workertime = 400,
    },
    armtarg = {
        buildtime = 13050,
    },
    armthor = {
        buildtime = 500000,
    },
    armtrident = {
        buildtime = 27000,
    },
    armuwadves = {
        buildtime = 30450,
    },
    armuwadvms = {
        buildtime = 30600,
    },
    armuwageo = {
        buildtime = 49950,
    },
    armuwfus = {
        buildtime = 149850,
    },
    armuwmme = {
        buildtime = 22350,
    },
    armuwmmm = {
        buildtime = 52500,
    },
    armvader = {
        buildtime = 11850,
    },
    armvang = {
        buildtime = 182000,
    },
    armveil = {
        buildtime = 13650,
    },
    armvp = {
        buildtime = 7600,
        featuredefs = {
            dead = {
                metal = 444,
            },
            heap = {
                metal = 177,
            },
        },
        metalcost = 680,
        workertime = 250,
    },
    armvulc = {
        buildtime = 2100000,
    },
    armwar = {
        buildtime = 5340,
        customparams = {
            paralyzemultiplier = 0.69999999,
            techlevel = 1.5,
        },
        energycost = 3720,
        featuredefs = {
            dead = {
                metal = 191,
            },
            heap = {
                metal = 76,
            },
        },
        health = 2000,
        idleautoheal = 10,
        metalcost = 320,
        speed = 60,
        weapondefs = {
            armwar_laser = {
                beamburst = "nil",
                beamtime = "nil",
                burst = 4,
                burstrate = 0.1,
                corethickness = "nil",
                cylindertargeting = 1,
                damage = {
                    default = 50,
                    vtol = 8,
                },
                explosiongenerator = "custom:plasmahit-small",
                impactonly = "nil",
                impulsefactor = 0.80000001,
                intensity = 0.66000003,
                laserflaresize = "nil",
                name = "Heavy EMG",
                range = 300,
                rgbcolor = "1 0.95 0.4",
                size = 2,
                soundhitwet = "splshbig",
                soundstart = "flashemg",
                sprayangle = 585.836304,
                thickness = "nil",
                tolerance = 5000,
                weapontype = "Cannon",
                weaponvelocity = 880,
            },
        },
    },
    armyork = {
        buildtime = 14925,
    },
    armzeus = {
        buildtime = 10875,
    },
    babylegshot = {
        buildtime = 11700,
    },
    coraak = {
        buildtime = 11400,
    },
    coraap = {
        buildtime = 36050,
        energycost = 30000,
        featuredefs = {
            dead = {
                metal = 1634,
            },
            heap = {
                metal = 817,
            },
        },
        metalcost = 2700,
        workertime = 1000,
    },
    coraca = {
        buildtime = 27000,
    },
    corack = {
        buildtime = 14550,
    },
    coracsub = {
        buildtime = 27000,
    },
    coracv = {
        buildtime = 19350,
    },
    corafus = {
        buildtime = 493800,
    },
    corageo = {
        buildtime = 48000,
        energycost = 31000,
        metalcost = 1600,
    },
    corak = {
        buildtime = 1140,
        energycost = 750,
        featuredefs = {
            dead = {
                metal = 20,
            },
            heap = {
                metal = 8,
            },
        },
        health = 250,
        metalcost = 40,
        weapondefs = {
            gator_laser = {
                range = 226,
            },
        },
    },
    coralab = {
        buildtime = 30200,
        energycost = 18000,
        featuredefs = {
            dead = {
                metal = 1442,
            },
            heap = {
                metal = 722,
            },
        },
        metalcost = 2400,
        workertime = 1500,
    },
    coramph = {
        buildtime = 14475,
    },
    coramsub = {
        workertime = 550,
    },
    corantiship = {
        buildtime = 30000,
    },
    corap = {
        buildtime = 7600,
        energycost = 1580,
        featuredefs = {
            dead = {
                metal = 463,
            },
            heap = {
                metal = 185,
            },
        },
        metalcost = 720,
        workertime = 250,
    },
    corape = {
        buildtime = 21750,
    },
    corarad = {
        buildtime = 12000,
    },
    corarch = {
        buildtime = 22500,
    },
    corason = {
        buildtime = 9150,
    },
    corasy = {
        buildtime = 28550,
        energycost = 12000,
        featuredefs = {
            dead = {
                metal = 1823,
            },
        },
        metalcost = 2600,
        workertime = 1500,
    },
    coratl = {
        buildtime = 16350,
    },
    coravp = {
        buildtime = 32750,
        energycost = 18000,
        featuredefs = {
            dead = {
                metal = 1414,
            },
            heap = {
                metal = 706,
            },
        },
        metalcost = 2300,
        workertime = 1500,
    },
    corawac = {
        buildtime = 19950,
    },
    corban = {
        buildtime = 34650,
    },
    corbats = {
        buildtime = 54000,
    },
    corbhmth = {
        buildtime = 89400,
    },
    corblackhy = {
        buildtime = 262950,
    },
    corbuzz = {
        buildtime = 2100000,
    },
    corcan = {
        buildtime = 17550,
    },
    corcarry = {
        buildtime = 30000,
    },
    corcat = {
        buildtime = 254000,
    },
    corcom = {
        airsightdistance = 675,
        cloakcost = 70,
        cloakcostmoving = 700,
    },
    corcrus = {
        buildtime = 25500,
    },
    corcrwh = {
        buildtime = 126300,
    },
    cordecom = {
        buildtime = 40500,
    },
    cordemon = {
        buildtime = 240000,
    },
    cordesolator = {
        buildtime = 210000,
    },
    cordoom = {
        buildtime = 82800,
    },
    cordronecarry = {
        buildtime = 30000,
    },
    corenaa = {
        buildtime = 34650,
    },
    corerad = {
        customparams = {
            paralyzemultiplier = 0.69999999,
            techlevel = 1.5,
        },
        weapondefs = {
            cor_erad = {
                damage = {
                    default = 55,
                },
            },
        },
        weapons = {
            {
                onlytargetcategory = "NOTSUB",
            },
        },
    },
    coreter = {
        buildtime = 9600,
    },
    corexp = {
        buildtime = 4350,
        customparams = {
            paralyzemultiplier = 0.69999999,
            techlevel = 1.5,
        },
        energycost = 2850,
        featuredefs = {
            dead = {
                metal = 183,
            },
            heap = {
                metal = 74,
            },
        },
        health = 1900,
        idleautoheal = 10,
        metalcost = 360,
        sightdistance = 682,
        weapondefs = {
            hllt_bottom = {
                damage = {
                    commanders = 125,
                    default = 84,
                    vtol = 6,
                },
                range = 485,
            },
        },
    },
    corfasp = {
        buildtime = 13950,
    },
    corfast = {
        buildtime = 9750,
    },
    corfatf = {
        buildtime = 15450,
    },
    corfdoom = {
        buildtime = 36000,
    },
    corfgate = {
        buildtime = 88500,
    },
    corflak = {
        buildtime = 30150,
    },
    corfmd = {
        buildtime = 90000,
    },
    corfort = {
        buildtime = 1350,
    },
    corfship = {
        buildtime = 14100,
    },
    corfus = {
        buildtime = 113100,
    },
    corgant = {
        buildtime = 203900,
        energycost = 103000,
        featuredefs = {
            dead = {
                metal = 8259,
            },
            heap = {
                metal = 3303,
            },
        },
        metalcost = 13600,
        workertime = 4500,
    },
    corgantuw = {
        buildtime = 203900,
        energycost = 103750,
        featuredefs = {
            dead = {
                metal = 8259,
            },
            heap = {
                metal = 3303,
            },
        },
        metalcost = 13520,
        workertime = 4500,
    },
    corgate = {
        buildtime = 82500,
    },
    corgol = {
        buildtime = 45000,
    },
    corhrk = {
        buildtime = 9900,
    },
    corhurc = {
        buildtime = 46500,
    },
    corint = {
        buildtime = 139950,
    },
    corintr = {
        buildtime = 21300,
    },
    corjugg = {
        buildtime = 1260000,
    },
    corkarg = {
        buildtime = 152000,
    },
    corkorg = {
        buildtime = 1110000,
    },
    corlab = {
        buildoptions = {
            [7] = "corroach",
        },
        buildtime = 7250,
        energycost = 1550,
        featuredefs = {
            dead = {
                metal = 428,
            },
            heap = {
                metal = 171,
            },
        },
        metalcost = 600,
        workertime = 250,
    },
    corlevlr = {
        speed = 45,
        weapondefs = {
            corlevlr_weapon = {
                range = 290,
            },
        },
    },
    cormabm = {
        buildtime = 63000,
    },
    cormando = {
        buildtime = 25650,
    },
    cormart = {
        buildtime = 9750,
    },
    cormexp = {
        buildtime = 50100,
        energycost = 14000,
        featuredefs = {
            dead = {
                metal = 1502,
            },
            heap = {
                metal = 601,
            },
        },
        metalcost = 2500,
    },
    cormist = {
        buildtime = 6880,
        customparams = {
            paralyzemultiplier = 0.69999999,
            techlevel = 1.5,
        },
        energycost = 4800,
        featuredefs = {
            dead = {
                metal = 206,
            },
            heap = {
                metal = 95,
            },
        },
        health = 1150,
        metalcost = 320,
        weapondefs = {
            cortruck_aa = {
                areaofeffect = 50,
                burst = 3,
                burstrate = 0.375,
                reloadtime = 5,
            },
            cortruck_missile = {
                areaofeffect = 50,
                burnblow = false,
                burst = 3,
                burstrate = 0.375,
                customparams = {
                    overrange_distance = 575,
                    place_target_on_ground = true,
                },
                dance = 6,
                flighttime = 1.19110394,
                model = "legsmallrocket.s3o",
                mygravity = 0,
                name = "Light Solid-Fuel Rocket",
                reloadtime = 5,
                startvelocity = 53,
                tracks = true,
                trajectoryheight = 0.25,
                turnrate = 8000,
                weaponacceleration = 717,
                weaponvelocity = 770,
                wobble = 600,
            },
        },
    },
    cormls = {
        buildtime = 7200,
    },
    cormmkr = {
        buildtime = 46950,
    },
    cormoho = {
        buildtime = 22500,
        energycost = 10100,
        featuredefs = {
            dead = {
                metal = 368,
            },
            heap = {
                metal = 158,
            },
        },
        metalcost = 740,
    },
    cormort = {
        buildtime = 7710,
    },
    cormship = {
        buildtime = 22500,
    },
    cornanotc = {
        buildtime = 6300,
        energycost = 3700,
        energystorage = 50,
        health = 625,
        metalcost = 260,
        metalstorage = 50,
    },
    cornanotcplat = {
        buildtime = 6300,
        energycost = 3100,
        energystorage = 50,
        health = 625,
        metalcost = 280,
        metalstorage = 50,
    },
    coronager = {
        buildtime = 30000,
    },
    corparrow = {
        buildtime = 28500,
    },
    corphantom = {
        buildtime = 13500,
    },
    corplat = {
        workertime = 700,
    },
    corprinter = {
        buildtime = 15300,
    },
    corpyro = {
        buildtime = 7545,
    },
    correap = {
        buildtime = 17250,
    },
    corrl = {
        weapondefs = {
            corrl_missile = {
                damage = {
                    default = 44,
                },
            },
        },
        weapons = {
            {
                onlytargetcategory = "NOTSUB",
            },
        },
    },
    corroach = {
        buildtime = 1950,
        customparams = {
            techlevel = "nil",
        },
        energycost = 900,
        explodeas = "mediumExplosionGenericSelfd",
        maxwaterdepth = 16,
        metalcost = 30,
        movementclass = "BOT1",
        radardistance = 630,
        radaremitheight = 18,
        selfdestructas = "fb_blastsml",
        speed = 100,
    },
    corroy = {
        customparams = {
            paralyzemultiplier = 0.69999999,
            techlevel = 1.5,
        },
    },
    corsala = {
        buildtime = 11850,
    },
    corsat = {
        buildtime = 19200,
    },
    corscreamer = {
        buildtime = 42000,
    },
    corsd = {
        buildtime = 18000,
    },
    corseah = {
        buildtime = 15000,
    },
    corseal = {
        buildtime = 18075,
    },
    corsent = {
        buildtime = 18000,
    },
    corsentinel = {
        buildtime = 30000,
    },
    corshark = {
        buildtime = 27000,
    },
    corshiva = {
        buildtime = 61200,
    },
    corshroud = {
        buildtime = 14100,
    },
    corsiegebreaker = {
        buildtime = 30000,
    },
    corsilo = {
        buildtime = 271500,
    },
    corsjam = {
        buildtime = 21750,
    },
    corsktl = {
        buildtime = 25500,
    },
    corsok = {
        buildtime = 54000,
    },
    corspec = {
        buildtime = 8160,
    },
    corspy = {
        buildtime = 33300,
    },
    corssub = {
        buildtime = 37125,
    },
    corstorm = {
        weapondefs = {
            cor_bot_rocket = {
                burnblow = false,
                customparams = {
                    overrange_distance = 475,
                    place_target_on_ground = true,
                },
                dance = 6,
                flighttime = 1.52029896,
                model = "legsmallrocket.s3o",
                mygravity = 0,
                name = "Light Solid-Fuel Rocket",
                startvelocity = 48.7000008,
                tracks = true,
                trajectoryheight = 0.25,
                turnrate = 8000,
                weaponacceleration = 369.299988,
                weaponvelocity = 418,
                wobble = 600,
            },
        },
    },
    corsumo = {
        buildtime = 76500,
    },
    corsy = {
        buildtime = 7300,
        energycost = 1500,
        workertime = 400,
    },
    cortarg = {
        buildtime = 16350,
    },
    cortermite = {
        buildtime = 22500,
    },
    corthud = {
        buildtime = 4200,
        customparams = {
            paralyzemultiplier = 0.69999999,
            techlevel = 1.5,
        },
        energycost = 2300,
        featuredefs = {
            dead = {
                metal = 192,
            },
            heap = {
                metal = 76,
            },
        },
        health = 2200,
        metalcost = 280,
        speed = 52,
        turnrate = 1327.04236,
        weapondefs = {
            arm_ham = {
                areaofeffect = 42,
                burst = 2,
                burstrate = 0.25,
                reloadtime = 2.59999514,
            },
        },
    },
    cortitan = {
        buildtime = 22050,
    },
    cortoast = {
        buildtime = 38550,
    },
    cortrem = {
        buildtime = 46650,
    },
    cortron = {
        buildtime = 88500,
    },
    coruwadves = {
        buildtime = 30600,
    },
    coruwadvms = {
        buildtime = 30750,
    },
    coruwageo = {
        buildtime = 48000,
    },
    coruwfus = {
        buildtime = 157500,
    },
    coruwmme = {
        buildtime = 21150,
    },
    coruwmmm = {
        buildtime = 46950,
    },
    corvac = {
        buildtime = 15000,
    },
    corvacct = {
        buildtime = 15,
    },
    corvamp = {
        buildtime = 12600,
    },
    corvipe = {
        buildtime = 22500,
    },
    corvoyr = {
        buildtime = 5925,
    },
    corvp = {
        buildtime = 7580,
        featuredefs = {
            dead = {
                metal = 431,
            },
            heap = {
                metal = 172,
            },
        },
        metalcost = 660,
        workertime = 250,
    },
    corvrad = {
        buildtime = 6330,
    },
    corvroc = {
        buildtime = 22500,
    },
    freefusion = {
        buildtime = 1200,
    },
    leegmech = {
        buildtime = 400000,
    },
    legaap = {
        buildtime = 36050,
        energycost = 30000,
        featuredefs = {
            dead = {
                metal = 1634,
            },
            heap = {
                metal = 817,
            },
        },
        metalcost = 2700,
        workertime = 1000,
    },
    legabm = {
        buildtime = 90000,
    },
    legaca = {
        buildtime = 26250,
    },
    legaceb = {
        buildtime = 14250,
    },
    legack = {
        buildtime = 13950,
    },
    legacv = {
        buildtime = 17850,
    },
    legadvaabot = {
        buildtime = 11850,
    },
    legadveconv = {
        buildtime = 46950,
    },
    legadvestore = {
        buildtime = 30600,
    },
    legafcv = {
        buildtime = 6000,
    },
    legafigdef = {
        buildtime = 15000,
    },
    legafus = {
        buildtime = 510000,
    },
    legageo = {
        buildtime = 49950,
        energycost = 31000,
        metalcost = 1700,
    },
    legaheattank = {
        buildtime = 28500,
    },
    legajam = {
        buildtime = 13650,
    },
    legalab = {
        buildtime = 30200,
        energycost = 18000,
        featuredefs = {
            dead = {
                metal = 1442,
            },
            heap = {
                metal = 722,
            },
        },
        metalcost = 2400,
        workertime = 1500,
    },
    legamcluster = {
        buildtime = 12000,
    },
    legamph = {
        buildtime = 28500,
    },
    legamphlab = {
        workertime = 550,
    },
    legamstor = {
        buildtime = 30750,
    },
    legap = {
        buildtime = 7600,
        energycost = 1580,
        featuredefs = {
            dead = {
                metal = 523,
            },
            heap = {
                metal = 209,
            },
        },
        metalcost = 620,
        workertime = 250,
    },
    legapopupdef = {
        buildtime = 26250,
    },
    legarad = {
        buildtime = 12000,
    },
    legaskirmtank = {
        buildtime = 12000,
    },
    legatorpbomber = {
        buildtime = 27360,
    },
    legavjam = {
        buildtime = 8895,
    },
    legavp = {
        buildtime = 32750,
        energycost = 18000,
        featuredefs = {
            dead = {
                metal = 1414,
            },
            heap = {
                metal = 706,
            },
        },
        metalcost = 2300,
        workertime = 1500,
    },
    legavrad = {
        buildtime = 9300,
    },
    legavroc = {
        buildtime = 23250,
    },
    legbart = {
        buildtime = 15000,
    },
    legbastion = {
        buildtime = 118500,
    },
    legbombard = {
        buildtime = 26250,
    },
    legbunk = {
        buildtime = 70520,
    },
    legcom = {
        airsightdistance = 675,
        cloakcost = 70,
        cloakcostmoving = 700,
    },
    legdecom = {
        buildtime = 40500,
    },
    legdeflector = {
        buildtime = 82500,
    },
    legeheatraymech = {
        buildtime = 880000,
    },
    legelrpcmech = {
        buildtime = 250000,
    },
    legerailtank = {
        buildtime = 280000,
    },
    legeshotgunmech = {
        buildtime = 240000,
    },
    legflak = {
        buildtime = 28500,
    },
    legfloat = {
        buildtime = 24000,
    },
    legfort = {
        buildtime = 135000,
    },
    legfus = {
        buildtime = 120000,
    },
    leggant = {
        buildtime = 203900,
        energycost = 103000,
        featuredefs = {
            dead = {
                metal = 8259,
            },
            heap = {
                metal = 3303,
            },
        },
        metalcost = 13600,
        workertime = 4500,
    },
    leggatet3 = {
        buildtime = 522000,
    },
    leghrk = {
        buildtime = 13500,
    },
    leginc = {
        buildtime = 82500,
    },
    leginf = {
        buildtime = 49500,
    },
    leginfestor = {
        buildtime = 6750,
    },
    legionnaire = {
        buildtime = 15000,
    },
    legjav = {
        buildtime = 64000,
    },
    legkeres = {
        buildtime = 120000,
    },
    leglab = {
        buildtime = 7250,
        energycost = 1550,
        featuredefs = {
            dead = {
                metal = 428,
            },
            heap = {
                metal = 171,
            },
        },
        metalcost = 600,
        workertime = 250,
    },
    leglraa = {
        buildtime = 42000,
    },
    leglrpc = {
        buildtime = 127500,
    },
    legmed = {
        buildtime = 33750,
    },
    legmoho = {
        buildtime = 23850,
        energycost = 12100,
        featuredefs = {
            dead = {
                metal = 418,
            },
            heap = {
                metal = 179,
            },
        },
        metalcost = 840,
    },
    legmohobp = {
        buildtime = 22500,
        energycost = 10100,
        featuredefs = {
            dead = {
                metal = 368,
            },
            heap = {
                metal = 158,
            },
        },
        metalcost = 740,
    },
    legmohocon = {
        buildtime = 30450,
        energycost = 16500,
        featuredefs = {
            dead = {
                metal = 348,
            },
            heap = {
                metal = 150,
            },
        },
        metalcost = 1160,
    },
    legmohoconct = {
        buildtime = 29100,
    },
    legmohoconin = {
        buildtime = 29100,
    },
    legmrv = {
        buildtime = 6750,
    },
    legnanotc = {
        buildtime = 6300,
        energycost = 3700,
        energystorage = 50,
        metalcost = 260,
        metalstorage = 50,
    },
    legnanotcplat = {
        buildtime = 6300,
        energycost = 3100,
        energystorage = 50,
        metalcost = 280,
        metalstorage = 50,
    },
    legnap = {
        buildtime = 54000,
    },
    legoptio = {
        buildtime = 15000,
    },
    legperdition = {
        buildtime = 93000,
    },
    legphoenix = {
        buildtime = 60000,
    },
    legrampart = {
        buildtime = 54000,
    },
    legrhapsis = {
        weapondefs = {
            burst_aa_missile = {
                damage = {
                    default = 6,
                },
            },
        },
        weapons = {
            {
                onlytargetcategory = "NOTSUB",
            },
        },
    },
    legrl = {
        weapondefs = {
            legrl_missile = {
                damage = {
                    default = 44,
                },
            },
        },
        weapons = {
            {
                onlytargetcategory = "NOTSUB",
            },
        },
    },
    legsd = {
        buildtime = 17850,
    },
    legshot = {
        buildtime = 11700,
    },
    legsilo = {
        buildtime = 271500,
    },
    legsnapper = {
        buildtime = 12000,
    },
    legsrail = {
        buildtime = 27000,
    },
    legstarfall = {
        buildtime = 2100000,
    },
    legstr = {
        buildtime = 10800,
    },
    legstronghold = {
        buildtime = 30000,
    },
    legtarg = {
        buildtime = 13050,
    },
    legvenator = {
        buildtime = 12600,
    },
    legvflak = {
        buildtime = 18000,
    },
    legvp = {
        buildtime = 7600,
        featuredefs = {
            dead = {
                metal = 431,
            },
            heap = {
                metal = 172,
            },
        },
        metalcost = 660,
        workertime = 250,
    },
    legwhisper = {
        buildtime = 21000,
    },
    mission_command_tower = {
        buildtime = 150000,
    },
    resourcecheat = {
        buildtime = 468750,
    },
}
```

## Tweakdefs encoded (URL-safe base64)

> bG9jYWwgYSxiLGMsZDtsb2NhbCBlPXsyLDQsNSw4LDEyLDIwLDUwLDEyNSwyNTB9bG9jYWwgZixnPTIwLDMwO2xvY2FsIGZ1bmN0aW9uIGgoaSwuLi4pZm9yIGosayBpbiBpcGFpcnMoey4uLn0pZG8gaVtrXT1kW2tdZW5kIGVuZDtsb2NhbCBmdW5jdGlvbiBsKG0sbilpZiBuIHRoZW4gbT1tL24gZWxzZSBuPTEgZW5kO2lmIG08PTMwIHRoZW4gcmV0dXJuIG1hdGguZmxvb3IobSswLjUpKm4gZW5kO2xvY2FsIG89e31mb3IgaixwIGluIGlwYWlycyhlKWRvIG9bcF09bWF0aC5mbG9vcihtL3ArMC41KSpwIGVuZDtsb2NhbCBxPW9bZVsxXV1sb2NhbCByPXEtbTtyPXIqci9lWzFdZm9yIHM9MiwjZSBkbyBsb2NhbCB0PWVbc11sb2NhbCB1PW9bdF0tbTt1PXUqdS9lW3NdaWYgcj51IHRoZW4gcT1vW3Rdcj11IGVuZCBlbmQ7cmV0dXJuIHEqbiBlbmQ7bG9jYWwgZnVuY3Rpb24gdih3LHgseSx6KWlmIG5vdCB4IHRoZW4geD0wIGVuZDtpZiBub3QgeSB0aGVuIHk9eCooYS5tZXRhbGNvc3QgYW5kIGEubWV0YWxjb3N0PjAgYW5kIGEuZW5lcmd5Y29zdC9hLm1ldGFsY29zdCBvciBmKWVuZDtpZiBub3QgeiB0aGVuIHo9eCooYS5tZXRhbGNvc3QgYW5kIGEubWV0YWxjb3N0PjAgYW5kIGEuYnVpbGR0aW1lL2EubWV0YWxjb3N0IG9yIGcpZW5kO2xvY2FsIEE9bChhLm1ldGFsY29zdCp3K3gsMTApbG9jYWwgQj1BL2EubWV0YWxjb3N0O2EubWV0YWxjb3N0PUE7YS5lbmVyZ3ljb3N0PWwoYS5lbmVyZ3ljb3N0KncreSwxMClhLmJ1aWxkdGltZT1sKGEuYnVpbGR0aW1lKncreiwxMClmb3IgQyxpIGluIHBhaXJzKGEuZmVhdHVyZWRlZnMgb3J7fSlkbyBpLm1ldGFsPW1hdGguZmxvb3IoQippLm1ldGFsKzAuNSllbmQgZW5kO2xvY2FsIGZ1bmN0aW9uIEQodyxFKWlmIG5vdCBFIHRoZW4gRT0wIGVuZDtmb3IgRixtIGluIHBhaXJzKGIuZGFtYWdlKWRvIGIuZGFtYWdlW0ZdPWwobSp3K0UpZW5kIGVuZDtsb2NhbCBmdW5jdGlvbiBHKEMpYT1Vbml0RGVmc1tDXXJldHVybiBhIGVuZDtsb2NhbCBmdW5jdGlvbiBIKEMpYj1hLndlYXBvbmRlZnNbQ11yZXR1cm4gYiBlbmQ7bG9jYWwgZnVuY3Rpb24gSShpKWM9aS5jdXN0b21wYXJhbXMgb3J7fWkuY3VzdG9tcGFyYW1zPWM7cmV0dXJuIGMgZW5kO2ZvciBqLEMgaW4gaXBhaXJzeyJhcm1jb20iLCJjb3Jjb20iLCJsZWdjb20ifWRvIEcoQylhLmFpcnNpZ2h0ZGlzdGFuY2U9bChhLnNpZ2h0ZGlzdGFuY2UqMS41KWEuY2xvYWtjb3N0PWwoYS5jbG9ha2Nvc3QqMC43KWEuY2xvYWtjb3N0bW92aW5nPWwoYS5jbG9ha2Nvc3Rtb3ZpbmcqMC43KWVuZDtsb2NhbCBKPXsiYXJtd2FyIiwiYXJtamFudXMiLCJhcm1yb3kiLCJhcm1jaXIiLCJhcm1hbWV4IiwiY29ydGh1ZCIsImNvcm1pc3QiLCJjb3Jyb3kiLCJjb3JlcmFkIiwiY29yZXhwIn1mb3IgQyxpIGluIHBhaXJzKFVuaXREZWZzKWRvIGlmIEkoaSkudGVjaGxldmVsPT0xLjUgdGhlbiBKWyNKKzFdPUMgZW5kIGVuZDtmb3IgaixDIGluIGlwYWlycyhKKWRvIEkoRyhDKSkudGVjaGxldmVsPTEuNTtjLnBhcmFseXplbXVsdGlwbGllcj0wLjcgZW5kO0koRygiY29ycm9hY2giKSkudGVjaGxldmVsPTE7Zm9yIEMsaSBpbiBpcGFpcnMoVW5pdERlZnMpZG8gaWYoSShpKS50ZWNobGV2ZWwgb3IgMSk8MS41IHRoZW4gaWYgaS5leHRyYWN0c21ldGFsIGFuZCBpLmV4dHJhY3RzbWV0YWw-MCB0aGVuIGkuaGVhbHRoPWwoRyhDKS5oZWFsdGgqMiwyNSllbHNlaWYgaS53aW5kZ2VuZXJhdG9yIGFuZCBpLndpbmRnZW5lcmF0b3I-MCB0aGVuIGkuaGVhbHRoPWwoRyhDKS5oZWFsdGgqMS4xLDI1KWVsc2VpZiBjLnNvbGFyIGFuZChpLmVuZXJneXVwa2VlcCBhbmQgaS5lbmVyZ3l1cGtlZXA8LTUwKW9yIGkuZW5lcmd5bWFrZSBhbmQgaS5lbmVyZ3ltYWtlPjUwIHRoZW4gaS5oZWFsdGg9bChHKEMpLmhlYWx0aCoxLjEyNSwyNSlpLmVuZXJneXN0b3JhZ2U9bCgoaS5lbmVyZ3lzdG9yYWdlIG9yIDApKjEuMTI1KWVsc2VpZiBuZXh0KGkuYnVpbGRvcHRpb25zKWFuZCBzdHJpbmcuZmluZChpLm1vdmVtZW50Y2xhc3Mgb3IiIiwiQk9UIil0aGVuIGkuaGVhbHRoPWwoRyhDKS5oZWFsdGgqMS4xMiwyNSllbmQgZW5kIGVuZDtHKCJhcm1wdyIpdigxLDAsMCwxMzIpYS5zcGVlZD1sKGEuc3BlZWQqMS4wOClHKCJhcm1mbGFzaCIpYS5zcGVlZD1sKGEuc3BlZWQqMS4wOClHKCJhcm1rYW0iKUgoImVtZyIpYi5zcHJheWFuZ2xlPWwoYi5zcHJheWFuZ2xlKjAuNiliLndlYXBvbnZlbG9jaXR5PWwoYi53ZWFwb252ZWxvY2l0eSoxLjEpYi5maXJldG9sZXJhbmNlPTM2MDA7RygiY29ybGV2bHIiKWEuc3BlZWQ9bChhLnNwZWVkKjEuMSlIKCJjb3JsZXZscl93ZWFwb24iKWIucmFuZ2U9bChiLnJhbmdlKjAuOTIpZm9yIEMsSyBpbiBwYWlyc3thcm1ybD0iYXJtcmxfbWlzc2lsZSIsYXJtY2lyPSJhcm1fY2lyIixjb3JybD0iY29ycmxfbWlzc2lsZSIsY29yZXJhZD0iY29yX2VyYWQiLGxlZ3JsPSJsZWdybF9taXNzaWxlIixsZWdyaGFwc2lzPSJidXJzdF9hYV9taXNzaWxlIn1kbyBHKEMpYS53ZWFwb25zWzFdLmZhc3RhdXRvcmV0YXJnZXRpbmc9dHJ1ZTthLndlYXBvbnNbMV0ub25seXRhcmdldGNhdGVnb3J5PSJOT1RTVUIiSChLKWxvY2FsIEw9KGIuYnVyc3Qgb3IgMSkqKGIucHJvamVjdGlsZXMgb3IgMSliLmRhbWFnZS5kZWZhdWx0PWwoKDIwKzAuMipiLmRhbWFnZS52dG9sKkwpL0wpZW5kO2ZvciBqLEMgaW4gaXBhaXJzeyJhcm1tb2hvIiwiY29ybW9obyIsImNvcm1leHAiLCJsZWdtb2hvIiwibGVnbW9obyIsImxlZ21vaG9icCIsImxlZ21vaG9jb24ifWRvIEcoQyl2KDEsMTAwLDIwMDAsOTAwKWVuZDtmb3IgQyxpIGluIHBhaXJzKFVuaXREZWZzKWRvIGlmIEkoaSkudGVjaGxldmVsPT0yIHRoZW4gaS5idWlsZHRpbWU9bChHKEMpLmJ1aWxkdGltZSoxLjUpZWxzZWlmIGMudGVjaGxldmVsPT0zIHRoZW4gaS5idWlsZHRpbWU9bChHKEMpLmJ1aWxkdGltZSoyKWVuZCBlbmQ7Zm9yIGosQyBpbiBpcGFpcnN7ImFybWFnZW8iLCJjb3JhZ2VvIiwibGVnYWdlbyJ9ZG8gRyhDKXYoMSwxMDAsNDAwMCwwKWVuZDtmb3IgaixNIGluIGlwYWlyc3siYXJtIiwiY29yIiwibGVnIn1kbyBmb3IgaixOIGluIGlwYWlyc3sibGFiIiwidnAiLCJhcCIsInN5In1kbyBpZiBHKE0uLk4pdGhlbiB2KDAuNSwzMDAsOTAwLDQwMDApYS53b3JrZXJ0aW1lPWwoYS53b3JrZXJ0aW1lKjIuNSw1MCllbmQgZW5kO2ZvciBqLE4gaW4gaXBhaXJzeyJwbGF0IiwiYW1zdWIiLCJhbXBobGFiIn1kbyBpZiBHKE0uLk4pdGhlbiBhLndvcmtlcnRpbWU9bChhLndvcmtlcnRpbWUqMysxMDAsNTApZW5kIGVuZDtmb3IgaixOIGluIGlwYWlyc3siYWxhYiIsImF2cCIsImFhcCIsImFzeSJ9ZG8gaWYgRyhNLi5OKXRoZW4gdigxLC01MDAsMjAwMCw1MDAwKWEud29ya2VydGltZT1sKGEud29ya2VydGltZSo1KWVuZCBlbmQ7Zm9yIGosTiBpbiBpcGFpcnN7ImdhbnQiLCJnYW50dXciLCJzaGx0eCIsInNobHR4dXcifWRvIGlmIEcoTS4uTil0aGVuIHYoMS41LDEwMDAsMTAwMDAsMjAwMClhLndvcmtlcnRpbWU9bChhLndvcmtlcnRpbWUqNy41LDUwMCllbmQgZW5kO2ZvciBqLE8gaW4gaXBhaXJzeyJuYW5vdGMiLCJuYW5vdGNwbGF0In1kbyBpZiBHKE0uLk8pdGhlbiB2KDEsNTAsNTAwLDEwMDApYS5tZXRhbHN0b3JhZ2U9NTA7YS5lbmVyZ3lzdG9yYWdlPTUwO2lmIE09PSJjb3IidGhlbiBhLmhlYWx0aD1sKGEuaGVhbHRoKjEuMTI1LDI1KWVuZCBlbmQgZW5kIGVuZDtHKCJhcm13YXIiKXYoMS4yLDAsMCwzMDApYS5oZWFsdGg9bChhLmhlYWx0aCoxLjI1LDI1KWEuaWRsZWF1dG9oZWFsPTEwO2Euc3BlZWQ9bChhLnNwZWVkKjEuMzMzMylIKCJhcm13YXJfbGFzZXIiKWIucmFuZ2U9bChiLnJhbmdlLTMwKUQoMS4yNSlHKCJhcm1qYW51cyIpdigxLjMzMzMpYS5oZWFsdGg9bChhLmhlYWx0aCoxLjE2NjcsMjUpYS5zcGVlZD1sKGEuc3BlZWQqMS4xMjUpSCgiamFudXNfcm9ja2V0IiliLnJlbG9hZHRpbWU9Yi5yZWxvYWR0aW1lKjAuOTI1O0coImFybWFtZXgiKXYoMS4xMjUpYS5oZWFsdGg9bChhLmhlYWx0aCoxLjI1LDI1KWEuZXhwbG9kZWFzPSJtZWRpdW1CdWlsZGluZ0V4cGxvc2lvbkdlbmVyaWMiYS5lbmVyZ3ltYWtlPWEuY2xvYWtjb3N0O2EucmFkYXJkaXN0YW5jZT0xMDAwO2EucmFkYXJlbWl0aGVpZ2h0PTI0O2Euc2lnaHRkaXN0YW5jZT0yMDA7RygiY29ydGh1ZCIpdigyKWEuaGVhbHRoPWwoYS5oZWFsdGgqMiwyNSlhLnNwZWVkPWwoYS5zcGVlZCoxLjE2NjcpYS50dXJucmF0ZT1hLnR1cm5yYXRlKjEuMDU7SCgiYXJtX2hhbSIpYi5hcmVhb2ZlZmZlY3Q9bChiLmFyZWFvZmVmZmVjdCoxLjE2NjcpYi5idXJzdD0yO2IuYnVyc3RyYXRlPTAuMjU7Yi5yZWxvYWR0aW1lPWIucmVsb2FkdGltZSoxLjU7RygiY29ybWlzdCIpdigyKWEuaGVhbHRoPWwoYS5oZWFsdGgqMS4zMzMzLDI1KWZvciBqLEsgaW4gaXBhaXJzeyJjb3J0cnVja19hYSIsImNvcnRydWNrX21pc3NpbGUifWRvIEgoSyliLmFyZWFvZmVmZmVjdD1Vbml0RGVmcy5jb3JzdG9ybS53ZWFwb25kZWZzLmNvcl9ib3Rfcm9ja2V0LmFyZWFvZmVmZmVjdCsyO2IuYnVyc3Q9MztiLmJ1cnN0cmF0ZT0wLjM3NTtiLnJlbG9hZHRpbWU9Yi5yZWxvYWR0aW1lKjIgZW5kO0coImNvcmV4cCIpdigxLjUpYS5oZWFsdGg9bChhLmhlYWx0aCoxLjMzMzMsMjUpYS5pZGxlYXV0b2hlYWw9MTA7YS5zaWdodGRpc3RhbmNlPWwoYS5zaWdodGRpc3RhbmNlKjEuNSliPWEud2VhcG9uZGVmcy5obGx0X2JvdHRvbTtiLnJhbmdlPWwoYi5yYW5nZSs1MClEKDEuMTI1KUcoImNvcmFrIil2KDAuODg4OClhLmhlYWx0aD1sKGEuaGVhbHRoKjAuODg4OCwyNSliPWEud2VhcG9uZGVmcy5nYXRvcl9sYXNlcjtiLnJhbmdlPWwoYi5yYW5nZSoxLjA1KUcoImNvcnJvYWNoIil2KDAuNSwwLC0yMDAwLC0yMDAwKWEubWF4d2F0ZXJkZXB0aD0xNjthLm1vdmVtZW50Y2xhc3M9IkJPVDEiYS5yYWRhcmRpc3RhbmNlPVVuaXREZWZzLmFybWZsZWEuc2lnaHRkaXN0YW5jZSszMDthLnJhZGFyZW1pdGhlaWdodD0xODthLnNwZWVkPWwoYS5zcGVlZCoxLjMzMzMpYS5leHBsb2RlYXM9Im1lZGl1bUV4cGxvc2lvbkdlbmVyaWNTZWxmZCJhLnNlbGZkZXN0cnVjdGFzPSJmYl9ibGFzdHNtbCJhLmN1c3RvbXBhcmFtcy50ZWNobGV2ZWw9bmlsO2ZvciBDLGkgaW4gaXBhaXJzKFVuaXREZWZzKWRvIGlmIGkuYnVpbGRlciBhbmQgdHlwZShpLmJ1aWxkb3B0aW9ucyk9PSJ0YWJsZSJ0aGVuIGZvciBzLFAgaW4gcGFpcnMoaS5idWlsZG9wdGlvbnMpZG8gaWYgUD09ImNvcnJvYWNoInRoZW4gRyhDKXRhYmxlLnJlbW92ZShpLmJ1aWxkb3B0aW9ucyxzKWVuZCBlbmQgZW5kIGVuZDtHKCJjb3JsYWIiKWEuYnVpbGRvcHRpb25zWyNhLmJ1aWxkb3B0aW9ucysxXT0iY29ycm9hY2giZD1Vbml0RGVmcy5hcm1rYW0ud2VhcG9uZGVmcy5lbWc7Zm9yIEMsSyBpbiBwYWlyc3thcm13YXI9ImFybXdhcl9sYXNlciIsYXJtaGx0PSJhcm1fbGFzZXJoMSJ9ZG8gRyhDKUgoSykubmFtZT0iSGVhdnkgRU1HImgoYiwid2VhcG9udHlwZSIsImNvcmV0aGlja25lc3MiLCJleHBsb3Npb25nZW5lcmF0b3IiLCJpbnRlbnNpdHkiLCJsYXNlcmZsYXJlc2l6ZSIsInJnYmNvbG9yIiwidGhpY2tuZXNzIiwic2l6ZSIsInNvdW5kaGl0d2V0Iiwic291bmRzdGFydCIsImJ1cnN0cmF0ZSIsImJlYW1idXJzdCIsImJlYW10aW1lIiwiY3lsaW5kZXJ0YXJnZXRpbmciLCJlbmVyZ3lwZXJzaG90IiwiaW1wYWN0b25seSIsInRvbGVyYW5jZSIsInByZWRpY3Rib29zdCIsIndlYXBvbnZlbG9jaXR5IiliLmltcHVsc2VmYWN0b3I9MC44O0QoKGIuYnVyc3Qgb3IgMSkvKGQuYnVyc3QrMSkpYi5idXJzdD1kLmJ1cnN0KzE7bG9jYWwgQj1kLnJlbG9hZHRpbWUvYi5yZWxvYWR0aW1lKmQucmFuZ2UvYi5yYW5nZTtiLnNwcmF5YW5nbGU9ZC5zcHJheWFuZ2xlKm1hdGguc3FydChCKWVuZDtkPVVuaXREZWZzLmFybW1hdi53ZWFwb25kZWZzLmFybW1hdl93ZWFwb247Zm9yIEMsSyBpbiBwYWlyc3thcm1oYW09ImFybV9oYW0ifWRvIEcoQyl2KDEuMSlIKEspLm5hbWU9IkdhdXNzIFBsYXNtYSBDYW5ub24iaChiLCdpbXB1bHNlZmFjdG9yJywnd2VhcG9udmVsb2NpdHknKWIucmVsb2FkdGltZT1sKGIucmVsb2FkdGltZSoxLjc1LDAuMDEpRCgxLjc1KWVuZDtmb3IgQyxLIGluIHBhaXJze2Nvcm1pc3Q9ImNvcnRydWNrX21pc3NpbGUiLGNvcnN0b3JtPSJjb3JfYm90X3JvY2tldCJ9ZG8gRyhDKUgoSykubmFtZT0iTGlnaHQgU29saWQtRnVlbCBSb2NrZXQiYi5tb2RlbD0ibGVnc21hbGxyb2NrZXQuczNvImIuYnVybmJsb3c9ZmFsc2U7Yi5teWdyYXZpdHk9MDtiLnRyYWNrcz10cnVlO2IudHJhamVjdG9yeWhlaWdodD0wLjI1O2IudHVybnJhdGU9ODAwMDtiLnN0YXJ0dmVsb2NpdHk9YS5zcGVlZCsxO2Iud2VhcG9udmVsb2NpdHk9bChiLndlYXBvbnZlbG9jaXR5KjIuMiliLndlYXBvbmFjY2VsZXJhdGlvbj1iLndlYXBvbnZlbG9jaXR5LWIuc3RhcnR2ZWxvY2l0eTtsb2NhbCBRPShiLndlYXBvbnZlbG9jaXR5LWIuc3RhcnR2ZWxvY2l0eSkvYi53ZWFwb25hY2NlbGVyYXRpb247bG9jYWwgUj1tYXRoLm1pbihiLnJhbmdlLFEqKGIuc3RhcnR2ZWxvY2l0eStiLndlYXBvbnZlbG9jaXR5KSowLjUpYi5mbGlnaHR0aW1lPVErKGIucmFuZ2UtUikqMC45L2Iud2VhcG9udmVsb2NpdHk7Yi5kYW5jZT02O2Iud29iYmxlPTYwMDtJKGIpLm92ZXJyYW5nZV9kaXN0YW5jZT1iLnJhbmdlO2MucGxhY2VfdGFyZ2V0X29uX2dyb3VuZD10cnVlO2MucHJvamVjdGlsZV9kZXN0cnVjdGlvbl9tZXRob2Q9ImRlc2NlbmQiZW5k

