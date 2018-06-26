%% Homework 3 - Stephen Fanale




clear all; close all; clc; 
import mlreportgen.ppt.* % import Matlab package to create ppt presentation
addpath(genpath('C:\Users\Stephen\Documents\MATLAB\MFE\'));

startOpt= 'Jan-2000';
endOpt= 'Dec-2015';
startHold='Jan-2016';
endHold='Dec-2016';
%% Load in tickers and get monthly prices from 2000-2016 
[Nums,textdata]=xlsread('HW3Tickers.csv'); 
symbols=textdata(:,1);
permno=Nums(:);

username = 'unc1@unc.edu';   %throughout the semester money.net has gotten almost unuseably bad
    pwd = 'moneynet';  
    c = moneynet(username,pwd);
    
date = [datetime(startOpt) datetime(endHold)]; % [begin end]
interval = '30D'; % time interval (alternatives: )
f = {'Close'}; % data fields we want
% Need to loop through individual retrieval
for j = 1:length(symbols) % loop through the length of symbols cells
     symbol = symbols{j}; % select symbol
     ticker = char(symbol); % generate string variable with symbol
     d.j = timeseries(c,symbol,date,interval,f); % retrieve data
     ticker=string(ticker);
      if (ticker=='BRK.B')
            symbol='BRK'; %the period in this ticker causes problems
      end
      if (ticker=='BF.B')
          symbol='BFB';
      end
     symbol
     portfolioOpt.(symbol)=(d.j.Close);
    % RiOpt(:,j)=(d.ticker.Close); 
end
close(c); % close connection
    
%% For each asset, ARMA -GARCH Forecasting 
Returns=zeros(203,500);  %203 is number of possible data points

for i=1:length(symbols)
symbol = symbols{i}; % select symbol
     symbol=string(symbol);
      if (symbol=='BRK.B')
            symbol='BRK'; %the period in this ticker causes problems
      end
      symbol=string(symbol);
      if (symbol=='BF.B')
          symbol='BFB';
      end
     symbol=char(symbol);
     %Size the data
    [T,N] = size(portfolioOpt.(symbol)); 
    
%Compute returns  
% need to account for different length ones, make first all zeros until
% data set starts
        Returns(203-T+2:end,i) = portfolioOpt.(symbol)(2:end,1)./portfolioOpt.(symbol)(1:end-1,1)-1; %set returns to zero if info doesnt go back to 2000 
end

[T,N] = size(Returns);  
holdout = 12; %Keep the last 10obs for evaluation; all before is for estimation    
%Estimate during the estimation window
    %Set the model assuming an ARMA(1,1) GARCH(1,1) structure
         Mdl = arima('ARLags',1,'MALags',1,'Variance',garch(1,1));
         Mdl2 = arima('ARLags',1,'MALags',1); %bc variance problem
    %Set the # of one day ahead forecasts
        NumFor = 1; 
        ForHor = 12; 
        forecastret =[];
for i=1:N
 clear ret 
    %Form the temporary returns
 ret = Returns(1:end-holdout,i);
    res = ret - mean(ret); 
    a = archtest(res); % see if model will work 
    
   if a == 0 
        EstMdl = estimate(Mdl2,ret);
        [E0,V0,LogL] = infer(EstMdl,ret); 
        [rfor,YMSE,V] = forecast(EstMdl,ForHor,'Y0',ret,'E0',E0,'V0',V0);
   end
   if a>0
       
                %Estimate the model 
                    EstMdl = estimate(Mdl,ret); 
                %Infer the variances
                    [E0,V0,LogL] = infer(EstMdl,ret); 
                %Forecast
                    [rfor,YMSE,V] = forecast(EstMdl,ForHor,'Y0',ret,'E0',E0,'V0',V0);
   end
                %Append that forecast to the Return Series
                    forecastret(1:12,i) = rfor;
                    forecastret(13,i)=i;
                    forecastVar(1:12,i)=V;
                    ret = [ret;rfor];
                %Display where you are in the loop 
                    clc
                    td = ['Asset #',num2str(i)];
                    disp(td); 
   
end %End loop through assets
        
%Compute forecast errors 
    ForecastErrors = (Returns(end-holdout+1:end,:)-forecastret(1:12,:));
%Compute the root mean squared forecast error for each asset
    MeanFE = (mean(ForecastErrors.^2)).^.5; 
    
    
 
    
%% make five bins based on performance of model
dataArray(:,1)=MeanFE';
dataArray(:,2)=mean(forecastVar);
dataArray(:,3)=forecastret(13,:); %for asset number 
dataArray(:,4)=mean(forecastret(1:12,:));
 
Temp2 = sortrows(dataArray,1); %sort - biggest at bottom
 
orderstat = round((.2)*size(Temp2,1),0); %Find the order statistic i.e. which observations to choose 
 

 temp=Temp2(1:orderstat,3); %get asset ids from sorted array and save to dec
 Dec1=temp;
 temp= Temp2(orderstat*1+1:orderstat*2,3);
 Dec2=temp;    %the Permnos of each dec at this date
 temp= Temp2(orderstat*2+1:orderstat*3,3);
 Dec3= temp;
 temp= Temp2(orderstat*3+1:orderstat*4,3);
 Dec4=temp;
 temp= Temp2(orderstat*4+1:end,3);
 Dec5= temp;

% dec five has the largest errors - dec 1 has the smallest

%% for each bin, one equal weight portfolio and one max sharpe ratio

w = (ones([orderstat,1])./orderstat); 

[~,dec1rows] = find(forecastret(13,:) == Dec1); %sort of like inner join
[~,dec2rows] = find(forecastret(13,:) == Dec2);  %just finds the places where these numbers 
[~,dec3rows] = find(forecastret(13,:) == Dec3);   %are the same in another array
[~,dec4rows] = find(forecastret(13,:) == Dec4);
[~,dec5rows] = find(forecastret(13,:) == Dec5);

dec1ret = Returns(end-holdout+1:end,dec1rows); %use mapped row numbers 
dec2ret = Returns(end-holdout+1:end,dec2rows);   %to get returns of interest
dec3ret = Returns(end-holdout+1:end,dec3rows);
dec4ret = Returns(end-holdout+1:end,dec4rows);
dec5ret = Returns(end-holdout+1:end,dec5rows);

%returns
A1ret = dec1ret*w;  A2ret = dec2ret*w; A3ret = dec3ret*w; A4ret = dec4ret*w; A5ret = dec5ret*w;

%Calculating portfolio standard deviation
A1std = std(A1ret); A2std = std(A2ret); A3std = std(A3ret); A4std = std(A4ret); A5std = std(A5ret);

temp = cumsum(A1ret); %Calculating the cumulative return and using the final value as total
A1_totret = temp(12,1); A1cum=[1;(1+temp)];
temp = cumsum(A3ret);
A2_totret = temp(12,1); A2cum=[1;(1+temp)];
temp = cumsum(A3ret);
A3_totret = temp(12,1); A3cum=[1;(1+temp)];
temp = cumsum(A4ret);
A4_totret = temp(12,1); A4cum=[1;(1+temp)];
temp = cumsum(A5ret);
A5_totret = temp(12,1); A5cum=[1;(1+temp)];

%% maximize Sharpe ratio of portfolio

rf = .0061432/12; %The average of the 1 year treasury divided by 12

dec1retS = forecastret(1:12,dec1rows); %same as before but now grabbing the 
dec2retS = forecastret(1:12,dec2rows);   %forecasted returns
dec3retS = forecastret(1:12,dec3rows);
dec4retS = forecastret(1:12,dec4rows);
dec5retS = forecastret(1:12,dec5rows);

dec1var = forecastVar(:,dec1rows); %same as before but now grabbing the 
dec2var = forecastVar(:,dec2rows);   %forecasted vars
dec3var = forecastVar(:,dec3rows);
dec4var = forecastVar(:,dec4rows);
dec5var = forecastVar(:,dec5rows);

% sharpeRatio=@(w)1/((w'*rAve-rf)/(sqrt(w'*cov(Ri)*w))); %minimizing the inverse of the sharpe ratio in order to maximize the sharpe ratio
sharpeRatio1 = @(w) 1/( (mean(dec1retS*w)-rf)/sqrt(mean(dec1var*w))); %Declaring the sharpe ratio formulas to feed into the optimizer
sharpeRatio2 = @(w) 1/( (mean(dec2retS*w)-rf)/sqrt(mean(dec2var*w))); 
sharpeRatio3 = @(w) 1/( (mean(dec3retS*w)-rf)/sqrt(mean(dec3var*w))); 
sharpeRatio4 = @(w) 1/( (mean(dec4retS*w)-rf)/sqrt(mean(dec4var*w))); 
sharpeRatio5 = @(w) 1/( (mean(dec5retS*w)-rf)/sqrt(mean(dec5var*w))); 


 lb=ones(orderstat,1)*-.25 ; ub=ones(orderstat,1)*1.25;
 beq= 1;  
 Aeq = ones(1,orderstat);
 

options = optimoptions(@fmincon, 'MaxFunctionEvaluations', 10000);
 
wStar1= fmincon(sharpeRatio1, w, [],[], Aeq, beq, lb, ub, [], options);
wStar2= fmincon(sharpeRatio2, w, [],[], Aeq, beq, lb, ub, [], options);
wStar3= fmincon(sharpeRatio3, w, [],[], Aeq, beq, lb, ub, [], options);
wStar4= fmincon(sharpeRatio4, w, [],[], Aeq, beq, lb, ub, [], options);
wStar5= fmincon(sharpeRatio5, w, [],[], Aeq, beq, lb, ub, [], options);

clear portfolio portfolioOpt interval textData Nums

%% evaluate Sharpe Ratio fits

% W stars and returns to find sharpe ratio returns
AS1ret = dec1ret*wStar1; AS2ret = dec2ret*wStar2;  AS3ret = dec3ret*wStar3;  AS4ret = dec4ret*wStar4;  AS5ret = dec5ret*wStar5; 

%standard deviations
AS1std = std(AS1ret); AS2std = std(AS2ret); AS3std = std(AS3ret); AS4std = std(AS4ret); AS5std = std(AS5ret);

%total returns
temp = cumsum(AS1ret); 
AS1cum=[1;(1+temp)];
AS1totret = temp(12,1);
temp = cumsum(AS2ret); 
AS2cum=[1;(1+temp)];
AS2totret = temp(12,1);
temp = cumsum(AS3ret); 
AS3cum=[1;(1+temp)];
AS3totret = temp(12,1);
temp = cumsum(AS4ret);
AS4cum=[1;(1+temp)];
AS4totret = temp(12,1);
temp = cumsum(AS5ret); 
AS5cum=[1;(1+temp)];
AS5totret = temp(12,1);

%% returns graphs

x = [0:1:12]; %Plot x from 0 to 12 with increments of 1
figure
plot1 = plot(x,A1cum,x,AS1cum);title('A1'),xlabel('Months'),ylabel('Nominal Return'),legend('Equal Weight', 'Sharpe Ratio')
figure
plot2 = plot(x,A2cum,x,AS2cum);title('A2'),xlabel('Months'),ylabel('Nominal Return'),legend('Equal Weight', 'Sharpe Ratio')
figure
plot3 = plot(x,A3cum,x,AS3cum);title('A3'),xlabel('Months'),ylabel('Nominal Return'),legend('Equal Weight', 'Sharpe Ratio')
figure
plot4 = plot(x,A4cum,x,AS4cum);title('A4'),xlabel('Months'),ylabel('Nominal Return'),legend('Equal Weight', 'Sharpe Ratio')
figure
plot5 = plot(x,A5cum,x,AS5cum);title('A5'),xlabel('Months'),ylabel('Nominal Return'),legend('Equal Weight', 'Sharpe Ratio')
        

%% ttest and vartest


[h1,p1,ci1,stats1] = ttest2(A1ret,AS1ret); %The ttest formula
[hv1,pv1,civ1,statsv1] = vartest2(A1ret,AS1ret); %The ftest formula

[h2,p2,ci2,stats2] = ttest2(A5ret,AS5ret);
[hv2,pv2,civ2,statsv2] = vartest2(A5ret,AS5ret);

[h3,p3,ci3,stats3] = ttest2(A1ret,A5ret);
[hv3,pv3,civ3,statsv3] = vartest2(A1ret,A5ret);

[h4,p4,ci4,stats4] = ttest2(AS1ret,AS5ret);
[hv4,pv4,civ4,statsv4] = vartest2(AS1ret,AS5ret);


