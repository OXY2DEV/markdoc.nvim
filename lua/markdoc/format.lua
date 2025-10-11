---@class markdoc.format.parsed
---
---@field kind "tag" | "code_span" | "option_link" | "tag_link" | "argument" | "keycode" | "url" | "word" | "space" Parsed string type.
---@field value string Parsed string

------------------------------------------------------------------------------

local format = {};

local config = require("markdoc.config");
local lpeg = vim.lpeg;

--- Parses given string into parts.
---@param input string
---@return markdoc.format.parsed[]
format.parse = function (input)
	---|fS "feat: LPeg grammar for inline Vimdoc"

	local function as_tag   (m) return { kind = "tag", value = m }; end
	local function as_code  (m) return { kind = "code_span", value = m }; end
	local function as_opt   (m) return { kind = "option_link", value = m }; end
	local function as_tlink (m) return { kind = "tag_link", value = m }; end
	local function as_arg   (m) return { kind = "argument", value = m }; end
	local function as_key   (m) return { kind = "keycode", value = m }; end
	local function as_url   (m) return { kind = "url", value = m }; end
	local function as_word  (m) return { kind = "word", value = m }; end
	local function as_space (m) return { kind = "space", value = m }; end

	-- Tag: `*...*`
	local tag = lpeg.C( lpeg.P("*") * (lpeg.P(1) - lpeg.S("* "))^1 * lpeg.P("*")) / as_tag;
	-- Code_span: `...`
	local code_span = lpeg.C( lpeg.P("`") * (lpeg.P(1) - lpeg.S("`"))^1 * lpeg.P("`") ) / as_code;
	-- Option_link: `'...'`
	local option_link = lpeg.C( lpeg.P("'") * ( lpeg.S("az")^2 ) * lpeg.P("'") ) / as_opt;
	-- Code_span: `|...|`
	local tag_link = lpeg.C( lpeg.P("|") * (lpeg.P(1) - lpeg.S("|"))^1 * lpeg.P("|") ) / as_tlink;
	-- Argument: `{...}`
	local argument = lpeg.C( lpeg.P("{") * (lpeg.P(1) - lpeg.S("}"))^1 * lpeg.P("}") ) / as_arg;

	local keycode_i = lpeg.S("-_") + lpeg.R("az", "AZ", "09");
	-- Marked_keycode: `<...>`
	local keycode_m = lpeg.P("<") * ( keycode_i^1 ) * lpeg.P(">");
	-- Keyword_keycode: `<CTRL-.>`
	local keycode_k = lpeg.P("CTRL-") * ( lpeg.P("Break") + lpeg.P("PageUp") + lpeg.P("PageDown") + lpeg.P("Insert") + lpeg.P("Del") + lpeg.P("{char}") );
	-- Unmarked_keycode: `<C-.>`
	local keycode_u = ( lpeg.P("S") + lpeg.P("C") + lpeg.P("M") + lpeg.P("D") + lpeg.P("CTRL-SHIFT") + lpeg.P("CTRL") + lpeg.P("META") + lpeg.P("SHIFT") ) *  lpeg.P("-") * lpeg.P(1);

	-- Keyword: `<CTRL-...>`
	local keycode = lpeg.C( keycode_m + keycode_k + keycode_u ) / as_key;

	-- URL: `https:..`, `http:..`
	local url = lpeg.C( lpeg.P("http") * ( lpeg.P("s")^-1 ) * ( lpeg.P(1) - lpeg.S(" \t") )^1 ) / as_url;

	-- Word: ...
	local word = lpeg.C( ( lpeg.P(1) - lpeg.S(" \t") )^1 ) / as_word;
	-- Space: ...
	local space = lpeg.C( lpeg.S(" \t")^1 ) / as_space;

	local part = tag + code_span + option_link + tag_link + argument + keycode + url + word + space;
	local line = lpeg.Ct(part^0);

	---|fE

	return lpeg.match(line, input);
end

--[[ Formats `line` using `width`. ]]
---@param line string
---@param width? integer 
---@param leader? string
---@return string[]
format.format = function (line, width, leader)
	---|fS

	width = width or config.active.textwidth;

	local parsed = format.parse(line);
	local output = { "" };

	for _, part in ipairs(parsed) do
		if vim.fn.strdisplaywidth(output[#output] .. part.value) > width then
			output[#output] = string.gsub(output[#output], "%s+$", "");
			table.insert(output, part.kind ~= "space" and part.value or nil);
		else
			output[#output] = output[#output] .. part.value;
		end
	end

	if leader then
		for l, _line in ipairs(output) do
			if l ~= 1 then
				output[l] = leader .. _line;
			end
		end
	end

	return output;

	---|fE
end

return format;
