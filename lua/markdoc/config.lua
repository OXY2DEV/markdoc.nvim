local config = {};

config.eval = function (val, ...)
	if type(val) ~= "function" then
		return val;
	end

	local sucess, new = pcall(val, ...);

	if sucess then
		return new;
	end
end

config.default = {
	textwidth = 80,
	indent = 4,

	tags = {
		default = { "a", "b", "c" }
	},
	block_quotes = {
		default = {
			border = "|"
		},
		NOTE = {
			border = "A"
		},
	},
	list_items = {}
};

config.active = vim.deepcopy(config.default, true);

config.block_quote = function (leader)
	local callout = string.match(leader, "^%>%s*%[!([^%]]+)%]");

	if not callout then
		return config.eval(config.active.block_quotes.default, leader), false;
	end

	local keys = vim.tbl_keys(config.active.block_quotes or {});

	for _, key in ipairs(keys) do
		if string.match(callout, key) then
			vim.print(callout)
			return config.eval(config.active.block_quotes[key], callout), true;
		end
	end

	return config.eval(config.active.block_quotes.default, leader), false;
end

config.get_tags = function (text)
	if not config.active.tags then
		return {};
	end

	local keys = vim.tbl_keys(config.active.tags or {});

	for _, key in ipairs(keys) do
		if string.match(text, key) then
			return config.eval(config.active.tags[key], text);
		end
	end

	return config.eval(config.active.tags.default, text);
end

config.setup = function (new)
	if type(new) ~= "table" then
		return;
	end

	config.active = vim.tbl_deep_extend("force", config.active, new);
end

return config;
