function GelAnalyzer_v_1_6(varargin)

% Initialise params.values
params.fs='';

% Update values
params=parse_pv_pairs(params,varargin);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS NEXT SECTION IS ALL TO DO WITH MAKING THE FIGURE

window_width=1024;
window_height=800;

% Initialise the figure
close all;
f=figure('Visible','off','Position',[1 1 window_width window_height], ...
    'Name','GelBandFitter - http://www.gelbandfitter.org');

% Sizes
row_height=0.018*window_height;
font_size=10;

% Default values
default_string='---';
default_fit_trendline_points=10;
default_trendline_mode=1;
default_fitting_algorithm=2;

% Controls

% Data File
h_data_file_panel=uipanel('Title','Image File', ...
    'Position',[0.01 0.895 0.38 0.085]);

% Set colors now you know what the panel looks like
background_color=1.0*get(h_data_file_panel,'BackgroundColor');
control_color=background_color;

h_data_file_string=uicontrol('Parent',h_data_file_panel, ...
    'Style','edit', ...
    'Position',[0.01*window_width 0.04*window_height ...
        0.29*window_width 1.0*row_height], ...
    'HorizontalAlignment','left');
h_data_file_push=uicontrol('Parent',h_data_file_panel, ...
    'Style','push', ...
    'Position',[0.31*window_width 0.04*window_height ...
        0.05*window_width 1.0*row_height], ...
    'String','Load File', ...
    'Callback',{@load_file});
h_data_file_info_text=uicontrol('Parent',h_data_file_panel, ...
    'Style','text', ...
    'Position',[0.01*window_width 0.001*window_width ...
        0.03*window_width 1.5*row_height], ...
    'HorizontalAlignment','left', ...
    'String','File info', ...
    'BackgroundColor',background_color);
h_data_file_info=uicontrol('Parent',h_data_file_panel, ...
    'Style','edit', ...
    'Position',[0.05*window_width 0.003*window_width ...
        0.31*window_width 1.8*row_height], ...
    'HorizontalAlignment','left', ...
    'String',['    ' default_string], ...
    'BackgroundColor',background_color, ...
    'Max',2);

% Fit Panel
x_anchor=0.01*window_width;
y_anchor=0.0*window_height;
x_width=0.12*window_width;
y_spacing=0.025*window_width;

h_fit_panel=uipanel('Title','Fit Profile', ...
    'Position',[0.01 0.635 0.385 0.25]);

h_fit_subtract_trendline_checkbox=uicontrol('Parent',h_fit_panel, ...
    'Style','checkbox', ...
    'Position', [x_anchor y_anchor+6.4*y_spacing ...
        x_width 1.5*row_height], ...
    'BackgroundColor',background_color, ...
    'String','Subtract trendline', ...
    'Callback',{@reset_fitting}, ...
    'Value',default_trendline_mode);

h_fit_trendline_points_text=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position', [x_anchor y_anchor+5.8*y_spacing ...
        0.4*x_width row_height], ...
    'String','Fit points', ...
    'BackgroundColor',background_color, ...
    'HorizontalAlignment','left');

h_fit_trendline_points=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor+0.45*x_width y_anchor+5.8*y_spacing ...
        0.35*x_width row_height], ...
    'String',sprintf('%i',default_fit_trendline_points), ...
    'BackgroundColor',background_color, ...
    'Callback',{@reset_fitting});

h_fit_fitting_function_text=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position', [x_anchor y_anchor+4.9*y_spacing ...
        x_width 1.0*row_height], ...
    'String','Fiting Mode', ...
    'BackgroundColor',background_color, ...
    'HorizontalAlignment','left');
h_fit_function_menu=uicontrol('Parent',h_fit_panel, ...
    'Style','popupmenu', ...
    'Position',[x_anchor y_anchor+4.3*y_spacing 0.8*x_width...
        1.0*row_height], ...
        'String',{'Manual','Gaussian','Lorentzian'}, ...
        'Callback',{@reset_fitting});
    
h_fit_fitting_algorithm_text=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position', [x_anchor y_anchor+3.1*y_spacing ...
        x_width 1.0*row_height], ...
    'String','Fiting Algorithm', ...
    'BackgroundColor',background_color, ...
    'HorizontalAlignment','left');
h_fit_solver_menu=uicontrol('Parent',h_fit_panel, ...
    'Style','popupmenu', ...
    'Position', [x_anchor y_anchor+2.5*y_spacing ...
        0.8*x_width 1.0*row_height], ...
        'String',{'SQP','Simplex','PSO'}, ...
        'Callback',{@reset_fitting}, ...
        'Value',default_fitting_algorithm);
    
h_fit_draw_fitting_checkbox=uicontrol('Parent',h_fit_panel, ...
    'Style','checkbox', ...
    'Position',[x_anchor y_anchor+1.5*y_spacing ...
        x_width 1.0*row_height], ...
        'String','Draw fitting process', ...
        'Value',0);
h_fit_push=uicontrol('Parent',h_fit_panel, ...
    'style','push', ...
 'Position',[x_anchor y_anchor+0.2*y_spacing ...
        0.8*x_width 2.0*row_height], ...
    'String','Curve fit', ...
    'Callback',{@fit_profile});    
    
% Fitting variables    
% Text labels
x_anchor=0.12*window_width;
y_anchor=0.005*window_height;
y_spacing=0.021*window_height;
x_width=0.10*window_width;

h_fit_parameter_text=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+8*y_spacing x_width 2*row_height], ...
    'String','Parameter', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);
h_fit_upper_band_x=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+7*y_spacing x_width row_height], ...
    'String','Upper Band x (Pixels)', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);
h_fit_lower_band_x=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+6*y_spacing x_width row_height], ...
    'String','Lower Band x (Pixels)', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);   
h_fit_upper_curve_shape=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+5*y_spacing x_width row_height], ...
    'String','Curve shape', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);   
h_fit_upper_amp=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+4*y_spacing x_width row_height], ...
    'String','Upper Amplitude', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);   
h_fit_lower_amp=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+3*y_spacing x_width row_height], ...
    'String','Lower Amplitude', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);
