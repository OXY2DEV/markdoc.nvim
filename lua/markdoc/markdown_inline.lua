local inline = {};

local config = require("markdoc.config");
local links = require("markdoc.links");

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

--- Text for a link.
---@param kind "link" | "image"
---@param buffer integer
---@param desc string
---@param url string
local function link_text (kind, buffer, desc, url)
	if config.use_refs(desc, url) then
		local ref = links.add(kind, buffer, url);
		return string.format(config.active.markdown.link_ref_format or "{%d}", ref);
	else
		return url;
	end
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

	local _desc = TSNode:named_child(0);
	local desc = "";

	if _desc and _desc:type() == "link_text" then
		desc = vim.treesitter.get_node_text(_desc, buffer, {});
	end

	local _dest = TSNode:named_child(1);
	local ref;

	if _dest and _dest:type() == "link_destination" then
		-- NOTE: link may contain `\r` or `\r`.
		local tmp = vim.treesitter.get_node_text(_dest, buffer, {}):gsub("%s", "");
		ref = link_text("link", buffer, desc, tmp);
	end

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], { desc .. (ref and " " .. ref or "") });

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

---@param buffer integer
---@param TSNode TSNode
inline.image = function (buffer, _, TSNode)
	---|fS

	local dest = TSNode:named_child(1);
	table.insert(inline.images, dest);

	clear_node(buffer, TSNode:child(6));
	clear_node(buffer, dest)
	clear_node(buffer, TSNode:child(4));

	clear_node(buffer, TSNode:child(3));

	if dest then
		local _last = TSNode:child(3);

		if _last then
			local R = { _last:range() };

			vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[1], R[2], { "^" .. tostring(#inline.links) });
		end
	end

	clear_node(buffer, TSNode:child(1));
	clear_node(buffer, TSNode:child(0));

	---|fE
end

inline.rule_map = {
	{ "(strong_emphasis) @bold", inline.bold },
	{ "(emphasis) @italic", inline.bold },

	{ "(inline_link  (link_text)  (link_destination)) @link", inline.inline_link },
	{ "(full_reference_link  (link_text)  (link_label)) @link", inline.full_reference_link },
	{ "(shortcut_link) @link", inline.shortcut_link },

	{ "(image) @link", inline.image },
};

inline.transform = function (TSTree, buffer, rule)
	local query = vim.treesitter.query.parse("markdown_inline", rule[1]);
	local stack = {};

	for capture_id, capture_node, _, _ in query:iter_captures(TSTree:root(), buffer) do
		local capture_name = query.captures[capture_id];
		table.insert(stack, 1, { capture_name, capture_node })
	end

	for _, item in ipairs(stack) do
		-- vim.print(
		pcall(rule[2], buffer, item[1], item[2])
		-- ;
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
