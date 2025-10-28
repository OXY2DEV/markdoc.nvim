-- `HTML` to `markdown` converter for `markdoc`.
local html = {};

local utils = require("markdoc.utils");

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

--[[
Turns a `comment` into a configuration table.

The comment is parsed as `JSON`.

Source:

```html
<!--markdoc { "foo": "bar" } -->
```

Result:

```lua
require("markdoc").setup({ foo = "bar" });
```
]]
---@param buffer integer
---@param TSNode TSNode
html.config = function (buffer, _, TSNode)
	---|fS

	local text = vim.treesitter.get_node_text(TSNode, buffer, {});
	text = string.gsub(text, "^<!%-%-%s*markdoc", "");
	text = string.gsub(text, "%-%->$", "");

	local JSON = vim.json.decode(text);

	local config = require("markdoc.config");

	config.last = vim.deepcopy(config.active);
	config.active = vim.tbl_deep_extend("force", config.active, JSON);

	html.comment(buffer, _, TSNode);

	---|fE
end

-- Removes `comments` from document.
---@param buffer integer
---@param TSNode TSNode
html.comment = function (buffer, _, TSNode)
	---|fS

	local R = { TSNode:range() };

	if R[2] == 0 then
		vim.api.nvim_buf_set_lines(buffer, R[1], R[3] + 1, false, {});
	else
		vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], {});
	end

	---|fE
end

--[[
Converts `HTML headings` to `ATX headings`.

Source:

```html
<h1>Hello world</h1>
```

Result:

```markdown
# Hello world
```
]]
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

-- Turns **bold tags**(`<b>Bold</b>`) into **bold text**(`**Bold**`).
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

-- Turns **italic tags**(`<i>Italic</i>`) into **italic text**(`*Italic*`).
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

-- Turns **codes**(`<code>Bold</code>`) into **code spans**(`\`Bold\``).
---@param buffer integer
---@param TSNode TSNode
html.code = function (buffer, _, TSNode)
	---|fS

	local normal = normalize(buffer, TSNode);
	normal = "`" .. normal .. "`";

	local lines = vim.fn.split(normal, "\n");

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], lines);

	---|fE
end

-- Turns **anchor tags**(`<a href="foo">Link</a>`) into **inline link**(`[Link](foo)`).
---@param buffer integer
---@param TSNode TSNode
html.anchor = function (buffer, _, TSNode)
	---|fS

	local text = vim.treesitter.get_node_text(TSNode, buffer, {});
	local href = string.match(text, 'href="(.-)"');

	local normal = normalize(buffer, TSNode);
	normal = "[" .. normal .. "]";

	if href then
		normal = normal .. string.format("(%s)", href);
	end

	local lines = vim.fn.split(normal, "\n");

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], lines);

	---|fE
end

-- Turns **image tags**(`<img src="foo" alt="Link">`) into **image link**(`![Link](foo)`).
---@param buffer integer
---@param TSNode TSNode
html.image = function (buffer, _, TSNode)
	---|fS

	if TSNode:type() ~= "element" or not TSNode:named_child(0) then
		return;
	end

	local tag = vim.treesitter.get_node_text(TSNode, buffer, {});

	local src = string.match(tag, 'src="([^"]+)"');
	local alt = string.match(tag, 'alt="([^"]+)"');

	local R = { TSNode:named_child(0):range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[1], R[4], {
		string.format("![%s]", alt or "Image") .. (src and string.format("(%s)", src) or "")
	});

	---|fE
end

-- Turns **keyboard-input elements**(`<kbd>C-Space</kbd>`) into **keycodes**(`<C-Space>`).
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

--[[
Turns **paragraph elements**(`<p align="center">foo</p>`) into **aligned paragraph**(`::center::foo`).

NOTE: This is also used for **div**s(`<div align="center">foo</div>`).
]]
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

-- Removes `<details></details>` tags.
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

-- Turns `<summary></summary>` tags into level 3 `ATX headings`.
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

html.ignore_end = {};

---@param TSNode TSNode
html.mark_ignore_end = function (_, _, TSNode)
	local R = { TSNode:range() };
	table.insert(html.ignore_end, R[3] + 1);
end

