% Copyright (C) 2015  Omer Ishaq @ omer.ishaq@gmail.com

function [ output_args ] = create_GUI_tab2( settings, hTabGroup)
%UNTITLED Function for creating the single image tab.
%   Detailed explanation goes here

global view;

tab1_X_offset = 50;
tab1_Y_offset = 150;
tab1 = uitab(hTabGroup, 'title', 'Annotation');

position = view.position(2,:);

ui_slider = uicontrol(tab1, 'Style', 'slider','Position', [1260 230 20 300], 'Callback', @slidercallback, 'Min',1,'Max',50,'Value',41);
view.tab2.slider = ui_slider;

tab1_instructions{1} = 'HELP:';
tab1_instructions{2} = '';
tab1_instructions{2} = 'REQUIREMENTS:';
tab1_instructions{3} = ['1. Please make sure that before starting anotation, a user has been selected/saved at the USERS tab.'];
tab1_instructions{5} = '';
tab1_instructions{4} = 'OPERATION:';
tab1_instructions{5} = '1. Specify the image to be loaded by pressing the load image button at the top.';
tab1_instructions{6} = ['2. the image to be loaded should have a corresponding text file in the same directory' ...
        ' with the same name. The corresponding text file should contain the horizontal, vertical coordinates and the key feature.'];
tab1_instructions{7} = '3. Once the image is loaded the user is shown a pair of magnified spots selected according to the Forced choice method and the user is asked to select either one of the spots as the more likely spot.';
tab1_instructions{8} = '4. The annotation progress is shown in the text bar below the selection buttons.';
tab1_instructions{9} = '5. The magnified spots are also shown in context in the larger low magnification.';
tab1_instructions{10} = '6. The slider on the right can be used for adjusting the display range of the image windows.';

ui_instructions = uicontrol(tab1, 'Style', 'text', 'String', tab1_instructions, 'Position', [10 0 470 230],'HorizontalAlignment','left','FontSize',6.5);

% tab1_instructions = ['Welcome to the Forced choice image annotation tab. Specify the image to be loaded by pressing the' ...
%     ' load image button at the top, the image to be loaded should have a corresponding text file in the same directory' ...
%     ' with the same name. The corresponding text file should contain the horizontal, vertical coordinates and the key feature.' ...
%     ' Once the image is loaded the user is shown a pair of magnified spots selected according to the Forced choice method and the' ...
%     ' user is asked to select either one of the spots as the more likely spot. The annotation progress is shown in the text' ...
%     ' bar below the selection buttons. The magnified spots are also shown in context in the larger low magnification. In addition' ...
%     ' the slider on the right can be used for adjusting the display range of the image windows.'];
% 
% 
% ui_instructions = uicontrol(tab1, 'Style', 'text', 'String', tab1_instructions, 'Position', [60 120 400 200],'HorizontalAlignment','left');

ui_text = uicontrol(tab1, 'Style', 'text', 'String', 'Specify file name',...
    'Position', [0+tab1_X_offset (position(4)-tab1_Y_offset)+75 150 25],'HorizontalAlignment','left');
ui_edit_text = uicontrol(tab1, 'Style', 'edit',...
    'Position', [100+tab1_X_offset (position(4)-tab1_Y_offset)+75 settings.active.popup_lengthX+55 settings.active.popup_lengthY],'HorizontalAlignment','left');
view.tab2.edit_file = ui_edit_text;
align([ui_text ui_edit_text],'None','Middle');

% START - ABC - Code to add a drop down here --------------------------------------
ui_text_2 = uicontrol(tab1, 'Style', 'text', 'String', 'Select image step-length',...
    'Position', [0+tab1_X_offset (position(4)-tab1_Y_offset)+10 150 25],'HorizontalAlignment','left');
ui_dropdown = uicontrol(tab1, 'Style', 'popup', 'String', {'1','2','3','4','5','6','7','8','9','10'},...
    'Position', [185+tab1_X_offset (position(4)-tab1_Y_offset)+10 150 25],'HorizontalAlignment','left','Callback', @execute_dropdown);
% END - ABC -----------------------------------------------------------------------
ui_dropdown.Value = 1;

ui_button_select = uicontrol(tab1, 'Style','pushbutton', 'String','Load image',...
    'Position',[185+tab1_X_offset (position(4)-(tab1_Y_offset+30))+75 settings.active.button_lengthX, settings.active.button_lengthY], 'Callback', @select_DataFile);
align([ui_button_select ui_edit_text],'Right','None');
view.tab2.button_select = ui_button_select;

