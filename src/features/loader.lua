return {
    initialize = LPH_NO_VIRTUALIZE(function()
        getgenv().Feature = require(("@src/features/generic_feature"));

        local feature_count = 0;
        local bad_modules = {} do
            for _, item in list_modules("features/auto-parry/data/*") do
                bad_modules[item] = true;
            end

            for _, item in list_modules("features/auto-parry/data/effects/*") do
                bad_modules[item] = true;
            end

            bad_modules["features/auto-parry/handlers/animator-handler"] = true;
        end

        for _, module in list_modules("features/*/*") do
            if bad_modules[module] then
                continue;
            end

            feature_count += 1;

            local feature = require(module);
            if feature and typeof(feature) == "table" and feature.id then
                aztup.features[feature.id] = feature;
            end
        end;
    end);
}
