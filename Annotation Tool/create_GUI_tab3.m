% Copyright (C) 2015  Omer Ishaq @ omer.ishaq@gmail.com

function [ output_args ] = create_GUI_tab3 ( settings, hTabGroup )

global view;
global model;

tab3 = uitab(hTabGroup, 'title','Results');                     % create the tab title
position = view.position(3,:);                                  % read the position at index 3 

tab1_X_offset = 50;
tab1_Y_offset = 50;

filenames = load_FileNames();

ui_text1 = uicontrol(tab3, 'Style', 'text', 'String', 'Specify file name',...
    'Position', [100 430 150 25],'HorizontalAlignment','left');
ui_tex2 = uicontrol(tab3, 'Style', 'text', 'String', 'Specify user name',...
    'Position', [100 400 150 25],'HorizontalAlignment','left');
ui_dropdown_imgs = uicontrol(tab3, 'Style', 'popup', 'String', filenames, ...
    'Position', [240 430 200 25],'HorizontalAlignment','left', 'Callback', @execute_img_dropdown);
ui_dropdown_users = uicontrol(tab3, 'Style', 'popup', 'String', filenames, ...
    'Position', [240 400 200 25],'HorizontalAlignment','left', 'Callback', @execute_users_dropdown);

ui_text1 = uicontrol(tab3, 'Style', 'text', 'String', 'Specify decision boundary',...
    'Position', [100 370 200 25],'HorizontalAlignment','left');
ui_dropdown_fg = uicontrol(tab3, 'Style', 'popup', 'String', {'','40','50','60','70','80','90'}, ...
    'Position', [290 370 150 25],'HorizontalAlignment','left', 'Callback', @execute_fg_dropdown);

ui_text1 = uicontrol(tab3, 'Style', 'pushbutton', 'String', 'Gen Original Spots',...
    'Position', [130 340 150 25],'HorizontalAlignment','left', 'Callback', @execute_b1);
ui_text1 = uicontrol(tab3, 'Style', 'pushbutton', 'String', 'Gen Annotated Spots',...
    'Position', [290 340 150 25],'HorizontalAlignment','left', 'Callback', @execute_b2);

ui_text1 = uicontrol(tab3, 'Style', 'pushbutton', 'String', 'Gen Original Overlay',...
    'Position', [130 310 150 25],'HorizontalAlignment','left', 'Callback', @execute_b3);
ui_text1 = uicontrol(tab3, 'Style', 'pushbutton', 'String', 'Gen Annotated Overlay',...
    'Position', [290 310 150 25],'HorizontalAlignment','left', 'Callback', @execute_b4);

% ui_button_results = uicontrol(tab3, 'Style', 'pushbutton', 'String', 'Generate results',...
%     'Position', [240 300 200 25],'HorizontalAlignment','left', 'Callback', @execute_generate_results);

view.tab3.dropdown_imgs = ui_dropdown_imgs;
view.tab3.dropdown_users = ui_dropdown_users;
model.tab3.dropdown_fg = ui_dropdown_fg;

% bg = uibuttongroup(tab3,'Visible','off', 'Position',[.3 .58 .24 .1], 'SelectionChangedFcn',@bselection);
% r1 = uicontrol(bg,'Style',...
%                   'radiobutton',...
%                   'String','Order by key feature',...
%                   'Position',[10 30 140 30],...
%                   'HandleVisibility','off');
%               
% r2 = uicontrol(bg,'Style','radiobutton',...
%                   'String','Order by annotations',...
%                   'Position',[10 0 140 30],...
%                   'HandleVisibility','off');
% bg.Visible = 'on';
% view.tab3.radio = bg;

tab1_instructions{1} = 'HELP:';
tab1_instructions{2} = '---------';
tab1_instructions{3} = '';
tab1_instructions{4} = 'REQUIREMENTS:';
tab1_instructions{5} = ['1. Please make sure that before generating the spots or the overlays (using the bottom four buttons on this tab), ' ...
    'you have selected an image in the ANNOTATION tab (you do not need to actually do an annotation but just select the image) ' ...
    'because the paths for the images folder are extracted from the ANNOTATION tab.'];
