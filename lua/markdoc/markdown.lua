local markdown = {};

local utils = require("markdoc.utils");
local format = require("markdoc.format");
local config = require("markdoc.config");

---@type integer[]
markdown.ignore_lines = {};

---@param buffer integer
---@param TSNode TSNode
---@return integer[]
local function range (buffer, TSNode)
	---|fS

	local lines = vim.fn.split(
		vim.treesitter.get_node_text(TSNode, buffer, {}),
		"\n"
	);
	local line_count = vim.api.nvim_buf_line_count(buffer);

	local R = { TSNode:range() };

	if string.match(lines[1] or "", "^%s+") then
		R[2] = R[2] + #string.match(lines[1] or "", "^%s+");
	end

	if R[3] >= line_count then
		R[3] = line_count - 1;
		R[4] = -1;
	elseif R[4] == 0 then
		R[3] = R[3] - 1;
		R[4] = -1;
	end

	return R;

	---|fE
end

--[[ Aligns `text` using `width`. ]]
---@param text string
---@param width integer
---@param alignment "left" | "right" | "center"
---@return string
local function align (text, width, alignment)
	---|fS

	local W = vim.fn.strdisplaywidth(text);

	if alignment == "left" then
		return text .. string.rep(" ", math.max(width - W, 0));
	elseif alignment == "right" then
		return string.rep(" ", math.max(width - W, 0)) .. text;
	else
		local B = math.ceil((width - W) / 2);
		local A = math.floor((width - W) / 2);

		return string.rep(" ", math.max(B, 0)) .. text .. string.rep(" ", math.max(A, 0));
	end

	---|fE
end

---@class markdoc.col
---
---@field width integer
---@field alignment "left" | "right" | "center"
---@field lines string[]

---@param ... markdoc.col
---@return string[]
local function merge_cols (...)
	---|fS

	local cols = { ... };
	local lines = 1;

	for _, col in ipairs(cols) do
		lines = math.max(lines, #col.lines);
	end

	local output = {};

	for l = 1, lines do
		local line = "";

		for _, col in ipairs(cols) do
			local row = col.lines[l] or "";
			line = line .. align(row, col.width, col.alignment);
		end

		table.insert(output, line);
	end

	return output;

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
---@param second? boolean Is this the second call?
markdown.atx_heading = function (buffer, _, TSNode, second)
	---|fS

	local _marker = TSNode:named_child(0) --[[ @as TSNode ]];
	local marker = vim.treesitter.get_node_text(_marker, buffer, {});
	local heading = {};

	local MAX = config.active.generic.textwidth or (vim.bo[buffer].textwidth > 0 and vim.bo[buffer].textwidth or 80);
	local ratio = config.active.markdown.heading_ratio;

	local fraction = MAX / (ratio[1] + ratio[2]);
	local text_w = math.floor(fraction * ratio[1]);
	local tag_w = math.floor(fraction * ratio[2]);

	local _content = TSNode:field("heading_content")[1];
	local R = range(buffer, TSNode);

	if not _content then
		vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], {});
		return;
	end

	local text = vim.treesitter.get_node_text(_content, buffer, {});

	local __tags = config.get_tags(text);
	local _tags = {};

	for _, tag in ipairs(__tags) do
		table.insert(_tags, "*" .. string.gsub(tag, "%*", "") .. "*")
	end

	local content = format.format(
		text:gsub("[\n\r]", ""),
		text_w
	);
	local tags = format.format(
		table.concat(_tags, " "),
		tag_w
	);

	if not second and #tags > #content then
		--[[
			BUG: Tag lines get incorrectly parsed.

			If the number of lines used to show tags exceeds the number of lines used to show heading text then the lines get parsed as indented code blocks.

			To avoid this we modify headings in *cycles*. The cycles are,

			1. Primary cycle: It converts headings that won't trigger this issue.
			2. Secondary cycle: It runs after the indented code blocks function and safely converts these special cases.
		]]
		return;
	end

	if #marker == 1 then
		table.insert(heading, string.rep("=", MAX));
		heading = vim.list_extend(heading, merge_cols({ width = text_w, alignment = "left", lines = content }, { width = tag_w, alignment = "right", lines = tags }))
	elseif #marker == 2 then
		table.insert(heading, string.rep("-", MAX));
		heading = vim.list_extend(heading, merge_cols({ width = text_w, alignment = "left", lines = content }, { width = tag_w, alignment = "right", lines = tags }))
	else
		return;
	end

	-- FIX: Remove trailing whitespaces.
	for h, hline in ipairs(heading) do
		heading[h] = string.gsub(hline, "%s+$", "");
	end

	vim.api.nvim_buf_set_text(buffer, R[1], 0, R[3], R[4], heading);

	---|fE
