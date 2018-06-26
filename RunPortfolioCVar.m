function [dateRange, wStar, prices, market ] = RunPortfolio( symbols, holdingperiod, startHold, endHold, startOpt, endOpt, rf, leverage,c )

%% Use Datafeed Toolbox to import price data from Money.net
% this will optimize a portfolio using a specified date range, then invest on
% using another specified range and return performances



    
%% Retrieve Money.Net last month
    date = [datetime(startOpt) datetime(endOpt)]; % [begin end]
    interval = '1D'; % time interval (alternatives: )
    f = {'Close'}; % data fields we want
    portfolio= struct;
    % Need to loop through individual retrieval
    for j = 1:length(symbols) % loop through the length of symbols cells
        symbol = symbols{j}; % select symbol
        ticker = char(symbol); % generate string variable with symbol
        d.ticker = timeseries(c,symbol,date,interval,f); % retrieve data
        ticker=string(ticker);
        if (ticker=='BRK.B')
            symbol='BRK'; %the period in this ticker causes problems
        end
        portfolio.(symbol)=(d.ticker.Close); %this is to save all the closes under the ticker names in a portfolio object
    end
    
   
    
    %% Now to create equal weight initial portfolio
lenp = length(symbols);    
w = ones([lenp,1])./lenp; %equal weights
rAve=ones([lenp,1]);
Ri= ones([length(portfolio.XOM),lenp]);
for j = 1:length(symbols) % loop through the length of symbols cells
        symbol = symbols{j}; % select symbol
        ticker=string(symbol);
        if (ticker=='BRK.B')
            symbol='BRK';
        end
        rAve(j,:)= mean(portfolio.(symbol)); %average returns
        Ri(:,j)=portfolio.(symbol); %actual daily returns
end
rAve; %in case you want to print these for testing
Ri;    %same
ErP = w'*rAve;
Sig= cov(Ri);
sigmaP = w'*Sig*w; %variance of portfolio

%% maximize Sharpe ratio of portfolio
rStar= mean(rAve);
ub=[]; lb=[];
beq= [leverage];  
Aeq=ones([lenp]);
Aeq = [ ones(1,lenp)];
rf = 0.5; %risk free rate 
sharpeRatio=@(w)1/((w'*rAve-rf)/(sqrt(w'*cov(Ri)*w))); %minimizing the inverse of the sharpe ratio in order to maximize the sharpe ratio
A=[]; b=[]; %No inequality constraints
options = optimoptions(@fmincon, 'MaxFunctionEvaluations', 10000);

wStar= fmincon(sharpeRatio, w, A,b, Aeq, beq, lb, ub, [], options);

%% using w*, buy shares, then find performance over last five days
    
%% Retrieve Money.Net last 100 days
    date = [datetime(startHold) datetime(endHold)]; % [begin end]
    interval = '1D'; % time interval (alternatives: )
    f = {'Close'}; % data fields we want
    portfolio= struct;
    % Need to loop through individual retrieval
    for j = 1:length(symbols) % loop through the length of symbols cells
        symbol = symbols{j}; % select symbol
        ticker = char(symbol); % generate string variable with symbol
        d.ticker = timeseries(c,symbol,date,interval,f); % retrieve data
        ticker=string(ticker);
        if (ticker=='BRK.B')
            symbol='BRK';
        end
        portfolio.(symbol)=(d.ticker.Close);
        dateRange(:,j)=(d.ticker.Date); %this saves the dates for portfolio reporting
       
    end
    
    market= timeseries(c,'IVV',date, interval, f);  % I used the IVV because its symbol was easy to find and it tracks the SP500 very well

        
        
    
    
prices= ones([holdingperiod,lenp]);
for j = 1:length(symbols) % loop through the length of symbols cells
        symbol = symbols{j}; % select symbol
        ticker=string(symbol);
        if (ticker=='BRK.B')
            symbol='BRK';
        end
        prices(:,j)=portfolio.(symbol); %closing prices each day moved from structure to matrix
end
end
