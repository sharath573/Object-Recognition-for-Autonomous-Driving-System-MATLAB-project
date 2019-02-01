clc;                                                                        % Clears Command Window
clear all;                                                                  % Clears Workspace
warning off;                                                                % Disable all warnings

% Create database
imgSet = [imageSet('.\Object Database\object_Benign'),...
         imageSet('.\Object Database\object_Malignant'),...
         imageSet('.\Object Database\object_Normal')];
 
% Loop over the folders
for i = 1:length({imgSet.Description})
    % Loop over images in that particular folder
    for j = 1:[imgSet(i).Count]
         Image = read(imgSet(i),j);                                         % Read image
         Image = im2uint8(Image);                                           % Change integar type
         Image = imresize(Image,[1000,667]);                                % Resize image
         [IDX,sep] = otsu(Image,3);                                         % Perform OTSU thresholding
         [M,N] = size(IDX);                                                 % Find out size i.e. no. of rows and columns
         a2 = zeros(M,N);                                                   % Create a zero matrix to append data in future
        % Loop over pixels in an image
        for i3 = 1:M
            for j3 = 1:N
                % Give some threshold value
                if(IDX(i3,j3)>= 2 )
                    a2(i3,j3) = 1;                                          
                else
                    a2(i3,j3) = 0;
                end
            end
        end
        
        [b,num] = bwlabel(a2,8);                                            % Find number of label connected objects
        count_pixels_per_obj = sum(bsxfun(@eq,b(:),1:num));                 % Count the pixels for every blob being obtained
        [~,ind] = max(count_pixels_per_obj);                                % Find blob corresponding to the maximum pixel
        a2 = (b==ind);                                                      % Take only that blob from entire image

        seg_image = Image;
        seg_image(~a2) = 0;                                                 % Highlight only that blob from original image
        a2 = adapthisteq(seg_image);

        
        F = fft2(a2);                                                       % Perform Fourier Transform
        Fa = abs(F);                                                        % Get the magnitude
        Fb = log(Fa+1);                                                     % Use log, for perceptual scaling, and +1 since log(0) is undefined
        Fc = mat2gray(Fb);                                                  % Convert matrix to grayscale image             

        F1 = fftshift(F);                                                   % Center FFT

        F2 = abs(F1);                                                       % Get the magnitude
        F3 = log(F2+1);                                                     % Use log, for perceptual scaling, and +1 since log(0) is undefined
        F4 = mat2gray(F3);                                                  % Convert matrix to grayscale image     

        [p3, p4] = size(F4);                                                % Find out size of an image
        q1 = 400; 
        i3_start = floor((p3-q1)/2); 
        i3_stop = i3_start + q1;
        i4_start = floor((p4-q1)/2);
        i4_stop = i4_start + q1; 
        F5 = F4(i3_start:i3_stop, i4_start:i4_stop, :);


        GLCM2 = graycomatrix(F5,'Offset',[0 1; -1 1; -1 0; -1 -1]);         % Create gray-level co-occurrence matrix from image
        stats = GLCM_Features1(GLCM2,0)                                     % Find out GLCM features in this
        t1= struct2array(stats)                                             % Convert this structure to an array


        f2(j,:) = t1;                                                       % Make feature vector of all images
    end

    if (i>=1)
        featureD_dft22([(((i-1)*j)+1):(i*j)],:) = f2;                       % Make feature vectors of all images of all folders
    end    
end

save featureD_dft22 featureD_dft22;                                         % Save this as a ".mat" file