end

--[[ Thin wrapper around the heading converter. ]]
---@param buffer integer
---@param TSNode TSNode
markdown.atx_heading_2 = function (buffer, _, TSNode)
	markdown.atx_heading(buffer, _, TSNode, true);
end

---@param buffer integer
---@param TSNode TSNode
markdown.atx_h3 = function (buffer, _, TSNode)
	---|fS

	local _marker = TSNode:named_child(0) --[[ @as TSNode ]];
	local marker = vim.treesitter.get_node_text(_marker, buffer, {});

	if #marker < 3 then
		return;
	end

	local heading = {};

	local MAX = config.active.generic.textwidth or (vim.bo[buffer].textwidth > 0 and vim.bo[buffer].textwidth or 80);
	local ratio = config.active.markdown.heading_ratio;

	local fraction = MAX / (ratio[1] + ratio[2]);
	local text_w = math.floor(fraction * ratio[1]);
	local tag_w = math.floor(fraction * ratio[2]);

	local _content = TSNode:field("heading_content")[1];
	local R = range(buffer, TSNode);

	if not _content then
		vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], {});
		return;
	end

	local text = vim.treesitter.get_node_text(_content, buffer, {});

	local __tags = config.get_tags(text);
	local _tags = {};

	for _, tag in ipairs(__tags) do
		tag_w = math.max(tag_w, vim.fn.strdisplaywidth(tag) + 2);
		table.insert(_tags, "*" .. string.gsub(tag, "%*", "") .. "*")
	end

	local content = format.format(
		text:gsub("[\n\r]", ""),
		text_w
	);
	local tags = format.format(
		table.concat(_tags, " "),
		tag_w
	);

	heading = vim.list_extend(heading, merge_cols({ width = text_w, alignment = "left", lines = content }, { width = tag_w, alignment = "right", lines = tags }));
	for l, line in ipairs(heading) do
		heading[l] = string.gsub(line, "%s+$", "") .. " ~";
	end

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], heading);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.setext_heading = function (buffer, _, TSNode)
	---|fS

	local _marker = TSNode:named_child(1) --[[ @as TSNode ]];
	local marker = vim.treesitter.get_node_text(_marker, buffer, {});

	local heading = {};

	local MAX = config.active.generic.textwidth or (vim.bo[buffer].textwidth > 0 and vim.bo[buffer].textwidth or 80);
	local ratio = config.active.markdown.heading_ratio;

	local fraction = MAX / (ratio[1] + ratio[2]);
	local text_w = math.floor(fraction * ratio[1]);
	local tag_w = math.floor(fraction * ratio[2]);

	local _content = TSNode:field("heading_content")[1];
	local R = range(buffer, TSNode);

	if not _content then
		vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], {});
		return;
	end

	local text = vim.treesitter.get_node_text(_content, buffer, {});

	local __tags = config.get_tags(text);
	local _tags = {};

	for _, tag in ipairs(__tags) do
		table.insert(_tags, "*" .. string.gsub(tag, "%*", "") .. "*")
	end

	local content = format.format(
		-- NOTE: Setext headings can span multiple lines, but help headings are single lined.
		text:gsub("[\n\r]", " "),
		text_w
	);
	local tags = format.format(
		table.concat(_tags, " "),
		tag_w
	);

	if string.match(marker, "=") then
		table.insert(heading, string.rep("=", MAX));
		heading = vim.list_extend(heading, merge_cols({ width = text_w, alignment = "left", lines = content }, { width = tag_w, alignment = "right", lines = tags }))
	else
		table.insert(heading, string.rep("-", MAX));
		heading = vim.list_extend(heading, merge_cols({ width = text_w, alignment = "left", lines = content }, { width = tag_w, alignment = "right", lines = tags }))
	end

	-- FIX: Remove trailing whitespaces.
	for h, hline in ipairs(heading) do
		heading[h] = string.gsub(hline, "%s+$", "");
	end

	vim.api.nvim_buf_set_text(buffer, R[1], 0, R[3], R[4], heading);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.block_quote = function (buffer, _, TSNode)
	---|fS

	local R = range(buffer, TSNode);

	local lines = vim.fn.split(
		vim.treesitter.get_node_text(TSNode, buffer),
		"\n"
	);

	for l, line in ipairs(lines) do
		lines[l] = string.sub(line, R[2] + 1);
	end

	local callout_config = config.block_quote(lines[1]);
	local title = string.match(lines[1], "^[%>%s]*%[[^%]]+%]%s*(%S.+)$")

	for l, line in ipairs(lines) do
		if l == 1 and title and callout_config.icon then
			vim.api.nvim_buf_set_text(
				buffer,

				R[1] + (l - 1),
				R[2],
				R[1] + (l - 1),
				-1,

				{ callout_config.border .. " " .. callout_config.icon .. title }
			);
		elseif l == 1 and callout_config.preview then
			vim.api.nvim_buf_set_text(
				buffer,

				R[1] + (l - 1),
				R[2],
				R[1] + (l - 1),
				-1,

				{ callout_config.border .. " " .. callout_config.preview }
			);
		else
			vim.api.nvim_buf_set_text(
				buffer,

				R[1] + (l - 1),
				R[2],
				R[1] + (l - 1),
				-1,

				{ vim.fn.substitute(line, "^>", callout_config.border or "", "g") }
			);
		end
	end

	---|fE
