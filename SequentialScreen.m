%Purpose: 
%   Example on how to conduct a sequential screening exercise. 
%   We will load in data, clean it, and form our unconditional universe of 
%   assets from which to choose.  We'll then sort size.  We'll keep only 
%   the biggest. Then we'll sort that smaller universe of assets based upon
%   volume.  Finally, we'll compare returns before and after each sorting.
%   
%Inputs: 
%   Requires the file Oneweek_prices.csv (gathered by Gonzalo Asis),  
%   which contains basic pricing data on a range of U.S. equities.  
%Author: 
%   Mike Aguilar - UNC-CH Economics Dept. Jan`17


%% Housekeeping
    clear all; close all; clc; 
    
%% Data
%Load in data
    [data,textdata]=xlsread('Oneweek_prices.csv'); 
    
%Form a data table for ease of anaylsis    
    permno = data(:,1); date = data(:,2); price = data(:,3); shareout = data(:,4); volume = data(:,5); 
    Univ1 = table(permno, date,price,shareout,volume); %Denote this as the first "universe" of assets. 

%Let's look at the data
    summary(Univ1)
    Univ1(1:25,:)
    
%Find unique permnos
    upermno = unique(Univ1.permno); 
    nu = size(upermno,1); %# of unique permno's (assets) 
    td = ['Number of assets=',num2str(nu)]; disp(td); clear td
    
%Calculate returns
    Univ1.ret = ones(size(Univ1,1),1).*99;% Allocate space to this new variable
    %Loop through each observation, check if it is the same asset as the
    %one prior; if so, then compute return. Otherwise it stays as 99.  Note
    %that we can speed up this algo dramatically, but this method is more
    %intuitive
    for t = 2:size(Univ1,1)
        if Univ1.permno(t,1)==Univ1.permno(t-1,1)
            Univ1.ret(t,1) = Univ1.price(t,1)/Univ1.price(t-1,1) - 1; 
        end
    end
    temp1 = size(Univ1,1); 
    %Scrape away all observations where ret=99 (these are the ones where we
    %didn't have a preceeding price in order to calculate the return
    Univ1=Univ1(Univ1.ret~=99,:); 
    temp2 = size(Univ1,1); 
    td1 = ['Size of Univ1 before remove 99=',num2str(temp1)]; disp(td1); 
    td2 = ['Size of Univ1 after remove 99=',num2str(temp2)]; disp(td2); 
    
    clear temp1 temp2 td1 td2 %Clean up 
    
%Compute size (market cap)
    Univ1.size = Univ1.price.*Univ1.shareout; 
    
    

%% Screen 1: Take only those assets in the top 10% of size
 
    upperquantile = .10; %user defined. Captures the top 10% for the screen
    
    Temp = grpstats(Univ1,'permno','mean','DataVars',{'size'}); %Compute the mean size for each permno
    Temp = sortrows(Temp,'mean_size');%Sort from smallest to largest according to size
    
    orderstat = round((1-upperquantile)*size(Temp,1),0); %Find the order statistic i.e. which observations to choose

    Temp2 = Temp(orderstat:end,:); %Pick only those assets above the orderstat i.e. meet the critertion
    
    Univ2 = innerjoin(Univ1,Temp2); %Permno is the unique matching key.  Keeps only those from Univ1 that meet the criterion
    
    nu = size(unique(Univ2.permno),1); 
    td = ['Size of Univ2 =',num2str(nu)]; disp(td); 
    
    clear Temp Temp2 upperquantile orderstat nu td %clean up
    

%% Screen 2: Take only those assets in the bottom 15% of volume AFTER conditioning
%upon size
    lowerquantile = .15; %user defined.  Captures the top 5% for the screen
    
    Temp = grpstats(Univ2,'permno','mean','DataVars',{'volume'}); %Compute the mean volume for each permno
    Temp = sortrows(Temp,'mean_volume');%Sort from smallest to largest according to volume
    
    orderstat = round((lowerquantile)*size(Temp,1),0); %Find the order statistic i.e. which observations to choose

    Temp2 = Temp(1:orderstat,:); %Pick only those assets below the orderstat i.e. meet the critertion
    
    Univ3 = innerjoin(Univ2,Temp2); %Permno is the unique matching key.  Keeps only those from Univ2 that meet the criterion
    
    nu = size(unique(Univ3.permno),1); 
    td = ['Size of Univ3 =',num2str(nu)]; disp(td); 
    
    clear Temp Temp2 lowerquantile orderstat nu td %clean up

%% Screen 3: Take only those assets in the top 15% share price AFTER conditioning
%upon size and volume
    upperquantile = .15; %user defined.  Captures the top 5% for the screen
    
    Temp = grpstats(Univ3,'permno','mean','DataVars',{'price'}); %Compute the mean price for each permno
    Temp = sortrows(Temp,'mean_price'); %Sort from smallest to largest according to price
    
    orderstat = round((1-upperquantile)*size(Temp,1),0); %Find the order statistic i.e. which observations to choose

    Temp2 = Temp(orderstat:end,:); %Pick only those assets above the orderstat i.e. meet the critertion
    
    Univ4 = innerjoin(Univ3,Temp2); %Permno is the unique matching key.  Keeps only those from Univ2 that meet the criterion
    
    nu = size(unique(Univ4.permno),1); 
    td = ['Size of Univ4 =',num2str(nu)]; disp(td); 
    
    clear Temp Temp2 upperquantile orderstat nu td %clean up

%% Performance
% Check the avg returns from each universe
    AvgRetUniv1 = mean(Univ1.ret);
    AvgRetUniv2 = mean(Univ2.ret);
    AvgRetUniv3 = mean(Univ3.ret);
    AvgRetUniv4 = mean(Univ4.ret);
    
    Temp = table([AvgRetUniv1;AvgRetUniv2;AvgRetUniv3;AvgRetUniv4],'VariableName',{'AvgReturns'},'RowNames',{'Univ1','Univ2','Univ3','Univ4'}); 
    disp(Temp); 

    