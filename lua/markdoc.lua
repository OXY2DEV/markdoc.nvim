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
---@param buffer? integer
---@param use? integer
markdoc.convert_buffer = function (buffer, use)
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

	require("markdoc.html").walk(new);
	require("markdoc.markdown_inline").walk(new);
	require("markdoc.markdown").walk(new);

	local config = require("markdoc.config");

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
---@param path string
---@param use? integer
markdoc.convert_file = function (path, use)
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

	require("markdoc.html").walk(new);
	require("markdoc.markdown_inline").walk(new);
	require("markdoc.markdown").walk(new);

	local config = require("markdoc.config");

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