end

---@param TSNode TSNode
markdown.ignore_format = function (buffer, _, TSNode)
	---|fS

	local R = range(buffer, TSNode);

	for l = R[1], R[3] - 1, 1 do
		table.insert(markdown.ignore_lines, l);
	end

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.formatter = function (buffer, _, TSNode)
	---|fS

	if not TSNode:parent() or not TSNode:parent():parent() or TSNode:parent():parent():type() ~= "document" then
		-- NOTE: Only apply formatting to nodes that are top-level.
		return;
	end

	local lines = vim.fn.split(
		vim.treesitter.get_node_text(TSNode, buffer, {}),
		"\n",
		true
	);

	local R = range(buffer, TSNode);
	local formatted = {};

	--[[ Gets `leader` used for text-wrapping. ]]
	---@param line string
	---@return string?
	local function get_leader (line)
		---|fS

		if string.match(line, "^[%>%s]*[%-%+%*]%s") then
			local _m = string.match(line, "^[%>%s]*[%-%+%*]%s");
			_m = string.gsub(_m, "[%-%+%*]", " ");
			return _m;
		elseif string.match(line, "^[%>%s]*[%-%+%*]%s") then
			local _m = string.match(line, "^[%>%s]*%d+[%.%)]%s");
			_m = string.gsub(_m, "[%d+%.%)]", " ");
			return _m;
		elseif string.match(line, "^[%>%s]+") then
			return string.match(line, "^[%>%s]+");
		end

		---|fE
	end

	for l, line in ipairs(lines) do
		if vim.list_contains(markdown.ignore_lines, R[1] + (l - 1)) or line == "" then
			--[[
				NOTE: Lines that should be ignored(e.g. `code block`, `table` etc.) and empty lines are added as is.

				The `format.format()` returns `{}` when the line is `""`. So, we add it directly here.
				We can't change how `format()` outputs as it breaks `table` & `block quote`.
			]]
			formatted = vim.list_extend(formatted, { line });
		else
			formatted = vim.list_extend(formatted, format.format(line, nil, get_leader(line)));
		end
	end

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], formatted);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.denest_code_block = function (buffer, _, TSNode)
	---|fS

	local R = range(buffer, TSNode);

	if R[2] == 0 then
		return;
	end

	local lines = vim.fn.split(
		vim.treesitter.get_node_text(TSNode, buffer, {}),
		"\n"
	);

	for l = 2, #lines, 1 do
		lines[l] = string.sub(lines[l], R[2] + 1);
	end

	-- NOTE: We need to start replacing from the start of the line.
	vim.api.nvim_buf_set_text(buffer, R[1], 0, R[3], R[4], lines);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.fenced_code_block = function (buffer, _, TSNode)
	---|fS

	local lines = vim.fn.split(
		vim.treesitter.get_node_text(TSNode, buffer, {}),
		"\n"
	);

	local is_info_string = TSNode:named_child(1);
	local lang;

	if is_info_string and is_info_string:type() == "info_string" and is_info_string:named_child(0) then
		lang = vim.treesitter.get_node_text(is_info_string:named_child(0) --[[ @as TSNode ]], buffer, {});
	end

	lines[1] = string.format(">%s", lang or "");

	if string.match(lines[#lines], "^```") then
		lines[#lines] = "<";
	else
		table.insert(lines, "<");
	end

	for l = 2, #lines - 1, 1 do
		lines[l] = "\t" .. lines[l];
	end

	local R = range(buffer, TSNode);

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3] + 1, R[4], {});
	vim.api.nvim_buf_set_lines(buffer, R[1], R[1], false, lines);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.indented_code_block = function (buffer, _, TSNode)
	---|fS

	local lines = vim.fn.split(
		vim.treesitter.get_node_text(TSNode, buffer, {}),
		"\n"
	);

	table.insert(lines, 1, string.format(">%s", config.active.markdown.code_blocks.fallback_language or ""));
	table.insert(lines, "<");

	-- for l = 2, #lines - 1 do
	-- 	lines[l] = lines[l];
	-- end

	local R = range(buffer, TSNode);

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], {});
	vim.api.nvim_buf_set_lines(buffer, R[1], R[1], false, lines);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.table = function (buffer, _, TSNode)
	---|fS

	local data = {
		header = {},
		alignments = {},

		rows = {}
	};

	local col_widths = {};

	---@param col TSNode
	local function width (col)
		local text = vim.treesitter.get_node_text(col, buffer, {});
		return math.min(config.active.markdown.tables.max_col_size or 40, vim.fn.strdisplaywidth(text));
	end

	--[[ Creates a border(*optionally* with given text). ]]
	---@param kind string
	---@param ...? string
	---@return string?
	local function border (kind, ...)
		---|fS

		---@type markdown.tables.border
		local borders = vim.tbl_extend("keep", config.active.markdown.tables.borders or {}, {
			separator = { "", "", "", "" },
			row_seperator = {},

			header = { "|", "", "|" },
			row = { "", "", ""},

			top = { "/", "-", "}", "|" },
			bottom = { "{", "-", "//", "|" },
		});

		local cols = { ... };
		local this_border = borders[kind] or { "", "", "", "" };

		if #this_border == 0 and #cols == 0 then
			return nil;
		end

		local output = this_border[1] or "";

		for c = 1, #col_widths, 1 do
			local align_k = data.alignments[c] or "left";

			if cols[c] then
				output = output .. " " .. align(cols[c], col_widths[c] - 2, align_k) .. " ";
			else
				output = output .. string.rep(this_border[2] or "", col_widths[c]);
			end

			if c < #col_widths then
				output = output .. (this_border[4] or this_border[3] or "");
			else
				output = output .. (this_border[3] or "");
			end
		end

		return output;

		---|fE
	end

	---@param row TSNode
	local function parse_row (row)
		---|fS

		local output = {};
		local c = 1;

		for col, _ in row:iter_children() do
			if col:named() and ( col:type() == "pipe_table_cell" or col:type() == "pipe_table_delimiter_cell" ) then
				local text = vim.treesitter.get_node_text(col, buffer, {});

				if config.active.markdown.tables.preserve_whitespace == false then
					text = string.gsub(text, "%s+$", "");
					text = string.gsub(text, "^%s+", "");
				end

				table.insert(output, text);

				if not col_widths[c] then
					col_widths[c] = width(col) + 2;
				elseif col_widths[c] < width(col) + 2 then
					col_widths[c] = width(col) + 2;
				end

				c = c + 1;
			end
		end

		return output;

		---|fE
	end

	for child, _ in TSNode:iter_children() do
		---|fS "chunk: Parse table into data."

		if vim.list_contains({ "pipe_table_header", "pipe_table_delimiter_row", "pipe_table_row" }, child:type()) then
			local cols = parse_row(child);

			if child:type() == "pipe_table_header" then
				data.header = cols;
			elseif child:type() == "pipe_table_row" then
				table.insert(data.rows, cols);
			else
				for _, col in ipairs(cols) do
					if string.match(col, ":%-+:") then
						table.insert(data.alignments, "center");
					elseif string.match(col, ":%-+") then
						table.insert(data.alignments, "left");
					elseif string.match(col, "%-+:") then
						table.insert(data.alignments, "right");
					else
						table.insert(data.alignments, config.active.markdown.tables.default_alignment or "left");
					end
				end
			end
		end

		---|fE
	end

	local lines = {};

	local function new_row (kind, row)
		---|fS "chunk: Create a new wrapped row"

		local formatted_row = {};
		local L = 0;

		for c, col in ipairs(row) do
			local formatted = format.format(col, col_widths[c] - 2, nil, true);
			L = math.max(L, #formatted);

			table.insert(formatted_row, formatted);
		end

		for r = 1, L, 1 do
			local this_line = {};

			for _, col in ipairs(formatted_row) do
				table.insert(this_line, col[r] or "");
			end

			table.insert(lines, border(kind, unpack(this_line)));
		end

		---|fE
	end

	local R = range(buffer, TSNode);
	local leader = vim.api.nvim_buf_get_text(buffer, R[1], 0, R[1], R[2], {})[1];

	table.insert(lines, border("top"));

	new_row("header", data.header);

	if #data.rows == 0 then
		table.insert(lines, border("bottom"));
	else
		table.insert(lines, border("separator"));

		for r, row in ipairs(data.rows) do
			new_row("row", row);

			if r < #data.rows then
				table.insert(lines, border("row_seperator"));
			end
		end

		table.insert(lines, border("bottom"));
	end

	if leader then
		for l, line in ipairs(lines) do
			if l > 1 then
				lines[l] = leader .. line;
			end
		end
	end

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], lines);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.paragraph = function (buffer, _, TSNode)
	---|fS

	local lines = vim.fn.split(
		vim.treesitter.get_node_text(TSNode, buffer, {}),
		"\n"
	);
	local R = range(buffer, TSNode);

	for l = 2, #lines, 1 do
		lines[l] = string.sub(lines[l], R[2]);
	end

	local alignment = string.match(lines[1], "^::(%w+)::") or "left";
	lines[1] = string.gsub(lines[1], "^::%w+::", "");

	local before = vim.api.nvim_buf_get_text(buffer, R[1], 0, R[1], R[2], {})[1];
	local W = (config.active.generic.textwidth or 80) - vim.fn.strdisplaywidth(before or "");

	local aligned = {}

	for l, line in ipairs(lines) do
		table.insert(aligned, (l > 1 and before or "") .. align(line, W, alignment));
	end

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], aligned);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.paragraph_root = function (buffer, _, TSNode)
	if not TSNode:parent() or not TSNode:parent():parent() or TSNode:parent():parent():type() ~= "document" then
		return;
	end

	markdown.paragraph(buffer, _, TSNode);
