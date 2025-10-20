vim.api.nvim_create_user_command("Doc", function (data)
	local markdoc = require("markdoc");
	local fargs = data.fargs;

	if #fargs == 0 then
		table.insert(fargs, vim.api.nvim_get_current_buf());
	end

	local use;

	for _, arg in ipairs(fargs) do
		if tonumber(arg) then
			use = markdoc.convert_buffer(tonumber(arg), use);
		else
			use = markdoc.convert_file(arg, use);
		end
	end
end, {
	desc = "Convert `markdown` to `vimdoc`",
	nargs = "*",
	complete = "file"
});

