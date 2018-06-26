%Purpose: 
%   Example on how to conduct a simultaneous screening exercise. 
%   We will load in data, clean it, and form our unconditional universe of
%   assets from which to choose. We'll screen on the largest size and
%   volume, under the suspicion that larger of each is associated with
%   higher returns.
%   
%Inputs: 
%   Requires the file Oneweek_prices.csv (gathered by Gonzalo Asis), which
%   contains basic pricing data on a range of U.S. equities.
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
    
%Compute size
    Univ1.size = Univ1.price.*Univ1.shareout; 
    
    

%% Screen 1: Compute z scores for avg size over life of each asset

        Temp = grpstats(Univ1,'permno',{'mean'},'DataVars',{'size','ret'}); %Compute the mean size for each permno
    %Compute the mean of the (avg size for each permno)
        MeanSize = mean(Temp.mean_size);
    %Compute the std of the (avg size for each permno)
        StdSize = std(Temp.mean_size); 
    %Compute size based z scores
        Temp.SizeZ = (Temp.mean_size-MeanSize)/StdSize; 
    %Look at the Size Z Scores
        f1 = figure(1); 
        bar(Temp.SizeZ); 
        title('Size Based Z Scores') 
        
    
%% Screen 2: Compute z scores for avg volume over life of each asset
        
        Temp2 = grpstats(Univ1,'permno',{'mean'},'DataVars',{'volume','ret'}); %Compute the mean size for each permno
    %Compute the mean of the (avg size for each permno)
        MeanVolume = mean(Temp2.mean_volume);
    %Compute the std of the (avg size for each permno)
        StdVolume = std(Temp2.mean_volume); 
    %Compute size based z scores
        Temp2.VolumeZ = (Temp2.mean_volume-MeanVolume)/StdVolume; 
        Temp2.VolumeZ = Temp2.VolumeZ; 
    %Look at the Size Z Scores
        f2 = figure(2); 
        bar(Temp2.VolumeZ); 
        title('Volume Based Z Scores') 
        
     
%% Performance
%Combine the tables with the individual Z scores
    clear Temp3
    Temp3 = join(Temp,Temp2,'Keys','permno','KeepOneCopy',{'mean_ret','GroupCount'}); 
    
%Create an simple equal weighted z score
    Temp3.Z = .75*(-Temp3.SizeZ) + .25*Temp3.VolumeZ; 

%Rank from lowest to highest on that z score
    Temp3 = sortrows(Temp3,{'Z'},'ascend'); 
    
%Take the highest 10% of aggregate z scores
    upperquantile = .10; 
    orderstat = round((1-upperquantile)*size(Temp3,1),0); 
    %Take all those beyond the orderstat
    Univ2 = Temp3(orderstat:end,:); 
    
    
    
%Check the avg returns from each universe
    AvgRetUniv1 = 100*mean(Univ1.ret);
    AvgRetUniv2 = 100*mean(Univ2.mean_ret); 
    
    Temp = table([AvgRetUniv1;AvgRetUniv2],'VariableName',{'AvgReturns_pct'},'RowNames',{'Univ1','Univ2'}); 
    disp(Temp); 

    
    
    