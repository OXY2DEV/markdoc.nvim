local markdown = {};

local format = require("markdoc.format");
local config = require("markdoc.config");

---@type integer[]
markdown.ignore_lines = {};

---@param buffer integer
---@param TSNode TSNode
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

	return R, { TSNode:range() };

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
markdown.atx_heading = function (buffer, _, TSNode)
	---|fS

	local _marker = TSNode:named_child(0) --[[ @as TSNode ]];
	local marker = vim.treesitter.get_node_text(_marker, buffer, {});
	local heading = {};

	local MAX = config.active.textwidth or (vim.bo[buffer].textwidth > 0 and vim.bo[buffer].textwidth or 80);

	local ratio = config.active.heading_ratio;

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

	if #marker == 1 then
		table.insert(heading, string.rep("=", MAX));
		heading = vim.list_extend(heading, merge_cols({ width = text_w, alignment = "left", lines = content }, { width = tag_w, alignment = "right", lines = tags }))
	elseif #marker == 2 then
		table.insert(heading, string.rep("-", MAX));
		heading = vim.list_extend(heading, merge_cols({ width = text_w, alignment = "left", lines = content }, { width = tag_w, alignment = "right", lines = tags }))
	elseif #marker == 3 then
		for l, line in ipairs(content) do
			content[l] = string.upper(line):gsub("^[^A-Z0-9.%(%)]", ""):gsub("[^-A-Z0-9.%(%)_ \t]", ""):gsub("^%s+", "");
		end
		heading = vim.list_extend(heading, merge_cols({ width = text_w, alignment = "left", lines = content }, { width = tag_w, alignment = "right", lines = tags }))
	else
		return;
	end

	vim.api.nvim_buf_set_text(buffer, R[1], 0, R[3], R[4], heading);

	---|fE
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

	local MAX = config.active.textwidth or (vim.bo[buffer].textwidth > 0 and vim.bo[buffer].textwidth or 80);

	local ratio = config.active.heading_ratio;

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

	heading = vim.list_extend(heading, merge_cols({ width = text_w, alignment = "left", lines = content }, { width = tag_w, alignment = "right", lines = tags }));
	for l, line in ipairs(heading) do
		heading[l] = line .. " ~";
	end

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], heading);

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

				{ callout_config.border .. callout_config.icon .. title }
			);
		elseif l == 1 and callout_config.preview then
			vim.api.nvim_buf_set_text(
				buffer,

				R[1] + (l - 1),
				R[2],
				R[1] + (l - 1),
				-1,

				{ callout_config.border .. callout_config.preview }
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
		"\n"
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
		if vim.list_contains(markdown.ignore_lines, R[1] + (l - 1)) then
			formatted = vim.list_extend(formatted, { line });
		else
			formatted = vim.list_extend(formatted, format.format(line, nil, get_leader(line)));
		end
	end

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], {});
	vim.api.nvim_buf_set_lines(buffer, R[1], R[1], false, formatted);

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

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], {});
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

	table.insert(lines, 1, string.format(">%s", config.active.code_block_lang or ""));
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
		return math.min(config.active.max_col_size or 20, vim.fn.strdisplaywidth(text));
	end

	--[[ Creates a border(*optionally* with given text). ]]
	---@param kind string
	---@param ...? string
	---@return string?
	local function border (kind, ...)
		---|fS

		local borders = vim.tbl_extend("keep", config.active.table_borders or {}, {
			header = { "|", "", "|", "|" },
			separator = { "", "", "", "" },
			row = { "", "", "", "" },
			row_seperator = {},

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
				output = output .. (this_border[4] or "");
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

				if config.active.table_preserve_space == false then
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
						table.insert(data.alignments, config.active.table_align or "left");
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
			local formatted = format.format(col, col_widths[c] - 2);
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
	local W = (config.active.textwidth or 80) - vim.fn.strdisplaywidth(before or "");

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

markdown.pre_rule = {
	{ "(atx_heading) @atx", markdown.atx_heading }
};
markdown.post_rule = {
	{ "[ (pipe_table) (fenced_code_block) (indented_code_block) ] @format", markdown.ignore_format },
	{ "[ (paragraph) (block_quote) (list) ] @format", markdown.formatter },

	-- NOTE: Convert nested aligned paragraphs first as markdown syntax is lost during conversion.
	{ '((paragraph) @paragraph (#lua-match? @paragraph "^::%w+::"))', markdown.paragraph_nested },
	{ "(atx_heading) @atx", markdown.atx_h3 },

	{ "(pipe_table) @table", markdown.table },
	{ "(block_quote) @block", markdown.block_quote },
	{ "(indented_code_block) @code_block", markdown.indented_code_block },
	{ "(fenced_code_block) @code_block", markdown.fenced_code_block },

	{ '((paragraph) @paragraph (#lua-match? @paragraph "^::%w+::"))', markdown.paragraph_root },
};


markdown.transform = function (TSTree, buffer, rule)
	local query = vim.treesitter.query.parse("markdown", rule[1]);
	local stack = {};

	for capture_id, capture_node, _, _ in query:iter_captures(TSTree:root(), buffer) do
		local capture_name = query.captures[capture_id];
		table.insert(stack, 1, { capture_name, capture_node })
	end

	for _, item in ipairs(stack) do
		vim.print(
			pcall(rule[2], buffer, item[1], item[2])
		)
	end
end

markdown.walk = function (buffer)
	markdown.ignore_lines = {};

	for _, rule in ipairs(markdown.pre_rule) do
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

	for _, rule in ipairs(markdown.post_rule) do
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

	vim.api.nvim_open_win(buffer, false, { split = "right" });
end

return markdown;
