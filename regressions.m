%% Housekeeping
    clear all % clear all variables from memory
    close all % close all figures
    clc % clear command window
    %Set path to OxFord MFE Toolbox on my machine...change to your local
    %drive!
    addpath(genpath('C:\Users\Stephen\Documents\MATLAB\MFE\'));
%% Import Data
    inputfile = [pwd,'\Lesson1data']; % file to input data from. Note: pwd indicates local directory. 
    %outputfile = [pwd,'\Lesson1results']; % file to output results to
        
    %Import the dates
        sheet = 'GOOG'; %Sheets are named as tickers
        range = 'A2:A64';%I know this range by looking at excel.  Could load in blind as well. 
        [~,Date] = xlsread(inputfile,sheet,range);%Load in the data
        
        
    %Import Google --- Note: I could also import dates and prices together.  
        sheet = 'GOOG'; %Sheets are named as tickers
        range = 'G2:G64'; %I know this range by looking at excel.  Could load in blind as well. 
        [GOOG] = xlsread(inputfile,sheet,range);%Load in the data
 
    %Import APPL --- Note: I could also import dates and prices together.  
        sheet = 'AAPL'; %Sheets are named as tickers
        range = 'G2:G64'; %I know this range by looking at excel.  Could load in blind as well. 
        [AAPL] = xlsread(inputfile,sheet,range);%Load in the data
    %Import SP500 --- Note: I could also import dates and prices together.  
        sheet = 'SP500'; %Sheets are named as tickers
        range = 'G2:G64'; %I know this range by looking at excel.  Could load in blind as well. 
        [SP500] = xlsread(inputfile,sheet,range);%Load in the data
%% Create table of prices
    Price = table(Date,GOOG,AAPL,SP500); 
    summary(Price); %Quick summary of what's in the table
    

%% Clean Data
        clearvars -except Price %clean up workspace. Keep only Price
    %Invert data so most recent prices are at the bottom (helpful for plots)
        Price = flipud(Price); 

%% Compute Daily Returns for each of 3 assets
        Ret(:,2) = Price.AAPL(2:end,1)./Price.AAPL(1:end-1,1)-1; 
        Ret(:,1) = Price.GOOG(2:end,1)./Price.GOOG(1:end-1,1)-1;
        Ret(:,3) = Price.SP500(2:end,1)./Price.SP500(1:end-1,1)-1;
    
    %Create a Return table for ease of viewing
        Return = table(Price.Date(2:end,1),Ret(:,1),Ret(:,2),Ret(:,3),'VariableNames',{'Date','GOOG','AAPL','SP500'}); 
    %Clean up 
        clearvars -except Price Return
    
%% Histograms for each asset
    figure(1)
    h1 = histogram(Return.GOOG);
    title('GOOG'); 
    figure(2)
    h2 = histogram(Return.AAPL); 
    title('AAPL')
    figure(3)
    h3 = histogram(Return.SP500); 
    title('SP500')


%% Compute CAPM coefficients: rt-rf = alpha + beta*(SP500-rf) + error
    %Let's assume risk free is zero for now. 
        C = 1; %Assume constant in CAPM regression.  
        Y = Return.GOOG; 
        X = Return.SP500; 
        [B,TSTAT,S2,VCV,VCV_WHITE,R2,RBAR,YHAT] = ols(Y,X,C);
        GOOG.alpha = B(1,1); 
        GOOG.beta = B(2,1); 
        GOOG.alphaT=TSTAT(1,1);
        GOOG.betaT=TSTAT(2,1);
        
        C = 1; %Assume constant in CAPM regression.  
        Y = Return.AAPL; 
        X = Return.SP500; 
        [B,TSTAT,S2,VCV,VCV_WHITE,R2,RBAR,YHAT] = ols(Y,X,C);
        AAPL.alpha = B(1,1); 
        AAPL.beta = B(2,1);
        AAPL.alphaT=TSTAT(1,1);
        AAPL.betaT=TSTAT(2,1);
  
        %Display alphas and betas
        GOOG
        AAPL
        
        C = 1; %Assume constant in CAPM regression.  
        Y = Return.GOOG; 
        X = [ Return.SP500, Return.AAPL];
        [B,TSTAT,S2,VCV,VCV_WHITE,R2,RBAR,YHAT] = ols(Y,X,C);
        GOOG2.alpha = B(1,1); 
        GOOG2.beta = B(2,1); 
        B
        TSTAT
        
        