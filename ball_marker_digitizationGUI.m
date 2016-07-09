function varargout = ball_marker_digitizationGUI(varargin)
% BALL_MARKER_DIGITIZATIONGUI MATLAB code for ball_marker_digitizationGUI.fig
%      BALL_MARKER_DIGITIZATIONGUI, by itself, creates a new BALL_MARKER_DIGITIZATIONGUI or raises the existing
%      singleton*.
%
%      H = BALL_MARKER_DIGITIZATIONGUI returns the handle to a new BALL_MARKER_DIGITIZATIONGUI or the handle to
%      the existing singleton*.
%
%      BALL_MARKER_DIGITIZATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BALL_MARKER_DIGITIZATIONGUI.M with the given input arguments.
%
%      BALL_MARKER_DIGITIZATIONGUI('Property','Value',...) creates a new BALL_MARKER_DIGITIZATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ball_marker_digitizationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ball_marker_digitizationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ball_marker_digitizationGUI

% Last Modified by GUIDE v2.5 29-Apr-2014 17:11:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ball_marker_digitizationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ball_marker_digitizationGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ball_marker_digitizationGUI is made visible.
function ball_marker_digitizationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ball_marker_digitizationGUI (see VARARGIN)

% Choose default command line output for ball_marker_digitizationGUI
handles.output = hObject;

%Disable buttons
set(handles.marker1,'enable','off');
set(handles.marker2,'enable','off');
set(handles.marker3,'enable','off');
set(handles.marker4,'enable','off');
set(handles.next_frame,'enable','off');
set(handles.prev_frame,'enable','off');
set(handles.pause_button,'enable','off');
set(handles.exit_button,'visible','off');
set(handles.frame_num,'enable','off');
set(handles.frame_saved,'enable','off');
set(handles.pitchmenu,'enable','off');
set(handles.video_axes,'visible','off');
set(handles.play_button,'enable','off');
set(handles.use_frame,'enable','off');
set(handles.set_release,'visible','off');
set(handles.image_cal,'enable','off');
set(handles.release_pos,'enable','off');
set(handles.ball_spin,'enable','off');
set(handles.origin_point,'visible','off');
set(handles.load_sag,'visible','off');

handles.ball_kinematics = 0;
handles.cal = 0;
handles.ball_rel = 0;
handles.cal_done = 0;
handles.spin_done = 0;
handles.rel_done = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ball_marker_digitizationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ball_marker_digitizationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in use_frame.
function use_frame_Callback(hObject, eventdata, handles)
% hObject    handle to use_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Disable/enable buttons
set(handles.use_frame,'enable','off');
set(handles.marker1,'enable','on');
set(handles.marker2,'enable','on');
set(handles.marker3,'enable','on');
set(handles.marker4,'enable','on');

%Add ball detection algorithm (handles.ballradius)
if isempty(handles.ini_radius_pixels)
   set(gcf,'name','Select either side of the ball');
   [x,~] = ginput(2);
   handles.ini_radius_pixels = abs(x(2)-x(1))/2;
end

%Fit circle to ball
% imshow(handles.mov.cdata-handles.background);
pixel_radius_range = [round(handles.ini_radius_pixels/2) round(handles.ini_radius_pixels)];
[centers, radii] = imfindcircles(handles.mov.cdata,pixel_radius_range,'ObjectPolarity','bright','Sensitivity',0.95);
handles.circle = viscircles(centers(1,:),radii(1)); %First row is best 'circle'
handles.center = centers(1,:);
handles.radius = radii(1);
handles.zoom_lims = [centers(1,1)-1.25*radii(1), centers(1,1)+1.25*radii(1);
                     centers(1,2)-1.25*radii(1), centers(1,2)+1.25*radii(1)];
