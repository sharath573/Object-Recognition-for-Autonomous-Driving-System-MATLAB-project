
clear all;
close all;
clc;

% I = double(imread('pepper_color.jpg'));
I = double(imread('hangzhou.jpg'));
image_size1 = size(I,1);
image_size2 = size(I,2);

% denoise image in advance
% H = fspecial('average',[3,3]);
H = fspecial('average',[5,5]);
I = imfilter(I,H,'symmetric');

% vectorize image
R = I(:,:,1);G = I(:,:,2);B = I(:,:,3);
x = [R(:) G(:) B(:)]; N = size(x,1);
% cluster = 8; % predefined segmentation number

%% Unsupervised EM algorithm(EM+MML)
% find number of segmentation using MML
Mmax = 8;Mmin = 3;
Lmin = 1e6;

for m = Mmax:-1:Mmin
  [Wt_hat,Meanmat_hat,Cov_hat] = GMmodel(x ,m);
  logsum = 0;
  mixpdf = 0;
  loglikelihood = 0;
  for i = 1:1:m
    logsum = logsum + log(N*Wt_hat(i)/12);
  end
  for k = 1:1:N
    for i = 1:1:m
      mixpdf = mixpdf +
      Wt_hat(i)*mvnpdf(x(k,:),Meanmat_hat(i,:),Cov_hat(:,:,i));
    end
    loglikelihood = loglikelihood + log(mixpdf);
  end
  Lm = (3/2)*logsum + (m/2)*log(N/2) + m*4/2-loglikelihood;
  if Lm<=Lmin
    Lmin = Lm;
    Wt = Wt_hat;
    Meanmat = Meanmat_hat;
    Cov = Cov_hat;
  end
end
cluster = size(Wt,1);

% estimate parameters using EM_algorithm
% Online file developed by Ravi Shankar, 3rd year B.tech, IIT Guwahati.
[Wt,Meanmat,Cov] = GMmodel(x,cluster);

% load 'EM_supervised.mat'
% load 'Wt_MML.mat'
% load 'Cov_MML.mat'
% load 'Meanmat_MML.mat'

% assign pixels to groups
map_em = zeros(image_size1*image_size2,3);
for i=1:1:N
  L = zeros(1,cluster);
  for j = 1:1:cluster
    invCov = inv(Cov(:,:,j));
    numerator = exp(-0.5*(x(i,:)-Meanmat(j,:))*invCov* (x(i,:)-
    Meanmat(j,:))');
    L(j) = numerator/det(invCov)^-0.5;
  end
  [value,index] = max(L);
  map_em(i,:) = Meanmat(index,:);
end

R_em = reshape(map_em(:,1),image_size1,image_size2);
G_em = reshape(map_em(:,2),image_size1,image_size2);
B_em = reshape(map_em(:,3),image_size1,image_size2);
EM_image = cat(3,R_em, G_em, B_em);

%% K-means clusttering algorithm
newmeans = kmclust(x,cluster);
map_k = zeros(image_size1*image_size2,3);
for i = 1:1:N
  for j =1:1:size(newmeans,1)
    L(j) = norm(newmeans(j,:) - x(i,:),2);
  end
  [value,index] = min(L);
  map_k(i,:) = newmeans(index,:);
end

R_k = reshape(map_k(:,1),image_size1,image_size2);
G_k = reshape(map_k(:,2),image_size1,image_size2);
B_k = reshape(map_k(:,3),image_size1,image_size2);

k_image = cat(3,R_k, G_k, B_k);

% figure(gcf+1);
% subplot(221);image(uint8(k_image));title('k-means algorithm');axis image
% subplot(222);image(uint8(EM_image_Supervised));title('Supervised EM algorithm');axis image
% subplot(223);image(uint8(EM_image));title('Unsupervised EM algorithm');axisimage
% subplot(224);image(uint8(EM_image - EM_image_Supervised));title('Difference');axis image

%original image

figure(gcf);
image(uint8(I));
title('original','FontSize', 15);
axis image

% results of K-means algorithm vs EM algorithm

figure(gcf+1);
subplot(121);
image(uint8(k_image));
title('k-means algorithm');
axis image
subplot(122);
image(uint8(EM_image));
title('Unsupervised EM algorithm');
axis image