h_fit_upper_skew=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+2*y_spacing x_width row_height], ...
    'String','Skew', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);
h_fit_lower_relative_shape=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+y_spacing x_width row_height], ...
    'String','Lower Relative Shape', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);

% Estimates
x_anchor=0.225*window_width;
x_width=0.05*window_width;

h_fit_estimate_text=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+8*y_spacing x_width 2*row_height], ...
    'String',{'Starting' 'Estimate'}, ...
    'HorizontalAlignment','center', ...
    'BackgroundColor',control_color);

h_fit_upper_band_x_estimate=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+7*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);
h_fit_lower_band_x_estimate=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+6*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);   
h_fit_upper_curve_shape_estimate=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+5*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);   
h_fit_upper_amp_estimate=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+4*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);   
h_fit_lower_amp_estimate=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+3*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);
h_fit_upper_skew_estimate=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+2*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);
h_fit_lower_relative_shape_estimate=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);


% Values
x_anchor=0.28*window_width;
x_width=0.05*window_width;

h_fit_value_text=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+8*y_spacing x_width 2*row_height], ...
    'String',{'Calculated' 'Value'}, ...
    'HorizontalAlignment','center', ...
    'BackgroundColor',control_color);

h_fit_upper_band_x_value=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+7*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);
h_fit_lower_band_x_value=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+6*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);   
h_fit_upper_curve_shape_value=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+5*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);   
h_fit_upper_amp_value=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+4*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);   
h_fit_lower_amp_value=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+3*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);
h_fit_upper_skew_value=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+2*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);
h_fit_lower_relative_shape_value=uicontrol('Parent',h_fit_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);

% Constraints
x_anchor=0.335*window_width;
x_width=0.04*window_width;

h_fit_constrain_text=uicontrol('Parent',h_fit_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+8*y_spacing x_width 2*row_height], ...
    'String','Constrain', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);

x_anchor=0.35*window_width;
x_width=0.02*window_width;

h_fit_upper_band_x_constrain=uicontrol('Parent',h_fit_panel, ...
    'Style','checkbox', ...
    'Position',[x_anchor y_anchor+7*y_spacing x_width row_height], ...
    'BackgroundColor',control_color);
h_fit_lower_band_x_constrain=uicontrol('Parent',h_fit_panel, ...
    'Style','checkbox', ...
    'Position',[x_anchor y_anchor+6*y_spacing x_width row_height], ...
    'BackgroundColor',control_color);   
h_fit_upper_curve_shape_constrain=uicontrol('Parent',h_fit_panel, ...
    'Style','checkbox', ...
    'Position',[x_anchor y_anchor+5*y_spacing x_width row_height], ...
    'BackgroundColor',control_color);   
h_fit_upper_amp_constrain=uicontrol('Parent',h_fit_panel, ...
    'Style','checkbox', ...
    'Position',[x_anchor y_anchor+4*y_spacing x_width row_height], ...
    'BackgroundColor',control_color);   
h_fit_lower_amp_constrain=uicontrol('Parent',h_fit_panel, ...
    'Style','checkbox', ...
    'Position',[x_anchor y_anchor+3*y_spacing x_width row_height], ...
    'BackgroundColor',control_color);
h_fit_upper_skew_constrain=uicontrol('Parent',h_fit_panel, ...
    'Style','checkbox', ...
    'Position',[x_anchor y_anchor+2*y_spacing x_width row_height], ...
    'BackgroundColor',control_color);
h_fit_lower_relative_shape_constrain=uicontrol('Parent',h_fit_panel, ...
    'Style','checkbox', ...
    'Position',[x_anchor y_anchor+y_spacing x_width row_height], ...
    'BackgroundColor',control_color, ...
    'Value',0);

% Output
h_output_panel=uipanel('Title','Output Parameters', ...
    'Position',[0.01 0.525 0.38 0.10]);

% Text labels
x_anchor=0.01*window_width;
y_anchor=0.005*window_height;
y_spacing=0.025*window_height;
x_width=0.09*window_width;

h_output_area1_string=uicontrol('Parent',h_output_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+2*y_spacing x_width row_height], ...
    'String','Area Peak 1 (Pixels)', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);
h_output_area2_string=uicontrol('Parent',h_output_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+y_spacing x_width row_height], ...
    'String','Area Peak 2  (Pixels)', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);
h_output_total_area_string=uicontrol('Parent',h_output_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor x_width row_height], ...
    'String','Total Area  (Pixels)', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);

% Pixel values
x_anchor=0.11*window_width;
x_width=0.05*window_width;

h_output_area1_value=uicontrol('Parent',h_output_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+2*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);
h_output_area2_value=uicontrol('Parent',h_output_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);
h_output_total_area_value=uicontrol('Parent',h_output_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);

% Text labels
x_anchor=0.23*window_width;
x_width=0.09*window_width;

h_output_rel_area1_string=uicontrol('Parent',h_output_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+2*y_spacing x_width row_height], ...
    'String','Relative Area 1', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);
h_output_rel_area2_string=uicontrol('Parent',h_output_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor+y_spacing x_width row_height], ...
    'String','Relative Area 2', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);
