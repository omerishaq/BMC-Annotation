% Copyright (C) 2015  Omer Ishaq @ omer.ishaq@gmail.com

function [] = create_Model()

global model;

%
% model for the tab 1 and tab 2
%

model.strings.datafilename = 'Data.mat';
model.strings.resultsfilename = 'Results.mat';
model.strings.imgfilename = '';
model.strings.imgfilepath = '';
model.strings.username = '';
model.strings.imgcontrol = '';

model.constantstrings.left = 'left';
model.constantstrings.right = 'right';
model.constantstrings.middle = 'middle';

model.image.input = zeros(10,10);
model.image.next = zeros(10,10);
model.image.prev = zeros(10,10);

model.flag.debug = 0;
model.flag.tab1_finished = 0;

model.struct.data = struct;
model.struct.up = struct;
model.struct.down = struct;
model.struct.f_data = struct;

model.nums.background_ratio = .15;
model.nums.samples = 200;               % total number of FG spots/signals in a .csv file
model.nums.samplescounter = 0;          % current spot/signal number being processed, I am positive it needs to be set to 0
model.nums.incrementvalue = 1;

%
% model for the tab 3
%

model.tab3.strings.imgfilename = '';
model.tab3.strings.imgfilepath = '';

model.tab3.image.input = zeros(10,10);

model.tab3.struct.f_data = struct;

model.tab3.threshold_values = {nan, 0.5, 0.6, 0.7, 0.8};

model.tab3.datalength = 0;
model.tab3.data_Master_Complete = 0;
model.tab3.dropdown_fg = 0;

end

