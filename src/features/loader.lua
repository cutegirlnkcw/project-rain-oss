local loader = {};

local function normalize_module_path(path)
    if type(path) ~= "string" then
        return nil;
    end

    local normalized = path:gsub("^@src/", "");
    normalized = normalized:gsub("\\", "/");
    return normalized;
end

local function should_skip_module(module_path)
    if type(module_path) ~= "string" then
        return true;
    end

    local normalized = normalize_module_path(module_path);
    if not normalized then
        return true;
    end

    local skip_prefixes = {
        "features/auto-parry",
        "features/buttons",
        "features/generic_feature",
        "features/hooking",
        "features/loader",
    };

    for _, prefix in ipairs(skip_prefixes) do
        if normalized == prefix or normalized:sub(1, #prefix + 1) == prefix .. "/" then
            return true;
        end
    end

    return false;
end

local function unique_modules(list)
    local seen = {};
    local result = {};

    for _, value in ipairs(list) do
        if type(value) == "string" and value ~= "" and not seen[value] then
            seen[value] = true;
            table.insert(result, value);
        end
    end

    return result;
end

local function collect_feature_modules()
    local modules = {};
    if type(list_modules) ~= "function" then
        return modules;
    end

    local patterns = {
        "features/*",
        "features/*/*",
        "features/*/*/*",
    };

    for _, pattern in ipairs(patterns) do
        for _, module_path in list_modules(pattern) do
            if not should_skip_module(module_path) then
                table.insert(modules, normalize_module_path(module_path));
            end
        end
    end

    return unique_modules(modules);
end

local function is_feature_module(module)
    if type(module) ~= "table" then
        return false;
    end

    return type(module.id) == "string" and (
        type(module.enable) == "function"
        or type(module.disable) == "function"
        or type(module.update) == "function"
        or type(module.conn) ~= "nil"
    );
end

function loader.initialize()
    aztup.features = aztup.features or {};

    for _, module_path in ipairs(collect_feature_modules()) do
        local ok, module = xpcall(function()
            return require(module_path);
        end, function(err)
            warn(string.format("[features/loader] failed to load %s: %s", module_path, tostring(err)));
        end);

        if not ok or not module then
            continue;
        end

        if not is_feature_module(module) then
            continue;
        end

        local feature_id = module.id;
        if type(feature_id) ~= "string" then
            continue;
        end

        if not aztup.features[feature_id] then
            aztup.features[feature_id] = module;
        end
    end

    return aztup.features;
end

return loader;