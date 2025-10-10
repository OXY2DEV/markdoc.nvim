local markdown = {};
local config = require("markdoc.config");

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
	local _marker = TSNode:named_child(0) --[[ @as TSNode ]];
	local marker = vim.treesitter.get_node_text(_marker, buffer, {});
	local heading = {};

	local MAX = config.active.textwidth or (vim.bo[buffer].textwidth > 0 and vim.bo[buffer].textwidth or 80);

	local _content = TSNode:field("heading_content")[1];

	local function tag_lines ()
		local text = vim.treesitter.get_node_text(_content, buffer, {});
		local tags = config.get_tags(text);

		local _tmp = text;
		local _tags = "";

		for _, tag in ipairs(tags) do
			local W = vim.fn.strdisplaywidth(_tmp .. _tags);

			if vim.fn.strdisplaywidth(tag) + 2 >= MAX then
				table.insert(heading, _tmp);
				table.insert(heading, string.format("*%s*", tag));

				_tmp = "";
			elseif (vim.fn.strdisplaywidth(tag) + 3) + W <= MAX then
				_tags = _tags .. string.format(" *%s*", tag);
			else
				table.insert(heading, _tmp .. string.rep(" ", MAX - W) .. _tags)
				_tmp = "";
				_tags = "";
			end
		end

		if _tags ~= "" then
			table.insert(heading, _tmp .. string.rep(" ", MAX - vim.fn.strdisplaywidth(_tmp .. _tags)) .. _tags)
		end
	end

	if not _content then
		goto no_content;
	end

	if #marker == 1 then
		table.insert(heading, string.rep("=", MAX));
		tag_lines();
	elseif #marker == 2 then
		table.insert(heading, string.rep("-", MAX));
		tag_lines();
	elseif #marker == 3 then
		tag_lines();
	else
	end

	::no_content::

	local R = { TSNode:range() };
	vim.api.nvim_buf_set_text(buffer, R[1], R[2], R[3] - 1, -1, heading);
end


markdown.pre_rule = {
	{ "(atx_heading) @atx", markdown.atx_heading }
};
markdown.post_rule = {};


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
		vim.cmd("normal! gggqG");
	end)

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
