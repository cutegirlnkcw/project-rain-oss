local env = getgenv() or _G;

local identity = function(value)
    return value;
end;

local function normalize_path(path)
    if type(path) ~= "string" then
        return nil;
    end

    local normalized = path:gsub("\\", "/");
    normalized = normalized:gsub("^@src/", "");
    normalized = normalized:gsub("^src/", "");
    normalized = normalized:gsub("^%./", "");
    return normalized;
end

local function file_exists(path)
    if type(path) ~= "string" then
        return false;
    end

    if type(isfile) == "function" then
        return isfile(path) == true;
    end

    return false;
end

local function list_dir(path)
    if type(listdir) == "function" then
        local items = listdir(path) or {};
        if type(items) == "table" then
            return items;
        end
    end

    if type(dir) == "function" then
        local items = dir(path) or {};
        if type(items) == "table" then
            return items;
        end
    end

    return {};
end

local function list_modules(pattern)
    if type(pattern) ~= "string" then
        return {};
    end

    local normalized = normalize_path(pattern);
    if not normalized or normalized == "" then
        return {};
    end

    if normalized:find("*", 1, true) then
        local base = normalized:match("^(.-)[/]*%*$") or "";
        local results = {};
        local seen = {};

        local function walk(dir_path)
            for _, entry in ipairs(list_dir(dir_path)) do
                local item_path = dir_path == "" and entry or (dir_path .. "/" .. entry);
                local item_key = normalize_path(item_path);
                if item_key and item_key ~= "" and not seen[item_key] then
                    seen[item_key] = true;
                    if item_key:match("%.lua$") or item_key:match("^" .. base) then
                        table.insert(results, item_key);
                    end
                end

                if type(entry) == "string" and entry ~= "" then
                    local child_path = dir_path == "" and entry or (dir_path .. "/" .. entry);
                    if type(isfolder) == "function" and isfolder(child_path) then
                        walk(child_path);
                    end
                end
            end
        end

        walk(base);
        return results;
    end

    if file_exists(normalized .. ".lua") then
        return { normalized };
    end

    if file_exists(normalized) then
        return { normalized };
    end

    return { normalized };
end

local function load_feature_base()
    local ok, generic_feature = pcall(function()
        return require("@src/features/generic_feature");
    end);

    if ok and generic_feature and generic_feature.new then
        return generic_feature;
    end

    return {
        __index = {},
        new = function(_, id, conn, func)
            local self = setmetatable({}, {
                __index = function(_, key)
                    return rawget(self, key);
                end,
            });
            self.id = id;
            self.conn = conn;
            self.func = func or function() end;
            self.current_connection = nil;
            self.enabled = false;
            self.state = "idle";
            self.held = false;
            return self;
        end,
    };
end

env.LPH_JIT = env.LPH_JIT or identity;
env.LPH_JIT_MAX = env.LPH_JIT_MAX or env.LPH_JIT or identity;
env.LPH_NO_VIRTUALIZE = env.LPH_NO_VIRTUALIZE or identity;
env.LPH_NO_UPVALUES = env.LPH_NO_UPVALUES or identity;
env.LPH_ENCSTR = env.LPH_ENCSTR or identity;
env.AUTH_GET_CONSTANT = env.AUTH_GET_CONSTANT or function(...)
    return ...;
end;
env.PROT_OBF_STR_SAFE_MACRO = env.PROT_OBF_STR_SAFE_MACRO or function(...)
    return ...;
end;
env.LPH_CRASH = env.LPH_CRASH or function(...)
    assert(select('#', ...) == 0, "LPH_CRASH does not accept any arguments.");
end;
env.LRM_INIT_SCRIPT = env.LRM_INIT_SCRIPT or function(value)
    return value();
end;

env.builder_require = env.builder_require or function(module_path)
    if type(module_path) ~= "string" then
        return nil;
    end

    local ok, result = pcall(function()
        return require(module_path);
    end);

    if ok then
        return result;
    end

    return nil;
end;

env.Feature = env.Feature or load_feature_base();
env.list_modules = env.list_modules or list_modules;
env.get_module_list = env.get_module_list or list_modules;

return true;
