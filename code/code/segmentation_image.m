function varargout = segmentation_image(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segmentation_image_OpeningFcn, ...
                   'gui_OutputFcn',  @segmentation_image_OutputFcn, ...
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


% --- Executes just before segmentation_image is made visible.
function segmentation_image_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segmentation_image (see VARARGIN)

% Choose default command line output for segmentation_image
handles.output = hObject;
clc;
warning off;

global Image;
global seg_image;
global a3;
global F5;
global Fc;
global F4;

F = fft2(a3);                                                               % Perform FFT 
Fa = abs(F);                                                                % Get the magnitude
Fb = log(Fa+1);                                                             % Use log, for perceptual scaling, and +1 since log(0) is undefined
Fc = mat2gray(Fb);                                                          % Convert matrix to grayscale image
axes(handles.axes1);
imshow(Fc);

F1 = fftshift(F);                                                           % Center FFT
F2 = abs(F1);                                                               % Get the magnitude
F3 = log(F2+1);                                                             % Use log, for perceptual scaling, and +1 since log(0) is undefined
F4 = mat2gray(F3);                                                          % Convert matrix to grayscale image
axes(handles.axes2);
imshow(F4);

[p3, p4] = size(F4);
q1 = 400; 
i3_start = floor((p3-q1)/2); 
i3_stop = i3_start + q1;
i4_start = floor((p4-q1)/2);
i4_stop = i4_start + q1; 
F5 = F4(i3_start:i3_stop, i4_start:i4_stop, :);

axes(handles.axes3);
imshow(Image);

axes(handles.axes4);
imshow(a3);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segmentation_image wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = segmentation_image_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Main MENU
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = classify_image;
close(segmentation_image);


%% Pre-Processing
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = preprocessing_image;
close(segmentation_image);



%% Feature Extraction
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global F5
global Fc;
global F4;
h = featureextraction_image(F5,Fc,F4);
close(segmentation_image);
