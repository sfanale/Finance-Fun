%% Script to create Portfolio Performance Report on Powerpoint
%  This will use specified inputs and a predefined function to collect the
%  performance of an automatically optimized portfolio using the Sharpe
%  Ratio. It will then report these performance measures in a powerpoint.

% I intend to maximize the sharpe ratio for my portfolio using one calendar 
% month worth of data. I will then update my weights each Friday at close. 


clear all; close all; clc; 

%% Inputs
student_name = 'Stephen Fanale';
portfolio_desc = 'This is a Large Cap portfolio that uses the Sharpe Ratio to optimize a portfolio. The assest will be reweighted each Friday close.';
 

%% Choose portfolio

symbols= {'MMM' 'GM' 'IBM' 'GOOG' 'FB' 'AAPL' 'BAC' 'CRM' 'HBI' 'MYL' 'MSFT' 'BRK.B' 'JPM' 'GS' 'DB' 'GE' 'BA' 'NKE' 'NVDA' 'INTC' 'AXP' 'DIS' 'PFE' 'AMZN' 'JNJ' 'HD' 'NFLX' 'BBT' 'XOM' 'CVX'};
%[symbols] = pickStocks(  );  %This isnt as good as my picks lol. Just switcht the comment to choose.

%%
startingCash = 1000000;
holdingperiod=6;   %buy on friday close, hold until next friday close
benchmark = {'SP500'};
rf = 0.5; % risk-free rate
leverage= 1.5;
weeks=9; %number of weeks of holding
startOpt= '20-Dec-2016';
endOpt= '20-Jan-2017';
endHold='27-Jan-2017';
startHold='20-Jan-2017';
%% Portfolio Performance
username = 'unc1@unc.edu';
    pwd = 'moneynet';
    
    c = moneynet(username,pwd);

[date1,wStar1, prices1, market1 ] = RunPortfolio( symbols, holdingperiod, startHold, endHold, startOpt, endOpt, rf,leverage,c);
output='Week One: Complete'

startOpt= '27-Dec-2016';
endOpt= '27-Jan-2017';
startHold='27-Jan-2017';
endHold='03-Feb-2017';
[date2,wStar2, prices2, market2 ] = RunPortfolio( symbols, holdingperiod, startHold, endHold, startOpt, endOpt, rf, leverage,c );
output='Week Two: Complete'

startOpt= '03-Jan-2017';
endOpt= '03-Feb-2017';
startHold='03-Feb-2017';
endHold='10-Feb-2017';
[date3,wStar3, prices3, market3 ] = RunPortfolio( symbols, holdingperiod, startHold, endHold, startOpt, endOpt, rf, leverage,c );
output='Week Three: Complete'

startOpt= '10-Jan-2017';
endOpt= '10-Feb-2017';
startHold='10-Feb-2017';
endHold='17-Feb-2017';
[date4,wStar4, prices4, market4 ] = RunPortfolio( symbols, holdingperiod, startHold, endHold, startOpt, endOpt, rf, leverage,c );
output='Week Four: Complete'

startOpt= '17-Jan-2017';
endOpt= '17-Feb-2017';
startHold='17-Feb-2017';
endHold='24-Feb-2017';
[date5,wStar5, prices5, market5 ] = RunPortfolio( symbols, 5, startHold, endHold, startOpt, endOpt, rf, leverage,c ); %president's day means the market was closed
output='Week Five: Complete'

startOpt= '24-Jan-2017';
endOpt= '24-Feb-2017';
startHold='24-Feb-2017';
endHold='3-Mar-2017';
[date6,wStar6, prices6, market6 ] = RunPortfolio( symbols, holdingperiod, startHold, endHold, startOpt, endOpt, rf, leverage ,c);
output='Week Six: Complete'

startOpt= '3-Feb-2017';
endOpt= '3-Mar-2017';
startHold='3-Mar-2017';
endHold='10-Mar-2017';
[date7,wStar7, prices7, market7 ] = RunPortfolio( symbols, holdingperiod, startHold, endHold, startOpt, endOpt, rf, leverage ,c);
output='Week Seven: Complete'

startOpt= '10-Feb-2017';
endOpt= '10-Mar-2017';
startHold='10-Mar-2017';
endHold='17-Mar-2017';
[date8,wStar8, prices8, market8 ] = RunPortfolio( symbols, holdingperiod, startHold, endHold, startOpt, endOpt, rf, leverage ,c);
output='Week Eight: Complete'

startOpt= '17-Feb-2017';
endOpt= '17-Mar-2017';
startHold='17-Mar-2017';
endHold='24-Mar-2017';
[date9,wStar9, prices9, market9 ] = RunPortfolio( symbols, holdingperiod, startHold, endHold, startOpt, endOpt, rf, leverage ,c);
output='Week Nine: Complete'

close(c); % close connection
%% Combine outputs and get stats

