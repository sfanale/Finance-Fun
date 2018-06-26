function [eventData, sharePer90, sector, buybackAmount, indDummies] = eventStudy( tickers,tableData )

%% event study code for buyback project - Stephen Fanale - May 2017
%This will be turned into a function to be called from a shell program. 
% It will perform the event study and return the results. 

% Inputs:
% -ticker 
% -file with price data - will be db file
% -event date

%db file is permno, date, Ticker, SIC, price, outstanding shares, SP return
ticker=tickers;
date1=tableData(1);

buybackAmount=tableData(2);
buybackCode=tableData(3);

Agri=0; Industrial=0; Manu=0; Util=0;
Retail=0; Finance=0; Service=0;
PublicAdmin=0;

%% Load in Data

conn = sqlite('myData.db','readonly'); 

A1=date1-90;
A2=date1;
A4=date1+90;
A1=num2str(A1);    % wait until turned into function
A2=num2str(A2);
A4=num2str(A4);
tickerSQL= char(ticker);

querry=['SELECT * FROM CRSPTable WHERE Date >' A1 ' and  Date<' A2 ' and Ticker="' tickerSQL '"']; % data before announcement 
out2 = fetch(conn,querry);
querry=['SELECT * FROM CRSPTable WHERE Date >=' A2 ' and  Date<=' A4 ' and Ticker="' tickerSQL '"'];  % data after announcement
out3 = fetch(conn,querry);

close(conn)
clear conn

if isempty(out2)==0 && isempty(out3)==0  % if it finds the data
    if length(out2)< 40 || length(out3)<40 % if for some reason there isnt enough price data
   eventData= [NaN NaN NaN];  sharePer90=NaN; sector=NaN; buybackAmount=NaN; indDummies(1,1:8)=NaN;
   else
priceBack=double(abs(cell2mat(out2(:,5))));
RmRfBack= double(cell2mat(out2(:,7)))/100 ;

priceFor=double(abs(cell2mat(out3(:,5))));
RmRfFor= double(cell2mat(out3(:,7)))/100 ;
       if isempty(find(priceBack==0,1))==1 && isempty(find(priceFor==0,1))==1  % if for some reason sql returns a zero price
ReturnsBack= price2ret(priceBack,[],'Periodic');
ReturnsFor= price2ret(priceFor,[],'Periodic');

rmrfBack= RmRfBack(2:end);
rmrfFor=RmRfFor(2:end);
   %get returns for each period of interest using forward data
    RetWeek= (( priceFor(6)-priceFor(1))/priceFor(1)) ;
    RetWeekMkt= (cumprod(rmrfFor(1:6)+1) - 1);
    RetWeekMkt=RetWeekMkt(end,:);
    Ret3Mon=( (priceFor(end)-priceFor(1))/priceFor(1));
    Ret3MonMkt=(cumprod(rmrfFor(:)+1) - 1);
    Ret3MonMkt=Ret3MonMkt(end,:);
    
    %do 1 day, 1 week, and 90 days
    [lamdahat] = olsQuant(ReturnsBack(:), rmrfBack(:) ,1);  % get lambda using backwards data
    effect(1,1)=ReturnsFor(1)-(rmrfFor(1)*lamdahat(2) +lamdahat(1));
    effect(2,1)=RetWeek-((RetWeekMkt)*lamdahat(2) +lamdahat(1));
    effect(3,1)=Ret3Mon-(Ret3MonMkt*lamdahat(2) +lamdahat(1));
    
    eventData= effect';
    
    %% adding the buybackRegress stuff in here - i used to have a seperate function but removed it to limit total number of SQL querries
    sharesFor=double(cell2mat(out3(2:end,6)));
    
    sector=floor(double(cell2mat(out3(1,3)))/100);  %this gets just the first two digits
    % for whichever sector is  - change zero to 1
    if sector <10
        Agri=1;
    elseif sector <20
        Industrial=1;
    elseif sector<40
        Manu=1;
    elseif sector<50
        Util=1;
    elseif sector<60
        Retail=1;
    elseif sector<68
        Finance=1;
    elseif sector<90
        Service=1;
    else
        PublicAdmin=1;
    end
    
    % conver all buyback amounts into dollars
    if buybackCode==1
        buybackAmount=buybackAmount*(10^6);   % in units of dollars
    elseif buybackCode==2
        buybackAmount= buybackAmount*priceFor(1)*(10^6);  % millions of shars into units of dollars
    elseif buybackCode==3
        buybackAmount= buybackAmount*sharesFor(1)*priceFor(1);        % perent of shares to dollars
    else
        buybackAmount=buybackAmount*(10^6); % if no units just assume in millions of dollars because that is most common - i would have revisted this but code execution takes 7-8 hours 
    end
    
    % calc percent completed after 90 days by converting change in shares
    % to dolalrs 
    
    sharePer90= -1*(((sharesFor-sharesFor(1))*priceFor(1)) /buybackAmount)*100  ;
    sharePer90= sharePer90(end); % percent complete after 90 days
    
    indDummies=[Agri, Industrial, Manu, Util, Retail, Finance,Service, PublicAdmin];
       else % if prices are zeros 
           %fun discovery i made- if you querry sql and the first row of a
           %column has a zero in it, it will change the entire column to
           %zeros - Fun!!
           eventData= [NaN NaN NaN];  sharePer90=NaN; sector=NaN; buybackAmount=NaN; indDummies(1,1:8)=NaN;
       end
    end

else %if it doesn't find the data
    eventData= [NaN NaN NaN];  sharePer90=NaN; sector=NaN; buybackAmount=NaN; indDummies(1,1:8)=NaN;
end



end

