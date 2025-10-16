local html = {};

---@param buffer integer
---@param TSNode TSNode
---@param inline? boolean
local function normalize (buffer, TSNode, inline)
	---|fS

	local _t = vim.treesitter.get_node_text(TSNode, buffer, {});

	local _start = TSNode:named_child(0) --[[@as TSNode]];
	local start = vim.treesitter.get_node_text(_start, buffer, {});

	_t = string.gsub(
		_t,
		vim.pesc(start),
		""
	);

	_t = string.gsub(_t, "^%s+", "");

	local _finish = TSNode:named_child(TSNode:named_child_count() - 1) --[[@as TSNode]];

	if _finish and _finish:type() == "end_tag" then
		local finish = vim.treesitter.get_node_text(_finish, buffer, {});

		_t = string.gsub(
			_t,
			vim.pesc(finish),
			""
		);
	end

	_t = string.gsub(_t, "%s+$", "");

	if inline ~= false then
		-- feat: Mimic how browsers handle spaces in `HTML`.
		_t = string.gsub(_t, "[\n\r]%s*", " ");
		_t = string.gsub(_t, "%s%s+", " ");
	end

	return _t;

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.comment = function (buffer, _, TSNode)
	---|fS

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], { "" });

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.heading = function (buffer, _, TSNode)
	---|fS

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

	local normal = normalize(buffer, TSNode);
	normal = string.rep("#", level) .. " " .. normal;

	local lines = vim.fn.split(normal, "\n");
	local R = { TSNode:range() };

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], lines);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.bold = function (buffer, _, TSNode)
	---|fS

	local normal = normalize(buffer, TSNode);
	normal = "**" .. string.gsub(normal, "%s", "") .. "**";

	local lines = vim.fn.split(normal, "\n");

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], lines);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.italic = function (buffer, _, TSNode)
	---|fS

	local normal = normalize(buffer, TSNode);
	normal = "*" .. string.gsub(normal, "%s", "") .. "*";

	local lines = vim.fn.split(normal, "\n");

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], lines);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.anchor = function (buffer, _, TSNode)
	---|fS

	local normal = normalize(buffer, TSNode);
	-- normal = "*" .. string.gsub(normal, "%s", "") .. "*";

	local lines = vim.fn.split(normal, "\n");

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], lines);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.image = function (buffer, _, TSNode)
	---|fS

	if TSNode:type() ~= "element" then
		return;
	end

	local tag = vim.treesitter.get_node_text(TSNode, buffer, {});

	local src = string.match(tag, 'src="([^"]+)"');
	local alt = string.match(tag, 'alt="([^"]+)"');

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[1], -1, { alt or "Image" });

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.keycode = function (buffer, _, TSNode)
	---|fS

	local normal = normalize(buffer, TSNode);
	normal = "<" .. string.gsub(normal, "%s", "") .. ">";

	local lines = vim.fn.split(normal, "\n");

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], lines);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.paragraph = function (buffer, _, TSNode)
	---|fS

	local start = TSNode:named_child(0) --[[@as TSNode]];
	local text = vim.treesitter.get_node_text(start, buffer, {});

	local align = string.match(text or "", "align='(%w-)'") or string.match(text or "", 'align="(%w-)"');

	local normal = normalize(buffer, TSNode);

	if align then
		normal = string.format("::%s::", align) .. normal;
	end

	local lines = vim.fn.split(normal, "\n");

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], lines);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.details = function (buffer, _, TSNode)
	---|fS

	local normal = normalize(buffer, TSNode, false);
	local lines = vim.fn.split(normal, "\n");

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], lines);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.summary = function (buffer, _, TSNode)
	---|fS

	local normal = normalize(buffer, TSNode);
	local lines = vim.fn.split(normal, "\n");

	lines[1] = "### " .. lines[1];

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], lines);

	---|fE
end

html.rules = {
	{ "(comment) @comment", html.comment },

	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^h%d+$")) )) @heading', html.heading },
	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^p$")) )) @paragraph', html.paragraph },
	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^div$")) )) @div', html.paragraph },

	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^summary$")) )) @summary', html.summary },
	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^details$")) )) @details', html.details },

	{ '(element (end_tag ((tag_name) @tag_name (#any-of? @tag_name "b" "bold" "em" "emphasis")) )) @bold', html.bold },
	{ '(element (end_tag ((tag_name) @tag_name (#any-of? @tag_name "i" "italic")) )) @italic', html.italic },
	{ '(element (end_tag ((tag_name) @tag_name (#any-of? @tag_name "a")) )) @anchor', html.anchor },
	{ '(element . (start_tag ((tag_name) @tag_name (#any-of? @tag_name "img")) ) .) @image', html.image },

	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^kbd$")) )) @keycode', html.keycode },
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
