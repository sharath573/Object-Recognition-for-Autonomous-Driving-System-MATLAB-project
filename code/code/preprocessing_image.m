function varargout = preprocessing_image(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @preprocessing_image_OpeningFcn, ...
                   'gui_OutputFcn',  @preprocessing_image_OutputFcn, ...
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


% --- Executes just before preprocessing_image is made visible.
function preprocessing_image_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to preprocessing_image (see VARARGIN)


% Choose default command line output for preprocessing_image
handles.output = hObject;
clc;
warning off;
global Image
global seg_image
global a3
Image = im2uint8(Image);                                                    % Convert datatype
Image = imresize(Image,[1000,667]);                                         % Resize it
axes(handles.axes1);                                                        % Define the axes to show image
imshow(Image);                                                              % Show image at axes1

[IDX,sep] = otsu(Image,3);                                                  % Perform OTSU thresholding on an image
[M,N] = size(IDX);
a2 = zeros(M,N);

% Give threshold value to get thresholded image. Loop over all pixel values
% of an image
for i3 = 1:M
    for j3 = 1:N
        if(IDX(i3,j3)>= 2 )
            a2(i3,j3) = 1;
        else
            a2(i3,j3) = 0;
        end
    end
end

[b,num] = bwlabel(a2,8);                                                    % Find label connected objects
count_pixels_per_obj = sum(bsxfun(@eq,b(:),1:num));                         % Get sum of all pixels of all blobs
[~,ind] = max(count_pixels_per_obj);                                        % Find blob corresponding to max. number of pixels
a2 = (b==ind);                                                              % Get particular blob from an image 
seg_image = Image;
seg_image(~a2) = 0;                                                         % Highlight only that blob from original image

% axes(handles.axes2);
% imshow(seg_image);                              
a3 = adapthisteq(seg_image);
axes(handles.axes2);
imshow(a3);



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes preprocessing_image wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = preprocessing_image_OutputFcn(hObject, eventdata, handles) 
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
close(preprocessing_image);


%% Segmentation
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Image;
global seg_image;
global a3;
h = segmentation_image(Image,seg_image,a3);
close(preprocessing_image);
