%% Portfolio Construction
%Purpose: 
    %Simple example to illustrate how to generate a portfolio. Data is
    %assumed to have been gathered from source and stored in excel.  Weights
    %are chosen subjectively. 
    %We will look at APPL, GOOG, and SP500 as benchmark. We assume that the
    %dates for all three assets are aligned properly.  Use Daily adjusted
    %closing prices. 
%Author: 
    %Mike Aguilar, UNC Economics, Jan 13, 2017. 
    %Adapted from code created by Gonzalo Asis 10/03/2016


%% Housekeeping
    clear all % clear all variables from memory
    close all % close all figures
    clc % clear command window
    
%% Import Data
    inputfile = [pwd,'\Lesson1data']; % file to input data from. Note: pwd indicates local directory. 
    %outputfile = [pwd,'\Lesson1results']; % file to output results to
        
    %Import the dates
        sheet = 'GOOG'; %Sheets are named as tickers
        range = 'A2:A64';%I know this range by looking at excel.  Could load in blind as well. 
        [~,txt] = xlsread(inputfile,sheet,range);%Load in the data
        datenums = datenum(txt); 
        T=size(txt,1); %# of days of prices
        %Verify the converted dates are matching the txt strings
            datestr(datenums(end,1)) %displays the string version of the last date
            txt(end,1) %displays the last string date
        %Store in a Price matrix
        Price = ones(T,4); %Create a temporary Price matrix filled with ones. T long and 4 across (Dates, GOOG, APPL, SP500)
        Price(:,1) = datenums; %Put dates in the first column 
        
    %Import Google --- Note: I could also import dates and prices together.  
        sheet = 'GOOG'; %Sheets are named as tickers
        range = 'G2:G64'; %I know this range by looking at excel.  Could load in blind as well. 
        [temp] = xlsread(inputfile,sheet,range);%Load in the data
    %Store in a Price matrix
        Price(:,2) = temp; %Put google in the second column.  
    
    
    %Import APPL --- Note: I could also import dates and prices together.  
        sheet = 'AAPL'; %Sheets are named as tickers
        range = 'G2:G64'; %I know this range by looking at excel.  Could load in blind as well. 
        [temp] = xlsread(inputfile,sheet,range);%Load in the data
    %Store in a Price matrix
        Price(:,3) = temp; %Put apple in the third column.        

    %Import SP500 --- Note: I could also import dates and prices together.  
        sheet = 'SP500'; %Sheets are named as tickers
        range = 'G2:G64'; %I know this range by looking at excel.  Could load in blind as well. 
        [temp] = xlsread(inputfile,sheet,range);%Load in the data
    %Store in a Price matrix
        Price(:,4) = temp; %Put apple in the third column.  

%% Clean Up 
    clearvars -except Price %clean up workspace. Keep only Price
    %Invert data so most recent prices are at the bottom (helpful for plots)
        Price = flipud(Price); 

%% Portfolio formation
    %User defined
        wG = .5; % Weight on GOOG
        wA = .5; % Weight on AAPL
        initequity = 100000000; %Initial Equity
    %Determine shares to purchase, assuming buy @ first day observed price.
    %recall that Price*Shares = w*EquityValue
        SharesG = wG*initequity/Price(1,2); 
        SharesA = wA*initequity/Price(1,3); 

    %Construct buy and hold portfolio for the entire holding period
        Portfolio = SharesG*Price(:,2) + SharesA*Price(:,3); 

      
%% Compare to benchmark
    %We can reindex the SP500 to value of initial equity, then grow it by
    %its own returns in order to compare to our portfolio. 
    SpReturn = Price(2:end,4)./Price(1:end-1,4)-1; 
    SpIndex = ones(size(Portfolio,1),1); 
    SpIndex(1,1) = initequity; 
    for t = 2:size(SpIndex,1)
        SpIndex(t,1) = SpIndex(t-1,1)*(1+SpReturn(t-1,1)); 
    end
    %Verify the change in the index = return
        TempRet = SpIndex(2:end,1)./SpIndex(1:end-1,1) - 1; 
        [SpReturn TempRet]
   
%% Create chart overlaying the portfolio to the SP500 index
    figure(1)
    plot(Price(:,1),Portfolio/1000000); %Divide by 1Mil for scaling purposes
    datetick('x',23,'keeplimits')
    %ylim([min(Portfolio)*.95,max(Portfolio)*1.05]); 
    xlim([min(Price(:,1)),max(Price(:,1))]);%Keep the axis tight
    hold on
    plot(Price(:,1),SpIndex/1000000,'r'); %Divide by 1Mil for scaling purposes
    hold off
    legend('Portfolio','SP500')
    ylabel('Mil$')
    
    %% Create Bar Chart of daily returns of portfolio
    figure(2)
    bar(Price(:,1),Portfolio/1000000, 'g');
    datetick('x',23,'keeplimits')
    xlim([min(Price(:,1)),max(Price(:,1))]);
    ylim([100,125]);
    
    figure(3)
    plot(Price(:,1),Portfolio/1000000,'b',Price(:,1),SpIndex/1000000,'r')
    xlim([min(Price(:,1)),max(Price(:,1))]);
    legend('Portfolio','SP500')
    ylabel('Mil$')
    
   