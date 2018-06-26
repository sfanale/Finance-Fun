%% Basic Matlab Commands
%Purpose: Introduce the user to a few commands within Matlab that are
%critical for a financial economist. 
% Created by: Gonzalo Asis & Mike Aguilar December 2016

%Housekeeping
    clear all; % clear all variables from memory
    close all; % close all figures
    clc; % clear command window
    
%% Load in Data
%Our data is already prepared in excel.  Could also be stored in myriad
%formats.  To read from excel, we use xlsread as an example of getting data 
%from the file Lesson1data.xlsx 
%Note the syntax "pwd", which is for the current directory.  
    inputfile = [pwd,'\Lesson1data']; % file to input data from
    [num,txt,raw] = xlsread(inputfile,'GOOG');
    txtheadings = txt(1,:);

%The dates are in the first column of the txt field.  Let's grab those.  Convert to numbers 
%so that matlab can handle more easily.   
    dates = datenum(datevec(txt(2:end,1))); 

%Now append dates to the data.  Never want to separate these. 
    Data = [dates num];
    
%Invert data so most recent prices are at the bottom (helpful for plots)
    Data = flipud(Data);
    
%Clean up so that only have the Data matrix and txt headings
    clearvars -except Data txtheadings


%% Transform data: Examples of return calculations
% Use prices at closing for this exercise. We know from txtheadings that
% the Close price is the 5th column of Data. 
    Close = Data(:,5);

% Compute holding period returns. First and Last observations.  
    ret_hold = Close(end,:)/Close(1,:)-1;

% Compute daily simple net returns 
    %Could do a loop
    for t = 2:size(Close,1)
        ret1(t,1) = Close(t,1)./Close(t-1,1)-1; 
    end
        %Drop the 1st observation
        ret1(1,:)=[];
    %Or could leverage matrices
        ret2 = Close(2:end,1)./Close(1:end-1,1)-1; 
    %Verify they are the same
        [ret1(1:5) ret2(1:5)]

%Compute daily log returns
    %Matrix
        logret1 = log(Close(2:end,1)./Close(1:end-1,1)); 
    %Built in functionality
        logret2 = price2ret(Close); 
    %Show they are the same
        [logret1(1:5) logret2(1:5)]


%% Compare log and simple returns
    figure(1)
    subplot(1,2,1)
    plot(Data(1:end-1,1),ret1)
    legend('Simple Returns')
    datetick('x',23,'keeplimits') % place date in x-axis in date format
   
    subplot(1,2,2)
    plot(Data(1:end-1,1),logret1)
    legend('Log Returns')
    suptitle('Google')
    datetick('x',23,'keeplimits') % place date in x-axis in date format

%% Compute sample moments for the daily log returns
    SampleStats = struct;
    SampleStats.mean_ret = mean(logret1);
    SampleStats.vol_ret = std(logret1);
    SampleStats.skew_ret = skewness(logret1);
    SampleStats.kurt_reht = kurtosis(logret1);
    SampleStats
    
    
    
%% Compute cumulative returns over the period
   cumret=cumsum(logret1);
   %Create an index value representing $100 invested in this asset and held
   Index = ones(size(Data,1),1); 
   InitialValue = 100; 
   Index(1,1) = InitialValue;
   Index(2:end,1) = InitialValue.*(1+cumret); 
%Plot the index
    figure(2)
    plot(Data(:,1),Index)
    datetick('x','mm/dd/yy')
    xlim([Data(1,1) Data(end,1)])
    %ylim([0,max(Index)])
    title('Buy and Hold'); 
    ylabel('$')
