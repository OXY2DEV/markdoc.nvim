local markdown = {};
local config = require("markdoc.config");
local utils = require("markdoc.utils");

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
markdown.atx_heading = function (buffer, _, TSNode)
	---|fS

	local _marker = TSNode:named_child(0) --[[ @as TSNode ]];
	local marker = vim.treesitter.get_node_text(_marker, buffer, {});
	local heading = {};

	local MAX = config.active.textwidth or (vim.bo[buffer].textwidth > 0 and vim.bo[buffer].textwidth or 80);

	local _content = TSNode:field("heading_content")[1];

	local function heading_tagger ()
		---|fS

		local text = vim.treesitter.get_node_text(_content, buffer, {});
		local wrapped = utils.wrap(text);

		local right = "";

		local tags = config.get_tags(text);

		for _, tag in ipairs(tags) do
			local left = wrapped[#wrapped];

			local L = vim.fn.strdisplaywidth(left);
			local T = vim.fn.strdisplaywidth(tag);

			if (T + 2) >= MAX then
				local _right = vim.fn.printf("%" .. (MAX - L) .. "S", right);
				wrapped[#wrapped] = left .. _right;

				table.insert(wrapped, string.format("*%s*", tag));

				right = "";
			elseif vim.fn.strdisplaywidth(left .. right) + (T + 3) > MAX then
				local _right = vim.fn.printf("%" .. (MAX - L) .. "S", right);
				wrapped[#wrapped] = left .. _right;

				_right = tag;
			else
				right = right .. string.format(" *%s*", tag);
			end
		end

		if right ~= "" then
			local left = wrapped[#wrapped];
			local L = vim.fn.strdisplaywidth(left);

			local _right = vim.fn.printf("%" .. (MAX - L) .. "S", right);
			wrapped[#wrapped] = left .. _right;
		end

		heading = vim.list_extend(heading, wrapped);

		---|fE
	end

	local function tag_section (text)
	end

	if not _content then
		goto no_content;
	end

	if #marker == 1 then
		table.insert(heading, string.rep("=", MAX));
		heading_tagger();
	elseif #marker == 2 then
		table.insert(heading, string.rep("-", MAX));
		heading_tagger();
	elseif #marker == 3 then
		-- local _text = vim.treesitter.get_node_text(TSNode, buffer, {});
		-- tag_section(_text .. " ~");
	else
	end

	::no_content::

	local R = { TSNode:range() };
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


markdown.pre_rule = {
	{ "(atx_heading) @atx", markdown.atx_heading }
};
markdown.post_rule = {
	{ "(block_quote) @block", markdown.block_quote }
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

	vim.api.nvim_buf_call(buffer, function ()
		vim.bo[buffer].textwidth = config.active.textwidth;
		-- vim.cmd("normal! gggqG");
	end);

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
