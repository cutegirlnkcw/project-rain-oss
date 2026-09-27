local main_menu = {
    initialized = false,
};

function main_menu.initialize()
    if main_menu.initialized then
        return true;
    end

    main_menu.initialized = true;
    return true;
end

return main_menu;