date= [date1(:,1);date2(2:end,1);date3(2:end,1);date4(2:end,1);date5(2:end,1);date6(2:end,1);date7(2:end,1);date8(2:end,1);date9(2:end,1)]; %this makes it so you dont grab the same day twice
weights=[wStar1, wStar2, wStar3, wStar4,wStar5,wStar6,wStar7,wStar8,wStar9];

prices= [prices1(:,:); prices2(2:end,:);prices3(2:end,:);prices4(2:end,:);prices5(2:end,:);prices6(2:end,:);prices7(2:end,:);prices8(2:end,:);prices9(2:end,:)];
market= [market1(:,:); market2(2:end,:);market3(2:end,:);market4(2:end,:);market5(2:end,:) ;market6(2:end,:);market7(2:end,:);market8(2:end,:);market9(2:end,:)];
holdingperiods=[6;6;6;6;5;6;6;6;6];
dayoffset=[0,0,0,0,0,1,1,1,1]; % because presidents day messed up my indexing of prices   
[SampleStats] = portStats(symbols, prices, market, weights, startingCash, rf, weeks, holdingperiods, dayoffset);
%% Create Figures
% Pie chart of asset allocation
for i=1:length(symbols)
    labels(i) = (symbols(i));
end

% Asset allocation pie chart
figure
pie((weights(:,end)),labels)
title('Asset Allocation')
saveas(gcf,'Pie_alloc.png');

% Histogram of returns
figure
histogram(SampleStats.ret_port)
title('Returns Histogram')
saveas(gcf,'Hist_port.png');

% Daily return of portfolio and benchmark
figure
plot(date(1:end,:),[0;SampleStats.ret_port*100], '--rs', 'MarkerSize',7) % Add zero because no returns on first day (you just buy)
hold on
plot(date(1:end,:),[0;SampleStats.ret_mkt*100],'--bs','MarkerSize',7)
legend('Portfolio',char(benchmark))
title('Daily Yield')
xlabel('Date');
ylabel('Percent Return');
datetick('x',23,'keeplimits')
saveas(gcf,'Daily_ret.png');

% Cumulative return of portfolio and benchmark
figure
plot(date(1:end,:),[0;SampleStats.cumret_port*100], '--rs', 'MarkerSize',7)
hold on
plot(date(1:end,:),[0;SampleStats.cumret_mkt*100],'--bs' ,'MarkerSize',7)
legend('Portfolio',char(benchmark))
title('Cumulative Returns')
xlabel('Date');
ylabel('Percent Return');
datetick('x',23,'keeplimits') % place date in x-axis in date format
saveas(gcf,'Cum_ret.png');

%% Create Tables
% Convert structure to cell
info = struct2cell(SampleStats);
numbers = zeros(14,3);

% Fill out the table with the data from SampleStats
numbers(end-1:end,1) = cell2mat(info(24:25,:)); % min and max
numbers(end-6:end-2,1) = cell2mat(info(13:17,:)); % median, mean, ..., kurtosis
numbers(2:4,1) = cell2mat(info(21:23,:));
numbers(1,1) = SampleStats.cumret_port(end,:)*100;
numbers(5:6,1) = cell2mat(info(18:19,:));
numbers(1,3)= SampleStats.cumret_mkt(end,:)*100;
numbers(end-6:end-2,3) = cell2mat(info(26:30,1));
numbers(2,3)= cell2mat(info(32,1));
numbers(end-1:end,3)= cell2mat(info(33:34,1));

numbers(:,2)=numbers(:,3); %move column 3 to 2
%numbers= round(numbers,6, 'significant'); % best way I could find to limit decimal precision
numbers=arrayfun(@(x) sprintf('%10.3f',x),numbers,'un',0);

close all; % close figures

%% Housekeeping
import mlreportgen.ppt.* % import Matlab package to create ppt presentation

%% Build Presentation
PresName = 'FanaleStephen_CodeBook9.pptx'; % name of ppt file
slides = Presentation(PresName); % create ppt presentation
student_name=strcat('Stephen Fanale');
replace(slides,'Footer',student_name); % Not working

% Gives information on presentation format
%masters = getMasterNames(slides)
%layout = getLayoutNames(slides,masters{1})

%% Title Slide
slide0 = add(slides,'Title Slide'); % 'Title Slide' tells the type of slide

contents = find(slides,'Title'); % find Title object and assign to placeholder variable
replace(contents(1),'Performance Report - Week 9'); % replace contents with text
contents(1).FontColor = 'red';
replace(slide0,'Subtitle',student_name);

%% Slide 1
slide1 = add(slides,'Title and Content');
replace(slide1,'Title','Portfolio Description')
replace(slide1,'Content',portfolio_desc);


%% Title Slide
slide3 = add(slides,'Title Slide');
replace(slide3,'Title','Portfolio-level Analysis')