tab1_instructions{6} = '';
tab1_instructions{7} = 'OPERATION:';
tab1_instructions{8} = '1. Specify the image for which you want the results in the first drop down control on this tab.';
tab1_instructions{9} = ['2. Specify the users whose annotations you want to view through the second drop down control on this tab. This will generate a plot ' ...
    'showing the total number of annotaions of each spot as well as the percentage of its positive annotations.'];
tab1_instructions{10} = '3. Specify the positive annotation threshold for selecting the foreground.';
tab1_instructions{11} = '4. Use any of the four buttons at the bottom to view the spots and their ovelay on the original image.';

ui_instructions = uicontrol(tab3, 'Style', 'text', 'String', tab1_instructions, 'Position', [20 10 550 280],'HorizontalAlignment','left');

end

function [filenames] = load_FileNames ()

    global model;
    global view;
    
    Records = load(model.strings.resultsfilename);
    Records = Records.Records;

    for i = 1:length(Records)
        CellArray{i} = getfield(Records(i), 'img');
    end
    
    CellArray = unique(CellArray, 'stable')';
    
    filenames = {''};
    
    if length(CellArray) > 1
        filenames = [filenames; CellArray(2:end)];
    end
    

end

function execute_img_dropdown(source, callbackdata)

    selected_Image = source.String(source.Value);

    global model;
    global view;
    
    Records = load(model.strings.resultsfilename);
    Records = Records.Records;
    
    for i = 1:length(Records)
        CellArray{i} = getfield(Records(i), 'img');
    end
    
    matched_Indices = strmatch(selected_Image, CellArray, 'exact');
    users_Array = Records(matched_Indices);
    
    clear CellArray;
    for i = 1:length(users_Array)
        CellArray{i} = getfield(users_Array(i), 'user');
    end
    
    CellArray = unique(CellArray, 'stable');
    
    user_Names = {'Select all users'};
    user_Names = [user_Names CellArray];
    
    view.tab3.dropdown_users.String = user_Names;

end

function execute_users_dropdown (source, callbackdata)

    global model;
    global view;
    
    data_Master = [];
    data_Annotated = [];
    
    if source.Value == 1 % case where all users are selected for an image
        % get img and all users and load all data.
        for i = 2:length(source.String)
            selected_User = view.tab3.dropdown_users.String(i);
            [return_Data_Annotation, return_Data_Master] = retrieve_Data_User (selected_User);
            data_Master = return_Data_Master;
            data_Annotated(i-1).anno = return_Data_Annotation;
        end
        
    else
        % get img and one selected user and load the data.
        selected_User = view.tab3.dropdown_users.String(view.tab3.dropdown_users.Value);
        [return_Data_Annotation, return_Data_Master] = retrieve_Data_User (selected_User);
        data_Master = return_Data_Master;
        data_Annotated(1).anno = return_Data_Annotation;
    end
    
    % By this stage in this function one has the master record called data_Master which contains the 'positive' data points 
    % for a given image and the data_Annotated which is an array of structures, where each structure contains an array of annotations 
    % for a given user, Ofcourse there may be multiple annotations per same user for the same datapoint.
    
    % Here call a function to overlay the annotation data ontop of the master data.
    [bins_Pos, bins_Neg] = overlay_Annotations_on_Master(data_Master, data_Annotated);
    view.tab3.bin_Pos = bins_Pos;
    view.tab3.bin_Neg = bins_Neg;
    
    %
    % Here the data has been generated now just generate the figure.
    % 
    
    % First generate the data
    bins_Count = bins_Pos + bins_Neg;
    data_Total = [];
    for i = 1:length(bins_Count)
        if bins_Count(i) == 0
            data_Total = [data_Total 0];
        else
            data_Total = [data_Total 100];
        end
    end
    data_Percentage = floor((bins_Pos ./ bins_Count)*100);
    data_Percentage(isnan(data_Percentage))=0;
    
    % Then display the data
    display_Results(data_Total, data_Percentage', bins_Count');

