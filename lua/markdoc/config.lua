local config = {};

config.eval = function (val, ...)
	if type(val) ~= "function" then
		return val;
	end

	local sucess, new = pcall(val, ...);

	if sucess then
		return new;
	end
end

---@type markdoc.config
config.default = {
	textwidth = 80,
	indent = 4,

	heading_ratio = { 6, 4 },

	generic = {
		textwidth = 80,
		indent = 4,
	},
	markdown = {
		use_link_refs = true,
		link_url_modifiers = {
			-- {
			-- 	"^#",
			-- 	function () end
			-- }
		},
	},

	table_borders = {
		header = { "│", "│", "│", "│" },
		separator = { "├", "─", "┤", "┼" },
		row = { "│", "│", "│", "│" },
		row_separator = { "├", "─", "┤", "┼" },

		top = { "╭", "─", "╮", "┬" },
		bottom = { "╰", "─", "╯", "┴" },
	},
	tags = {
		default = { "a", "b", "c" }
	},
	block_quotes = {
		default = {
			border = "|"
		},
		NOTE = {
			border = "A",
			icon = "# ",
			preview = "$ Note"
		},
	},
	list_items = {
		indent_size = 4,
		shift_width = 4
	}
};

---@type markdoc.config
config.active = vim.deepcopy(config.default, true);

config.block_quote = function (leader)
	leader = leader or "";
	local callout = string.match(leader, "^%>%s*%[!([^%]]+)%]");

	if not callout then
		return config.eval(config.active.block_quotes.default, leader), false;
	end

	local keys = vim.tbl_keys(config.active.block_quotes or {});

	for _, key in ipairs(keys) do
		if string.match(callout, key) then
			return config.eval(config.active.block_quotes[key], callout), true;
		end
	end

	return config.eval(config.active.block_quotes.default, leader), false;
end

config.get_tags = function (text)
	if not config.active.tags then
		return {};
	end

	local keys = vim.tbl_keys(config.active.tags or {});

	for _, key in ipairs(keys) do
		if string.match(text, key) then
			return config.eval(config.active.tags[key], text);
		end
	end

	return config.eval(config.active.tags.default, text);
end

--- Modifies URL.
---@param buffer integer
---@param description string
---@param destination string
---@return string
config.modify_url = function (buffer, description, destination)
	---|fS

	if not config.active.markdown.link_url_modifiers or #config.active.markdown.link_url_modifiers == 0 then
		return destination;
	end

	local output = destination;

	for _, entry in ipairs(config.active.markdown.link_url_modifiers) do
		if string.match(destination, entry[1]) then
			if type(entry[2]) == "string" then
				---@cast entry [ string, string ]
				output = entry[2];
			else
				---@cast entry [ string, fun (description: string, destination: string): string ]
				local can_eval, evaled = pcall(entry[2], description, destination);

				if can_eval then
					output = evaled;
				end
			end

			break;
		end
	end

	return output;

	---|fE
end

--[[ Should a link use a `reference` or the `URL`? ]]
---@param description string
---@param destination string
---@return boolean
config.use_refs = function (description, destination)
	---|fS

	if config.active.markdown.use_link_refs == nil then
		return false;
	elseif type(config.active.markdown.use_link_refs) == "boolean" then
		return config.active.markdown.use_link_refs --[[@as boolean]];
	end

	local can_eval, evaled = pcall(config.active.markdown.use_link_refs --[[@as function]], description, destination)

	if can_eval then
		return evaled == true;
	else
		return false;
	end

	---|fE
end

config.setup = function (new)
	if type(new) ~= "table" then
		return;
	end

	config.active = vim.tbl_deep_extend("force", config.active, new);
end

return config;
