% Copyright (C) 2015  Omer Ishaq @ omer.ishaq@gmail.com

function [ output_args ] = create_GUI_tab4 ( settings, hTabGroup )

global view;
global model;

tab4 = uitab(hTabGroup, 'title','Machine Learning Data Export');                     % create the tab title
position = view.position(4,:);  

ui_text1 = uicontrol(tab4, 'Style', 'pushbutton', 'String', 'Export Data',...
    'Position', [120 250 150 25],'HorizontalAlignment','left', 'Callback', @execute_export);

tab1_instructions{1} = 'HELP:';
tab1_instructions{2} = '---------';
tab1_instructions{3} = '';
tab1_instructions{4} = 'REQUIREMENTS:';
tab1_instructions{5} = ['1. Please make sure that the first three controls (image, user, threshold) of the RESULTS tab have been selected, ' ...
    'since the data to be exported corresponds to the image, user and threshold selected at the RESULTS tab.'];
tab1_instructions{6} = '';
tab1_instructions{7} = 'OPERATION:';
tab1_instructions{8} = '1. Press the export button, located above, to generate a comma separated file with the export data.';

ui_instructions = uicontrol(tab4, 'Style', 'text', 'String', tab1_instructions, 'Position', [10 10 385 200],'HorizontalAlignment','left');

end

function execute_export(source, callbackdata)

    global model;
    global view;
    % Here comes the code for exporting the data to a csv file
    % underneath I will list the data to be exported 
    % img spot.r spot.c 5_features 49_pixel_values num_annotations percentage_foreground class list_user_annotation
    
    % Filename
    filename = [datestr(datetime) '.txt'];
    filename = strrep(filename, ':', '');
    filename = strrep(filename, '-', '');
    fid = fopen(filename,'w');
    
    % First get the image, user and threshold
    [img, users, threshold] = get_img_users_threshold ();
    
    % Call a function to write the header of the data file
    %
    
    write_header(fid);
    
    % Now acquire the spot positions and the five features and start writing to the file
    % - The best way to do that would be through a for loop which loops over every spot in the image file
    %
    % For writing use the following convention
    % - for the first line          dlmwrite('test.txt', [1 2 3], 'newline', 'pc');
    % - for the next lines          dlmwrite('test.txt', [1 2 3], '-append', 'newline', 'pc');
    
    [m] = arrayfun(@(x) x.ispeak == 1 && strcmp(x.img, img), model.tab3.data_Master_Complete,'uniformoutput',false);
    lenN = length(find(cell2mat(m)));
    
    for k = 1:lenN
            
        fprintf(fid,'%s,', img);                                                % write image name
        fprintf(fid,'%d,', model.tab3.data_Master_Complete(k).r);               % write spot.r
        fprintf(fid,'%d,', model.tab3.data_Master_Complete(k).c);               % write spot.c
        
        fprintf(fid,'%.2f,', model.tab3.data_Master_Complete(k).peak);            % write feature1
        fprintf(fid,'%.2f,', model.tab3.data_Master_Complete(k).sigma);           % write f2
        fprintf(fid,'%.2f,', model.tab3.data_Master_Complete(k).std);             % write f3
        fprintf(fid,'%.2f,', model.tab3.data_Master_Complete(k).uncertainty);     % write f4
        fprintf(fid,'%.2f,', model.tab3.data_Master_Complete(k).intensity);       % write f5
        
        % write the 49 pixel values
        Image = imread([model.strings.imgfilepath view.tab3.dropdown_imgs.String{view.tab3.dropdown_imgs.Value}]);
        for r = -4:1:4
            for c = -4:1:4
            
            value = Image(model.tab3.data_Master_Complete(k).r + r, model.tab3.data_Master_Complete(k).c + c);
            fprintf(fid,'%d,', value); 
                
            end
        end
        
        % write the remaining values
        %
        
        Records = load(model.strings.resultsfilename);
        Records = Records.Records;
        
        % num annotations
        [m] = arrayfun(@(x) model.tab3.data_Master_Complete(k).r == x.r && model.tab3.data_Master_Complete(k).c == x.c && strcmp(x.img, img), ...
            Records,'uniformoutput',false);
        num_annotations = length(find(cell2mat(m)));
        fprintf(fid,'%d,', num_annotations);
        
        % num percentage
        if num_annotations > 0 
            [m] = arrayfun(@(x) model.tab3.data_Master_Complete(k).r == x.r && model.tab3.data_Master_Complete(k).c == x.c && strcmp(x.img, img) && x.peak == 1, ...
                Records,'uniformoutput',false);
            num_positive = length(find(cell2mat(m)));
            fprintf(fid,'%.2f,', 100*(num_positive/num_annotations));
        else
            fprintf(fid,'%.2f,', 0);
        end
        
        % class
        % There are two cases here...
        % First, the data has annotations
        % Second, the data has no annotations
        if num_annotations > 0 
            % compute its class by threshold
            level = 100*(num_positive/num_annotations);
            if level >= threshold
                fprintf(fid,'%s,', 'Foreground');
            else
                fprintf(fid,'%s,', 'Background');
            end
        else
            % compute its class by closest annotated neighbor
            query_value = model.tab3.data_Master_Complete(k).peak;
            [indices_annotated] = generate_overlay (img, lenN);
            data_annotated = horzcat(model.tab3.data_Master_Complete(indices_annotated).peak);
                        
            [c index] = min(abs(data_annotated-query_value));
            closestValues = data_annotated(index);
            
            actual_index = indices_annotated(index);
            
            [m] = arrayfun(@(x) model.tab3.data_Master_Complete(actual_index).r == x.r && model.tab3.data_Master_Complete(actual_index).c == x.c && strcmp(x.img, img), ...
            Records,'uniformoutput',false);
            num_annotations_temp = length(find(cell2mat(m)));

            % num percentage
            [m] = arrayfun(@(x) model.tab3.data_Master_Complete(actual_index).r == x.r && model.tab3.data_Master_Complete(actual_index).c == x.c && strcmp(x.img, img) && x.peak == 1, ...
                Records,'uniformoutput',false);
            num_positive_temp = length(find(cell2mat(m)));

            level = 100*(num_positive_temp/num_annotations_temp);
            if level >= threshold
                fprintf(fid,'%s,', 'Foreground');
            else
                fprintf(fid,'%s,', 'Background');
            end
           
        end
        
        % Here is the part where I do the following
        % - write the annotations for this particular spot.
        %
        [m] = arrayfun(@(x) model.tab3.data_Master_Complete(k).r == x.r && model.tab3.data_Master_Complete(k).c == x.c && strcmp(x.img, img), ...
        Records,'uniformoutput',false);
        indices = find(cell2mat(m));
        Annotation_Records = Records(indices);
        write_str = [];
        for kk = 1:length(Annotation_Records)
            write_str = [write_str Annotation_Records(kk).user ':' num2str(Annotation_Records(kk).peak) ';'];
        end
        fprintf(fid,'%s,', write_str);
        
        % write next line
        fprintf(fid,'\n');
    end
    
    fclose('all');
    msgbox('Export fisnished!')
