
function [Wt,Meanmat,Cov] = GMmodel(x,no_gaus_distr)

% the above expression is the definition of the function GMmodel which 
% takes in the training data and the number of gaussian distribution 
% to model the data as input and the output consist of the three matrices, 
% first one is mixing ratios whch is P * N matrix and contains the 
% fraction of datapoints belonging to each gaussian distribution, the
% second one is mean matrix that contains the means of each gaussian
% distribution in P * D matix and the third one is covariance matrix which
% is D * D * P matrix and has covariance of each distribution in D * D
% matrix.

%-----------------------------------------------------//---------------------------------------------------------------------------------------------------%
         % initialization of the Meanmat, Wt and Cov is done in this block
         % of code. Initially K-mean clustering technique is being applied
         % to find the weights, means and covariance matrices.

         sizemat = size(x);
         tot_rows = sizemat(1);
         dimension = sizemat(2);
         Wt = zeros(no_gaus_distr,1);
         Cov = zeros(dimension,dimension,no_gaus_distr);
         Meanmat = kmclust(x,no_gaus_distr);
         
         % kmclust is a function that does the K-mean clustering out of
         % many data sets and returns the mean of each cluster.
         
         Eff_no_pnts = zeros(no_gaus_distr,1);
         indexcol = zeros(tot_rows,1);
         
         % the for loop used next is for indexing each row to the mean from
         % which its distance is minimum and the output is stored in
         % indexcol matrix.
    
         
         for currow = 1:tot_rows
                threshold = 10^20;
                for curmean = 1:no_gaus_distr
                    sqdist = 0;
                    for curdim = 1:dimension
                        sqdist = sqdist + ((x(currow,curdim) - Meanmat(curmean,curdim))^2);
                    end
                    dist = sqdist^(0.5);
                    if (dist <= threshold)
                       indexcol(currow,1) = curmean;
                       threshold = dist;
                    end
                end
         end
         
         % the covariance matrix is initialised first with values that are
         % found using the datapoints which are belonging to the same
         % cluster.
         
         for loopvar1 = 1:no_gaus_distr
             count = 0;
             tempcov = zeros(dimension,dimension);
             for loopvar2 = 1:tot_rows
                    if (indexcol(loopvar2,1) == loopvar1)
                        count = count + 1;
                        tempcov = tempcov + ((x(loopvar2,:)-Meanmat(loopvar1,:))')*(x(loopvar2,:)-Meanmat(loopvar1,:));
                    end
             end
             Wt(loopvar1,1) = count/tot_rows;
             tempcov = tempcov./count;
             %det(tempcov)
             Cov(:,:,loopvar1) = tempcov;
             %if (loopvar1 == 1)
             %    Cov(:,:) = tempcov(:,:);
             %else
             %    Cov = [Cov;tempcov];
             %end
         end
         %save('covariance first.mat','Cov');
         %exit (0);
         %tempvar2 = 0;
         %for currow = 1:tot_rows
         %   tempvar = 0;
             %cov_var = 1;
         %   for curdistr = 1:no_gaus_distr
         %        %tempcov = Cov(cov_var:(dimension*curdistr),:);
         %        tempcov = Cov(:,:,curdistr);
                 %cov_var = cov_var + dimension; 
         %        exp_part = exp(-0.5*(x(currow,:)-Meanmat(curdistr,:))*(1/tempcov)*((x(currow,:)-Meanmat(curdistr,:))'));
         %        tempvar = tempvar + ((Wt(curdistr,1))*(1/((det(tempcov))^(0.5)))*exp_part);
         %    end
         %    tempvar2 = tempvar2 + log(tempvar);
         %end
         %likelihoodnew = -((tot_rows*dimension)/2)*log(2*pi) + tempvar2;
         %flag_new = exp(likelihoodnew*(10^-5));
         likelihoodold = -10^30;
         likelihoodnew = -10^25;
         flag = 10^(-10);
         %flag_new = 10000;
         %flag_old = 1000;
         iteration = 0;
         
         % responsibilities matrix is nothing but the responsibiliets of each
         % gaussian to take each point and it is a N * P matrix one row for
         % each data set and cloumn for each gaussian distribution.
         
         responsibilities = zeros(tot_rows,no_gaus_distr);
         
         
%------------------------------------------------------//-------------------------------------------------------------------------------------------%
         % loop starts here 

         % the loop runs until the difference between successive iteration
         % becomes less than 0.001 times the value of log of the
         % probability of observing the training set of data
         % while (abs(likelihoodold-likelihoodnew)>0.001 && iteration <=500)
         while (((likelihoodnew-likelihoodold)>flag || iteration<25) && iteration<200)
               iteration = iteration + 1 %abs(likelihoodold-likelihoodnew)
               likelihoodold = likelihoodnew;
               %flag_old = flag_new;
 
               
               
%----------------------------------------------------//----------------------------------------------------------------------------------------------%               
               % this chunk involves finding the responsibilities of each
               % gaussian distribution for each point in N*P matrix.
               % inv is a predefined function of matlab that finds the
               % inverse of the matrix given in its argument. This is
               % essentially the most time consuming part if the dimension
               % of feature is very large.
               
               for currow = 1:tot_rows 
                   %cov_var = 1;
                   evidence = 0;
                   for loopvar1 = 1:no_gaus_distr
                       %tempcov = Cov(cov_var:(dimension*loopvar1),:);
                       tempcov = Cov(:,:,loopvar1);
                       %cov_var = cov_var + dimension;
                       exp_part = exp(-0.5*(x(currow,:)-Meanmat(loopvar1,:))*(inv(tempcov))*((x(currow,:)-Meanmat(loopvar1,:))'));
                       denominator = (Wt(loopvar1,1))*(1/((det(tempcov))^(0.5)))*exp_part;
                       responsibilities(currow,loopvar1) = denominator;
                       evidence = evidence + denominator;
                   end
                   responsibilities(currow,:) = responsibilities(currow,:)./evidence;
               end
               
               %str = 'finished first job'
               
%-------------------------------------------------//--------------------------------------------------------------------------------------------------%



               % this chunk calculates new means, weights and effective 
               % number of points.   

               for loopvar1 = 1:no_gaus_distr
                      tempvar = zeros(1,dimension);
                      tempvar2 = 0;
                      for currow = 1:tot_rows
                          tempvar = tempvar + (responsibilities(currow,loopvar1).*x(currow,:));
                          tempvar2 = tempvar2 + responsibilities(currow,loopvar1);
                      end
                      Meanmat(loopvar1,:) = tempvar./tempvar2;
                      Eff_no_pnts(loopvar1,1) = tempvar2;
                      Wt(loopvar1,1) = Eff_no_pnts(loopvar1,1)/tot_rows;
               end
               
              % str = 'finished second job'
              
%-----------------------------------------------//------------------------------------------------------------------------------------------------------%



              % this chunk of code is for recalculation of covariance
              % matrix. By recalculation it means the covariance matrix is
              % filled with new data sets that makes use of the
              % responsibilities calculated earlier.
              
              %cov_var = 1;
              for loopvar1 = 1:no_gaus_distr
                  tempcov = zeros(dimension,dimension);
                  tempvar2 = 0;
                  for currow = 1:tot_rows
                         tempcov = tempcov + responsibilities(currow,loopvar1)*(((x(currow,:))')*(x(currow,:)));
                         tempvar2 = tempvar2 + responsibilities(currow,loopvar1);
                  end
                  Cov(:,:,loopvar1) = (tempcov/tempvar2) - (Meanmat(loopvar1,:)')*(Meanmat(loopvar1,:));
                  %Cov(cov_var:(dimension*loopvar1),:) = tempcov./Eff_no_pnts(loopvar1,1);
                  %cov_var = cov_var + dimension;
              end
              
              % str = 'finished third job'
              
%---------------------------------------------//---------------------------------------------------------------------------------------------------------%



              % this chunk calculates the log likelihood in order to 
              % compare the previous value with the current value. 
              
              tempvar2 = 0;
              for currow = 1:tot_rows
                     tempvar = 0;
                     %cov_var = 1;
                     for curdistr = 1:no_gaus_distr
                         tempcov = Cov(:,:,curdistr);
                         %tempcov = Cov(cov_var:(dimension*curdistr),:);
                         %cov_var = cov_var + dimension;
                         exp_part = exp(-0.5*(x(currow,:)-Meanmat(curdistr,:))*(inv(tempcov))*((x(currow,:)-Meanmat(curdistr,:))'));
                         tempvar = tempvar + ((Wt(curdistr,1))*(1/((det(tempcov))^(0.5)))*exp_part);
                     end
                     tempvar2 = tempvar2 + log(tempvar);
              end
       
              
              % str = 'finished fourth job'
                
              likelihoodnew = -((tot_rows*dimension)/2)*log(2*pi) + tempvar2
              if (iteration==3)
                  flag = -1*(likelihoodnew/(10^(5)))
              end
              likelihoodnew-likelihoodold
              %flag_new = exp(likelihoodnew*(10^-5));
              %exp(abs(flag_old-flag_new))
         end   
%-------------------------------------------//----------------------------------------------------------------------------------------------------------%          