end

---@param buffer integer
---@param TSNode TSNode
markdown.paragraph_nested = function (buffer, _, TSNode)
	if not TSNode:parent() or not TSNode:parent():parent() or TSNode:parent():parent():type() ~= "document" then
		markdown.paragraph(buffer, _, TSNode);
	end
end

---@param buffer integer
---@param TSNode TSNode
markdown.list_marker = function (buffer, _, TSNode)
	---|fS

	local R = range(buffer, TSNode);
	local modified;

	if TSNode:type() == "list_marker_minus" then
		modified = config.active.markdown.list_items.marker_minus;
	elseif TSNode:type() == "list_marker_plus" then
		modified = config.active.markdown.list_items.marker_plus;
	elseif TSNode:type() == "list_marker_star" then
		modified = config.active.markdown.list_items.marker_star;
	elseif TSNode:type() == "list_marker_dot" then
		modified = config.active.markdown.list_items.marker_dot;
	end

	local text = vim.treesitter.get_node_text(TSNode, buffer, {});
	local after = string.match(text, "[ \t]*$");

	-- NOTE: List markers contain spaces after them(e.g. `-  `).
	R[4] = R[4] - #after;

	if not modified then
		return;
	elseif string.match(modified, "%%d") then
		local prev_sibling = TSNode:parent():prev_named_sibling();
		local N = 1;

		while prev_sibling do
			if prev_sibling:type() ~= "list_item" then
				break;
			end

			N = N + 1;
			prev_sibling = prev_sibling:prev_named_sibling();
		end

		modified = string.format(modified, N)
	end

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], { modified });

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.hr = function (buffer, _, TSNode)
	---|fS

	local R = range(buffer, TSNode);

	vim.api.nvim_buf_set_text(buffer, R[1], 0, R[1], -1, {
		config.active.markdown.hr
	});

	---|fE
