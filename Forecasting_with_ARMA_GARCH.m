%Purpose: 
%   Forecasting return series with ARMA models
%Author: 
%   Mike Aguilar, UNC Econ, 3/1/17 ---- Need to fix this by including less
%   time period
%Housekeeping
    clear all; close all; clc; 
%Load data
    load Data_GlobalIdx1
%Size the data
    [T,N] = size(DataTable); 
%Compute returns
    for i = 1:N
        Returns(1:T-1,i) = DataTable.(i)(2:end,1)./DataTable.(i)(1:end-1,1)-1; 
    end 
    %Resize: 
        %Returns = (T-500:end,:); %%%Only use the last two years of the sample
        T = size(Returns,1); 
%Set the estimation window 
    holdout = 10; %Keep the last 10obs for evaluation; all before is for estimation

%Estimate during the estimation window
    %Set the model assuming an ARMA(1,1) GARCH(1,1) structure
        Mdl = arima('ARLags',1,'MALags',1,'Variance',garch(1,1)); 
    %Set the # of one day ahead forecasts
        NumFor = holdout; 
        ForHor = 1; 
        %TotalObs = T + NumFor; %Total number of observations when stack actual and forecasts
    %Loop through each asset
    forecastret =[];
    for i = 1:N
        clear ret 
    %Form the temporary returns

        ret = Returns(1:end-holdout,i); 
    %Loop through each forecast 
        for f = 1:NumFor
    %Estimate the model 
        EstMdl = estimate(Mdl,ret); 
    %Infer the variances
        [E0,V0,LogL] = infer(EstMdl,ret); 
    %Forecast
        [rfor,YMSE,V] = forecast(EstMdl,ForHor,'Y0',ret,'E0',E0,'V0',V0);
    %Append that forecast to the Return Series
        forecastret(f,i) = rfor;
        ret = [ret;rfor];
    %Display where you are in the loop 
        clc
        td = ['Asset #',num2str(i),' Forecast #',num2str(f)];
        disp(td); 
        end %End loop through forecasts
    end %End loop through assets
        
%Compute forecast errors 
    ForecastErrors = [Returns(end-holdout+1:end,:)-forecastret];
%Compute the mean forecast error for each asset
    MeanFE = mean(ForecastErrors); 
    MeanFE = array2table(MeanFE,'VariableNames',DataTable.Properties.VariableNames)
    
%Plot the best and worst
    close all
    subplot(1,2,1),plot(Returns(end-holdout+1:end,1))
    hold on
    plot(forecastret(:,1),'r')
    hold off
    legend('Actual','Forecast'); 
    title('TSX Returns')
    subplot(1,2,2),plot(Returns(end-holdout+1:end,3))
    hold on
    plot(forecastret(:,3),'r')
    hold off
    legend('Actual','Forecast'); 
    title('DAX Returns')
    
    