xlim(handles.zoom_lims(1,:)); %Zoom to identified ball
ylim(handles.zoom_lims(2,:));
handles.ballOrig = [centers(1,1), handles.mov_obj.Height-centers(1,2)]; %pixels
handles.ballcenterdata = [handles.ballcenterdata; handles.ballOrig];
handles.ballradiusdata = [handles.ballradiusdata; handles.radius];
impoint(handles.video_axes, handles.center);

%ID left-right and up-down max/min
handles.Hscale = handles.radius / handles.ballradius; %pixels/m
handles.Vscale = handles.radius / handles.ballradius; %pixels/m

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in marker1.
function marker1_Callback(hObject, eventdata, handles)
% hObject    handle to marker1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.marker1,'enable','off');
[x,z] = ginput(1);

xs = (x - handles.ballOrig(1))/handles.Hscale;
zs = (handles.mov_obj.Height - z - handles.ballOrig(2))/handles.Vscale;
ys = -abs(sqrt(handles.ballradius^2 - xs^2 - zs^2)); %negative because viewing from back of ball

ts = handles.frame_index/handles.OrigFrameRate;
handles.marker1data = [handles.marker1data; ts, xs, ys, zs];

if size(handles.marker1data,1) > str2double(get(handles.frame_saved,'String'));
    set(handles.frame_saved,'String',num2str(size(handles.marker1data,1)))
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in marker2.
function marker2_Callback(hObject, eventdata, handles)
% hObject    handle to marker2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.marker2,'enable','off');
[x,z] = ginput(1);

xs = (x - handles.ballOrig(1))/handles.Hscale;
zs = (handles.mov_obj.Height - z - handles.ballOrig(2))/handles.Vscale;
ys = -abs(sqrt(handles.ballradius^2 - xs^2 - zs^2)); %negative because viewing from back of ball

ts = handles.frame_index/handles.OrigFrameRate;
handles.marker2data = [handles.marker2data; ts, xs, ys, zs];

if size(handles.marker2data,1) > str2double(get(handles.frame_saved,'String'));
    set(handles.frame_saved,'String',num2str(size(handles.marker2data,1)))
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in marker3.
function marker3_Callback(hObject, eventdata, handles)
% hObject    handle to marker3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.marker3,'enable','off');
[x,z] = ginput(1);

xs = (x - handles.ballOrig(1))/handles.Hscale;
zs = (handles.mov_obj.Height - z - handles.ballOrig(2))/handles.Vscale;
ys = -abs(sqrt(handles.ballradius^2 - xs^2 - zs^2)); %negative because viewing from back of ball

ts = handles.frame_index/handles.OrigFrameRate;
handles.marker3data = [handles.marker3data; ts, xs, ys, zs];

if size(handles.marker3data,1) > str2double(get(handles.frame_saved,'String'));
    set(handles.frame_saved,'String',num2str(size(handles.marker3data,1)))
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in marker4.
function marker4_Callback(hObject, eventdata, handles)
% hObject    handle to marker4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.marker4,'enable','off');
[x,z] = ginput(1);

xs = (x - handles.ballOrig(1))/handles.Hscale;
zs = (handles.mov_obj.Height - z - handles.ballOrig(2))/handles.Vscale;
ys = -abs(sqrt(handles.ballradius^2 - xs^2 - zs^2)); %negative because viewing from back of ball

ts = handles.frame_index/handles.OrigFrameRate;
handles.marker4data = [handles.marker4data; ts, xs, ys, zs];

if size(handles.marker4data,1) > str2double(get(handles.frame_saved,'String'));
    set(handles.frame_saved,'String',num2str(size(handles.marker4data,1)))
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in prev_frame.
function prev_frame_Callback(hObject, eventdata, handles)
% hObject    handle to prev_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Update frame index
handles.frame_index = handles.frame_index - 1;
set(handles.frame_num,'String',num2str(handles.frame_index));

%Disable previous frame button if necessary
if handles.frame_index == 1
    set(handles.prev_frame,'enable','off');
else
    set(handles.prev_frame,'enable','on');
end

%Disable next frame button if necessary
if handles.frame_index == handles.mov_obj.NumberOfFrames
    set(handles.next_frame,'enable','off');
