local utils = {};

utils.create_ignore_range = function (buffer)
	local root_parser = vim.treesitter.get_parser(buffer);

	if not root_parser then
		return {};
	end

	local trees = root_parser:parse(true) or {};
	local root_tree = trees[1];

	if not root_tree then
		return {};
	end

	local ignore = {};
	local lang = root_parser:lang();

	if lang == "markdown" then
		local query = vim.treesitter.query.parse("markdown", '((language) @ignore (#any-of? @ignore "md" "html" "markdown"))');

		for _, capture_node, _, _ in query:iter_captures(root_tree:root(), buffer) do
			if
				capture_node:parent() and capture_node:parent():parent() and
				capture_node:parent():parent():type() == "fenced_code_block"
			then
				local R = { capture_node:parent():parent():range() };
				table.insert(ignore, { R[1], R[3] });
			end
		end
	end

	return ignore;
end

---@param TSTree TSTree
---@param ignore any
---@return boolean
utils.ignore_tree = function (TSTree, ignore)
	local root = TSTree:root();
	local R = { root:range() };

	for _, ign in ipairs(ignore) do
		if R[1] >= ign[1] and R[2] <= ign[2] then
			return true;
		end
	end

	return false
end

return utils;