end

markdown.pre_rule = {
	{ "(setext_heading) @atx", markdown.setext_heading },
	{ "(thematic_break) @hr", markdown.hr },
	{ "(atx_heading) @atx", markdown.atx_heading }
};
markdown.post_rule = {
	{ "[ (pipe_table) (fenced_code_block) (indented_code_block) ] @no_format", markdown.ignore_format },
	{ "[ (fenced_code_block) (indented_code_block) ] @denest", markdown.denest_code_block },

	{ "[ (paragraph) (block_quote) (list) ] @format", markdown.formatter },

	-- NOTE: Convert nested aligned paragraphs first as markdown syntax is lost during conversion.
	{ '((paragraph) @paragraph (#lua-match? @paragraph "^::%w+::"))', markdown.paragraph_nested },
	{ "(atx_heading) @atx", markdown.atx_h3 },

	{ "[ (list_marker_minus) (list_marker_plus) ] @item", markdown.list_marker },
	{ "(pipe_table) @table", markdown.table },
	{ "(block_quote) @block", markdown.block_quote },
	{ "(indented_code_block) @code_block", markdown.indented_code_block },
	{ "(fenced_code_block) @code_block", markdown.fenced_code_block },

	{ '((paragraph) @paragraph (#lua-match? @paragraph "^::%w+::"))', markdown.paragraph_root },
	{ "(atx_heading) @atx", markdown.atx_heading_2 }
};