else
    set(handles.next_frame,'enable','on');
end

%Disable/enable buttons
if handles.ball_kinematics == 1
    set(handles.use_frame,'enable','on');
else
    set(handles.use_frame,'enable','off');
end
set(handles.marker1,'enable','off');
set(handles.marker2,'enable','off');
set(handles.marker3,'enable','off');
set(handles.marker4,'enable','off');

%Reset circle plot
if ~isempty(handles.circle)
    delete(handles.circle);
    handles.circle = [];
end

%Display updated video frame
vidFrames = read(handles.mov_obj,handles.frame_index);
mov.cdata = vidFrames(:,:,:,1);
imshow(mov.cdata);

handles.mov = mov;

% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in next_frame.
function next_frame_Callback(hObject, eventdata, handles)
% hObject    handle to next_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Update frame index
handles.frame_index = handles.frame_index + 1;
set(handles.frame_num,'String',num2str(handles.frame_index));

%Disable previous frame button if necessary
if handles.frame_index == 1
    set(handles.prev_frame,'enable','off');
else
    set(handles.prev_frame,'enable','on');
end

%Disable next frame button if necessary
if handles.frame_index == handles.mov_obj.NumberOfFrames
    set(handles.next_frame,'enable','off');
else
    set(handles.next_frame,'enable','on');
end

%Disable/enable buttons
if handles.ball_kinematics == 1
    set(handles.use_frame,'enable','on');
else
    set(handles.use_frame,'enable','off');
end
set(handles.marker1,'enable','off');
set(handles.marker2,'enable','off');
set(handles.marker3,'enable','off');
set(handles.marker4,'enable','off');

%Reset circle plot
if ~isempty(handles.circle)
    delete(handles.circle);
    handles.circle = [];
end

%Display updated video frame
vidFrames = read(handles.mov_obj,handles.frame_index);
mov.cdata = vidFrames(:,:,:,1);
imshow(mov.cdata);
brighten(handles.video_axes,0.99);

handles.mov = mov;

% Update handles structure
guidata(hObject, handles);


function frame_num_Callback(hObject, eventdata, handles)
% hObject    handle to frame_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_num as text
%        str2double(get(hObject,'String')) returns contents of frame_num as a double

%Update frame index
handles.frame_index = str2double(get(handles.frame_num,'String'));


%Disable previous frame button if necessary
if handles.frame_index == 1
    set(handles.prev_frame,'enable','off');
else
    set(handles.prev_frame,'enable','on');
end

%Disable next frame button if necessary
if handles.frame_index == handles.mov_obj.NumberOfFrames
    set(handles.next_frame,'enable','off');
else
    set(handles.next_frame,'enable','on');
end

%Disable/enable buttons
if handles.ball_kinematics == 1
    set(handles.use_frame,'enable','on');
else
    set(handles.use_frame,'enable','off');
end
set(handles.marker1,'enable','off');
set(handles.marker2,'enable','off');
set(handles.marker3,'enable','off');
set(handles.marker4,'enable','off');

%Reset circle plot
if ~isempty(handles.circle)
    delete(handles.circle);
    handles.circle = [];
end

%Display updated video frame
vidFrames = read(handles.mov_obj,handles.frame_index);
mov.cdata = vidFrames(:,:,:,1);
imshow(mov.cdata);
brighten(handles.video_axes,0.99);

handles.mov = mov;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function frame_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frame_saved_Callback(hObject, eventdata, handles)
% hObject    handle to frame_saved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_saved as text
%        str2double(get(hObject,'String')) returns contents of frame_saved as a double


% --- Executes during object creation, after setting all properties.
function frame_saved_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_saved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exit_button.
function exit_button_Callback(hObject, eventdata, handles)
% hObject    handle to exit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dones = [handles.cal_done, handles.spin_done, handles.rel_done];
if handles.ball_kinematics == 1 && dones(2)==0
    handles.spin_done = 1;
    set(handles.ball_spin,'visible','off');
    filename = handles.filename;
    ind = regexpi(filename,'.avi');
    filename = sprintf('%s.mat',filename(1:ind-1));
    save(filename,'handles');
    handles.ball_kinematics = 0;
