% Copyright (C) 2015  Omer Ishaq @ omer.ishaq@gmail.com

function [ column ] = find_TabPosition( hObject )
%UNTITLED2 Summary of this function goes here
%   hObject - The tab parent object

    column = -1;
    for i=1:length(hObject.Children)
        if strcmp (hObject.Children(i).Title, hObject.SelectedTab.Title)
            column = i;
            break;
        end
    end
    assert(column >= 0);


end

