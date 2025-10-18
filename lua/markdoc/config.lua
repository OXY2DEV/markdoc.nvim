local config = {};

---@type markdoc.config
config.default = {
	generic = {
		textwidth = 80,
		indent = 4,

		header = {},
		links = {},
		images = {},

		toc = {
			enabled = true,

			heading = nil,
			heading_level = 2,

			entries = {
				-- { text = "Hello world", tag = "hi" },
				-- { text = "Hello world This is soms very looong text to show to the usrr", tag = "hi" },
			},
		},
	},
	markdown = {
		heading_ratio = { 6, 4 },

		use_link_refs = true,
		link_url_modifiers = {
			-- {
			-- 	"^#",
			-- 	function () end
			-- }
		},

		block_quotes = {
			---|fS

			default = {
				border = "▋",
			},

			["ABSTRACT"] = {
				preview = "󱉫 Abstract",
				icon = "󱉫",
			},
			["SUMMARY"] = {
				preview = "󱉫 Summary",
				icon = "󱉫",
			},
			["TLDR"] = {
				preview = "󱉫 Tldr",
				icon = "󱉫",
			},
			["TODO"] = {
				preview = " Todo",
				icon = "",
			},
			["INFO"] = {
				preview = " Info",

				custom_title = true,
				icon = "",
			},
			["SUCCESS"] = {
				preview = "󰗠 Success",
				icon = "󰗠",
			},
			["CHECK"] = {
				preview = "󰗠 Check",
				icon = "󰗠",
			},
			["DONE"] = {
				preview = "󰗠 Done",
				icon = "󰗠",
			},
			["QUESTION"] = {
				preview = "󰋗 Question",
				icon = "󰋗",
			},
			["HELP"] = {
				preview = "󰋗 Help",
				icon = "󰋗",
			},
			["FAQ"] = {
				preview = "󰋗 Faq",
				icon = "󰋗",
			},
			["FAILURE"] = {
				preview = "󰅙 Failure",
				icon = "󰅙",
			},
			["FAIL"] = {
				preview = "󰅙 Fail",
				icon = "󰅙",
			},
			["MISSING"] = {
				preview = "󰅙 Missing",
				icon = "󰅙",
			},
			["DANGER"] = {
				preview = " Danger",
				icon = "",
			},
			["ERROR"] = {
				preview = " Error",
				icon = "",
			},
			["BUG"] = {
				preview = " Bug",
				icon = "",
			},
			["EXAMPLE"] = {
				preview = "󱖫 Example",
				icon = "󱖫",
			},
			["QUOTE"] = {
				preview = " Quote",
				icon = "",
			},
			["CITE"] = {
				preview = " Cite",
				icon = "",
			},
			["HINT"] = {
				preview = " Hint",
				icon = "",
			},
			["ATTENTION"] = {
				preview = " Attention",
				icon = "",
			},

			["NOTE"] = {
				preview = "󰋽 Note",
				icon = "󰋽",
			},
			["TIP"] = {
				preview = " Tip",
				icon = "",
			},
			["IMPORTANT"] = {
				preview = " Important",
				icon = "",
			},
			["WARNING"] = {
				preview = " Warning",
				icon = "",
			},
			["CAUTION"] = {
				preview = "󰳦 Caution",
				icon = "󰳦",
			}

			---|fE
		},

		code_blocks = {
			indentation = "\t"
		},

		hr = " ╶" .. string.rep("─", 76) .. "╴ ",

		tags = {
			-- default = { "a", "b", "c" }
		},

		tables = {
			max_col_size = 20,
			preserve_whitespace = true,
			default_alignment = "left",

			borders = {
				header = { "│", "│", "│" },
				row = { "│", "│", "│" },

				separator = { "├", "─", "┤", "┼" },
				row_separator = { "├", "─", "┤", "┼" },

				top = { "╭", "─", "╮", "┬" },
				bottom = { "╰", "─", "╯", "┴" },
			},
		},

		list_items = {
			-- marker_plus = "•",
		}

		---|fE
	},
};

---@param val any
---@param ... any
---@return any
config.eval = function (val, ...)
	---|fS

	if type(val) ~= "function" then
		return val;
	end

	local sucess, new = pcall(val, ...);

	if sucess then
		return new;
	end

	---|fE
end

---@type markdoc.config
config.active = vim.deepcopy(config.default, true);

-- Get `block quote` configuration.
---@param leader string
---@return table
---@return boolean
config.block_quote = function (leader)
	---|fS

	leader = leader or "";
	local callout = string.match(leader, "^%>%s*%[!([^%]]+)%]");

	if not callout then
		return config.eval(config.active.markdown.block_quotes.default, leader), false;
	end

	local keys = vim.tbl_keys(config.active.markdown.block_quotes or {});
	---@type markdown.block_quotes.opts
	local default = config.eval(config.active.markdown.block_quotes.default, callout);

	for _, key in ipairs(keys) do
		if string.match(callout, key) then
			---@type markdown.block_quotes.opts
			local this = config.eval(config.active.markdown.block_quotes[key], callout);

			return vim.tbl_extend("force", default or {}, this or {}), true;
		end
	end

	return default, false;

	---|fE
end

--- Gets tags for heading.
---@param text string
---@return string[]
config.get_tags = function (text)
	---|fS

	if not config.active.markdown.tags or vim.tbl_isempty(config.active.markdown.tags) then
		return {};
	end

	local keys = vim.tbl_keys(config.active.markdown.tags or {});

	for _, key in ipairs(keys) do
		if string.match(text, key) then
			return config.eval(config.active.markdown.tags[key], text) or {};
		end
	end

	return config.eval(config.active.markdown.tags.default, text) or {};

	---|fE
end

--- Modifies URL.
---@param _ integer
---@param description string
---@param destination string
---@return string
config.modify_url = function (_, description, destination)
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

---@param new markdoc.config
config.setup = function (new)
	config.active = vim.tbl_deep_extend("force", config.active, new);
end

return config;