elseif handles.ball_rel == 1 && dones(3)==0
    handles.rel_done = 1;
    set(handles.release_pos,'visible','off');
    filename = handles.filename;
    ind = regexpi(filename,'.avi');
    filename = sprintf('%s.mat',filename(1:ind-1));
    save(filename,'handles');
    handles.ball_rel = 0;
elseif handles.cal == 1 && dones(1) == 0
    handles.cal_done = 1;
    set(handles.image_cal,'visible','off');
    filename = handles.filename;
    ind = regexpi(filename,'.avi');
    filename = sprintf('%s.mat',filename(1:ind-1));
    save(filename,'handles');
    handles.cal = 0;
elseif sum(dones)==3
    uiresume;
end   

guidata(hObject, handles);




function frame_rate_Callback(hObject, eventdata, handles)
% hObject    handle to frame_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_rate as text
%        str2double(get(hObject,'String')) returns contents of frame_rate as a double


% --- Executes during object creation, after setting all properties.
function frame_rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in play_button.
function play_button_Callback(hObject, eventdata, handles)
% hObject    handle to play_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Enable/disable buttons
set(handles.play_button,'enable','off');
set(handles.pause_button,'enable','on');
set(handles.prev_frame,'enable','off');
set(handles.next_frame,'enable','off');

%Update pause variable
handles_check.pause = 0;


%Update frame index
while handles.frame_index < handles.mov_obj.NumberOfFrames && handles_check.pause == 0
    %Set new frame index
    set(handles.frame_num,'String',num2str(handles.frame_index));
    
    %Show movie frame
    vidFrames = read(handles.mov_obj,handles.frame_index);
    mov.cdata = vidFrames(:,:,:,1);
    imshow(mov.cdata);
    brighten(handles.video_axes,0.99);
    
    %Update handles structure with new movie frame
    handles.mov = mov;
    
    %Increment frame _index
    handles.frame_index = handles.frame_index + 1;
    
    %Pause for standard frame rate video playback speed
    pause(1/30);
    
    %Check to see if pause has been pressed 
    handles_check = guidata(hObject);
end
handles.pause = 0;
guidata(hObject, handles);




% --- Executes on button press in pause_button.
function pause_button_Callback(hObject, eventdata, handles)
% hObject    handle to pause_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Enable/disable buttons
set(handles.pause_button,'enable','off');
set(handles.play_button,'enable','on');
set(handles.prev_frame,'enable','on');
set(handles.next_frame,'enable','on');

%Update handles
handles.pause = 1;
guidata(hObject, handles);


% --- Executes on button press in continuebutton.
function continuebutton_Callback(hObject, eventdata, handles)
% hObject    handle to continuebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Extract information from user inputs
handles.OrigFrameRate = str2double(get(handles.frame_rate,'String'));
handles.pitch_type = get(handles.pitchmenu,'Value');
handles.subject = str2double(get(handles.subject_num,'String'));
handles.ball_type = get(handles.ballmenu,'Value');

set(handles.pitchmenu,'visible','off');
set(handles.ballmenu,'visible','off');
set(handles.frame_rate,'visible','off');
set(handles.subject_num,'visible','off');
set(handles.text7,'visible','off');
set(handles.text6,'visible','off');
set(handles.text5,'visible','off');
set(handles.text3,'visible','off');
set(handles.continuebutton,'visible','off');

%Load posterior video data
[datafile, datapath] = uigetfile('*.*','Pick a posterior view video file');
handles.filename = strcat(datapath,datafile);
movie = strcat(datapath,datafile); 
obj = VideoReader(movie);