ui_button_red = uicontrol(tab1, 'Style','pushbutton', 'String','Red', 'BackgroundColor', [1 0 0],...
    'Position',[60+tab1_X_offset position(4)-(tab1_Y_offset+250), settings.active.button_lengthX, settings.active.button_lengthY], 'Callback', @execute_Red);
view.tab2.button_red = ui_button_red;

ui_button_green = uicontrol(tab1, 'Style','pushbutton', 'String','Green', 'BackgroundColor', [0 1 0],...
    'Position',[230+tab1_X_offset position(4)-(tab1_Y_offset+250), settings.active.button_lengthX, settings.active.button_lengthY], 'Callback', @execute_Green);
view.tab2.button_green = ui_button_green;

ui_progress = uicontrol(tab1, 'Style', 'text', 'String', 'Image 0 of 0',...
    'Position', [115+tab1_X_offset position(4)-(tab1_Y_offset+305), 200, 30],'HorizontalAlignment','Center');
view.tab2.text_progress = ui_progress;

% create the main axis here
ah = axes('Parent', tab1, 'Position',  [.335 0.17 settings.active.magnification+0.10 settings.active.magnification+0.10], 'Box', 'off');
view.tab2.axes_main = ah; 
hold on; axis off; axis equal;

% create the 'left red' minor axis here
ah1 = axes('Parent', tab1, 'Position',  [0.04 0.52 0.20 0.25], 'Box', 'off');
view.tab2.axes_red_left = ah1; 
hold on; axis off; axis equal;

% create the 'right green' minor axis here
ah2 = axes('Parent', tab1, 'Position',  [0.165 0.52 0.20 0.25], 'Box', 'off');
view.tab2.axes_green_right = ah2; 
hold on; axis off; axis equal;
 


end

