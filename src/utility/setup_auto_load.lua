local auto_load = {
    enabled = true,
    initialized = false,

    initialize = function(self)
        if self.initialized then
            return true;
        end

        self.initialized = true;
        return true;
    end,

    start = function(self)
        return self:initialize();
    end,
};

return auto_load;
