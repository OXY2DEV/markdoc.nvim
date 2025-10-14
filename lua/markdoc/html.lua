local html = {};

---@param TSNode? TSNode
local function clear_node (buffer, TSNode)
	---|fS

	if not TSNode then
		return;
	end

	local R = { TSNode:range() };

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], {});

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.heading = function (buffer, _, TSNode)
	local _end = TSNode:named_child(TSNode:named_child_count() - 1);

	local start = TSNode:named_child(0) --[[@as TSNode]];
	local text = vim.treesitter.get_node_text(start, buffer, {});

	local level = tonumber(
		string.match(text or "", "^%<h(%d)")
	);

	if not level or level < 1 then
		level = 1;
	elseif level > 6 then
		level = 6;
	end

	local R = { start:range() };

	if _end and _end:type() == "end_tag" then
		clear_node(buffer, _end);
	end

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], { string.rep("#", level) .. " " })
end

html.rules = {
	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "h%d+")) )) @heading', html.heading },
};

html.transform = function (TSTree, buffer, rule)
	local query = vim.treesitter.query.parse("html", rule[1]);
	local stack = {};

	for capture_id, capture_node, _, _ in query:iter_captures(TSTree:root(), buffer) do
		local capture_name = query.captures[capture_id];
		table.insert(stack, 1, { capture_name, capture_node })
	end

	for _, item in ipairs(stack) do
		-- vim.print(
			pcall(rule[2], buffer, item[1], item[2])
		-- )
	end
end

html.walk = function (buffer)
	for _, rule in ipairs(html.rules) do
		local root_parser = vim.treesitter.get_parser(buffer);

		if not root_parser then
			return;
		end

		root_parser:parse(true);

		root_parser:for_each_tree(function (TSTree, language_tree)
			local lang = language_tree:lang();

			if lang == "html" then
				html.transform(TSTree, buffer, rule)
			end
		end);
	end
end

return html;
