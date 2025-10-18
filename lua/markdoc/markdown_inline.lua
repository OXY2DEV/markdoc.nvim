local inline = {};

local utils = require("markdoc.utils");
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

---@param kind "link" | "image"
---@param buffer integer
---@param desc string
---@param url string
local function link_ref (kind, buffer, desc, url)
	---|fS

	if config.use_refs(desc, url) then
		local ref = links.add(kind, buffer, url);
		return string.format(config.active.markdown.link_ref_format or "{%d}", ref);
	else
		return config.modify_url(buffer, desc, url);
	end

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
inline.strikethrough = function (buffer, _, TSNode)
	---|fS

	clear_node(buffer, TSNode:named_child(
		TSNode:named_child_count() - 1
	));
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
		ref = link_ref("link", buffer, desc, tmp);
	end

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], { desc .. (ref and " " .. ref or "") });

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
inline.full_reference_link = function (buffer, _, TSNode)
	---|fS

	local _desc = TSNode:named_child(0);
	local desc = "";

	if _desc and _desc:type() == "link_text" then
		desc = vim.treesitter.get_node_text(_desc, buffer, {});
	end

	local _dest = TSNode:named_child(1);
	local ref;

	if _dest and _dest:type() == "link_label" then
		-- NOTE: link may contain `\r`, `\r`, `[` or `]`.
		local tmp = vim.treesitter.get_node_text(_dest, buffer, {}):gsub("[%s%[%]]", "");
		ref = link_ref("link", buffer, desc, tmp);
	end

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], { desc .. (ref and " " .. ref or "") });

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

	local _desc = TSNode:named_child(0);
	local desc = "";

	if _desc and _desc:type() == "image_description" then
		desc = vim.treesitter.get_node_text(_desc, buffer, {});
	end

	local _dest = TSNode:named_child(1);
	local ref;

	if _dest and ( _dest:type() == "link_destination" or _dest:type() == "link_label" ) then
		-- NOTE: link may contain `\r` or `\r`.
		local tmp = vim.treesitter.get_node_text(_dest, buffer, {}):gsub("%s", "");
		ref = link_ref("image", buffer, desc, tmp);
	end

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], { desc .. (ref and " " .. ref or "") });

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
inline.autolink = function (buffer, _, TSNode)
	---|fS

	local text = vim.treesitter.get_node_text(TSNode, buffer, {});

	text = string.gsub(text, "%s", "");
	text = string.gsub(text, "^%<", "");
	text = string.gsub(text, "%>$", "");

	local ref = link_ref("link", buffer, "", text);

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], { ref });

	---|fE
end

inline.rule_map = {
	{ "(strong_emphasis) @bold", inline.bold },
	{ "(emphasis) @italic", inline.italic },

	--[[
		NOTE: `strikethrough` nodes can contain another `strikethrough` inside of them
		Clear the nested ones first to prevent going out of bounds.
	]]
	{ "(strikethrough (strikethrough)) @striked", inline.strikethrough },
	{ "(strikethrough) @striked", inline.strikethrough },

	{ "(inline_link  (link_text)  (link_destination)) @link", inline.inline_link },
	{ "(full_reference_link  (link_text)  (link_label)) @link", inline.full_reference_link },
	{ "(shortcut_link) @link", inline.shortcut_link },

	{ "(image) @image", inline.image },
	{ "[ (email_autolink) (uri_autolink) ] @autolink", inline.autolink },
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
		-- );
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
		local ignore = utils.create_ignore_range(buffer);

		root_parser:for_each_tree(function (TSTree, language_tree)
			local lang = language_tree:lang();

			if lang == "markdown_inline" and utils.ignore_tree(TSTree, ignore) == false then
				inline.transform(TSTree, buffer, rule)
			end
		end);
	end

	return inline.links, inline.images;
end

return inline;
