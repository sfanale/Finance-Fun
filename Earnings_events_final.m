% Pogram to perform similar analysis as in Rendelman, Jones, Latane (1982)
% Use as an example of an event study to analyze stock price respnse to
% earnings announcements
% 
% Author: Gonzalo Asis
% Date: 1/24/2017
% 
% Legend from Earnings spreadsheet:
% datadate = last date included in the report
% datacqtr = calendar data year and quarter (mirrors fyearq?)
% datafqtr = fiscal year and quarter of data
% rdq = report date of quarterly earnings

%% Housekeeping
clear all
clc
close all
tic;

%% User inputs
% Directory
cd 'C:\Users\Gonzalo\Dropbox\QFE\Curriculum\Lesson Plans\EMH';

% Number of days post-report
win_end = 40;

% Number of days pre-report
win_beg = 5;

% Number of eps-sorted groups to divide into
G = 6;
toc;

%% Input earning announcement dates from Compustat

% Earnings per share and report release dates
Earnings = importdata('Earnings_dates.csv',',');
Earnings.headers = Earnings.textdata(1,:);
Earnings.textdata = Earnings.textdata(2:end,:);

% Daily stock prices
fid = fopen('daily_stocks_small.csv');
Firm.headers = textscan(fid,'%s %s %s %s',1,'Delimiter',',');
Firm.alldata = textscan(fid,'%f %f %s %f','HeaderLines',1,'Delimiter',',');
fclose(fid);

% Daily S&P prices
Index = importdata('daily_sp500.csv',',');
Index.headers = Index.textdata(1,:);
Index.textdata = Index.textdata(2:end,:);
toc;

%% Format dates

% Format dates for Firm
[kf, ~] = size(Firm.alldata{1,1}); % number of firm-day observations
FirmDateNumbers = zeros(kf, 1); % initialize date vector
for i = 1:kf
    a = Firm.alldata{1,2}(i,:); % date
    b = Firm.alldata{1,4}(i,:); % price
    date1 = datevec(num2str(a),'yyyyMMdd');
    FirmDateNumbers(i) = datenum(date1(1), date1(5), date1(3)); % year day month
    Firm.alldata{:,4}(i,:) = abs(b); % format CRSP data (includes -)
end

% Format dates for Index
[ki, ~] = size(Index.textdata); % number of firm-report observations
IndexDateNumbers = zeros(ki,1); % initialize date vector
for i = 1:ki
    a = Index.textdata(i,1); % date
    date2 = datevec(a{1},'MM/dd/yyyy');
    IndexDateNumbers(i) = datenum(date2(1), date2(5), date2(3)); % year day month
end

% Format dates for Earnings
[ke, ~] = size(Earnings.textdata);
EarningsDateNumbers = zeros(ke,1); % initialize date vector
for i = 1:ke
    a = Earnings.data(i,1); % date
    date3 = datevec(num2str(a),'yyyyMMdd');
    EarningsDateNumbers(i) = datenum(date3(1), date3(5), date3(3)); % year day month
end
toc;

%% Calculate returns for the company file

% Create data structure with the company name (ticker), date number, and return
comps = struct('Name', {}, 'dateNum', {}, 'return', {}); % Empty structure

% Create index file with the company name (ticker) and position where its
% prices begin
compIndex = struct('Name', {}, 'begin', {}); % Empty structure

% Initiate variables
com = '';
count = 0;
countInd = 0;

% Create index file with the beginning of each firm's records and compute
% returns
for i = 1:kf % Each element of firm data
    a = Firm.alldata{1,3}(i,:); % Grab third column (ticker)
    if(~strcmp(a, com)) % if the firm name is not equal to most recent firm looped through (i.e. if this is a new firm)
        com = a; % assign firm name to variable com
        countInd = countInd+1; % increase index count
        compIndex(countInd).Name = com; % assign firm name to compIndex structure
        compIndex(countInd).begin = count + 1; % mark the beginning of new firm (by ordered integers)
    else % if this is the same firm as the last iteration
        count = count + 1; % increase count to move on to second observation of same firm
        comps(count).Name = com; % name that observation by the name of the previous observation
        comps(count).dateNum = FirmDateNumbers(i); % assign date to firm
        comps(count).return = (Firm.alldata{:,4}(i,:) - Firm.alldata{:,4}(i-1,:))/Firm.alldata{:,4}(i-1,:); % calculate and assign return for this firm and date
    end
end

% Mark the ending position of each firm (one observation prior to beginning
% of next firm)
for q = 1:countInd-1
    compIndex(q).end = compIndex(q+1).begin - 1;
end
compIndex(countInd).end = count;
toc;

%% Calculate returns for the index

% Create structure with the date number and return for the index
sp = struct('dateNum', {}, 'return', {}); % Empty structure

for i = 2:ki
    sp(i-1).dateNum = IndexDateNumbers(i);
    sp(i-1).return = (Index.data(i,1) - Index.data(i-1,1))/Index.data(i-1,1);
end

ki = ki - 1; % Reduce size of Index file to adjust for returns
toc;

%% Create data structure for the Earnings file

earn = struct('ID',{},'firmName',{},'eventDate',{},'windowEnd',{},'windowLength',{});
 
for i = 1:ke % Each observation in Earnings file
    % Populate earn structure from Firm data
    earn(i).firmName = Earnings.textdata(i, 2); % Ticker
    earn(i).eventDate = EarningsDateNumbers(i); % Event date
    earn(i).eps = Earnings.textdata(i,3); % Earnings per share
    earn(i).windowEnd = win_end; % Number of days post-report
    earn(i).windowLength = win_beg + win_end; % Size of window around report 
end

clear IndexDateNumbers EarningsDateNumbers FirmDateNumbers Firm Earnings Index
toc;

