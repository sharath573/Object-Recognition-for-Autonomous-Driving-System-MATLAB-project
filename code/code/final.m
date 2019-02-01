function varargout = final(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @final_OpeningFcn, ...
                   'gui_OutputFcn',  @final_OutputFcn, ...
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


% --- Executes just before final is made visible.
function final_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to final (see VARARGIN)

% Choose default command line output for final
handles.output = hObject;
ss=ones(300,300);
axes(handles.axes1);
imshow(ss);
axes(handles.axes2);
imshow(ss);
axes(handles.axes3);
imshow(ss);
axes(handles.axes4);
imshow(ss);
axes(handles.axes5);
imshow(ss);
axes(handles.axes6);
imshow(ss);
axes(handles.axes7);
imshow(ss);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes final wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = final_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Object Detection 

%% Read Test Image

% Database Images 
offset=1;
dirname=uigetdir();
D=dir(dirname);
count=0;
for i=3:length(D)
   
    count=count+1;
    files{count}=[dirname '\\' D(i).name];
    I0=files{count};
    I1=imread(I0);
    
    axes(handles.axes1);
    imshow(I1);
    title('Test Cropped Image');
    
    
    
    I = rgb2gray(im2double(I1));
I_ratio=double(I1)./repmat(I,[1 1 3])./255;

% Frame enhancement using a general remapping function
N=20;

I_enhanced2=llf_general(I,@remapping_function,N);

I_enhanced2=repmat(I_enhanced2,[1 1 3]).*I_ratio;


axes(handles.axes2);
imshow(I_enhanced2);
title('Edge-aware Enhancement Image');

Tr=rgb2gray(I_enhanced2);
axes(handles.axes3);
imshow(Tr);
title('Edge Enhanced Gray Image');


axes(handles.axes4);
nbins = 50;
hist(Tr,nbins)
title('Histogram of Gray Image');


%% Detect Feature Points

TestPoints = detectSURFFeatures(Tr);

% Visualize the strongest feature points found in the test image.

axes(handles.axes5);
imshow(Tr);
title('Features Points from Test Image');
hold on;
plot(TestPoints.selectStrongest(100));

[ObjectFeatures, TestPoints] = extractFeatures(Tr,TestPoints);

save('objectFeature.mat','ObjectFeatures');

Standard_Deviation = std2(ObjectFeatures);

Variance = mean2(var(double(ObjectFeatures)));
Feature=[Standard_Deviation,Variance];

xlswrite('te.xls',[Feature]);
end 
   
handles.Feature=Feature;
   
handles.I1=I1;

   % Update handles structure
guidata(hObject, handles);
   

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Feature=handles.Feature;
I1=handles.I1;

Da=xlsread('Trainfeature1.xls');

A='Test Feature matched with Train Feature';
set(handles.edit1,'string',A);


   % Update handles structure
guidata(hObject, handles);





function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
