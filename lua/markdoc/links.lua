-- Link references for `markdoc`.
local links = {};

---@type table<integer, string[]>
links.urls = {};
---@type table<integer, string[]>
links.imagss = {};

--- Adds a new link/image.
---@param kind "link" | "image"
---@param buffer integer
---@param url string
---@return integer link_ref The ID of the link.
links.add = function (kind, buffer, url)
	local store = kind == "link" and links.urls or links.imagss;

	if not store[buffer] then
		store[buffer] = {};
	end

	table.insert(store[buffer], url);
	return #store[buffer];
end

-- Lists links available for `buffer`.
---@param kind "link" | "image"
---@param buffer integer
---@return string[]
links.list = function (kind, buffer)
	if kind == "link" then
		return links.urls[buffer];
	else
		return links.imagss[buffer];
	end
end

return links;
