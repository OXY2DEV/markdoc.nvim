--[[
A `markdown` to `vimdoc` converter for **Neovim** with support for `HTML`.

Usage 

```lua
require("markdoc").setup();
```
]]
local markdoc = {};

--[[ Converts `buffer` into `vimdoc`. ]]
---@param buffer? integer
markdoc.convert_buffer = function (buffer)
	---|fS

	buffer = buffer or vim.api.nvim_get_current_buf();

	if vim.bo[buffer].ft ~= "markdown" then
		return;
	end

	local new = vim.api.nvim_create_buf(false, true);
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

	---|fE
end

markdoc.setup = function ()
	vim.api.nvim_create_user_command("Doc", function ()
		markdoc.convert_buffer();
	end, {});
end

return markdoc;
