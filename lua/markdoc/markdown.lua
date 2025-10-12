local markdown = {};

local format = require("markdoc.format");
local config = require("markdoc.config");
local utils = require("markdoc.utils");

---@type integer[]
markdown.ignore_lines = {};

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

	local function align (text, width, alignment)
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
	local R = { TSNode:range() };

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
			content[l] = string.upper(line):gsub("^[^A-Z0-9.%(%)]", ""):gsub("[^-A-Z0-9.%(%)_]", ""):gsub("^%s+", "");
		end
		heading = vim.list_extend(heading, merge_cols({ width = text_w, alignment = "left", lines = content }, { width = tag_w, alignment = "right", lines = tags }))
	else
		heading = vim.list_extend(heading, merge_cols({ width = text_w, alignment = "left", lines = content }, { width = tag_w, alignment = "right", lines = tags }));
		for l, line in ipairs(heading) do
			heading[l] = line .. " ~";
		end
	end

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3] - 1, -1, heading);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.block_quote = function (buffer, _, TSNode)
	---|fS

	local text = vim.treesitter.get_node_text(TSNode, buffer, {});
	local range = { TSNode:range() };

	if string.match(text, "^%s+") then
		range[2] = range[2] + #string.match(text, "^%s+");
	end

	local lines = vim.api.nvim_buf_get_lines(buffer, range[1], range[3], false);

	for l, line in ipairs(lines) do
		lines[l] = string.sub(line, range[2] + 1);
	end

	local callout_config = config.block_quote(lines[1]);
	local title = string.match(lines[1], "^[%>%s]*%[[^%]]+%]%s*(%S.+)$")

	for l, line in ipairs(lines) do
		if l == 1 and title and callout_config.icon then
			vim.api.nvim_buf_set_text(
				buffer,

				range[1] + (l - 1),
				range[2],
				range[1] + (l - 1),
				-1,

				{ callout_config.border .. callout_config.icon .. title }
			);
		elseif l == 1 and callout_config.preview then
			vim.api.nvim_buf_set_text(
				buffer,

				range[1] + (l - 1),
				range[2],
				range[1] + (l - 1),
				-1,

				{ callout_config.border .. callout_config.preview }
			);
		else
			vim.api.nvim_buf_set_text(
				buffer,

				range[1] + (l - 1),
				range[2],
				range[1] + (l - 1),
				-1,

				{ vim.fn.substitute(line, "^>", callout_config.border or "", "g") }
			);
		end
	end

	---|fE
end

---@param TSNode TSNode
markdown.ignore_format = function (_, _, TSNode)
	local R = { TSNode:range() };

	for l = R[1], R[3] - 1, 1 do
		table.insert(markdown.ignore_lines, l);
	end
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

	local R = { TSNode:range() };
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

	if vim.list_contains({ "list" }, TSNode:type()) and R[4] == 0 then
		R[3] = R[3] - 1;
		R[4] = -1;
	end

	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3], R[4], {});
	vim.api.nvim_buf_set_lines(buffer, R[1], R[1], false, formatted);

	---|fE
end

---@param buffer integer
---@param TSNode TSNode
markdown.fenced_code_block = function (buffer, _, TSNode)
	local lines = vim.fn.split(
		vim.treesitter.get_node_text(TSNode, buffer, {}),
		"\n"
	);

	local is_info_string = TSNode:named_child(1);
	local lang;

	if is_info_string and is_info_string:type() == "info_string" and is_info_string:named_child(0) then
		lang = vim.treesitter.get_node_text(is_info_string:named_child(0) --[[ @as TSNode ]], buffer, {});
	end

	lines[1] = string.format(">%s", lang);
end


markdown.pre_rule = {
	{ "(atx_heading) @atx", markdown.atx_heading }
};
markdown.post_rule = {
	{ "[ (pipe_table) (fenced_code_block) (indented_code_block) ] @format", markdown.ignore_format },
	{ "[ (paragraph) (block_quote) (list) ] @format", markdown.formatter },

	{ "(block_quote) @block", markdown.block_quote },
	{ "(fenced_code_block) @code_block", markdown.fenced_code_block },
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
