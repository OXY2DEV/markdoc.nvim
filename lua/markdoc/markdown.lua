local markdown = {};

markdown.wrap_buf = vim.api.nvim_create_buf(false, true);

markdown.wrap = function (lines, width, comment)
	if not markdown.wrap_buf or not vim.api.nvim_buf_is_valid(markdown.wrap_buf) then
		markdown.wrap_buf = vim.api.nvim_create_buf(false, true);
	end

	vim.api.nvim_buf_set_lines(markdown.wrap_buf, 0, -1, false, lines);

	vim.bo[markdown.wrap_buf].filetype = "vimdoc";
	vim.bo[markdown.wrap_buf].textwidth = width;
	vim.bo[markdown.wrap_buf].comments = comment;

	vim.api.nvim_buf_call(markdown.wrap_buf, function ()
		vim.cmd("normal! gggqG");
	end);

	return vim.api.nvim_buf_get_lines(markdown.wrap_buf, 0, -1, false);
end

markdown.to_block = function (buffer, TSNode)
	local range = { TSNode:range() };

	if range[2] == 0 then
		return vim.split(
			vim.treesitter.get_node_text(TSNode, buffer, {}),
			"\n"
		);
	end

	local lines = vim.api.nvim_buf_get_lines(buffer, range[1], range[3], false);

	for l, line in ipairs(lines) do
		lines[l] = string.sub(line, range[2]);
	end

	return lines;
end

---@param buffer integer
---@param TSNode TSNode
markdown.paragraph = function (buffer, _, TSNode)
	local wrapped = markdown.wrap(
		markdown.to_block(buffer, TSNode),
		20
	);

	local R = { TSNode:range() };

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], wrapped);
end

markdown.rule_map = {
	{ "(paragraph) @paragraph", markdown.paragraph },
};

markdown.transform = function (TSTree, buffer, rule)
	local query = vim.treesitter.query.parse("markdown", rule[1]);
	local stack = {};

	for capture_id, capture_node, _, _ in query:iter_captures(TSTree:root(), buffer) do
		local capture_name = query.captures[capture_id];
		table.insert(stack, 1, { capture_name, capture_node })
	end

	for _, item in ipairs(stack) do
		pcall(rule[2], buffer, item[1], item[2]);
	end
end

markdown.walk = function (buffer)
	for _, rule in ipairs(markdown.rule_map) do
		local root_parser = vim.treesitter.get_parser(buffer);

		if not root_parser then
			return;
		end

		root_parser:parse(true);

		root_parser:for_each_tree(function (TSTree, language_tree)
			local lang = language_tree:lang();

			if lang == "markdown" then
				markdown.transform(TSTree, buffer, rule)
			end
		end);
	end

	vim.print(
		table.concat(
			vim.api.nvim_buf_get_lines(buffer, 0, -1, false),
			"\n"
		)
	)
end

return markdown;