function select_DataFile(hObject, event, handles)
    
    global model
    global view
    global timing_information;
    
    timing_information = 0;
  

    if model.flag.tab1_finished == 0
        msgbox('Please save user information in the previous tab before proceeeding for annotation.')
        return;
    end

    [FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.tif');
    model.strings.imgfilename = FILENAME;
    model.strings.imgfilepath = PATHNAME;

    try
        model.image.input = imread([model.strings.imgfilepath model.strings.imgfilename]);
        [indices] = find(model.image.input > 16000);
        model.image.input(indices) = 0;
        
    catch E % read failure if the user terminate the image loading procedure
        return;
    end
    set(view.tab2.edit_file,'String',[model.strings.imgfilename]);

    % START - ABC - Here comes in the code for tying the slider bar to the image depth
    img_info = imfinfo([model.strings.imgfilepath model.strings.imgfilename]);
    view.tab2.slider.Max = 2^(img_info.BitDepth)-1;
    view.tab2.slider.Max = 10000;
    view.tab2.slider.Min = 0;
    view.tab2.slider.Value = 10000;
    % STOP - ABC
    
    update_Tab2_MainAxes();
    
    tempfilename = model.strings.imgfilename(1:end-4);
    
 
    % This line of code is important since it loads the f_data structure
    model.struct.f_data = csvread([ model.strings.imgfilepath tempfilename '.csv'], 1, 0);
    
    % here comes the function to setup the initial code for single view
    setup_SingleView_Logic();
    set(view.tab2.button_green,'Enable','on');
    set(view.tab2.button_red,'Enable','on');
    
end

function update_Tab2_MainAxes()

    global model;
    global view;
    imshow(model.image.input, [view.tab2.slider.Min view.tab2.slider.Value], 'Parent', view.tab2.axes_main);
    drawnow
end

function update_Tab2_MinorAxes()

flag_normalized = 0; % either 0 or 1

global model;
global view;
 
axes(view.tab2.axes_main) 
curAxisProps=axis;
rectangle('Position',[model.struct.up.c-6, model.struct.up.r-6,13,13],'EdgeColor','r');
axis(curAxisProps)
drawnow

axes(view.tab2.axes_main) 
curAxisProps=axis;
rectangle('Position',[model.struct.down.c-6, model.struct.down.r-6,13,13],'EdgeColor','g');
axis(curAxisProps)
drawnow

if flag_normalized == 1
    [patch1, patch2] =  normalize_patches(model.image.input(model.struct.up.r-4:model.struct.up.r+4, model.struct.up.c-4:model.struct.up.c+4), ...
    model.image.input(model.struct.down.r-4:model.struct.down.r+4, model.struct.down.c-4:model.struct.down.c+4));

    imshow(patch1, [0 6], 'Parent', view.tab2.axes_red_left); 
    imshow(patch2, [0 6], 'Parent', view.tab2.axes_green_right);
elseif flag_normalized == 0
    imshow(model.image.input(model.struct.up.r-4:model.struct.up.r+4, model.struct.up.c-4:model.struct.up.c+4), [view.tab2.slider.Min view.tab2.slider.Value], 'Parent', view.tab2.axes_red_left); 
    imshow(model.image.input(model.struct.down.r-4:model.struct.down.r+4, model.struct.down.c-4:model.struct.down.c+4), [view.tab2.slider.Min view.tab2.slider.Value], 'Parent', view.tab2.axes_green_right); 
end    

drawnow
end

function [img_output] = firstproc_Image_Tab2(img_input) 

    global model;

    img_denoised = img_input; % directly taken from parameter since no denoising being done now
    img_double = double(img_denoised);

    Data = []; % This part needs to be changed so that the as many additional parameters can be incorporated as possible 
    
    for k = 1:size(model.struct.f_data,1)  %%% ...length(int_linearindices_high)
        % These three are ofcourse understandable with TWO elements from CSV
        Data(k).img = model.strings.imgfilename;
        Data(k).r = round(model.struct.f_data(k,2) + 0.5); %%% ... int_R_high(k);
        Data(k).c = round(model.struct.f_data(k,1) + 0.5); %%% ... int_C_high(k);
        
        % ISPEAK is not loaded from any csv file
        Data(k).ispeak = 1;
        
        % The THIRD element from CSV, i.e., "THE KEY FEATURE" is loaded into the PEAK attribute
        try
            Data(k).peak = (model.struct.f_data(k,4)*.4) / (pi*(model.struct.f_data(k,3)^2));  %%% ... sum(img_grade_high(int_R_high(k), int_C_high(k), :));
        catch E
            Data(k).peak = 0;
            Data(k).sigma = 0;
            Data(k).std = 0;
            Data(k).uncertainty = 0;
            Data(k).intensity = 0;
        end
        
        try
            Data(k).sigma = model.struct.f_data(k,6);
        catch E
            Data(k).sigma = 0;
            Data(k).std = 0;
            Data(k).uncertainty = 0;
            Data(k).intensity = 0;
        end
            
        try    
            Data(k).std = model.struct.f_data(k,4);
        catch E
            Data(k).std = 0;
            Data(k).uncertainty = 0;
            Data(k).intensity = 0;
        end
        
        try
            Data(k).uncertainty = model.struct.f_data(k,5);
        catch E
            Data(k).uncertainty = 0;
            Data(k).intensity = 0;
        end
        
        try
            Data(k).intensity = model.struct.f_data(k,7); %%% ... sum(sum(img_double(int_R_high(k)-2:int_R_high(k)+2, int_C_high(k)-2:int_C_high(k)+2)/54));
        catch E
            Data(k).intensity = 0;
        end
        
        Data(k).negintensity = -1*Data(k).intensity;

    end

% model.struct.data = nestedSortStruct(Data, 'peak');
data_peak = vertcat(Data(1:end).peak);
[data_peak I] = sort(data_peak);
data_ordered = Data(I);
model.struct.data = data_ordered;
%model.struct.data = fliplr(model.struct.data);

limit = round(length(model.struct.data) * model.nums.background_ratio);

% Code below is used to set a certain percentage of the fluorophore's
% ispeak criterion to 0 which means they are being allocated to the
% background.
for k = 1:limit
    model.struct.data(k).ispeak = 0;
end

model.nums.samples = length(model.struct.data)-limit;
update_Counter();

% Reflip the data so that the data is ordered in decreasing order of the
% 'peak' field of the 'Data' structure.

model.struct.data = fliplr(model.struct.data);
img_output = model.struct.data;

end

function flipviews_Tab2(struct_data)

        global model;

        % ... Now let the user perform the forced choice experiments.
        [struct_H, struct_L] = twoafc_SingleView(struct_data);

        % Flip the data if required
        if rand > 0.5
            if model.flag.debug == 1; disp('UP'); end;
            model.struct.up = struct_H;
            model.struct.down = struct_L;
        else
            if model.flag.debug == 1; disp('DOWN'); end;
            model.struct.up = struct_L;
            model.struct.down = struct_H;
        end

end

function [struct_H, struct_L] = twoafc_SingleView(struct_input) % substitutes the performforcedchoice function in the original app 

global model;

increment_Counter();

% Perform forced choice by ...

% ... Randomly select a high SNR datapoint.
[int_matches] = find([struct_input.ispeak] == 1);
struct_highSNR = struct_input(int_matches);

lenH = length(int_matches); 

model.nums.samples = lenH;

ratioH = 1; %%% ... ratioH = lenH / int_samples;
indicesH = floor([1 : ratioH : lenH]);

int_temp1 = indicesH(model.nums.samplescounter);
struct_H = struct_highSNR(int_temp1);


% ... Randomly select a low SNR datapoint.
[int_matches] = find([struct_input.ispeak] == 0);
struct_lowSNR = struct_input(int_matches);

lenL = length(int_matches); 

%%% Use the code below if you want to select the signals from the
%%% background determiniistically, i.e., similar to the way they are
%%% selected for the foreground.
% ratioL = lenL / int_samples;
% indicesL = floor([1 : ratioL : lenL]);
% int_temp2 = indicesL(int_samplescounter);

randnum = floor(rand * lenL);
if model.flag.debug == 1;  disp(['Low Index = ' num2str(randnum)]); end
if randnum == 0
    struct_L = struct_lowSNR(1);
else
    try
    struct_L = struct_lowSNR(randnum);
    catch 
        a = 10;
    end
end

% Increment the counter
% model.nums.samplescounter = model.nums.samplescounter + 1;

end

function loadNeighborImages()

end

function setup_SingleView_Logic()

    global model;

    % Load the Data file
if exist(model.strings.datafilename, 'file')
    % Data file exists, therefore ...
    
    % ... Load all the data.
    temp_data = load(model.strings.datafilename);
    
    % ... Find if the image has already been added to the database.
    matchf = 0;
    for i = 1:length(temp_data.struct_data)
        if strcmp(temp_data.struct_data(i).img, model.strings.imgfilename);
            matchf = 1;
            break
        end
    end
    
    % ...If match found
    if matchf == 1
        struct_data = [];
        for i = 1:length(temp_data.struct_data)
            if strcmp(temp_data.struct_data(i).img, model.strings.imgfilename);
                struct_data = [struct_data temp_data.struct_data(i)];
            end
        end
        
        model.struct.data = struct_data;
        
        % code added so that the progress counter remains working properly
        % in the mode where a data.mat file exists and the image being
        % processed is already in the database.
        limit = round(length(model.struct.data) * model.nums.background_ratio);
        model.nums.samples = length(model.struct.data)-limit;
        update_Counter();
        
        flipviews_Tab2(struct_data)
        update_Tab2_MinorAxes();

    end
        
    % ... If match not found... process the image for the first time
    if matchf == 0
        [img_output] = firstproc_Image_Tab2(model.image.input);
        struct_data = img_output;

        flipviews_Tab2(struct_data)
        update_Tab2_MinorAxes();

        temp_data = load(model.strings.datafilename);
        struct_data = [temp_data.struct_data struct_data];
        save(model.strings.datafilename, 'struct_data');
    end
    
else    
    % Part of code to be executed if no Data.mat database exists...
    
    % ... Process the img for the first time
    [img_output] = firstproc_Image_Tab2(model.image.input);
    
    % ... Copy the data
    struct_data = img_output;
    save(model.strings.datafilename, 'struct_data');
    
    flipviews_Tab2(struct_data)
    update_Tab2_MinorAxes();
    
end % end of the if block

% load the next and the previous images
loadNeighborImages()

% after loading these images enable the button for navigating to these
% images
% set(handles.btnNextImage,'Enable','on');
% set(handles.btnPreviousImage,'Enable','on');

end

function execute_Red(hObject, event, handles) 

global model;
global timing_information;

if timing_information == 0
    timing_information = tic;
    tim = 0;
else
    tim = toc(timing_information);
end

% global private_handles;
% private_handles = handles;

struct_record.img = model.strings.imgfilename;   
struct_record.user = model.strings.username;

% Decode this part figure out how this works

if model.struct.up.ispeak == 1
    struct_record.peak = 1;
    struct_record.r = model.struct.up.r;
    struct_record.c = model.struct.up.c;
else
    struct_record.peak = 0;
    struct_record.r = model.struct.down.r;
    struct_record.c = model.struct.down.c;
end

Records = load(model.strings.resultsfilename);
Records = Records.Records;
ilength = length(Records);
Records(ilength + 1).peak = struct_record.peak;
Records(ilength + 1).r = struct_record.r;
Records(ilength + 1).c = struct_record.c;
Records(ilength + 1).user = struct_record.user;
Records(ilength + 1).img = struct_record.img;
Records(ilength + 1).time = tim;
save(model.strings.resultsfilename, 'Records');

loadnext();

timing_information = tic;

end

function execute_Green(hObject, event, handles)

global model;
global timing_information;

if timing_information == 0
    timing_information = tic;
    tim = 0;
else
    tim = toc(timing_information);
end

% global private_handles;
% private_handles = handles;

struct_record.img = model.strings.imgfilename;   
struct_record.user = model.strings.username;

if model.struct.down.ispeak == 1
    struct_record.peak = 1;
    struct_record.r = model.struct.down.r;
    struct_record.c = model.struct.down.c;
else
    struct_record.peak = 0;
    struct_record.r = model.struct.up.r;
    struct_record.c = model.struct.up.c;
end

Records = load(model.strings.resultsfilename);
Records = Records.Records;
ilength = length(Records);
Records(ilength + 1).peak = struct_record.peak;
Records(ilength + 1).r = struct_record.r;
Records(ilength + 1).c = struct_record.c;
Records(ilength + 1).user = struct_record.user;
Records(ilength + 1).img = struct_record.img;
Records(ilength + 1).time = tim;
save(model.strings.resultsfilename, 'Records');

loadnext();   

timing_information = tic;

end

function loadnext()

    global model;
    
    if model.nums.incrementvalue + model.nums.samplescounter > model.nums.samples
        msgbox(['The next index ' num2str(model.nums.incrementvalue + model.nums.samplescounter) ' exceeds the total number ' ...
            num2str(model.nums.samples) ' of valid images, please choose another image for annotation.']) 
        disableAllControls();
        return;
    end
       
    % ... Now let the user perform the forced choice experiments.
    [struct_H, struct_L] = twoafc_SingleView(model.struct.data);
    
    if model.nums.samplescounter >= model.nums.samples
        disableAllControls();
        return
    end
    
    % Flip the data if required
    if rand > 0.5
        if model.flag.debug == 1; disp('UP'); end;
        model.struct.up = struct_H;
        model.struct.down = struct_L;
    else
        if model.flag.debug == 1; disp('DOWN'); end;
        model.struct.up = struct_L;
        model.struct.down = struct_H;
    end
    
    update_Tab2_MainAxes();  % replaces updateMainScreen(handles);
    update_Tab2_MinorAxes(); % replaces updatescreens(handles);

end

function disableAllControls()

    global model;
    global view;
    global t;


display('Debug: In disable controls function');
set(view.tab2.edit_file,'String','');
set(view.tab2.button_green,'Enable','off');
set(view.tab2.button_red,'Enable','off');
msgbox('Session finsihed for this image, please select another image','modal');

% Insert code here to flush or clear the model.
create_Model(); % Resets the model to its original value

        model.strings.username = view.tab1.edit_user.String;
        model.nums.background_ratio = str2num(view.tab1.popup_mode.String);
        assert(~isempty(model.strings.username));
        view.tab1.edit_user.Enable = 'off';
        view.tab1.button_save.Enable = 'off';
        view.tab1.popup_mode.Enable = 'off';
        t.Enable = 'off';
        model.flag.tab1_finished = 1;

end

function increment_Counter()
    global model;
    global view;
    
    %
    % code commneted out below so that the now the images can be incremented by the variable step-length
    %
    % model.nums.samplescounter = model.nums.samplescounter + 1;
    model.nums.samplescounter = model.nums.samplescounter + model.nums.incrementvalue;
    
    set(view.tab2.text_progress, 'string', ['Image ' num2str(model.nums.samplescounter) ' of ' num2str(model.nums.samples)]);
end

function update_Counter()
    global model;
    global view;
    set(view.tab2.text_progress, 'string', ['Image ' num2str(model.nums.samplescounter) ' of ' num2str(model.nums.samples)]);
end
 
function slidercallback(source, callbackdata)

    % There are three important things here
    % min, max and the value properties
    % num2str(source.Value)
    
    update_Tab2_MainAxes();
    update_Tab2_MinorAxes();
end

function execute_dropdown(source,callbackdata)
    
    global model; 

    val = source.Value;
    model.nums.incrementvalue = val;
    
end

function [patch1, patch2] = normalize_patches(img1, img2)

    mean1   = mean(img1(:)); 
    mean2   = mean(img2(:));
    
    img1    = double (img1);
    img2    = double (img2);
    
    std1    = std(img1(:));
    std2    = std(img2(:));
    
    img1 = img1 - mean1;
    img2 = img2 - mean2;
    
    img1 = img1/std1;
    img2 = img2/std2;
    
    patch1 = img1 - min(img1(:));
    patch2 = img2 - min(img2(:));
    
    patch1 = uint16(patch1);
    patch2 = uint16(patch2);

end




