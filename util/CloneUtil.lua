CloneUtil = {}

function CloneUtil.clone(obj)
    if type(obj) ~= 'table' then return obj end
    local res = setmetatable({}, getmetatable(obj))
    for k, v in pairs(obj) do res[CloneUtil.clone(k)] = CloneUtil.clone(v) end
    return res
end