end

function [return_Data_Annotation, return_Data_Master] = retrieve_Data_User (selected_User)

    global model;
    global view;
    
    selected_Image = view.tab3.dropdown_imgs.String(view.tab3.dropdown_imgs.Value);
    
    % This is the part where the data for annotations for a 
    % particular user is being recovered from the 'Results' file. 
    %
    
    Records = load(model.strings.resultsfilename);
    Records = Records.Records;
    
    [m] = arrayfun(@(x) strcmp(x.user, selected_User) && strcmp(x.img, selected_Image), Records,'uniformoutput',false);
    selected_Indices = find(cell2mat(m)); % This returns all those indices which tested positive for the specified user and image
    return_Data_Annotation = Records(selected_Indices);
    
    % This is the part where the master record from the 'Data' folder is being 
    % recovered for a particular image.
    %
    
    Data = load(model.strings.datafilename);
    Data = Data.struct_data;
    
    [m] = arrayfun(@(x) strcmp(x.img, selected_Image) && x.ispeak == 1, Data,'uniformoutput',false);
    selected_Indices = find(cell2mat(m));
    return_Data_Master = Data(selected_Indices);
    
    [m] = arrayfun(@(x) strcmp(x.img, selected_Image), Data,'uniformoutput',false);
    selected_Indices = find(cell2mat(m));
    model.tab3.data_Master_Complete = Data(selected_Indices);
    
end

function [bins_Pos, bins_Neg] = overlay_Annotations_on_Master (data_Master, data_Annotated)

    % create a list equal to the length of the data_Master list.
    bins_Pos = zeros(length(data_Master),1);
    bins_Neg = zeros(length(data_Master),1);
    
    % first go over all users each elements of data annotated with the data Master
    for i = 1:length(data_Annotated)
        Anno = data_Annotated(i).anno;
        
        for j = 1:length(Anno)
            
            [m] = arrayfun(@(x) x.r == Anno(j).r && x.c == Anno(j).c, data_Master,'uniformoutput',false);
            index = find(cell2mat(m));
            if Anno(j).peak == 1
                bins_Pos(index(1)) = bins_Pos(index(1)) + 1;
            else
                bins_Neg(index(1)) = bins_Neg(index(1)) + 1;
            end
            
        end
        
    end
    

end

function bselection(source, callbackdata)
       

end