%Fill in edit boxes
handles.frame_index = 1;
set(handles.frame_num,'String',num2str(handles.frame_index));
set(handles.frame_saved,'String',num2str(0));

%Plot first image from video 
set(handles.video_axes,'Visible','on');
axes(handles.video_axes);
vidFrames = read(obj,1);
mov.cdata = vidFrames(:,:,:,1);
imshow(mov.cdata);

handles.mov = mov;
handles.mov_obj = obj;
handles.background = mov.cdata;
handles.pause = 0;

%Initialize position data matrices
handles.marker1data = [];
handles.marker2data = [];
handles.marker3data = [];
handles.marker4data = [];
handles.ballcenterdata = [];
handles.ballradiusdata = [];
handles.ini_radius_pixels = [];
handles.circle = [];

%Assign correct ball radius
if handles.ball_type==1 %baseball
    handles.ballradius = 0.036; %meters
elseif handles.ball_type==2 %softball
    handles.ballradius = 0.048; %meters
elseif handles.ball_type==3 %basketball
    handles.ballradius = 0.121; %meters
end

%Enable video navigation buttons and 'set release frame' button
set(handles.set_release,'visible','on');
set(handles.next_frame,'enable','on');
set(handles.prev_frame,'enable','on');
set(handles.pause_button,'enable','on');
set(handles.play_button,'enable','on');

guidata(hObject, handles);





function subject_num_Callback(hObject, eventdata, handles)
% hObject    handle to subject_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subject_num as text
%        str2double(get(hObject,'String')) returns contents of subject_num as a double


% --- Executes during object creation, after setting all properties.
function subject_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subject_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ballmenu.
function ballmenu_Callback(hObject, eventdata, handles)
% hObject    handle to ballmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ballmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ballmenu

contents = cellstr(get(hObject,'String'));
value = contents{get(hObject,'Value')};
if strcmpi(value,'baseball')
    set(handles.pitchmenu,'String',{'Pitch Type';'Fast';'Change';'Slider';'Curve';'Cutter'});
elseif strcmpi(value,'softball')
    set(handles.pitchmenu,'String',{'Pitch Type';'Rise';'Drop';'Screw';'Curve';'Change';'Fast'});    
elseif strcmpi(value,'basketball')
    set(handles.pitchmenu,'String',{'Shot Type';'Freethrow';'Set';'Jump';'Pass'});    
end
set(handles.pitchmenu,'enable','on');

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function ballmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ballmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pitchmenu.
function pitchmenu_Callback(hObject, eventdata, handles)
% hObject    handle to pitchmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pitchmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pitchmenu


