% Copyright (C) 2015  Omer Ishaq @ omer.ishaq@gmail.com

function [hTabGroup] = create_GUI(settings)

global view;

% create the tabbed interface
f = figure('MenuBar','None','Name','SpotObserver', 'NumberTitle', 'off', 'Resize', 'off', 'Position', view.position(1,:));       % create a figure without the default menu
hTabGroup = uitabgroup('SelectionChangedFcn',@select_Tab); 
drawnow;    % create a tab group

view.tabgroup = hTabGroup;

% create the first tab
create_GUI_tab1( settings, hTabGroup);
create_GUI_tab2( settings, hTabGroup);
create_GUI_tab3( settings, hTabGroup);
create_GUI_tab4( settings, hTabGroup);

%%tab4 = uitab(hTabGroup, 'title','Data Export');

end

function select_Tab(hObject, event, handles)

    global view;
    column = find_TabPosition(hObject);
    set(gcf, 'Position', view.position(column,:));
    
    if column == 3 || column == 4
        view.tab2.button_green.Enable = 'off';
        view.tab2.button_red.Enable = 'off';
        view.tab2.button_select.Enable = 'off';
    end
  
end

