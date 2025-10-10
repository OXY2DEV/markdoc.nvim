local inline = {};

inline.links = {};
inline.images = {};

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
inline.bold = function (buffer, _, TSNode)
	---|fS

	clear_node(buffer, TSNode:named_child(3));
	clear_node(buffer, TSNode:named_child(2));
	clear_node(buffer, TSNode:named_child(1));
	clear_node(buffer, TSNode:named_child(0));

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
inline.italic = function (buffer, _, TSNode)
	---|fS

	clear_node(buffer, TSNode:named_child(1));
	clear_node(buffer, TSNode:named_child(0));

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
inline.inline_link = function (buffer, _, TSNode)
	---|fS

	local dest = TSNode:named_child(1);
	table.insert(inline.links, dest);

	clear_node(buffer, TSNode:child(5));
	clear_node(buffer, dest)
	clear_node(buffer, TSNode:child(3));

	clear_node(buffer, TSNode:child(2));

	if dest then
		local _last = TSNode:child(2);

		if _last then
			local R = { _last:range() };

			vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[1], R[2], { "^" .. tostring(#inline.links) });
		end
	end

	clear_node(buffer, TSNode:child(0));

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
inline.full_reference_link = function (buffer, _, TSNode)
	---|fS

	clear_node(buffer, TSNode:child(3));
	clear_node(buffer, TSNode:child(2));
	clear_node(buffer, TSNode:child(0));

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
inline.shortcut_link = function (buffer, _, TSNode)
	---|fS

	local range = { TSNode:range() };
	local before = vim.api.nvim_buf_get_text(buffer, range[1], 0, range[1], range[2], {})[1] or "";

	if string.match(before, "%>%s*$") and string.match(before, "^[%s%>]+$") then
		return;
	end

	clear_node(buffer, TSNode:child(2));
	clear_node(buffer, TSNode:child(0));

	---|fE
end

inline.rule_map = {
	{ "(strong_emphasis) @bold", inline.bold },
	{ "(emphasis) @italic", inline.bold },

	{ "(inline_link  (link_text)  (link_destination)) @link", inline.inline_link },
	{ "(full_reference_link  (link_text)  (link_label)) @link", inline.full_reference_link },
	{ "(shortcut_link) @link", inline.shortcut_link },
};

inline.transform = function (TSTree, buffer, rule)
	local query = vim.treesitter.query.parse("markdown_inline", rule[1]);
	local stack = {};

	for capture_id, capture_node, _, _ in query:iter_captures(TSTree:root(), buffer) do
		local capture_name = query.captures[capture_id];
		table.insert(stack, 1, { capture_name, capture_node })
	end

	for _, item in ipairs(stack) do
		pcall(rule[2], buffer, item[1], item[2]);
	end
end

inline.walk = function (buffer)
	inline.links = {};
	inline.images = {};

	for _, rule in ipairs(inline.rule_map) do
		local root_parser = vim.treesitter.get_parser(buffer);

		if not root_parser then
			return;
		end

		root_parser:parse(true);

		root_parser:for_each_tree(function (TSTree, language_tree)
			local lang = language_tree:lang();

			if lang == "markdown_inline" then
				inline.transform(TSTree, buffer, rule)
			end
		end);
	end

	return inline.links, inline.images;
end

return inline;
