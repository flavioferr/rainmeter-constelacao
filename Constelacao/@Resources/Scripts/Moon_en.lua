-- Fase da lua calculada pela data (lua nova de referencia: 06/01/2000 18:14 UTC; ciclo de 29,530588 dias).
-- Define as variaveis usadas no desenho (MoonX, MoonW, MoonK, MoonOp) e os textos.

local SYNODIC = 29.530588853
local REF = 947182440 -- 2000-01-06 18:14:00 UTC em segundos Unix

function Initialize()
	last = -1
end

local function name(age)
	if age < 1.0 or age > SYNODIC - 1.0 then return 'New moon' end
	if age < 6.4 then return 'Waxing crescent' end
	if age < 8.4 then return 'First quarter' end
	if age < 13.8 then return 'Waxing gibbous' end
	if age < 15.8 then return 'Full moon' end
	if age < 21.1 then return 'Waning gibbous' end
	if age < 23.1 then return 'Last quarter' end
	return 'Waning crescent'
end

function Update()
	local now = os.time(os.date('!*t'))
	local age = ((now - REF) / 86400) % SYNODIC
	local key = math.floor(age * 24)
	if key == last then return 0 end
	last = key
	local p = age / SYNODIC
	local k = math.cos(2 * math.pi * p)
	local illum = (1 - k) / 2
	local waxing = p < 0.5
	-- meio disco iluminado: direita na crescente, esquerda na minguante
	SKIN:Bang('!SetVariable', 'MoonSide', waxing and 0 or 1)
	-- elipse do terminador: largura |k|; some (exclude) na fase fina, soma (union) na gibosa
	SKIN:Bang('!SetVariable', 'MoonK', string.format('%.4f', math.abs(k)))
	SKIN:Bang('!SetVariable', 'MoonOp', k > 0 and 'Exclude' or 'Union')
	SKIN:Bang('!SetVariable', 'MoonName', name(age))
	SKIN:Bang('!SetVariable', 'MoonIllum', string.format('%d', math.floor(illum * 100 + 0.5)))
	local toFull = (SYNODIC / 2 - age) % SYNODIC
	local toNew = (SYNODIC - age) % SYNODIC
	SKIN:Bang('!SetVariable', 'MoonNext', toFull < toNew
		and string.format('full in %d days', math.floor(toFull + 0.5))
		or string.format('new in %d days', math.floor(toNew + 0.5)))
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
	return 0
end
