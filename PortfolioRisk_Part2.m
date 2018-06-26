%Housekeeping
    clear all; close all; clc; 
    %tspath = 'C:\Users\maguilar\Dropbox\Teaching\QFE\Curriculum\Econ590-490 Spring 2017\Lecture Notes\Risk\Code\';
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
    %Find the start and ending dates within the Prices table
    ind1 = find(Prices.DateNum==StartDate); 
    ind2 = find(Prices.DateNum==EndDate); 
    %Curtail the Prices vector only to the case of interest
    Prices = Prices(ind1:ind2,:); 
%Drop the DateNum to clean things up
    Prices.DateNum = [];
%Compute returns
    temp = table2array(Prices(:,2:end)); 
    N = size(temp,2); %# of assets
    T = size(temp,1); % # of months
    Returns = zeros(T-1,N); 
    for i =1:N
        Returns(1:T-1,i) = temp(2:end,i)./temp(1:end-1,i)-1; 
    end
    tickers = Prices.Properties.VariableNames; 
    tickers(:,1)=[];
    Returns = array2table(Returns,'VariableNames',tickers); 
    Returns.Date=Prices.Date(2:end,1); 


%%%%%%%%%%%%%%%%%%%%%%%
%Max Sharpe Ratio portfolio
    Dates = Returns.Date;%Set up a date vector for use in plotting 
    Returns = table2array(Returns(:,1:end-1)); %Turn into array for ease
    Pi = mean(Returns); %Mean returns
    Sigma = cov(Returns); %Cov of returns
    %Set up a MeanVariance (MV) portfolio object
        mvp = Portfolio('AssetMean',Pi, 'AssetCovar',Sigma);
        mvp = setDefaultConstraints(mvp);
    %Optimize
        mvwgt = estimateMaxSharpeRatio(mvp);
    %Grab the resultant risk and return    
        [mvstd, mvret] = estimatePortMoments(mvp, mvwgt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct a Min CVaR portfolio

%Set up a portfolio object
    cvarp = PortfolioCVaR;
    cvarp = setAssetList(cvarp, tickers);
    cvarp = setDefaultConstraints(cvarp);
%The initial portfolio as the Max SR portfolio
    cvarp = setInitPort(cvarp, mvwgt);
%Simuate many portfolios based upon the historical moments
    cvarp = simulateNormalScenariosByMoments(cvarp, Pi, Sigma, 20000);
%Set a confidence level for the estimation of VaR
    level = .99; 
    cvarp = setProbabilityLevel(cvarp,level);
%Grab the optimal weights from the estimation Frontier call
    [cvarwgt, pbuy, psell] = estimateFrontierByRisk(cvarp,1-level);

%Blotter = dataset([{100*[mvwgt, cvarwgt, pbuy, psell]}, ...
%{'Initial','Weight', 'Purchases','Sales'}],'obsnames',cvarp.AssetList);
%display(Blotter);
%Compute the 1st 2 moments of the CVaR portfolio
    cvarstd = estimatePortStd(cvarp,cvarwgt); 
    cvarret = estimatePortReturn(cvarp,cvarwgt); 

%%%%%%%%%%%%%%%%%%%%%%%    
% Compare the portfolios
    row1 = [mvret mvstd mvret/mvstd mvwgt'];
    row2 = [cvarret cvarstd cvarret/cvarstd cvarwgt'];
    Output = [row1; row2];
    cnames = ['Ret','Std','RetOverRisk',tickers];
    OutputTable = array2table(Output,'VariableNames',cnames,'RowNames',{'MV','CVaR'}); 
    disp(OutputTable);

%Plot the implied portfolio price series
    MVPortPrice = ret2price(Returns*mvwgt); 
    CVaRPortPrice = ret2price(Returns*cvarwgt); 
    plot(Dates,MVPortPrice(2:end,1)); 
    hold on
    plot(Dates,CVaRPortPrice(2:end,1),'r');
    legend('MV','CVaR');
    title('Implied Portfolio Prices')
