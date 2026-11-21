local function bind_key(key, action, opts)
	hl.unbind(key) -- Unbind the key first to avoid conflicts
	hl.bind(key, action, opts)
end

return {
	bind_key = bind_key,
}
