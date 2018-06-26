%Housekeeping
    clear all; close all; clc; 
    tspath = 'C:\Users\maguilar\Dropbox\Teaching\QFE\Curriculum\Econ590-490 Spring 2017\Lecture Notes\Risk\Code\';
%Load Adjusted Closing Prices
load Prices
%Flip the data so that oldest to youngest
Prices = flipud(Prices);
Prices.DateNum = datenum(Prices.Date); 

%Set the examination period 
firstdate = Prices.DateNum(1,1);
lastdate = Prices.DateNum(end,1);
Case = 3;
%Case 1 = full sample
if Case == 1
    StartDate = firstdate; 
    EndDate = lastdate;
%Case 2 = Great Recession
elseif Case == 2
    StartDate = datenum('01/02/2008'); 
    EndDate = datenum('12/01/2009'); 
%Case 3 = 2015 forward
elseif Case == 3
    StartDate = datenum('01/02/2015'); %First date I'll use in my sample; 
    EndDate = lastdate; %last date I'll use in my sample; 
end
ind1 = find(Prices.DateNum==StartDate); 
ind2 = find(Prices.DateNum==EndDate); 
Prices = Prices(ind1:ind2,:); 
%Drop the DateNum to clean things up
    Prices.DateNum = [];
%Compute returns
temp = table2array(Prices(:,2:end)); 
N = size(temp,2); %# of assets
T = size(temp,1); % # of months
Returns = zeros(T-1,N); 
%Returns = Prices; 
for i =1:N
    Returns(1:T-1,i) = temp(2:end,i)./temp(1:end-1,i)-1; 
end
tickers = Prices.Properties.VariableNames; 
tickers(:,1)=[];
Returns = array2table(Returns,'VariableNames',tickers); 
Returns.Date=Prices.Date(2:end,1); 

%Plot the returns
f1 = figure(1) ;
for i = 1:N
subplot(2,5,i), plot(table2array(Returns(:,end)),table2array(Returns(:,i))); 
ttl = [tickers(1,i)];
title(ttl)
datetick('x','yyyy') 
clear ttl
end
%Save the figure
st = [tspath,'Case',num2str(Case),'Returns.jpg'];
saveas(f1,st); 
%Compute the Historical VaR for each 
f2 = figure; 
for i = 1:N
subplot(5,2,i)
confidence_level = 0.95;
plot_flag = 1; 
histVaR(i,1) = -computeHistoricalVaR(table2array(Returns(:,i)),confidence_level,plot_flag); 
end
%Save the figure
clear st
st = [tspath,'Case',num2str(Case),'HistVar.jpg'];
saveas(f2,st)

%Compute sample moments of return series
tempReturns = table2array(Returns(:,1:end-1)); 
meanR = mean(tempReturns); 
stdR = std(tempReturns); 
skewR = skewness(tempReturns); 
kurtR = kurtosis(tempReturns); 

%Compute the Gaussian VaR,lpm for each 
RiskThreshold = 1-confidence_level;
PortValue = 1; 
for i = 1:N
gaussianVaR(i,1) = portvrisk(meanR(1,i),stdR(1,i),RiskThreshold,PortValue); 
lowerPartial(i,1) = lpm(table2array(Returns(:,i))); 
maxDD(i,1) = maxdrawdown(table2array(Prices(:,i+1))); 
end

%Create a table of the various risk metrics
Output = table(meanR',stdR',skewR',kurtR',histVaR,gaussianVaR,lowerPartial,maxDD,'VariableNames',{'mean','std','skew','kurt','HistVaR','GaussianVaR','LPM','MaxDD'},'RowNames',tickers'); 

%Display
td = ['Case ',num2str(Case)];
disp(td)
disp(Output)