---@param buffer integer
---@param TSNode TSNode
html.clear_ignore = function (buffer, _, TSNode)
	---|fS

	--[[
		NOTE: `ignore_end` should be accessed from first to last.

		This is because the rules are parsed from the **bottom** of the file.
		So, the first entry in `ignore_end` is the end of the *last* region.
	]]
	local to = table.remove(html.ignore_end, 1);

	if not to then
		return;
	end

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_lines(buffer, R[1], to, false, {});

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
html.toc = function (buffer, _, TSNode)
	---|fS

	local format = require("markdoc.format");
	local config = require("markdoc.config");

	local toc = config.active.generic.toc;

	if toc.enabled == false or #toc.entries == 0 then
		local R = { TSNode:range() };
		vim.api.nvim_buf_set_lines(buffer, R[1], R[1] + 1, false, {});
		return;
	end

	local textwidth = config.active.generic.textwidth or 80;
	local lines = {};

	table.insert(lines, string.rep("#", toc.heading_level or 1) .. " " .. (toc.heading or "Table of contents"));
	table.insert(lines, "");

	local text_W = math.floor(textwidth * 0.6);

	for _, entry in ipairs(toc.entries) do
		local formatted = format.format(entry.text or "", text_W);

		for f, line in ipairs(formatted) do
			if f < #formatted then
				table.insert(lines, line);
			else
				local used = vim.fn.strdisplaywidth(line .. "|" .. entry.tag .. "|") + 2;
				table.insert(lines, line .. " " .. string.rep(".", textwidth - used) .. " |" .. entry.tag .. "|");
			end
		end
	end

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_lines(buffer, R[1], R[1] + 1, false, lines);

	---|fE
end

---@type markdoc.rule[]
html.rules = {
	{ '((comment) @comment (#lua-match? @comment "^%<!%-%-%s*markdoc%s+"))', html.config },

	{ '((comment) @start (#lua-match? @start "^%<!%-%-%s*markdoc_ignore_end%s*%-%-%>"))', html.mark_ignore_end },
	{ '((comment) @start (#lua-match? @start "^%<!%-%-%s*markdoc_ignore_start%s*%-%-%>"))', html.clear_ignore },

	{ "(comment) @comment", html.comment },

	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^h%d+$")) )) @heading', html.heading },
	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^p$")) )) @paragraph', html.paragraph },
	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^div$")) )) @div', html.paragraph },

	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^summary$")) )) @summary', html.summary },
	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^details$")) )) @details', html.details },

	{ '(element (end_tag ((tag_name) @tag_name (#any-of? @tag_name "code")) )) @code', html.code },
	{ '(element (end_tag ((tag_name) @tag_name (#any-of? @tag_name "b" "bold" "em" "emphasis")) )) @bold', html.bold },
	{ '(element (end_tag ((tag_name) @tag_name (#any-of? @tag_name "i" "italic")) )) @italic', html.italic },
	{ '(element (end_tag ((tag_name) @tag_name (#any-of? @tag_name "a")) )) @anchor', html.anchor },
	{ '(element (start_tag ((tag_name) @tag_name (#any-of? @tag_name "img")) )) @image', html.image },

	{ '(element (end_tag ((tag_name) @tag_name (#lua-match? @tag_name "^kbd$")) )) @keycode', html.keycode },

	{ '((self_closing_tag) @toc (#any-of? @toc "<TOC/>"))', html.toc },
};

--[[ Provides text transformation for `HTML` to `markdown`. ]]
---@param TSTree TSTree
---@param buffer integer
---@param rule markdoc.rule
html.transform = function (TSTree, buffer, rule)
	---|fS

	local query = vim.treesitter.query.parse("html", rule[1]);
	local stack = {};

	for capture_id, capture_node, _, _ in query:iter_captures(TSTree:root(), buffer) do
		local capture_name = query.captures[capture_id];

		if capture_name ~= "tag_name" then
			table.insert(stack, 1, { capture_name, capture_node });
		end
	end

	for _, item in ipairs(stack) do
		-- vim.print(
			pcall(rule[2], buffer, item[1], item[2])
		-- )
	end

	---|fE
end

--[[ Walks/Parses `buffer` and transforms `HTML`. ]]
---@param buffer integer
html.walk = function (buffer)
	---|fS

	for _, rule in ipairs(html.rules) do
		local root_parser = vim.treesitter.get_parser(buffer);

		if not root_parser then
			return;
		end

		root_parser:parse(true);
		local ignore = utils.create_ignore_range(buffer);

		root_parser:for_each_tree(function (TSTree, language_tree)
			local lang = language_tree:lang();

			if lang == "html" and not utils.ignore_tree(TSTree, ignore) then
				html.transform(TSTree, buffer, rule)
			end
		end);
	end

	---|fE
end

return html;
