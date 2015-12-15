% Copyright (C) 2015  Omer Ishaq @ omer.ishaq@gmail.com

function [settings] = initialize_Settings()

    % the settings are divided into two groups; active and passive. 
    % Active ones are those which are actually used as constants some where
    % later in the application. 
    % Passive ones are those which are not used them selves but are useful
    % for the developer in knowing what settings were kept in mind when
    % developing the GUI controls.

    % passive settings come below
    settings.passive.interbutton_spacing_X = 3;
    settings.passive.interbutton_spacing_y = 5;
    
    % active settings come here
    settings.active.button_lengthX = 150;
    settings.active.button_lengthY = 25;
    
    settings.active.text_lengthX = 150;
    settings.active.text_lengthY = 25;
    
    settings.active.popup_lengthX = 150;
    settings.active.popup_lengthY = 25;
    
    settings.active.magnification = 0.6;
end