%% Calculate cumulative returns in earnings report window
% Steps:
% 1. Take company and date from Earnings file
% 2. Find company and date in Company file
% 3. Find date in S&P file

sp_ret = cell(1,G);
comps_ret = cell(1,G);
ex_ret = cell(1,G);
for i = 1:ke % Each firm (ke)
    marker = 0;
    name = earn(i).firmName; % take ticker from the earnings file
    date = earn(i).eventDate; % take date from the earnings file
    eps = str2num(cell2mat(earn(i).eps)); % take date from the earnings file
    
    % Find the firm in the compIndex file
    for j = 1:countInd
        if(strcmp(name, compIndex(j).Name))
            break; % Select j such that the name in compIndex matches the name we selected from Earnings
        end
    end
    
    pos = compIndex(j).begin; % Beginning position of firm
    pos2 = compIndex(j).end; % Ending position of firm
    % Find in comps the earnings report date for this firm
    for k = pos:pos2
        if(date == comps(k).dateNum)
            marker = 1; % Change marker to 1 if dates match
            break; % Select k such that the date in comps matches the date we selected from Earnings
        end
    end
    
    if marker == 1 && ~isempty(eps) % if firm and earnings date have a match and eps is nonempty
        windowEnd = k + earn(i).windowEnd; % Create index for end of report window
        windowBeg = windowEnd - earn(i).windowLength +1; % Create index for beginning of report window
        
        % Find index of the event in the sp file
        for jj = 1:ki
            if(sp(jj).dateNum == date)
                break; % Select jj such that the date in sp matches the date we selected from Earnings
            end
        end
        
        % Get the report window in the sp file
        windowEnd_ = jj + earn(i).windowEnd; % Create index for end of report window
        windowBeg_ = windowEnd_ - earn(i).windowLength +1; % Create index for beginning of report window
        
        spRet = zeros(earn(i).windowLength, 1); % Initialize empty matrix of report window length
        compsRet = zeros(earn(i).windowLength, 1); % Initialize empty matrix of report window length
        
        % Fill matrices with returns of comps and sp during report window
        for ii = 1:earn(i).windowLength
            % keep only stocks with data for all years
            if windowBeg_ + ii -1 > 0 && windowBeg + ii -1 > 0 && windowBeg_ + ii -1 < length(sp) && windowBeg + ii -1 < length(comps)
                spRet(ii)= sp(windowBeg_ + ii -1).return;
                compsRet(ii) = comps(windowBeg + ii -1).return;
            end
        end
        
        % Eliminate outliers (-20% > daily return, daily return > 20%)
        compsRet(compsRet>0.2) = NaN;
        compsRet(compsRet<-0.2) = NaN;
        
        % Sort by eps (1 = highest EPS, 6 = lowest EPS)
        if eps < -1
            n = 6;
        end
        if -1 <= eps && eps < -0.5
            n = 5;
        end
        if -0.5 <= eps && eps < 0
            n = 4;
        end
        if 0 <= eps && eps < 0.5
            n = 3;
        end
        if 0.5 <= eps && eps < 1
            n = 2;
        end
        if eps >= 1
            n = 1;
        end
        
        % Store returns for firms with returns data on earnings date
        ij = size(sp_ret{n},2) + 1; 
        sp_ret{n}(:,ij) = spRet;
        comps_ret{n}(:,ij) = compsRet;
        ex_ret{n}(:,ij) = comps_ret{n}(:,ij) - sp_ret{n}(:,ij);
    end  
end

clear windowBeg windowBeg_ windowEnd windowEnd_ win_beg win_end pos pos2

%% Find average returns within each eps group PER DAY
for n = 1:length(ex_ret)
    meanRet(:,n) = nanmean(ex_ret{n},2);
    cumRet(:,n) = cumsum(meanRet(:,n));
end

%% Plot average return
figure
plot(cumRet)
hold on;
plot([5 5],[-0.01 0.08])
legend('Group 1 (High EPS)','Group 2','Group 3','Group 4','Group 5','Group 6 (Low EPS)');
title('Cumulative Excess Returns Around Earnings Announcements');
toc;
%% Debugging
% 
% for n = 1:5
%     for ij = 1:size(sp_ret{n},2)
%         kk = isnan(ex_ret{n}(:,ij));
%         ex_ret{n}(kk,ij) = 0;
%         cum_ret{n}(:,ij) = cumsum(ex_ret{n}(:,ij));
%     end 
% mean_cum_ret(:,n) = mean(cum_ret{n},2);
% end 
% 
% for n = 1:length(ex_ret)
%     meanSp(:,n) = nanmean(sp_ret{n},2);
%     cumSp(:,n) = cumsum(meanSp(:,n));
% end
% 
% for n = 1:length(ex_ret)
%     meanComps(:,n) = nanmean(comps_ret{n},2);
%     cumComps(:,n) = cumsum(meanComps(:,n));
% end
% 
% figure
% plot(meanRet)
% legend('Group 1 (High EPS)','Group 2','Group 3','Group 4','Group 5','Group 6 (Low EPS)');
% title('meanRet')
% 
% figure
% plot(meanSp)
% legend('Group 1 (High EPS)','Group 2','Group 3','Group 4','Group 5','Group 6 (Low EPS)');
% title('cumSp')
% 
% figure
% plot(cumComps)
% legend('Group 1 (High EPS)','Group 2','Group 3','Group 4','Group 5','Group 6 (Low EPS)');
% title('cumComps')
% 
% figure
% plot(cumRet)
% legend('Group 1 (High EPS)','Group 2','Group 3','Group 4','Group 5','Group 6 (Low EPS)');
% title('cumRet')
% 
% 
