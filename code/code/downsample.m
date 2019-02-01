
function [R,subwindow_child] = downsample(I, filter, subwindow)

r = size(I,1);
c = size(I,2);
if ~exist('subwindow','var')
    subwindow = [1 r 1 c];
end
subwindow_child = child_window(subwindow);

border_mode = 'reweighted';
%border_mode = 'symmetric';

switch border_mode
    case 'reweighted'       
        % low pass, convolve with 2D separable filter
        R = imfilter(I,filter);
        
        % reweight, brute force weights from 1's in valid image positions
        Z = imfilter(ones(size(I)),filter);        
        R = R./Z;
        
    otherwise
        % low pass, convolve with 2D separable filter
        R = imfilter(I,filter,border_mode);        
end

% decimate
reven = mod(subwindow(1),2)==0;
ceven = mod(subwindow(3),2)==0;
R = R(1+reven:2:r, 1+ceven:2:c, :);

end