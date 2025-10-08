local markdoc = {};

markdoc.init = function ()
	local buf = vim.api.nvim_get_current_buf();

	if vim.bo[buf].ft ~= "markdown" then
		return;
	end

	local new = vim.api.nvim_create_buf(false, true);
	vim.bo[new].ft = "markdown";

	vim.api.nvim_buf_set_lines(
		new,
		0,
		-1,
		false,

		vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	);

	require("markdoc.markdown_inline").walk(new);
	require("markdoc.markdown").walk(new);
end

markdoc.setup = function ()
	vim.api.nvim_create_user_command("Doc", function ()
		markdoc.init();
	end, {});
end

return markdoc;
