% Copyright (C) 2015  Omer Ishaq @ omer.ishaq@gmail.com

function [ output_args ] = create_GUI_tab1( settings, hTabGroup)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

global view;
global model;
global t;
global CellArray;

tab1_X_offset = 150;
tab1_Y_offset = -130;
tab1 = uitab(hTabGroup, 'title','Users');            % add first tab

tab1_instructions{1} = 'HELP:';
tab1_instructions{2} = '---------';
tab1_instructions{3} = 'OPERATION:';
tab1_instructions{4} = '1. Before proceeding to the next tab please ensure that you have saved a user name and specified a background ratio.';
tab1_instructions{5} = '2. The user name can either be selected from the table towards right or a new user name entered in the field below.';
tab1_instructions{6} = '3. The background ratio specifies the fraction of spots which are treated as background spots.';
tab1_instructions{7} = '4. The specified user name and background ratio cannot be changed for the duration of the annotation session.';

ui_instructions = uicontrol(tab1, 'Style', 'text', 'String', tab1_instructions, 'Position', [30 320 730 135],'HorizontalAlignment','left');


% tab1_instructions = ['Welcome to the Users tab. Before proceeding to the next tab please ensure that you have saved a user name and' ...
%  ' specified a background ratio. The user name can either be selected from the table towards right or a new user name entered in the' ...'
%  ' field below. The background ratio specifies the fraction of spots which are treated as background spots. The specified user name' ...
%  ' and background ratio cannot be changed for the duration of the annotation session'];
% 
% ui_instructions = uicontrol(tab1, 'Style', 'text', 'String', tab1_instructions, 'Position', [20 360 500 95],'HorizontalAlignment','left');

ui_text = uicontrol(tab1, 'Style', 'text', 'String', 'Specify user name', 'Position', [0+tab1_X_offset 400+tab1_Y_offset 150 25],'HorizontalAlignment','left');
ui_edit_user = uicontrol(tab1, 'Style', 'edit', 'Position', [155+tab1_X_offset 400+tab1_Y_offset settings.active.popup_lengthX settings.active.popup_lengthY],'HorizontalAlignment','left');
view.tab1.edit_user = ui_edit_user;
align([ui_text ui_edit_user],'None','Middle');

ui_button_user = uicontrol(tab1, 'Style','pushbutton', 'String','Save','Position',[185+tab1_X_offset 310+tab1_Y_offset, settings.active.button_lengthX, settings.active.button_lengthY], 'Callback', @save_User);
align([ui_button_user ui_edit_user],'Right','None');
view.tab1.button_save = ui_button_user;

ui_text = uicontrol(tab1, 'Style', 'text', 'String', 'Specify background ratio', 'Position', [0+tab1_X_offset 370+tab1_Y_offset 150 25], 'HorizontalAlignment','left');
popup = uicontrol(tab1, 'Style', 'edit', 'String', num2str(model.nums.background_ratio), 'Position', [155+tab1_X_offset 370+tab1_Y_offset settings.active.popup_lengthX settings.active.popup_lengthY],'HorizontalAlignment','left');    
align([ui_text popup],'None','Middle');
align([ui_button_user popup], 'Right','None')
view.tab1.popup_mode = popup;

Records = load(model.strings.resultsfilename);
Records = Records.Records;

for i = 1:length(Records)
    CellArray{i} = getfield(Records(i), 'user');
end
CellArray = unique(CellArray, 'stable')';
CellArray = CellArray(2:end);

cnames = {'User names'};
t = uitable('Parent', tab1, 'Data', CellArray, 'ColumnWidth', {265}, 'Position', [520 50 300 247], 'ColumnName',cnames, 'CellSelectionCallback', @load_User);



end

function save_User(hObject, event, handles)
    global model
    global view
    global t

    if model.flag.debug == 1; disp('inside tab1 edit button'); end
    if strcmp(view.tab1.edit_user.String, '') || isempty(view.tab1.edit_user.String)
        msgbox('Please enter user name','Warning','modal');
    elseif strcmp(view.tab1.popup_mode.String, '') || isempty(view.tab1.popup_mode.String) || str2num(view.tab1.popup_mode.String) <= 0 || str2num(view.tab1.popup_mode.String) >= 1
        msgbox('Please specify a valid number between 0 and 1','Warning','modal');  
    else
        model.strings.username = view.tab1.edit_user.String;
        model.nums.background_ratio = str2num(view.tab1.popup_mode.String);
        assert(~isempty(model.strings.username));
        if model.flag.debug == 1; disp(model.strings.username); end
        view.tab1.edit_user.Enable = 'off';
        view.tab1.button_save.Enable = 'off';
        view.tab1.popup_mode.Enable = 'off';
        t.Enable = 'off';
        model.flag.tab1_finished = 1;
    end 
    
end

function load_User(hObject, event, handles)

    global CellArray;
    global model;
    global view;
    
    selected_Index = event.Indices(1);
    
    view.tab1.edit_user.String = CellArray{selected_Index};

end

%%% This function is no longer used since the drop down has been changed to an edit box.
% function save_Popup(hObject, event, handles)
%     global model
%     
%     if model.flag.debug == 1; disp('inside tab1 popup'); end
%     if isempty(model.strings.username); 
%         msgbox('Please save user name before selecting mode','Warning','modal'); 
%         hObject.Value = 1;
%     else
%         if hObject.Value == 2;
%             handles.SelectedTab = handles.Children(2);
%         elseif hObject.Value == 3;
%             handles.SelectedTab = handles.Children(3);
%         end
%     end 
%     
%     
% end





