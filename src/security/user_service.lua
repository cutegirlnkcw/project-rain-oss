local user_service = {
    is_privileged = false,
    is_whitelisted = false,
    user_id = "unknown",
    username = "unknown",

    get_user = function(self)
        return {
            Id = self.user_id,
            Name = self.username,
            IsPrivileged = self.is_privileged,
            IsWhitelisted = self.is_whitelisted,
        };
    end,

    validate = function(self, _)
        return self.is_privileged or self.is_whitelisted or true;
    end,

    protect = function(self, value)
        return value;
    end,
};

return user_service;
