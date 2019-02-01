%% Fish Detection 
% Database Images 
offset=1;
dirname=uigetdir();
D=dir(dirname);
count=0;
for i=3:length(D)
   
    count=count+1;
    files{count}=[dirname '\\' D(i).name];
    I0=files{count};
    F=imread(I0);
    
F1=rgb2gray(F);


% Feature Extraction using SURF

fishPoints = detectSURFFeatures(F1);


% Visualize the strongest feature points found in the reference image.

figure,
imshow(F1);
title('F.Points from Train Image');
hold on;
plot(fishPoints.selectStrongest(100));

% Extract feature descriptors at the interest points in both images.

[fishFeatures, fishPoints] = extractFeatures(F1, fishPoints);



Standard_Deviation = std2(fishFeatures);

Variance = mean2(var(double(fishFeatures)));
Feature=[Standard_Deviation,Variance];

xlswrite('Trainfeaturenew.xls', [Feature], 1, sprintf('A%d',offset));
offset = offset + 1;
end