% --- Executes during object creation, after setting all properties.
function pitchmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pitchmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_release.
function set_release_Callback(hObject, eventdata, handles)
% hObject    handle to set_release (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.release_frame = handles.frame_index;
set(handles.set_release,'visible','off');
set(handles.exit_button,'visible','on');
set(handles.frame_num,'enable','on');
set(handles.frame_saved,'enable','on');
set(handles.image_cal,'enable','on');
set(handles.release_pos,'enable','on');
set(handles.ball_spin,'enable','on');

guidata(hObject, handles);


% --- Executes on button press in image_cal.
function image_cal_Callback(hObject, eventdata, handles)
% hObject    handle to image_cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cal = 1;
set(handles.image_cal,'enable','off');

guidata(hObject, handles);

% --- Executes on button press in release_pos.
function release_pos_Callback(hObject, eventdata, handles)
% hObject    handle to release_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ball_rel = 1;
set(handles.use_frame,'enable','off');
set(handles.release_pos,'enable','off');

%Pick out release position from posterior view

%Update video frame to be instant of release
handles.frame_index = handles.release_frame;
vidFrames = read(handles.mov_obj,handles.frame_index);
mov.cdata = vidFrames(:,:,:,1);
imshow(mov.cdata);
brighten(handles.video_axes,0.99);
handles.mov = mov;

%Fit circle to ball
if isempty(handles.ini_radius_pixels)
   set(gcf,'name','Select either side of the ball');
   [x,~] = ginput(2);
   handles.ini_radius_pixels = abs(x(2)-x(1))/2;
end
pixel_radius_range = [round(handles.ini_radius_pixels/2) round(handles.ini_radius_pixels)];
[centers, radii] = imfindcircles(handles.mov.cdata,pixel_radius_range,'ObjectPolarity','bright','Sensitivity',0.95);
handles.circle = viscircles(centers(1,:),radii(1)); %First row is best 'circle'
handles.center = centers(1,:);
handles.radius = radii(1);
handles.ballOrig = [centers(1,1), handles.mov_obj.Height-centers(1,2)]; %pixels
impoint(handles.video_axes, handles.center);

%ID left-right and up-down max/min
handles.Hscale = handles.radius / handles.ballradius; %pixels/m
handles.Vscale = handles.radius / handles.ballradius; %pixels/m

%Enable origin point button
set(handles.origin_point,'visible','on');
handles.post_process = 1;
handles.sag_process = 0;

guidata(hObject, handles);

% --- Executes on button press in ball_spin.
function ball_spin_Callback(hObject, eventdata, handles)
% hObject    handle to ball_spin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Allow user to go through ball_spin algorithm
handles.ball_kinematics = 1;
set(handles.use_frame,'enable','on');
set(handles.ball_spin,'enable','off');

guidata(hObject, handles);


% --- Executes on button press in origin_point.
function origin_point_Callback(hObject, eventdata, handles)
% hObject    handle to origin_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Select origin point 
set(gcf,'name','Select origin point');
[x,z] = ginput(1);

%Identify x (horizontal) and z (vertical) components of ball rel to origin
xs = -(x - handles.ballOrig(1))/handles.Hscale;
zs = -(handles.mov_obj.Height - z - handles.ballOrig(2))/handles.Vscale;

%Assign position to output variable
if handles.post_process == 1
    handles.post_view_rel = [xs, zs];
    handles.post_process = 0;
    set(handles.load_sag,'visible','on');
elseif handles.sag_process == 1
    handles.sag_view_rel = [xs, zs];
    handles.sag_process = 0;
end

%Enable button to load sagital view
set(handles.origin_point,'enable','off');

guidata(hObject, handles);


% --- Executes on button press in load_sag.
function load_sag_Callback(hObject, eventdata, handles)
% hObject    handle to load_sag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.load_sag,'visible','off');

%Load and show sagittal video data at release
[datafile, datapath] = uigetfile('*.*','Pick a posterior view video file');
movie = strcat(datapath,datafile); 
obj = VideoReader(movie);

handles.frame_index = handles.release_frame;
vidFrames = read(obj,handles.frame_index);
mov.cdata = vidFrames(:,:,:,1);
imshow(mov.cdata);

%This might need to be replaced with just clicking on the ball
%Fit circle to ball
set(gcf,'name','Select either side of the ball');
[x,~] = ginput(2);
handles.ini_radius_pixels = abs(x(2)-x(1))/2;

pixel_radius_range = [round(handles.ini_radius_pixels/2) round(handles.ini_radius_pixels)];
[centers, radii] = imfindcircles(handles.mov.cdata,pixel_radius_range,'ObjectPolarity','bright','Sensitivity',0.95);
handles.circle = viscircles(centers(1,:),radii(1)); %First row is best 'circle'
handles.center = centers(1,:);
handles.radius = radii(1);
handles.ballOrig = [centers(1,1), handles.mov_obj.Height-centers(1,2)]; %pixels
impoint(handles.video_axes, handles.center);

%ID left-right and up-down max/min
handles.Hscale = handles.radius / handles.ballradius; %pixels/m
handles.Vscale = handles.radius / handles.ballradius; %pixels/m

%Enable origin point button
set(handles.origin_point,'enable','on');
handles.post_process = 1;
handles.sag_process = 0;

guidata(hObject, handles);







