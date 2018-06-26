%% portfolio performance 

function [ SampleStats,txt ] = portfolioPerformance( securities,weights,startingCash,benchmark,rf )
% This function computes the performance of a user-specified portfolio

%% Inputs:
% securities: name of securities in the portfolio
% weights: weight assigned to each security, in the same order as securities
% startingCash: amount of cash the user started trading with
% benchmark: name of the index used as a benchmark

%% Outputs:
% SampleStats: structure containing the following variables:
% - holding period return
% - mean return
% - return volatility (std dev)
% - return skewness
% - return kurtosis
% - CAPM alpha
% - CAPM beta

%% Performance of individual securities
%% Create Money.Net Connection
    % Input username and password
    username = 'unc1@unc.edu';
    pwd = 'moneynet';
    
    c = moneynet(username,pwd); % create connection
    
%% Retrieve Money.Net last 100 days
    date = [datetime('12-Oct-2016') datetime('20-Jan-2017')]; % [begin end]
    interval = '1D'; % time interval (alternatives: )
    f = {'Close'}; % data fields we want
    portfolio= struct;
    % Need to loop through individual retrieval
    for j = 1:length(securities) % loop through the length of symbols cells
        symbol = securities{j}; % select symbol
        ticker = char(symbol); % generate string variable with symbol
        d.ticker = timeseries(c,symbol,date,interval,f); % retrieve data
        ticker=string(ticker);
        if (ticker=='BRK.B')
            symbol='BRK';
        end
        portfolio.(symbol)=(d.ticker.Close);
    end
    
    close(c); % close connection
    
Ri= ones([69,30]);
for j = 1:length(symbols) % loop through the length of symbols cells
        symbol = symbols{j}; % select symbol
        ticker=string(symbol);
        if (ticker=='BRK.B')
            symbol='BRK';
        end
        rAve(j,:)= mean(portfolio.(symbol));
        Ri(:,j)=portfolio.(symbol);
end
for i=1:length(securities)

% Use prices at closing
Close(:,i) = num(:,4,i);

% Create structure to hold sample statistics
if i==1
SampleStats = struct;
end

% Compute holding period returns
SampleStats.ret_hold(i) = Close(end,i)/Close(1,i)-1;

% Compute daily returns
ret(:,i) = price2ret(Close(:,i));
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

%% Performance of Benchmark
% Import data
[num_mkt,txt_mkt,raw_mkt] = xlsread(inputfile,char(benchmark));

% Compute returns
Close_mkt=num_mkt(:,4);
ret_mkt = price2ret(Close_mkt); % daily returns
cumret_mkt=cumsum(ret_mkt); % cumulative returns

% Add to SampleStats structure
SampleStats.ret_mkt = ret_mkt;
SampleStats.cumret_mkt = cumret_mkt;

%% Portfolio Performance
% Determine how many shares of each to buy
for j=1:length(securities)
    shares(j) = cell2mat(weights(j))*startingCash/Close(1,j);
end

% Construct portfolio
for j=1:length(securities)
    sec(:,j) = shares(j).*Close(:,j);
end
port=sum(sec,2);

% Daily returns
ret_port = price2ret(port);
SampleStats.ret_port = ret_port;

% Cumulative returns
cumret_port=cumsum(ret_port); % flipud inverts the direction of the vector
SampleStats.cumret_port = cumret_port;

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
SampleStats.volPort5 = std(port(end-4:end,:)); % 5-day volatility

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

end