h_output_r_squared_string=uicontrol('Parent',h_output_panel, ...
    'Style','text', ...
    'Position',[x_anchor y_anchor x_width row_height], ...
    'String','R-squared', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',control_color);

% Relative areas
x_anchor=0.32*window_width;
x_width=0.05*window_width;

h_output_rel_area1_value=uicontrol('Parent',h_output_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+2*y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);
h_output_rel_area2_value=uicontrol('Parent',h_output_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor+y_spacing x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);
h_output_r_squared_value=uicontrol('Parent',h_output_panel, ...
    'Style','edit', ...
    'Position',[x_anchor y_anchor x_width row_height], ...
    'String',default_string, ...
    'BackgroundColor',control_color);

% Axes Positions

raw_image_x=0.075*window_width;
raw_image_y=0.1*window_height;

zoomed_image_x=0.45*window_width;
zoomed_image_y=0.55*window_height;

zoomed_profile_x=0.65*window_width;
zoomed_profile_y=0.55*window_height;

zoomed_image2_x=0.45*window_width;
zoomed_image2_y=0.10*window_height;

target_x=0.65*window_width;
target_y=0.10*window_height;

% Setup axes

large_axes_width=300;
large_axes_height=300;

small_axes_width=150;
small_axes_height=300;

ha_raw_axes=axes('Units','Pixels', ...
    'Position',[raw_image_x raw_image_y ...
         large_axes_width large_axes_height]);
title('Raw Image');

ha_zoomed_image=axes('Units','Pixels', ...
    'Position',[zoomed_image_x zoomed_image_y ...
            small_axes_width small_axes_height]);
title('Zoomed Image');

ha_zoomed_profile=axes('Units','Pixels', ...
    'Position',[zoomed_profile_x zoomed_profile_y ...
            large_axes_width large_axes_height]);
title('Zoomed Profile');

ha_zoomed_image2=axes('Units','Pixels', ...
    'Position',[zoomed_image2_x zoomed_image2_y ...
            small_axes_width small_axes_height]);
title('Zoomed Image');

ha_target=axes('Units','Pixels', ...
    'Position',[target_x target_y ...
            large_axes_width large_axes_height], ...
    'ButtonDownFcn',{@drag_target_cursor});
title('Target Intensity');
    
% Allow for resizing

set([f,h_data_file_panel,h_data_file_string, ...
    h_data_file_push,h_data_file_info_text, h_data_file_info, ...
    ha_raw_axes,ha_zoomed_image, ha_zoomed_profile ...
    ha_zoomed_image2, ha_target, ...
    h_fit_panel,h_fit_subtract_trendline_checkbox, ...
    h_fit_push,h_fit_function_menu,h_fit_solver_menu, ...
    h_fit_trendline_points_text h_fit_trendline_points ...
    h_fit_fitting_function_text ...
    h_fit_fitting_algorithm_text ...
    h_fit_draw_fitting_checkbox ...
    h_fit_parameter_text ...
    h_fit_upper_band_x h_fit_lower_band_x ...
    h_fit_upper_curve_shape ...
    h_fit_upper_amp h_fit_lower_amp ...
    h_fit_upper_skew h_fit_lower_relative_shape ...
    h_fit_estimate_text ...
    h_fit_upper_band_x_estimate h_fit_lower_band_x_estimate ...
    h_fit_upper_curve_shape_estimate ...
    h_fit_upper_amp_estimate h_fit_lower_amp_estimate ...
    h_fit_upper_skew_estimate h_fit_lower_relative_shape_estimate ...
    h_fit_value_text ...
    h_fit_upper_band_x_value h_fit_lower_band_x_value ...
    h_fit_upper_curve_shape_value ...
    h_fit_upper_amp_value h_fit_lower_amp_value ...
    h_fit_upper_skew_value h_fit_lower_relative_shape_value ...
    h_fit_constrain_text ...
    h_fit_upper_band_x_constrain h_fit_lower_band_x_constrain ...
    h_fit_upper_curve_shape_constrain ...
    h_fit_upper_amp_constrain h_fit_lower_amp_constrain ...
    h_fit_upper_skew_constrain h_fit_lower_relative_shape_constrain ...
    h_fit_draw_fitting_checkbox ...
    h_output_area1_string h_output_area2_string ...
        h_output_total_area_string ...
    h_output_area1_value h_output_area2_value ...
        h_output_total_area_value ...
    h_output_rel_area1_string h_output_rel_area2_string ...
        h_output_r_squared_string ...
    h_output_rel_area1_value h_output_rel_area2_value ...
        h_output_r_squared_value], ...
    'Units','normalized');

set(f,'Visible','on');
maximize_window();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Nested functions

    function reset_fitting(source,EventData)
        
        % Retrieve the data
        image_data=getappdata(f,'image_data');
        
        % Reset some variables
        image_data.upper_band_x_estimate=NaN;
        image_data.lower_band_x_estimate=NaN;
        image_data.upper_curve_shape_estimate=NaN;
        image_data.upper_amp_estimate=NaN;
        image_data.lower_amp_estimate=NaN;
        image_data.upper_skew_estimate=NaN;
        image_data.lower_relative_shape_estimate=NaN;
       
        image_data.upper_band_x=NaN;
        image_data.lower_band_x=NaN;
        image_data.upper_curve_shape=NaN;
        image_data.upper_amp=NaN;
        image_data.lower_amp=NaN;
        image_data.upper_skew=NaN;
        image_data.lower_relative_shape=NaN;

        % Deduce whether the program is in manual mode
        temp_strings=get(h_fit_function_menu,'String');
        image_data.fit_function_string=temp_strings{ ...
            get(h_fit_function_menu,'Value')};
        
        if (~strcmp(image_data.fit_function_string,'Manual'))
            image_data.manual_fit_mode=0;
        else
            image_data.manual_fit_mode=1;
        end
               
        % Update the data
        setappdata(f,'image_data',image_data);
        
        % Draw if necessary
        if (isfield(image_data,'target'));
            % Redraw
            display_zoomed_profile;
            
            % Reload
            image_data=getappdata(f,'image_data');
        
            % Clean the fit display
            update_fit_profile_display([],[],1);
            
            % And update it if appropriate
            if (image_data.manual_fit_mode==0)
                estimate_fit_parameters;
                % Reset the output box
                update_output_display([],[],1);
            else
                manual_determination;
            end
        end
        
        % Update the data
        setappdata(f,'image_data',image_data);
    end

    function load_file(source,EventData)
        
        % Clear any existing image data
        image_data=[];
        
        setappdata(f,'image_data',image_data);
        
        % Do some initialization
        reset_fitting;
        
        axes(ha_raw_axes);
        cla;
        axes(ha_zoomed_image);
        cla;
        axes(ha_zoomed_image2);
        cla;
        axes(ha_zoomed_profile);
        cla;
        axes(ha_target);
        cla;
                
        % Load in the blank image_data
        image_data=getappdata(f,'image_data');
        
        % and reset manual_x
        image_data.manual_x=NaN;
         
        [data_file_string,path_string]=uigetfile({ ...
            '*.jpg;*.tif;*.png;*.gif','All Image Files'; ...
            '*.*','All Files'},'Select a gel image file');
        image_data.data_file_string= ...
            fullfile(path_string,data_file_string);

         try
            % Try to load the image file
            image_data.im=imread(image_data.data_file_string);
            image_data.im=flipdim(image_data.im,1);
            image_data.im=sum(image_data.im,3);
            [image_data.no_of_y_pixels,image_data.no_of_x_pixels,temp]= ...
                size(image_data.im);
            
            set(h_data_file_string,'String',image_data.data_file_string);
            
            image_data.image_info=imfinfo(image_data.data_file_string);
            display_string1=sprintf( ...
                'Format: %s     Size: %.0f kB     %i x %i pixels', ...
                image_data.image_info.Format, ...
                (image_data.image_info.FileSize)/1000, ...
                image_data.image_info.Width, ...
                image_data.image_info.Height);
            display_string2=sprintf('Bitdepth: %i     Colortype: %s', ...
                image_data.image_info.BitDepth, ...
                image_data.image_info.ColorType);
            set(h_data_file_info,'String',...
                {display_string1 display_string2});
            
            % Store it with the figure
            setappdata(f,'image_data',image_data);
            
            % and display it
            display_raw_image();
            
        catch
            % If that fails, display an error
            display_string=sprintf('%s could not be opened', ...
                image_data.data_file_string);
            errordlg(display_string,'Image file error');
        end
    end

    function display_raw_image(source,EventData)
       
        image_data=getappdata(f,'image_data');
        
        % Try to get the image itself
        if (isfield(image_data,'im'))
            
            % and display it
            axes(ha_raw_axes);
            cla;
            hold on;
            h_raw_image=imagesc(image_data.im);
            colormap('gray');
            title('Raw Image');
            xlabel('Pixels');
            ylabel('Pixels');
            xlim([1 image_data.no_of_x_pixels]);
            ylim([1 image_data.no_of_y_pixels]);
            
            % set the drag_box callback
            set(h_raw_image,'ButtonDownFcn',{@drag_box});
        end
        
        % Draw the zoom box if it is valid
        if (isfield(image_data,'zoom_box_set'))

            if (image_data.zoom_box_set==1)
                line(image_data.zoom_box_x, ...
                    image_data.zoom_box_y, ...
                    'Color',[0 0 1]);
            end
            
            display_string=sprintf('Box x: %i - %i\nBox y: %i - %i', ...
                image_data.zoom_box_x(1),image_data.zoom_box_x(2), ...
                image_data.zoom_box_y(1),image_data.zoom_box_y(3));
            text(0.05*image_data.no_of_x_pixels, ...
                0.9*image_data.no_of_y_pixels,display_string);
        end
        
    end

    function display_zoomed_image(source,EventData)

        % Retrieve the data
        image_data=getappdata(f,'image_data');
        
        % Get the zoomed in bit
        image_data.zoomed_im=image_data.im( ...
            [image_data.zoom_box_y(1):image_data.zoom_box_y(3)], ...
            [image_data.zoom_box_x(1):image_data.zoom_box_x(2)],:);
        image_data.zoomed_im=flipdim(image_data.zoomed_im,1);
        
        % and display it
        axes(ha_zoomed_image);
        imagesc(image_data.zoomed_im);
        title('Zoomed Image');
        xlabel('Pixels');
        ylabel('Pixels');
        
        % Now display the copy
        axes(ha_zoomed_image2);
        imagesc(image_data.zoomed_im);
        title('Zoomed Image');
        xlabel('Pixels');
        ylabel('Pixels');

        % Update the figure data
        setappdata(f,'image_data',image_data);
        
        % Update the profile
        display_zoomed_profile;
    end

    function display_zoomed_profile(source,EventData)
        
        % Retrieve the figure data
        image_data=getappdata(f,'image_data');
        
        % Calculate profile
        image_data.zoomed_profile= ...
            mean(image_data.zoomed_im,2);
        [temp,temp,no_of_dimensions]=size(image_data.zoomed_im);
        image_data.zoomed_profile=image_data.zoomed_profile./ ...
            no_of_dimensions;
        
        % and display it
        axes(ha_zoomed_profile);
        cla;
        hold on;
        image_data.zoomed_pixels=1:length(image_data.zoomed_profile);
        plot(image_data.zoomed_profile,image_data.zoomed_pixels,'b-');
        set(gca,'YDir','reverse');
        ylim([1 length(image_data.zoomed_profile)]);
        title('Zoomed Profile (Mean Pixel Value)');
        
        % Get the trend_points and set some arrays for later
        try
            image_data.trend_points=round(str2double( ...
                get(h_fit_trendline_points,'String')));
            % Some error checking
            if (image_data.trend_points> ...
                    (0.5*length(image_data.zoomed_pixels)))
                image_data.trend_points= ...
                    round(0.5*length(image_data.zoomed_pixels))-1;
            end
        catch
            image_data.trend_points=1;
        end
        image_data.trend_indices1=1:image_data.trend_points;
        image_data.trend_indices2=length(image_data.zoomed_pixels)+ ...
            ((-image_data.trend_points+1):0);
        
        % Display this on the zoomed_profile
        axes(ha_zoomed_profile);
        plot(image_data.zoomed_profile(image_data.trend_indices1), ...
            image_data.zoomed_pixels(image_data.trend_indices1),'m');
        plot(image_data.zoomed_profile(image_data.trend_indices2), ...
            image_data.zoomed_pixels(image_data.trend_indices2),'m');
        % And show the trendline
        [grad,intercept,temp,temp,temp]=fit_straight_line( ...
            image_data.zoomed_pixels([image_data.trend_indices1 ...
                    image_data.trend_indices2]), ...
                image_data.zoomed_profile([image_data.trend_indices1 ...
                    image_data.trend_indices2]));
        image_data.zoomed_trend=intercept+grad*image_data.zoomed_pixels';
        plot(image_data.zoomed_trend,image_data.zoomed_pixels,'b:');
        
        xlabel('Mean Pixel Value');
        
        % Update the figure data
        setappdata(f,'image_data',image_data);
        
        % Display the target
        calculate_and_display_target;
        
    end

    function calculate_and_display_target(source,EventData)

         % Retrieve the figure data
        image_data=getappdata(f,'image_data');
        
        % Calculate target
        % First offset it ...
        image_data.target=image_data.zoomed_profile- ...
            max([image_data.zoomed_profile(1) ...
                    image_data.zoomed_profile(end)]);
        
        % Now negate it
        image_data.target=-image_data.target;
        
        % Now calculate the baseline
        [grad,intercept,temp,temp,temp]=fit_straight_line( ...
                image_data.zoomed_pixels([image_data.trend_indices1 ...
                    image_data.trend_indices2]), ...
                image_data.target([image_data.trend_indices1 ...
                    image_data.trend_indices2]));
        image_data.baseline=intercept + ...
                (grad*image_data.zoomed_pixels');
        
        % Now subtract the baseline if appropriate
        if (get(h_fit_subtract_trendline_checkbox,'Value'))
            image_data.target=image_data.target - ...
                    image_data.baseline;
                
            % And correct the baseline for display
            image_data.baseline=zeros(1,length(image_data.target));
        end
 
        % and display it
        axes(ha_target);
        cla;
        hold on;
        plot(image_data.target,image_data.zoomed_pixels,'b-');
        ylim([1 length(image_data.zoomed_profile)]);
        set(gca,'YDir','reverse');
        title('Target Intensity');
        
        % draw the (vertical if corrected) baseline
        plot(image_data.baseline,image_data.zoomed_pixels,'b:');
         
        % draw the fitting points
        plot(image_data.target(image_data.trend_indices1), ...
            image_data.zoomed_pixels(image_data.trend_indices1),'m');
        plot(image_data.target(image_data.trend_indices2), ...
            image_data.zoomed_pixels(image_data.trend_indices2),'m');
        
        xlabel('Mean Pixel Value');
        
        % Update the figure data
        setappdata(f,'image_data',image_data);
        
        % Try to set the curve_shape parameters correctly
        estimate_fit_parameters;
    end

    function drag_target_cursor(source,EventData)

        % Retrieve the data
        image_data=getappdata(f,'image_data');
        
        if (isfield(image_data,'target'))

           % Detect the mouse drag
            point1 = get(gca,'CurrentPoint');    % button down detected
            finalRect = rbbox;                   % return figure units
            point2 = get(gca,'CurrentPoint');    % button up detected

            image_data.manual_x=round(point2(1,2));

            % Update
            setappdata(f,'image_data',image_data);

            manual_determination;
        end
    
    end

    function manual_determination(source,EventData)
        % This function fits the areas manually

        % First check that we are in the manual mode
        temp_strings=get(h_fit_function_menu,'String');
        image_data.fit_function_string=temp_strings{ ...
            get(h_fit_function_menu,'Value')};

        if (~strcmp(image_data.fit_function_string,'Manual'))
            disp('Not manual mode');
            return;
        end
       
        % Retrieve the data
        image_data=getappdata(f,'image_data');
        
        % Check to see if we've been here before
        if (isnan(image_data.manual_x))
            % Try to set the manual_x position intelligently
            pd=find_peaks('x',image_data.zoomed_pixels, ...
                'y',image_data.target, ...
                'min_rel_delta_y',0.05, ...
                'min_x_index_spacing',10);
            if (length(pd.min_indices)==1)
                image_data.manual_x=pd.min_indices(1);
            else
                image_data.manual_x=round(0.5*length(image_data.target));
            end
        end
        
        % Set profile
        mask_array=1:length(image_data.target);
        
        x_patch=[mask_array(mask_array<=image_data.manual_x) ...
            image_data.manual_x ...
            mask_array(mask_array>image_data.manual_x) 1];
        y1_patch=[image_data.target(1:image_data.manual_x)' ...
            zeros(1,length(image_data.target)-image_data.manual_x+1) 0];
        y2_patch=[zeros(1,image_data.manual_x) ...
            image_data.target(image_data.manual_x:end)' 0];
        
        % Draw the patches

        % Set colors
        patch_colors=(1/256)*[229 229 254;201 236 208;236 201 208;210 205 207];

        axes(ha_target);
        cla;
        hold on;
        h_profile=plot(image_data.target,image_data.zoomed_pixels,'b-', ...
            'LineWidth',1.5, ...
            'ButtonDownFcn',{@drag_target_cursor});
        
        fill(y1_patch,x_patch,patch_colors(1,:), ...
            'ButtonDownFcn',{@drag_target_cursor});
        fill(y2_patch,x_patch,patch_colors(2,:), ...
            'ButtonDownFcn',{@drag_target_cursor});
        
        % Plot the cursor
        plot(image_data.target(image_data.manual_x), ...
            image_data.manual_x,'k+', ...
            'MarkerSize',12);

        % draw the (vertical if corrected) baseline
        plot(image_data.baseline,image_data.zoomed_pixels,'b:');
         
        % draw the fitting points
        plot(image_data.target(image_data.trend_indices1), ...
            image_data.zoomed_pixels(image_data.trend_indices1),'m');
        plot(image_data.target(image_data.trend_indices2), ...
            image_data.zoomed_pixels(image_data.trend_indices2),'m');
        
        % Set image_data.y_array for calculations
        y1=y1_patch;
        y1([image_data.manual_x+1 end])=[];
        y2=y2_patch;
        y2([image_data.manual_x end])=[];
        y_temp=zeros(length(image_data.target),1);
        
        image_data.y_array=[y1' y2' y_temp];
        
        % Set r_squared
        image_data.r_squared=NaN;
        
        % Update
        setappdata(f,'image_data',image_data);
        
        % Calculate the area
        calculate_areas;
        
        % Update the figure
        update_output_display([],[],0);
    end

    function read_fit_profile_variables(source,EventData)
        % Retrieve the figure data
        image_data=getappdata(f,'image_data');
        
        % Update image_data based on user controls
        
         % First the function type
        temp_strings=get(h_fit_function_menu,'String');
        image_data.fit_function_string=temp_strings{ ...
            get(h_fit_function_menu,'Value')};
        
         % Now the solver type
        temp_strings=get(h_fit_solver_menu,'String');
        image_data.fit_solver_string=temp_strings{ ...
            get(h_fit_solver_menu,'Value')};
        
        % And other options
        image_data.display_fitting_process= ...
            get(h_fit_draw_fitting_checkbox,'Value');
        
        % Fitting estimates
        image_data.upper_band_x_estimate= ...
            str2double(get(h_fit_upper_band_x_estimate,'String'));
        image_data.lower_band_x_estimate= ...
            str2double(get(h_fit_lower_band_x_estimate,'String'));
        image_data.upper_curve_shape_estimate=str2double( ...
            get(h_fit_upper_curve_shape_estimate,'String'));
        image_data.upper_amp_estimate=str2double( ...
            get(h_fit_upper_amp_estimate,'String'));
        image_data.lower_amp_estimate=str2double( ...
            get(h_fit_lower_amp_estimate,'String'));
        image_data.upper_skew_estimate=str2double( ...
            get(h_fit_upper_skew_estimate,'String'));
        image_data.lower_relative_shape_estimate=str2double( ...
            get(h_fit_lower_relative_shape_estimate,'String'));
        
         % Update the figure data
        setappdata(f,'image_data',image_data);
    end

    function fit_profile(source,EventData)
        
        % Retrieve the figure data
        image_data=getappdata(f,'image_data');
        
        % Some error checking
        if (~isfield(image_data,'target'))
            errordlg({'There is not a gel profile to analyze', ...
                'Please select a lane and try again'}, ...
                'No bands selected');
            return;
        end
        
        % Update image_data based on user controls
        read_fit_profile_variables;
        
        % Update the image_data
        image_data=getappdata(f,'image_data');
    
        % And now set p
        p=[image_data.upper_band_x_estimate ...
            image_data.lower_band_x_estimate ...
            image_data.upper_curve_shape_estimate ...
            image_data.upper_amp_estimate  ...
            image_data.lower_amp_estimate ...
            image_data.upper_skew_estimate ...
            image_data.lower_relative_shape_estimate]
        
        % Set the function handle
        if (strcmp(image_data.fit_function_string,'Gaussian'))
            % Using the Gaussian function
            fh_profile=@skewed_Gaussian;
        else
            fh_profile=@skewed_Lorentzian;
        end
        
        % Set x
        x=image_data.zoomed_pixels;
    
        no_of_parameters=7;
        A_constraints=[1 -1 0 0 0 0 0];
        B_constants=[0];
        lower_bounds=zeros(1,no_of_parameters);
        upper_bounds=Inf*ones(1,no_of_parameters);
        
        % Tidy the bounds where possible
        upper_bounds(1)=image_data.no_of_x_pixels;
        upper_bounds(2)=image_data.no_of_x_pixels;
        if (strcmp(image_data.fit_function_string,'Gaussian'))
            upper_bounds(4)=max(image_data.target);
            upper_bounds(5)=max(image_data.target);
        end
        
        % Set the constraints
        if (get(h_fit_upper_band_x_constrain,'Value'))
            lower_bounds(1)=image_data.upper_band_x_estimate;
            upper_bounds(1)=image_data.upper_band_x_estimate;
        end
        if (get(h_fit_lower_band_x_constrain,'Value'))
            lower_bounds(2)=image_data.lower_band_x_estimate;
            upper_bounds(2)=image_data.lower_band_x_estimate;
        end
        if (get(h_fit_upper_curve_shape_constrain,'Value'))
            lower_bounds(3)=image_data.upper_curve_shape_estimate;
            upper_bounds(3)=image_data.upper_curve_shape_estimate;
        end
        if (get(h_fit_upper_amp_constrain,'Value'))
            lower_bounds(4)=image_data.upper_amp_estimate;
            upper_bounds(4)=image_data.upper_amp_estimate;
        end
        if (get(h_fit_lower_amp_constrain,'Value'))
            lower_bounds(5)=image_data.lower_amp_estimate;
            upper_bounds(5)=image_data.lower_amp_estimate;
        end
        if (get(h_fit_upper_skew_constrain,'Value'))
            lower_bounds(6)=image_data.upper_skew_estimate;
            upper_bounds(6)=image_data.upper_skew_estimate;
        end
        if (get(h_fit_lower_relative_shape_constrain,'Value'))
            lower_bounds(7)=image_data.lower_relative_shape_estimate;
            upper_bounds(7)=image_data.lower_relative_shape_estimate;
        else
            % Constrain relative shape estimate to finite numbers
            lower_bounds(7)=0.05;
            upper_bounds(7)=5;
        end
        
        % Clear the displays
        update_output_display(source,EventData,1);
        update_fit_profile_display([],[],1);
    
        % Run the solver
        if (strcmp(image_data.fit_solver_string,'Simplex'))
            opts=optimset('fminsearch')
            opts.Display='off';
            opts.MaxIter=1000;
            opts.MaxFunEvals=10000;
            [p_result,fval,exitflag,output]= ...
                fminsearchcon(@return_profile_error,p, ...
                lower_bounds,upper_bounds,A_constraints,B_constants, ...
                [],opts);
        end
        if (strcmp(image_data.fit_solver_string,'SQP'))
            p_result=fmincon(@return_profile_error,p, ...
                A_constraints,B_constants,[],[], ...
                lower_bounds,upper_bounds,[]);
        end
        if (strcmp(image_data.fit_solver_string,'PSO'))
            p_result=particle_swarm_optimization( ...
                'function_handle',@return_profile_error, ...
                'initial_p',p, ...
                'no_of_particles',20, ...
                'lower_bounds',lower_bounds, ...
                'upper_bounds',upper_bounds, ...
                'max_velocity',0.3);
        end
        
        % Calculate the profile
        [y1,y2,y_profile]= ...
            calculate_profile(x,fh_profile,p_result);
        image_data.y_array=[y1' y2' y_profile'];
        
        % Unpack p_result
        image_data.upper_band_x=p_result(1);
        image_data.lower_band_x=p_result(2);
        image_data.upper_curve_shape=p_result(3);
        image_data.upper_amp=p_result(4);
        image_data.lower_amp=p_result(5);
        image_data.upper_skew=p_result(6);
        image_data.lower_relative_shape=p_result(7);
        
        % Update the figure data
        setappdata(f,'image_data',image_data);
        
        % Draw the fit
        draw_profile;
        
        % Calculate the area
        calculate_areas;
        
        % Calculate r_squared
        calculate_r_squared_value;
        
        % Update the figure
        update_fit_profile_display(source,EventData,0);
        update_output_display(source,EventData,0);

            % Nested function
            function [error_value]=return_profile_error(p)

                target=image_data.target;

                [y1,y2,y_fit]=calculate_profile(x,fh_profile,p);
                
                ii=length(target);
                
                error_value=sum((y_fit(1:ii)-target(1:ii)').^2);
                
                if (image_data.display_fitting_process==1)
                    axes(ha_target);
                    cla;
                    hold on;
                    plot(image_data.target,image_data.zoomed_pixels,'b-');
                    plot(y_fit,image_data.zoomed_pixels,'c-');
                    ylim([1 length(image_data.zoomed_profile)]);
                    set(gca,'YDir','reverse');
                    title('Target Intensity');
                end
            end
    end

    function estimate_fit_parameters(source,EventData)
        % Update from the screen
        read_fit_profile_variables;
        
        % Retrieve the figure data
        image_data=getappdata(f,'image_data');
        
        % Find index difference from the position of the max amplitude
        % to the nearest position with half-max amplitude
        [max_value,max_index]=max(image_data.target);
        % First one
        half1= ...
            find(image_data.target(1:max_index)<(0.5*max_value),1,'last');
        % Second one
        half2=max_index-1 + ...
            find(image_data.target(max_index:end)<(0.5*max_value), ...
                1,'first');
        % Half-distance
        if ((length(half1)>0)&&(length(half2)>0))
            half_distance= ...
                min([abs(max_index-half1) abs(max_index-half2)]);
        else
            % Guess something plausible
            half_distance=(0.1*length(image_data.zoomed_pixels));
        end
        
        % Now use the half-distance to set the curve-shape parameters
        if (strcmp(image_data.fit_function_string,'Gaussian'))
            % Using the Gaussian function
            image_data.upper_curve_shape_estimate= ...
                -log(0.5)/(half_distance^2);
        else
            % Using the Lorentzian
            image_data.upper_curve_shape_estimate=half_distance;
        end

        % Now the amplitude
        if (strcmp(image_data.fit_function_string,'Gaussian'))
            % Using the Gaussian function
            image_data.upper_amp_estimate=max_value;
            image_data.lower_amp_estimate=image_data.upper_amp_estimate;
        else
            % Using the Lorentzian
            image_data.upper_amp_estimate= ...
                pi*max_value*image_data.upper_curve_shape_estimate;
            image_data.lower_amp_estimate=image_data.upper_amp_estimate;
        end

        % Now set the skews
        image_data.upper_skew_estimate=1;
        
        % And the shape estimate
        image_data.lower_relative_shape_estimate=1.5;
                
        % And the positions
        % Try to find peaks automatically
        pd=find_peaks('x',image_data.zoomed_pixels, ...
            'y',image_data.target, ...
            'min_rel_delta_y',0.05, ...
            'min_x_index_spacing',10);
        
        if (length(pd.max_indices)==2)
            % There were two peaks
            image_data.upper_band_x_estimate=pd.max_indices(1);
            image_data.lower_band_x_estimate=pd.max_indices(2);
        else
            % Set something plausible
            image_data.upper_band_x_estimate= ...
                0.5*length(image_data.zoomed_pixels);
            image_data.lower_band_x_estimate= ...
                0.6*length(image_data.zoomed_pixels);
        end
        
        % Update the figure data
        setappdata(f,'image_data',image_data);
             
        % Update the display
        update_fit_profile_display([],[],0);
    end
    
    function draw_profile(source,EventData)

        % Retrieve the figure data
        image_data=getappdata(f,'image_data');
        
        % Set colors
        patch_colors=(1/256)*[229 229 254;201 236 208;236 201 208;210 205 207];
        
        % Set variables
        x=image_data.zoomed_pixels;
        x=[x'; x(end) ; x(1) ; x(1)];
        y=[image_data.y_array ; zeros(2,3); image_data.y_array(end,:)];
        
        % Draw
        axes(ha_target);
        cla;
        for i=3:-1:1
            patch(y(:,i),x,patch_colors(i,:));
        end
        y_min=min(y(:,1:2)');
        patch(y_min,x,patch_colors(4,:));
        plot(image_data.target,image_data.zoomed_pixels,'b-', ...
            'LineWidth',1.5);


        % Update the figure data
        setappdata(f,'image_data',image_data);
        
    end

    function calculate_areas(source,EventData)
        
        % Retrieve the figure data
        image_data=getappdata(f,'image_data');
        
        % Calculate the relative areas
        for i=1:2
            image_data.area(i)=trapz(image_data.zoomed_pixels, ...
                image_data.y_array(:,i));
        end

        image_data.total_area=sum(image_data.area);
        
        for i=1:2
            image_data.rel_area(i)=image_data.area(i)/ ...
                image_data.total_area;
        end
        
        % Update the figure data
        setappdata(f,'image_data',image_data);
    end

    function calculate_r_squared_value(source,EventData)
        
        % Retrieve the figure data
        image_data=getappdata(f,'image_data');
        
        image_data.r_squared=calculate_r_squared( ...
            image_data.target,image_data.y_array(:,3));
        
        % Update the figure data
        setappdata(f,'image_data',image_data);
    end

    function drag_box(source,EventData)
        
        % Get image data
        image_data=getappdata(f,'image_data');
        
        % Reset the fit profile display
        update_fit_profile_display(source,EventData,1);
        
        % Detect the mouse drag
        point1 = get(gca,'CurrentPoint');    % button down detected
        finalRect = rbbox;                   % return figure units
        point2 = get(gca,'CurrentPoint');    % button up detected
        point1 = point1(1,1:2);              % extract x and y
        point2 = point2(1,1:2);
        
        % Update the zoom_box data
        image_data.zoom_box_x([1 4 5])=min( ...
            round([point1(1) point2(1)]));
        image_data.zoom_box_x([2 3])=max( ...
            round([point1(1) point2(1)]));
        image_data.zoom_box_y([1 2 5])=min( ...
            round([point1(2) point2(2)]));
        image_data.zoom_box_y([3 4])=max( ...
            round([point1(2) point2(2)]));
        
        image_data.zoom_box_set=1;
        
        % Update the image_data
        setappdata(f,'image_data',image_data);
        
        % And update the display
        display_raw_image;
        display_zoomed_image;
        reset_fitting;
    end

    function update_fit_profile_display(source,EventData,reset_mode)
        
        % Get image data
        image_data=getappdata(f,'image_data');
        
        if (reset_mode)
            % Clears the display
            set(h_fit_upper_band_x_estimate,'String',default_string);
            set(h_fit_lower_band_x_estimate,'String',default_string);
            set(h_fit_upper_curve_shape_estimate,'String',default_string);
            set(h_fit_upper_amp_estimate,'String',default_string);
            set(h_fit_lower_amp_estimate,'String',default_string);
            set(h_fit_upper_skew_estimate,'String',default_string);
            set(h_fit_lower_relative_shape_estimate,'String',default_string);      
            set(h_fit_upper_band_x_value,'String',default_string);
            set(h_fit_lower_band_x_value,'String',default_string);
            set(h_fit_upper_curve_shape_value,'String',default_string);
            set(h_fit_upper_amp_value,'String',default_string);
            set(h_fit_lower_amp_value,'String',default_string);
            set(h_fit_upper_skew_value,'String',default_string);
            set(h_fit_lower_relative_shape_value,'String',default_string);
        else
            % Assigns estimates
            set(h_fit_upper_band_x_estimate,'String', ...
                NaN_proof_string(image_data.upper_band_x_estimate));
            set(h_fit_lower_band_x_estimate,'String', ...
                NaN_proof_string(image_data.lower_band_x_estimate));
            set(h_fit_upper_curve_shape_estimate,'String', ...
                NaN_proof_string(image_data.upper_curve_shape_estimate));
            set(h_fit_upper_amp_estimate,'String', ...
                NaN_proof_string(image_data.upper_amp_estimate));
            set(h_fit_lower_amp_estimate,'String', ...
                NaN_proof_string(image_data.lower_amp_estimate));
            set(h_fit_upper_skew_estimate,'String', ...
                NaN_proof_string(image_data.upper_skew_estimate));
            set(h_fit_lower_relative_shape_estimate,'String', ...
                NaN_proof_string(image_data.lower_relative_shape_estimate));

            % Assigns values
            set(h_fit_upper_band_x_value,'String', ...
                NaN_proof_string(image_data.upper_band_x));
            set(h_fit_lower_band_x_value,'String', ...
                NaN_proof_string(image_data.lower_band_x));
            set(h_fit_upper_curve_shape_value,'String', ...
                NaN_proof_string(image_data.upper_curve_shape));
            set(h_fit_upper_amp_value,'String', ...
                NaN_proof_string(image_data.upper_amp));
            set(h_fit_lower_amp_value,'String', ...
                NaN_proof_string(image_data.lower_amp));
            set(h_fit_upper_skew_value,'String', ...
                NaN_proof_string(image_data.upper_skew));
            set(h_fit_lower_relative_shape_value,'String', ...
                NaN_proof_string(image_data.lower_relative_shape));
        end
        
         % Update the image_data
        setappdata(f,'image_data',image_data);
    end

    function update_output_display(source,EventData,reset_mode)
        
        % Get image data
        image_data=getappdata(f,'image_data');
        
        if (reset_mode)
            % Clears the display
            set(h_output_area1_value,'String',default_string);
            set(h_output_area2_value,'String',default_string);
            set(h_output_total_area_value,'String',default_string);
            set(h_output_rel_area1_value,'String',default_string);
            set(h_output_rel_area2_value,'String',default_string);
            set(h_output_r_squared_value,'String',default_string);
        else
            % Assigns values
            set(h_output_area1_value,'String', ...
                sprintf('%6g',image_data.area(1)));
            set(h_output_area2_value,'String', ...
                sprintf('%6g',image_data.area(2)));
            set(h_output_total_area_value,'String', ...
                sprintf('%6g',image_data.total_area));
            set(h_output_rel_area1_value,'String', ...
                sprintf('%6g',image_data.rel_area(1)));
            set(h_output_rel_area2_value,'String', ...
                sprintf('%4g',image_data.rel_area(2)));
            set(h_output_r_squared_value,'String', ...
                NaN_proof_string(image_data.r_squared));
        end
        
         % Update the image_data
        setappdata(f,'image_data',image_data);
    end

    
end


% Not nested functions

function y=skewed_Gaussian(x,x0,gamma,A,skew1)
    offset=zeros(1,length(x));
    offset((x-x0)>0)=skew1*(x((x-x0)>0)-x0);

    y=A*exp(-gamma*(((x-x0)+offset).^2));
end

function y=skewed_Lorentzian(x,x0,gamma,A,skew1)
    offset=zeros(1,length(x));
    offset((x-x0)>0)=skew1*(x((x-x0)>0)-x0);

    y=(A/pi)*(gamma./(((x-x0)+offset).^2+gamma^2));
end

function [y1,y2,y_profile]=calculate_profile(x,fh,p)

    % fh is a function handle

    % Unpack
    x1=p(1);
    x2=p(2);
    curve_shape1=p(3);
    amp1=p(4);
    amp2=p(5);
    skew1=p(6);
    relative_shape=p(7);

    % And calculate
    y1=fh(x,x1,curve_shape1,amp1,skew1);
    y2=fh(x,x2,relative_shape*curve_shape1,amp2,skew1);
    
    y_profile=y1+y2;
end

function display_string=NaN_proof_string(value)
    default_string='---';

    if (isnan(value))
        display_string=default_string;
    else
        display_string=sprintf('%f',value);
    end
end