function [] = display_Results (data_Total, data_Percentage, bins_Count)

    %%%
    %data_Total = [100 100 0 100 100];
    %data_Percentage = [35 34 0 20 20];
    x = length(data_Percentage);
    x = 1:x;
    y = data_Total;
    
    %%%

    global model;
    global view;
    
    model.tab3.datalength = length(x);

    h = figure('Name','Results Plot Window','NumberTitle','off','Position', [100, 100, 1600, 400]);
    view.tab3.fighandle1 = h;
    hold on;
    hBar = bar(x, [data_Percentage; data_Total-data_Percentage]', 'stacked');
    set(hBar,{'FaceColor'},{'m';'w'}); 
    
    for i1=1:numel(y)
        if bins_Count(i1) > 0    
                text(x(i1),y(i1),num2str(bins_Count(i1),'%d'),...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom')
        end
    end
    ylim([1 110]);
    ylabel('Percentage of positive annotations');
    xlabel('Fluorescent spots');
    hold off;

end

function execute_fg_dropdown(source, callbackdata)

    global view;
    global model;
    
    bins_Pos = view.tab3.bin_Pos;
    bins_Neg = view.tab3.bin_Neg;
    
    %
    % Here the data has been generated now just generate the figure.
    % 
    
    if ~isempty(findobj(view.tab3.fighandle1))
        close(view.tab3.fighandle1);
        view.tab3.fighandle1 = 0;
    end
    
    % First generate the data
    bins_Count = bins_Pos + bins_Neg;
    data_Total = [];
    for i = 1:length(bins_Count)
        if bins_Count(i) == 0
            data_Total = [data_Total 0];
        else
            data_Total = [data_Total 100];
        end
    end
    data_Percentage = floor((bins_Pos ./ bins_Count)*100);
    data_Percentage(isnan(data_Percentage))=0;
    
    % Then display the data
    display_Results(data_Total, data_Percentage', bins_Count');
    
    
    
    
    
    if isempty(findobj(view.tab3.fighandle1))
        return;
    end

    base = 20;
    max_base = 0;
    
    if source.Value == 1
        % do nothing
    else
        max_base = base + source.Value * 10;
    end
    
    figure(view.tab3.fighandle1);
    hold on
    plot(0:model.tab3.datalength, ones(model.tab3.datalength+1, 1)*max_base, 'b');
    hold off

end

function execute_b1(source, callbackdata)

    global model;
    global view;
    
    selected_Image = view.tab3.dropdown_imgs.String(view.tab3.dropdown_imgs.Value);
    Data = model.tab3.data_Master_Complete;
    
    Image = imread([model.strings.imgfilepath view.tab3.dropdown_imgs.String{view.tab3.dropdown_imgs.Value}]);
    
    [m] = arrayfun(@(x) strcmp(x.img, selected_Image) && x.ispeak == 1, Data,'uniformoutput',false);
    selected_Indices = find(cell2mat(m));
    fg_Data = Data(selected_Indices);
  
    for k = 1:length(fg_Data)
        fgspots(k).r = getfield(fg_Data(k),'r');
        fgspots(k).c = getfield(fg_Data(k),'c');
    end
    
    
    [m] = arrayfun(@(x) strcmp(x.img, selected_Image) && x.ispeak == 0, Data,'uniformoutput',false);
    selected_Indices = find(cell2mat(m));
    bg_Data = Data(selected_Indices);

    for k = 1:length(bg_Data)
        bgspots(k).r = getfield(bg_Data(k),'r');
        bgspots(k).c = getfield(bg_Data(k),'c');
    end
    
    gridimage = createGridImage (fgspots, bgspots, Image);
    
    h = figure;
    hold on
    imagesc(gridimage)
    hold on
    axis image
    hold off

end

function execute_b2(source, callbackdata)

    global model;
    global view;
    
    selected_Image = view.tab3.dropdown_imgs.String(view.tab3.dropdown_imgs.Value);
    Data = model.tab3.data_Master_Complete;
    
    Image = imread([model.strings.imgfilepath view.tab3.dropdown_imgs.String{view.tab3.dropdown_imgs.Value}]);
    
    base = 20;
    max_base = 0;
    
    if model.tab3.dropdown_fg.Value == 1
        % do nothing
    else
        max_base = base + model.tab3.dropdown_fg.Value * 10;
    end
    
    bins_Pos = view.tab3.bin_Pos;
    bins_Neg = view.tab3.bin_Neg;
    
    bins_Count = bins_Pos + bins_Neg;
    data_Total = [];
    for i = 1:length(bins_Count)
        if bins_Count(i) == 0
            data_Total = [data_Total 0];
        else
            data_Total = [data_Total 100];
        end
    end
    data_Percentage = floor((bins_Pos ./ bins_Count)*100);
    data_Percentage(isnan(data_Percentage))=0;
    
    fgspots = [];
    bgspots = [];
    
    for i = 1:length(data_Percentage)
        if bins_Count(i) > 0 && data_Percentage(i) >= max_base
            spot.r = getfield(Data(i),'r');
            spot.c = getfield(Data(i),'c');
            fgspots = [fgspots spot];
            
        elseif bins_Count(i) > 0 && data_Percentage(i) < max_base
            
            spot.r = getfield(Data(i),'r');
            spot.c = getfield(Data(i),'c');
            bgspots = [bgspots spot];
        end
    end
    
    gridimage = createGridImage (fgspots, bgspots, Image);
    
    h = figure;
    hold on
    imagesc(gridimage)
    hold on
    axis image
    hold off

end

function execute_b3(source, callbackdata)

    global model;
    global view;
    
    Data = model.tab3.data_Master_Complete;
    
    Image = imread([model.strings.imgfilepath view.tab3.dropdown_imgs.String{view.tab3.dropdown_imgs.Value}]);
    
    h = figure;
    hold on
    imshow(Image)
    hold on
    axis image
    for i = 1:length(Data)
        if Data(i).ispeak == 1
            plot(Data(i).c, Data(i).r, 'r+');
        else
            plot(Data(i).c, Data(i).r, 'g+');
        end
    end
    hold off
    

end

function execute_b4(source, callbackdata)

    global model;
    global view;
    
    Data = model.tab3.data_Master_Complete;
    
    Image = imread([model.strings.imgfilepath view.tab3.dropdown_imgs.String{view.tab3.dropdown_imgs.Value}]);
    
    % Here is the code to get the value at which the decision is to be taken
    %
    
    base = 20;
    max_base = 0;
    
    if model.tab3.dropdown_fg.Value == 1
        % do nothing
    else
        max_base = base + model.tab3.dropdown_fg.Value * 10;
    end
    
    %
    % Here comes the plotting code
    %
    bins_Pos = view.tab3.bin_Pos;
    bins_Neg = view.tab3.bin_Neg;
    
    bins_Count = bins_Pos + bins_Neg;
    data_Total = [];
    for i = 1:length(bins_Count)
        if bins_Count(i) == 0
            data_Total = [data_Total 0];
        else
            data_Total = [data_Total 100];
        end
    end
    data_Percentage = floor((bins_Pos ./ bins_Count)*100);
    data_Percentage(isnan(data_Percentage))=0;
    
    h = figure;
    hold on
    imshow(Image)
    hold on
    axis image
    for i = 1:length(data_Percentage)
        if bins_Count(i) > 0 && data_Percentage(i) >= max_base
            plot(Data(i).c, Data(i).r, 'r+');
        elseif bins_Count(i) > 0 && data_Percentage(i) < max_base
            plot(Data(i).c, Data(i).r, 'g+');
        end
    end
    hold off

end





%
% Below is the dummy function in which I copied the GUI code from the last version of the Tab 3
% Incase it is required to revert back, just copy this code back to the create_GUI function

function [] = dummy_GUI_func ()

    % % code for adding the three controls and registering them in the view. ui_text = uicontrol(tab3, 'Style', 'text', 'String',
    % 'Specify file name','Position', [50 position(4)-100 settings.active.popup_lengthX+50
    % settings.active.popup_lengthY],'HorizontalAlignment','left'); ui_edit = uicontrol(tab3, 'Style', 'edit','Position', [270
    % position(4)-100 settings.active.popup_lengthX settings.active.popup_lengthY],'HorizontalAlignment','left'); ui_button =
    % uicontrol(tab3, 'Style', 'pushbutton', 'String', 'Specify file name','Position', [270 position(4)-130
    % settings.active.popup_lengthX settings.active.popup_lengthY],'HorizontalAlignment','left', 'Callback', @select_DataFile);
    % 
    % view.tab3.edit_file = ui_edit; view.tab3.button_select = ui_button;
    % 
    % % code for adding the drop down ui_text = uicontrol(tab3, 'Style', 'text', 'String', 'Select signals for
    % display','Position', [50 position(4)-170 settings.active.popup_lengthX
    % settings.active.popup_lengthY],'HorizontalAlignment','left'); ui_popup = uicontrol(tab3, 'Style', 'popup', 'String', {'
    % ','All signals','Only annotated spots'}, 'Position', [270 position(4)-170 settings.active.popup_lengthX
    % settings.active.popup_lengthY],'HorizontalAlignment','left'); view.tab3.popup_mode = ui_popup;
    % 
    % % code for adding the drop down for specifying the foreground-background threshold. ui_text = uicontrol(tab3, 'Style',
    % 'text', 'String', 'Select foreground threshold (%)','Position', [50 position(4)-230 settings.active.popup_lengthX+50
    % settings.active.popup_lengthY],'HorizontalAlignment','left'); ui_popup = uicontrol(tab3, 'Style', 'popup', 'String', {'
    % ','0.5','0.6','0.7','0.8'}, 'Position', [270 position(4)-230 settings.active.popup_lengthX
    % settings.active.popup_lengthY],'HorizontalAlignment','left','Callback', @update_Threshold); view.tab3.popup_threshold =
    % ui_popup;
    % 
    % ui_text = uicontrol(tab3, 'Style', 'radiobutton', 'String', 'Link displays','Position', [270 position(4)-260
    % settings.active.popup_lengthX settings.active.popup_lengthY],'HorizontalAlignment','right','Callback', @link_Displays);
    % view.tab3.radio_displays = ui_text;
    % 
    % % code for adding the two pannels p1 = uipanel(tab3, 'Title', 'Before annotation','Position', [.03 .03 .45 .65]); p2 =
    % uipanel(tab3, 'Title', 'After annotation','Position', [.49 .03 .45 .65]); view.tab3.panel_before = p1;
    % view.tab3.panel_after = p2;
    % 
    % % code for adding the four axes to the panels. % the first two axes display the spots before and after the manual
    % annotation % The next two axes display the spots before and after the manual annotation displayed on the image itself a1  =
    % axes('Parent', p1, 'Position',  [.30 .05 0.65 0.9], 'Box', 'off'); hold on; if model.flag.debug == 0; axis off; end; a11 =
    % axes('Parent', p1, 'Position',  [.02 .05 0.26 0.9], 'Box', 'off'); hold on; if model.flag.debug == 0; axis off; end;
    % 
    % a2  = axes('Parent', p2, 'Position',  [.30 .05 0.65 0.9], 'Box', 'off'); hold on; if model.flag.debug == 0; axis off; end;
    % a22 = axes('Parent', p2, 'Position',  [.02 .05 0.26 0.9], 'Box', 'off'); hold on; if model.flag.debug == 0; axis off; end;
    % 
    % % register the axes to the view.tab3 view.tab3.axis_before_image     =   a1; view.tab3.axis_before_spots     =   a11;
    % view.tab3.axis_after_image      =   a2; view.tab3.axis_after_spots      =   a22;
    % 
    % set(view.tab3.popup_threshold,'Value',3); set(view.tab3.popup_mode,'Value',3);

end
%
% End of the dummy function
%



% Here are the old functions which may or may not be useful

function select_DataFile(hObject, event, handles)

    global model;
    global view;
    
    [FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.png');
    model.tab3.strings.imgfilename = FILENAME;
    model.tab3.strings.imgfilepath = PATHNAME;

    model.tab3.image.input = imread([model.tab3.strings.imgfilepath model.tab3.strings.imgfilename]);
    set(view.tab3.edit_file,'String',[model.tab3.strings.imgfilename]);
    
    tempfilename = model.tab3.strings.imgfilename(1:end-4);
    model.tab3.struct.f_data = csvread([ model.tab3.strings.imgfilepath tempfilename '.csv'], 1, 0);
    
    % code comes here for loading all the data and making it work.
    %
    % this is important - there are multiple things which need to be done
    % one - load the image, already done in the line above
    % two - load the original data from the 'thunder storm' already done above
    % third - load the data from the results file, augmented to the data file if required.

    load_BeforeAnnotationData();
    load_AfterAnnotationData();
    
end

function load_BeforeAnnotationData ()

    global model;
    global view;
    
    % show the image in both the axes.
    imshow(model.tab3.image.input, 'Parent', view.tab3.axis_before_image);
    zoom on;
    
    % load the datapoints from the file
    Data = [];
    for k = 1:size(model.tab3.struct.f_data,1) 
        Data(k).peak = model.tab3.struct.f_data(k,4); 
        Data(k).r = round(model.tab3.struct.f_data(k,2)); 
        Data(k).c = round(model.tab3.struct.f_data(k,1)); 
    end
    
    % Data = nestedSortStruct(Data, 'peak');
    data_peak = vertcat(Data(1:end).peak);
    [data_peak I] = sort(data_peak);
    data_ordered = Data(I);
    Data = data_ordered;
    
    
    limit = round(length(Data) * model.nums.background_ratio);
    Data = fliplr(Data);
    
    fgspots = Data(1:length(Data)-limit);
    bgspots = Data((length(Data)-limit)+1:end);
    assert(length([fgspots bgspots]) == length(Data), 'Assertion failed in load_BeforeAnnotationData');
    
    axes(view.tab3.axis_before_image); hold on;
    for i = 1:length(fgspots)
        plot(fgspots(i).c, fgspots(i).r, 'r.');
    end
    for i = 1:length(bgspots)
        plot(bgspots(i).c, bgspots(i).r, 'g.');
    end
    
    gridimg_before_annotation = createGridImage(fgspots, bgspots, model.tab3.image.input);
    imshow(gridimg_before_annotation, [0 max(gridimg_before_annotation(:)) ], 'Parent', view.tab3.axis_before_spots, 'InitialMagnification', 'fit');

end

function [gridimg] = createGridImage (fgspots, bgspots, img_data)

    % img_data - Actual image on from which the spot cutouts are to be taken.  
    % fgspots - A list of r,c tuples for foreground spots in order of decreasing 'spottiness'.
    % bgspots - A list of r,c tuples for background spots in order of decreasing 'spottiness'.

    global model;

    grid_cols = 8;
    grid_spacing = 5;
    spotsize = 9;

    % sort on photon count in descending order.
    csv_data_peak = fgspots; num_peaks = length(csv_data_peak);
    csv_data_bkgd = bgspots;

    % first plot the foreground spots.
    num_rows = ceil(num_peaks/grid_cols);
    Image = [];
    counter = 1;
for i = 1:num_rows;
    
    Row = zeros(spotsize, spotsize*grid_cols + grid_spacing*(grid_cols-1));
    for j = 1:grid_cols
        
        patch = img_data(round(csv_data_peak(counter).r)-4:round(csv_data_peak(counter).r)+4, round(csv_data_peak(counter).c)-4:round(csv_data_peak(counter).c)+4);
        Row(:,((j-1)*spotsize)+((j-1)*grid_spacing)+1:  ((j-1)*spotsize)+((j-1)*grid_spacing)+spotsize) = patch;
        counter = counter + 1;
        
        if counter >= num_peaks; break; end;
        
    end
    Image = [Image; Row];
    Image = [Image; zeros(grid_spacing, spotsize*grid_cols + grid_spacing*(grid_cols-1))];
    
end

% Insert vertical spacing
Image = [Image; zeros(grid_spacing*2, spotsize*grid_cols + grid_spacing*(grid_cols-1))];    

% now plot the background spots
num_peaks = length(csv_data_bkgd);
num_rows = ceil(num_peaks/grid_cols);
counter = 1;
for i = 1:num_rows;
    
    Row = zeros(spotsize, spotsize*grid_cols + grid_spacing*(grid_cols-1));
    for j = 1:grid_cols
        
        patch = img_data(round(csv_data_bkgd(counter).r)-4:round(csv_data_bkgd(counter).r)+4, round(csv_data_bkgd(counter).c)-4:round(csv_data_bkgd(counter).c)+4);
        Row(:,((j-1)*spotsize)+((j-1)*grid_spacing)+1:  ((j-1)*spotsize)+((j-1)*grid_spacing)+spotsize) = patch;
        counter = counter + 1;
        
        if counter >= num_peaks; break; end;
        
    end
    Image = [Image; Row];
    Image = [Image; zeros(grid_spacing, spotsize*grid_cols + grid_spacing*(grid_cols-1))];
    
end

Image = [Image; zeros(grid_spacing-4, spotsize*grid_cols + grid_spacing*(grid_cols-1))];    

gridimg = Image;

end

function load_AfterAnnotationData ()

    global view;
    global model;

    display_mode = get(view.tab3.popup_mode,'Value');
    peak_threshold = get(view.tab3.popup_threshold,'Value');
    peak_threshold = model.tab3.threshold_values(peak_threshold);
    peak_threshold = cell2mat(peak_threshold);
    disp(['Peak threshold ' num2str(peak_threshold)]);
    
    if display_mode == 2    
        % case where all the signals are to be displayed.
        
    elseif display_mode == 3
        % case where only the graded signals are to be shown
        % load the data from Results.mat
        Records = load(model.strings.resultsfilename);
        Records = Records.Records;
        
        % Find the data which belong to the current image.
        struct_data = [];
        for i = 1:length(Records)
            if strcmp(Records(i).img, model.tab3.strings.imgfilename);
                struct_data = [struct_data Records(i)];
            end
        end
        
        % display the +ve peak data and display the -ve peak data.
        i = 1;
        while i <= length(struct_data)
            totalcount = 0;
            positcount = 0;
            negatcount = 0;
            j = 1;
            while j <= length(struct_data)
            	if struct_data(i).r == struct_data(j).r && struct_data(i).c == struct_data(j).c  
                    totalcount = totalcount + 1;
                    if struct_data(j).peak == 1
                        positcount = positcount + 1;
                    else
                        negatcount = negatcount + 1;
                    end
                    if i ~= j
                        struct_data(j) = [];
                    end
                end
                j = j + 1;
            end
            struct_data(i).posit = positcount;
            struct_data(i).total = totalcount;
            i = i+1;
        end
        
        imshow(model.tab3.image.input, 'Parent', view.tab3.axis_after_image);
        axes(view.tab3.axis_after_image); 
        
        % create the empty struct lists for holding the foreground and background spots.
        fgspots = [];
        bgspots = [];
        
        hold on;
        for i = 1:length(struct_data)
            if struct_data(i).posit/struct_data(i).total >= peak_threshold
                plot(struct_data(i).c, struct_data(i).r, 'r.')
                fgspots(i).r = struct_data(i).r;
                fgspots(i).c = struct_data(i).c;
            else
                plot(struct_data(i).c, struct_data(i).r, 'g.')
                bgspots(i).r = struct_data(i).r;
                bgspots(i).c = struct_data(i).c;
            end
        end
        
        empty_elems = arrayfun(@(s) isempty(s.r) & isempty(s.c), fgspots);
        fgspots(empty_elems) = [];
        
        empty_elems = arrayfun(@(s) isempty(s.r) & isempty(s.c), bgspots);
        bgspots(empty_elems) = [];
        
        gridimg_after_annotation = createGridImage(fgspots, bgspots, model.tab3.image.input);
        imshow(gridimg_after_annotation, [0 max(gridimg_after_annotation(:)) ], 'Parent', view.tab3.axis_after_spots, 'InitialMagnification', 'fit');
        
    else
        assert(8==9, 'Data selection mode on tab3 not properly set');
    end
    
    

end

function link_Displays(hObject, event, handles)

    global view;
    if get(view.tab3.radio_displays, 'Value')
        disp('on');
        linkaxes([view.tab3.axis_before_image view.tab3.axis_after_image], 'xy');
    else
        disp('off');
        linkaxes([view.tab3.axis_before_image view.tab3.axis_after_image], 'off');
    end

end

function update_Threshold (hObject, event, handles)

    global view;
    global model;
    
    peak_threshold = get(view.tab3.popup_threshold,'Value');
    peak_threshold = model.tab3.threshold_values(peak_threshold);
    peak_threshold = cell2mat(peak_threshold);
    
    if ~isnan(peak_threshold)
        load_AfterAnnotationData();
    end

end

% End of the old functions





