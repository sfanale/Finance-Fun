%Estimating Factor Models where Exposures are NOT Observed
%Our goal here is to determine the ability of a factor to explain the cross-section of returns.  We will explore 3 methods: 1) Simple 2-Pass, 2) Fama MacBeth, and 3) Pooled/Panel regression.  
%Note: We will use the ols function from the Oxford MFE Toolbox (https://www.kevinsheppard.com/MFE_Toolbox). Be sure it is installed and on your local path before you begin. 
%Author: Mike Aguilar, UNC-CH Economics Dept, Jan`17

%Housekeeping
    clear all; close all; clc
    


    addpath(genpath('C:\Users\Stephen\Documents\MATLAB\MFE\'));
%Simulate data
%Set up dimensions
    T = 12*50; 
    N = 150; 
    K = 2; 
    mu = 0; 
    sigma2 = .05; 
%Simulate
    seed = 5; %Set the seed for the simulator. 
    rng(seed); %Lock in the seed 
    F = [ones(T,1) randn(T,K-1)];
    u = randn(T,N); %Note: If existed cross sectional correlation, then results for cov(beta) differ
    %Simulate beta1 (intercept) to be mean 0 with unit variance
        BigBeta1 = randn(1,N); 
    %Simulate beta2 (slope) to be mean 10 with std of .5
        BigBeta2 = .5.*randn(1,N) + 10; 
    %Combine the beta vector        
        BigBeta = [BigBeta1;BigBeta2]; 
    for i = 1:N
        beta = BigBeta(:,i); 
        r(:,i) = F*beta+u(:,i); 
    end
    
%Summarize the simulated series
    f1 = figure(1);
    bar(BigBeta(2,:)); 
    title('\beta_{2}')
    
    f2 = figure(2);
    bar(BigBeta(1,:)); 
    title('\beta_{1}')
    
    f3 = figure(3);
    plot(r(:,1));
    title('Plot of 1 simulated return path'); 
    xlabel('time')
    ylabel('%')
    
    %Sample moments of returns
        stats.mean = mean(r); 
        stats.std = std(r); 
        stats.skew = skewness(r); 
        stats.kurt = kurtosis(r); 
      
        f4 = figure(4); 
        bar(stats.mean); 
        title('Mean of each simulated return'); 
        
        f5 = figure(5); 
        bar(stats.std); 
        title('Std Deviation of each simulated return'); 
        
      %% 2 pass method
      %regress Beta and F 
      close all;
      for i= 1:150
      [betahat, tstatB]=ols(r(:,i), F,0);
      betahats(:,i)= betahat;
      end
      
      
      %regress bhats and returns to find lamda
     [lamdahat tstat] = ols(stats.mean',betahats',0);
     lamdahat , tstat
     
     
     %% Fama 
     
     for i=1:600
     [FamaLambda , tstasFL] = ols(r(i,:)', betahats',0);
     FamaLambdas(:,i)= FamaLambda;
     end
     LambdaMean= mean(FamaLambdas');
     
     %% panel
     newr= r(1,:);
     newBeta= betahats(:,:);
     for i=2:600
       newr= [newr, r(i,:)];
       newBeta=[newBeta, betahats(:,:)];
       i
     end
     
     
  [panelLam tstatPan]=ols(newr',newBeta',0); 
 
  panelLam 
     