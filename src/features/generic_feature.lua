local profiler = require("@src/utility/profiler");
local feature = {};

feature.__index = feature;

function feature.new(_, id, conn, func)
    local self = setmetatable({}, feature);
    self.id = id;
    self.conn = conn or Instance.new("BindableEvent").Event;
    self.func = func or function() end;
    self.update = self.func;

    if profiler and type(profiler.wrap_no_xpcall) == "function" then
        self.update = profiler.wrap_no_xpcall(id, self.func);
    end

    self.current_connection = nil;
    self.enabled = false;
    self.held = false;
    self.state = "idle";
    return self;
end

function feature:bind()
    if not self.conn then
        return;
    end

    if self.current_connection then
        return self.current_connection;
    end

    local connection = self.conn:Connect(function(...)
        if self.update then
            xpcall(self.update, warn, ...);
        end
    end);

    self.current_connection = connection;
    return connection;
end

function feature:unbind()
    if self.current_connection then
        pcall(function()
            self.current_connection:Disconnect();
        end);
        self.current_connection = nil;
    end
end

function feature:enable()
    self.enabled = true;
    self.state = "enabled";
    self:bind();
end

function feature:disable()
    self.enabled = false;
    self.state = "disabled";
    self:unbind();
end

return feature