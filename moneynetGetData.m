%% Use Datafeed Toolbox to import price data from Money.net
%Purpose:
    %Illustrate by example how to retrieve financial data from Money.Net
%Author: 
    %Gonzalo Asis, UNC Economics, Jan 16, 2017. 

%% Housekeeping
    clear all % clear all variables from memory
    close all % close all figures
    clc % clear command window
    
%% Create Money.Net Connection
    % Input username and password
    username = 'unc7@unc.edu';
    pwd = 'moneynet';
    
    c = moneynet(username,pwd); % create connection
    
%% Retrieve Money.Net Current Data
    % Retrieve last price and highest price of day for one security
    symbol = 'AAPL'; % input security ticker(s)
    f = {'High','Last'}; % data fields we want
    d = getdata(c,symbol,f); % retrieve data
    d % display it
    
    % Retrieve data for multiple securities this time
    symbols = {'AAPL','GOOG','YHOO'}; % input security ticker(s)
    d = getdata(c,symbols,f); % retrieve data
    d % display it
    
%% Retrieve Money.Net Historical Data
    % Retrieve historical prices for one security
    symbol = 'AAPL';
    date = [datetime('1-Jun-2015') datetime('25-Jun-2015')]; % [begin end]
    interval = '1W'; % time interval (alternatives: )
    f = {'High','Close'}; % data fields we want
    
    d2 = timeseries(c,symbol,date,interval,f);
    d2(1:3,:) % display first three rows of data
    
    % Retrieve historical prices for multiple securities
    symbols = {'AAPL','GOOG','YHOO'};
    date = [datetime('1-Jun-2015') datetime('25-Jun-2015')];
    interval = '1W'; % time interval
    f = {'High','Close'}; % data fields we want
    % Need to loop through individual retrieval
    for j = 1:length(symbols) % loop through the length of symbols cells
        symbol = symbols{j}; % select symbol
        ticker = char(symbol); % generate string variable with symbol
        d.ticker = timeseries(c,symbol,date,interval,f); % retrieve data
        ticker % display ticker
        d.ticker(1:3,:) % display first three rows of data
    end
    
    close(c); % close connection
    
    