end

function [img, users, threshold] = get_img_users_threshold ()

    global model;
    global view;
    
    img = model.tab3.data_Master_Complete(1).img; % Got the image
    
    if view.tab3.dropdown_users.Value == 1 % Got the users
        users = 'ALL';
    else
        users = view.tab3.dropdown_users.String(view.tab3.dropdown_users.Value);
    end
    
    base = 20; % Got the threshold
    threshold = 0;
    
    if model.tab3.dropdown_fg.Value == 1
        % do nothing
    else
        threshold = base + model.tab3.dropdown_fg.Value * 10;
    end

end

function write_header (fid)

        fprintf(fid,'%s,', 'Image name');                                                % write image name
        fprintf(fid,'%s,', 'Position Y');               % write spot.r
        fprintf(fid,'%s,', 'Position X');               % write spot.c
        
        fprintf(fid,'%s,', 'Feature 1');              % write feature1
        fprintf(fid,'%s,', 'Feature 2');              % write f2
        fprintf(fid,'%s,', 'Feature 3');              % write f3
        fprintf(fid,'%s,', 'Feature 4');              % write f4
        fprintf(fid,'%s,', 'Feature 5');              % write f5
        
        k = 1;
        for r = -4:1:4
            for c = -4:1:4
                fprintf(fid,'%s,', ['Pixel value ' num2str(k)]); 
                k = k + 1;    
            end
        end
        
        fprintf(fid,'%s,', 'Number of annotations');
        fprintf(fid,'%s,', 'Percentage classified foreground');
        fprintf(fid,'%s,', 'Class');
        
        fprintf(fid,'%s,', 'User annotation details');
        
        fprintf(fid,'\n');

end

function [overlay] = generate_overlay (img, lenN)

    global model;
    global view;
    
    Records = load(model.strings.resultsfilename);
    Records = Records.Records;
    
    for k = 1:lenN
        [m] = arrayfun(@(x) model.tab3.data_Master_Complete(k).r == x.r && model.tab3.data_Master_Complete(k).c == x.c && strcmp(x.img, img), ...
        Records,'uniformoutput',false);
        overlay(k) = length(find(cell2mat(m)));
    end
    
    overlay = find(overlay);
end