markdown.transform = function (TSTree, buffer, rule)
	local query = vim.treesitter.query.parse("markdown", rule[1]);
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

---@param buffer integer
markdown.header = function (buffer)
	---|fS

	local header = config.active.generic.header;
	local textwidth = config.active.generic.textwidth or 80;

	if header.enabled == false or ( not header.desc and not header.tag ) then
		return;
	end

	local tag = { header.tag and "*" .. header.tag .. "*" or nil };
	local tag_w = vim.fn.strdisplaywidth(tag[1] or "");

	local formatted = format.format(header.desc or "", textwidth - tag_w);

	local lines = merge_cols({
		alignment = "left",
		lines = tag,
		width = tag_w
	}, {
		alignment = "right",
		lines = formatted,
		width = textwidth - tag_w
	});

	if header.last_modified then
		table.insert(lines, align(os.date() --[[@as string]], textwidth, "right"))
	end

	if header.author then
		table.insert(lines, align(header.author --[[@as string]], textwidth, "right"))
	end

	if header.version then
		table.insert(lines, align(header.version --[[@as string]], textwidth, "right"))
	end

	vim.api.nvim_buf_set_lines(buffer, 0, 0, false, lines);

	---|fE
end

---@param buffer integer
markdown.footer = function (buffer)
	---|fS

	vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {
		"",
		string.format("vim:ft=vimdoc:textwidth=%d:tabstop=%d:noexpandtab:", config.active.generic.textwidth or 80, config.active.generic.indent or 4)
	});

	---|fE
