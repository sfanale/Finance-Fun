function [SampleStats] = portStats( symbols, prices, market, wStar, startingCash, rf, weeks, holdingperiod, dayoffset)




for i=1:length(symbols)
% Create structure to hold sample statistics
if i==1
SampleStats = struct;
end

% Compute holding period returns
SampleStats.ret_hold(i) = prices(end,i)/prices(1,i)-1;

% Compute daily returns
ret(:,i) = price2ret(prices(:,i));
SampleStats.ret(:,i) = ret(:,i);

% Compute sample moments for the returns
SampleStats.median_ret(:,i) = median(ret(:,i));
SampleStats.mean_ret(:,i) = mean(ret(:,i));
SampleStats.vol_ret(:,i) = std(ret(:,i));
SampleStats.skew_ret(:,i) = skewness(ret(:,i));
SampleStats.kurt_ret(:,i) = kurtosis(ret(:,i));

% Compute cumulative returns over the period
SampleStats.cumret(:,i)=cumsum(ret(:,i));
end

for j=1:length(symbols)
    for n=1:weeks
        shares(j,n) = wStar(j)*startingCash/prices(1,j);
    end
end

% Construct portfolio
for n=1:weeks
    if n==1
for j=1:length(symbols)
    sec(:,j) = shares(j,n).*prices(1:6,j);    % first six prices
end
    else
 for j=1:length(symbols)
     j,n
    temp(:,j) = shares(j,n).*prices(2-dayoffset(n)+(n-1)*5:((n-1)*5)+holdingperiod(n)-dayoffset(n),j); %next five prices
 end
    sec= [sec;temp];
    clear temp
    end
end

port=sum(sec,2);

% Daily returns
ret_port = price2ret(port);
SampleStats.ret_port = ret_port;

% Cumulative returns
cumret_port=cumsum(ret_port); 
SampleStats.cumret_port = cumret_port;

Close_mkt=table2array(market(:,2));
ret_mkt = price2ret(Close_mkt); % daily returns
cumret_mkt=cumsum(ret_mkt); % cumulative returns

% Add to SampleStats structure
SampleStats.ret_mkt = ret_mkt;
SampleStats.cumret_mkt = cumret_mkt;
% Compute sample moments for the returns
SampleStats.median_port = median(ret_port);
SampleStats.mean_port = mean(ret_port);
SampleStats.vol_port = std(ret_port);
SampleStats.skew_port = skewness(ret_port);
SampleStats.kurt_port = kurtosis(ret_port);


% CAPM
ex_ret = ret_port-rf; % excess returns
ex_mkt = ret_mkt-rf; % excess returns of market index
covar = cov(ex_ret,ex_mkt); % variance-covariance matrix
SampleStats.Beta = covar(1,2)/var(ex_mkt); % equivalent to OLS regression coefficient
SampleStats.Alpha = mean(ex_ret)-SampleStats.Beta*mean(ex_mkt); % solve for alpha

% Volatility
SampleStats.volPort = std(port); % total volatility
%SampleStats.volPort5 = std(port(end-4:end,:)); % 5-day volatility

% Sharpe ratio
SampleStats.sharpe = (cumret_port(end,:)-rf)/std(port);

% Information ratio
beat_mkt = ret_port - ret_mkt;
track_error = std(beat_mkt);
SampleStats.info_ratio = beat_mkt(end,:)/track_error;

% Maximum drawdown
SampleStats.max_draw = maxdrawdown(port);

% Minimum and Maximum values
SampleStats.max = max(port);
SampleStats.min = min(port);

% Compute sample moments for the returns
SampleStats.median_mkt = median(ret_mkt);
SampleStats.mean_mkt = mean(ret_mkt);
SampleStats.vol_mkt = std(ret_mkt);
SampleStats.skew_mkt = skewness(ret_mkt);
SampleStats.kurt_mkt = kurtosis(ret_mkt);

% Volatility
SampleStats.volMkt = std(Close_mkt); % total volatility
%SampleStats.volPort5 = std(port(end-4:end,:)); % 5-day volatility

% Sharpe ratio
SampleStats.sharpemkt = (cumret_mkt(end,:)-rf)/std(Close_mkt);

SampleStats.maxmkt = max(Close_mkt);
SampleStats.minmkt = min(Close_mkt);

% VaR
confidence_level = 0.95;
plot_flag = 1; 
SampleStats.histVaR = -computeHistoricalVaR(ret_port,confidence_level,plot_flag); 

%Compute the Gaussian VaR,lpm for each 
RiskThreshold = 1-confidence_level;
PortValue = 1; 
SampleStats.gaussianVaR = portvrisk(SampleStats.mean_port,SampleStats.volPort,RiskThreshold,PortValue); 
SampleStats.lowerPartial= lpm(ret_port); 


end
