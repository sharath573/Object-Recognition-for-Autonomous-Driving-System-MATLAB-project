I1=imread('c1.jpg');
I = rgb2gray(im2double(I1));
I_ratio=double(I1)./repmat(I,[1 1 3])./255;

% Frame enhancement using a general remapping function
N=20;

I_enhanced2=llf_general(I,@remapping_function,N);

I_enhanced2=repmat(I_enhanced2,[1 1 3]).*I_ratio;


figure,
imshow(I_enhanced2);
title('Edge-aware Enhancement Image');

boxImage=rgb2gray(I_enhanced2);
figure,
imshow(boxImage);
title('Edge Enhanced Gray Image');
    figure,
    imshow(boxImage);
    title('This is Fake Image');
    

%%
% Read the target image containing a cluttered scene.
As1=imread('6.jpg');
As = rgb2gray(im2double(As1));

figure,
imshow(As);
title('Whole Test Image');

%% Step 2: Detect Feature Points
% Detect feature points in both images.
boxPoints = detectSURFFeatures(boxImage);
scenePoints = detectSURFFeatures(As);

%% 
% Visualize the strongest feature points found in the reference image.
figure,
 imshow(boxImage);
title('F.Points from Fake Image');
hold on;
plot(boxPoints.selectStrongest(300));

%% 
% Visualize the strongest feature points found in the target image.
figure,
 imshow(As);
title('F.Points from Test Image');
hold on;
plot(scenePoints.selectStrongest(300));

%% Step 3: Extract Feature Descriptors
% Extract feature descriptors at the interest points in both images.
[boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints);
[sceneFeatures, scenePoints] = extractFeatures(As, scenePoints);

%% Step 4: Find Putative Point Matches
% Match the features using their descriptors. 
boxPairs = matchFeatures(boxFeatures, sceneFeatures);

%% 
% Display putatively matched features. 
matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
matchedScenePoints = scenePoints(boxPairs(:, 2), :);
figure,
showMatchedFeatures(boxImage, As, matchedBoxPoints, ...
    matchedScenePoints, 'montage');
title(' Matched Points (Outliers)');

%% Step 5: Locate the Object in the Scene Using Putative Matches
% |estimateGeometricTransform| calculates the transformation relating the
% matched points, while eliminating outliers. This transformation allows us
% to localize the object in the scene.
[tform, inlierBoxPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'affine');

%%
% Display the matching point pairs with the outliers removed
figure,
showMatchedFeatures(boxImage, As, inlierBoxPoints, ...
    inlierScenePoints, 'montage');
title('Matched Points (Inliers)');

%% 
% Get the bounding polygon of the reference image.
boxPolygon = [1, 1;...                           % top-left
        size(boxImage, 2), 1;...                 % top-right
        size(boxImage, 2), size(boxImage, 1);... % bottom-right
        1, size(boxImage, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon

%%
% Transform the polygon into the coordinate system of the target image.
% The transformed polygon indicates the location of the object in the
% scene.
newBoxPolygon = transformPointsForward(tform, boxPolygon);    

%%
% Display the detected object.
figure,
 imshow(uint8(As1));
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'R');
title('Detected Fake Person');