end

---@param buffer integer
markdown.links = function (buffer)
	---|fS

	local link_config = config.active.generic.links;
	local links = require("markdoc.links");

	if link_config.enabled == false or #(links.urls[buffer] or {}) then
		return;
	end

	local lines = {};

	table.insert(lines, "");
	table.insert(lines, link_config.desc or "Links ~" );

	for l, link in ipairs(links.urls[buffer] or {}) do
		local _link = config.modify_url(buffer, tostring(l), link);

		local index = string.format(link_config.list_marker or "%d:", l);
		local url = string.format(link_config.url_format or " %s", _link);

		table.insert(lines, index .. url);
	end

	table.insert(lines, "");
	vim.api.nvim_buf_set_lines(buffer, -1, -1, false, lines);

	---|fE
end

---@param buffer integer
markdown.images = function (buffer)
	---|fS

	local image_config = config.active.generic.images;
	local links = require("markdoc.links");

	if image_config.enabled == false or #(links.urls[buffer] or {}) == 0 then
		return;
	end

	local lines = {};

	table.insert(lines, image_config.desc or "Images ~");

	for l, link in ipairs(links.urls[buffer] or {}) do
		local _link = config.modify_url(buffer, tostring(l), link);

		local index = string.format(image_config.list_marker or "%d:", l);
		local url = string.format(image_config.url_format or " %s", _link);

		table.insert(lines, index .. url);
	end

	table.insert(lines, "");
	vim.api.nvim_buf_set_lines(buffer, -1, -1, false, lines);

	---|fE
end

-- Walks & transforms `buffer` into `vimdoc`.
---@param buffer integer
markdown.walk = function (buffer)
	---|fS

	markdown.ignore_lines = {};

	for _, rule in ipairs(markdown.pre_rule) do
		local root_parser = vim.treesitter.get_parser(buffer);

		if not root_parser then
			return;
		end

		root_parser:parse(true);
		local ignore = utils.create_ignore_range(buffer);

		root_parser:for_each_tree(function (TSTree, language_tree)
			local lang = language_tree:lang();

			if lang == "markdown" and utils.ignore_tree(TSTree, ignore) == false then
				markdown.transform(TSTree, buffer, rule);
			end
		end);
	end

	for _, rule in ipairs(markdown.post_rule) do
		local root_parser = vim.treesitter.get_parser(buffer);

		if not root_parser then
			return;
		end

		root_parser:parse(true);
		local ignore = utils.create_ignore_range(buffer);

		root_parser:for_each_tree(function (TSTree, language_tree)
			local lang = language_tree:lang();

			if lang == "markdown" and utils.ignore_tree(TSTree, ignore) == false then
				markdown.transform(TSTree, buffer, rule)
			end
		end);
	end

	markdown.header(buffer);
	markdown.links(buffer);
	markdown.images(buffer);
	markdown.footer(buffer);

	vim.bo[buffer].ft = "vimdoc";

	---|fE
end

return markdown;
