%% Buyback Project 2 - May 2017 - Stephen Fanale
%This code reads in the .mat file with the output from the event studies to
%collect stats and run regressions for part 2

clear all; close all; clc; 


%% load in data
addpath(genpath('C:\Users\Stephen\Documents\MATLAB\MFE\'));
load('buybackVars.mat'); % load in data

%% organize the data
results=table(sector, tickers, eventResults, sharePer90,buybackPer, indDummies); 
 
cleanResults=rmmissing(results);  %remove values where there were out problems
 

%% make arrays to get means of the information
Results=mean(table2array(cleanResults(:,3:5)))

resultsAr=table2array(cleanResults(:,3:end));

%% using inudstry dummy variables organize into arrays by industry to get results by industry
ind1=find(resultsAr(:,6)==1); ind2=find(resultsAr(:,7)==1); ind3=find(resultsAr(:,8)==1);
ind4=find(resultsAr(:,9)==1); ind5=find(resultsAr(:,10)==1); ind6=find(resultsAr(:,11)==1);
ind7=find(resultsAr(:,12)==1);ind8=find(resultsAr(:,13)==1);

Agri=resultsAr(ind1,1:4);
Industrial=resultsAr(ind2,1:4);
Manu=resultsAr(ind3,1:4);
Util=resultsAr(ind4,1:4);
Retail=resultsAr(ind5,1:4);
Finance=resultsAr(ind6,1:4);
Service=resultsAr(ind7,1:4);
PublicAdmin=resultsAr(ind8,1:4);
'Agri'
mean(Agri)
'ind'
mean(Industrial)
'manu'
mean(Manu)
'util'
mean(Util)
'retail'
mean(Retail)
'fin'
mean(Finance)
'ser'
mean(Service)
'pub'
mean(PublicAdmin)


%% part 2: event regressions by sector
% for each eventResult time window, regress EventResults against %buyback90days, relative size, and industry
% dummies
 

regressors=resultsAr(:,4:12);   %Public Admin sector as control dummy

[lambda, tstat, S2] = olsQuant(resultsAr(:,1),regressors ,1)   % next day
[lambda2, tstat2, S22] = olsQuant(resultsAr(:,2),regressors ,1) % next week 
[lambda3, tstat3, S23] = olsQuant(resultsAr(:,3),regressors ,1)  % 90 days