%% Picture slide 1
close all; % To prevent picture from staying open

% Create slide and insert picture
Pie_alloc = Picture('Pie_alloc.png');
picSlide1 = add(slides,'Picture with Caption');
replace(picSlide1,'Title','Current Asset Allocation');
replace(picSlide1,'Picture',Pie_alloc);
caption=strcat('Pie chart showing allocation of resources in percents');
replace(picSlide1,'Text',caption);

%% Weights Slide
% Create table
headers1 = { 'Current Investment'}';
rownames = {'';'MMM';'GM'; 'IBM'; 'GOOG' ;'FB'; 'AAPL' ;'BAC' ;'CRM'; 'HBI'; 'MYL'};
weightsRounded= round(weights(:,end),3, 'significant');
data1 = [headers1;num2cell(startingCash*weightsRounded(1:10))];
data = [rownames, data1];
myTable1 = Table(data);

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Current Holdings');
replace(tableSlide,'Table',myTable1); % remember to wrap the table in Table()

%% Weights Slide
% Create table
headers1 = { 'Current Investment'}';
rownames = {''; 'MSFT'; 'BRK.B' ;'JPM'; 'GS'; 'DB'; 'GE'; 'BA'; 'NKE'; 'NVDA'; 'INTC'};

data1 = [headers1;num2cell(startingCash*weightsRounded(11:20))];
data = [rownames, data1];
myTable1 = Table(data);

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Current Holdings');
replace(tableSlide,'Table',myTable1); % remember to wrap the table in Table()
%% Weights Slide
% Create table
headers1 = { 'Current Investment'}';
rownames = {''; 'AXP'; 'DIS'; 'PFE'; 'AMZN' ;'JNJ'; 'HD'; 'NFLX'; 'BBT'; 'XOM'; 'CVX'};

data1 = [headers1;num2cell(startingCash*weightsRounded(21:30))];
data = [rownames, data1];
myTable1 = Table(data);

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Current Holdings');
replace(tableSlide,'Table',myTable1); % remember to wrap the table in Table()

%% Picture slide 2
% Create slide and insert picture
Hist_port = Picture('Hist_port.png');
picSlide2 = add(slides,'Picture with Caption');
replace(picSlide2,'Title','Histogram of Returns');
replace(picSlide2,'Picture',Hist_port);
text=strcat('This is a histogram of the returns of the assets held in the portfolio.');
replace(picSlide2,'Text',text);


%% Picture slide 3
% Create slide and insert picture
Daily_ret = Picture('Daily_ret.png');
picSlide3 = add(slides,'Picture with Caption');
replace(picSlide3,'Title','Daily Returns');
replace(picSlide3,'Picture',Daily_ret);
text=strcat('Daliy returns of my portfolio versus the IVV, and ETF that tracks the S&P 500.');
replace(picSlide3,'Text',text);
%% Picture slide 4
% Create slide and insert picture
Cum_ret = Picture('Cum_ret.png');
picSlide4 = add(slides,'Picture with Caption');
replace(picSlide4,'Title','Cumulative Returns');
replace(picSlide4,'Picture',Cum_ret);
text=strcat('Cumluative returns of my portfolio versus the IVV, and ETF that tracks the S&P 500.');
replace(picSlide4,'Text',text);

%% Table slide 1
% Create table
headers1 = {'Portfolio'; 'Benchmark';}';
headers2 = {'Since Inception';'Since Inception';}';
rownames = {'';'';'Cumulative Return';'Sharpe Ratio';'Information Ratio' ...
            ;'Maximum Drawdown';'CAPM beta';'CAPM alpha'};
data1 = [headers1;headers2;(numbers(1:6,1:2))];
data = [rownames, data1];
myTable2 = Table(data);

% Create slide and insert table
tableSlide = add(slides,'Title and Content');
replace(tableSlide,'Title','Performance Statistics');
replace(tableSlide,'Content',myTable2); % remember to wrap the table in Table()

%% Table slide 2
% Create table
headers1 = {'Portfolio'; 'Benchmark';}';
headers2 = {'Since Inception';'Since Inception';}';
rownames = {'';'';'Median' ...
            ;'Mean';'Standard Deviation';'Skewness';'Kurtosis';'Maximum';'Minimum'};
data1 = [headers1 ;headers2 ;(numbers(8:end,1:2))];
data = [rownames, data1];
myTable3 = Table(data);

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Performance Statistics');
replace(tableSlide,'Table',myTable3); % remember to wrap the table in Table()

%% Conclusion
slide1 = add(slides,'Title and Content');
replace(slide1,'Title','Portfolio Performance Review');
content= strcat(' Homework 3 took up all the time I would have used to do more performance review. The hand picked stocks are still doing better than the Factor selected ones.') ;
replace(slide1,'Content',content);


%% Generate and open the presentation
close(slides);

if ispc % if this machine is Windows
    winopen(PresName);
end