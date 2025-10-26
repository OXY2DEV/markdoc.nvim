--[[
A tree-sitter based `markdown` to `vimdoc` converter for **Neovim** with support for `HTML`.

Usage 

```lua
require("markdoc").setup();
```
]]
local markdoc = {};

--- Gets export file path
---@param buffer number | string
---@param filename string
---@param use_relative_path boolean
---@return string
local function export_path (buffer, filename, use_relative_path)
	---|fS

	local leader = "";

	if type(buffer) == "number" then
		vim.api.nvim_buf_call(buffer, function ()
			leader = vim.fn.expand("%:h") .. "/";
		end);
	elseif type(buffer) == "string" then
		if use_relative_path then
			leader = vim.fn.fnamemodify(buffer, ":p:h") .. "/";
		else
			leader = "";
		end
	end

	return leader .. filename;

	---|fE
end

--[[ Converts `buffer` into `vimdoc`. ]]
---@param buffer? integer Buffer ID. Defaults to *current* buffer.
---@param user_config? markdoc.config Custom configuration. Overrides the file specific configuration.
---@param use? integer Buffer to dump the preview into. Has no effect if `generic.filename` is set.
markdoc.convert_buffer = function (buffer, user_config, use)
	---|fS

	buffer = buffer or vim.api.nvim_get_current_buf();

	if vim.bo[buffer].ft ~= "markdown" then
		return;
	end

	---@type integer
	local new;

	if use and vim.api.nvim_buf_is_valid(use) then
		new = use;
	else
		new = vim.api.nvim_create_buf(false, true);
	end

	vim.bo[new].ft = "markdown";

	vim.api.nvim_buf_set_lines(
		new,
		0,
		-1,
		false,

		vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	);

	local config = require("markdoc.config");
	require("markdoc.html").walk(new);

	if user_config then
		--[[
			NOTE: The `html` converter sets the config from comments.

			So, this needs to be run after that.
		]]
		config.active = vim.tbl_deep_extend("force", config.active, user_config);
	end

	require("markdoc.markdown_inline").walk(new);
	require("markdoc.markdown").walk(new);

	if config.active.generic.filename then
		local fname = config.active.generic.filename --[[@as string]];
		local path = export_path(
			buffer,
			fname,
			config.active.generic.relative_path or not string.match(fname, "^~")
		);

		vim.api.nvim_buf_call(new, function ()
			vim.cmd(
				(config.active.generic.force_write and "write! " or "write ") ..
				path
			);
		end);
	else
		local opts = vim.tbl_extend("force", { split = "right" }, config.active.generic.winopts or {});
		vim.api.nvim_open_win(new, true, opts);

		return nil;
	end

	return new;

	---|fE
end

--[[ Converts **file** with `path` into `vimdoc`. ]]
---@param path string Path to file.
---@param user_config? markdoc.config Custom configuration. Overrides the file specific configuration.
---@param use? integer Buffer to dump the preview into. Has no effect if `generic.filename` is set.
markdoc.convert_file = function (path, user_config, use)
	---|fS

	---@type integer
	local new;

	if use and vim.api.nvim_buf_is_valid(use) then
		new = use;
	else
		new = vim.api.nvim_create_buf(false, true);
	end

	local file = vim.fn.readfile(path);

	vim.bo[new].ft = "markdown";

	vim.api.nvim_buf_set_lines(
		new,
		0,
		-1,
		false,

		file
	);

	local config = require("markdoc.config");
	require("markdoc.html").walk(new);

	if user_config then
		--[[
			NOTE: The `html` converter sets the config from comments.

			So, this needs to be run after that.
		]]
		config.active = vim.tbl_deep_extend("force", config.active, user_config);
	end

	require("markdoc.markdown_inline").walk(new);
	require("markdoc.markdown").walk(new);

	if config.active.generic.filename then
		local fname = config.active.generic.filename --[[@as string]];
		local _path = export_path(
			path,
			fname,
			config.active.generic.relative_path or not string.match(fname, "^~")
		);

		vim.api.nvim_buf_call(new, function ()
			vim.cmd(
				(config.active.generic.force_write and "write! " or "write ") ..
				_path
			);
		end);
	else
		local opts = vim.tbl_extend("force", { split = "right" }, config.active.generic.winopts or {});
		vim.api.nvim_open_win(new, true, opts);

		return nil;
	end

	return new;

	---|fE
end

---@param user_config? markdoc.config
markdoc.setup = function (user_config)
	---|fS

	if type(user_config) == "table" then
		local config = require("markdoc.config");
		config.setup(user_config)
	end

	---|fE
end

return markdoc;
