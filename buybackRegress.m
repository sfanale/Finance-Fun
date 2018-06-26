function [sharePer90, sector, buybackAmount, indDummies] = buybackRegress ( tickers,tableData)

%% regression on buyback code for buyback project - Stephen Fanale - May 2017
% This will be turned into a function to be called from a shell program. 
% It will perform the regression and return the results. I will start with
% just the number of shares as the variable and modify it to add the
% percentage complete


% Inputs:
% -permno 
% -file with price data - will be db file
% -buyback info

%db file is permno, date, div,  price, outstanding shares, market rets
ticker=tickers;
date1=tableData(1);

buybackAmount=tableData(2);
buybackCode=tableData(3);

Agri=0; Industrial=0; Manu=0; Util=0;
Retail=0; Finance=0; Service=0;
PublicAdmin=0;

%% Load in Data

conn = sqlite('myData.db','readonly'); 

A1=date1;
A2=A1+90;
A1=num2str(A1);    % wait until turned into function
A2=num2str(A2);

tickerSQL= char(ticker);

querry=['SELECT * FROM CRSPTable WHERE Date >' A1 ' and  Date<=' A2 ' and Ticker="' tickerSQL '"'];
out2 = fetch(conn,querry);
close(conn)
clear conn

if isempty(out2)==0 

price=abs(double(cell2mat(out2(:,5))));
shares=double(cell2mat(out2(2:end,6)));
   
sector=floor(double(cell2mat(out2(1,3)))/100);  %this gets just the first two digits I hope
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
   

if buybackCode==1
    buybackAmount=buybackAmount*(10^6);   % in units of dollars
elseif buybackCode==2
    buybackAmount= buybackAmount*price(1)*(10^6);  % millions of shars into units of dollars
elseif buybackCode==3
    buybackAmount= buybackAmount*shares(1)*price(1);        % perent of shares to dollars
else 
    buybackAmount=buybackAmount*(10^6); % if no units just assume in millions of dollars because that is most common
end

sharePer90= -1*(((shares-shares(1))*price(1)) /buybackAmount)*100  ;
sharePer90= sharePer90(end); % percent complete after 90 days
else
    sharePer90=NaN; sector=NaN; buybackAmount=NaN;
end

indDummies=[Agri, Industrial, Manu, Util, Retail, Finance,Service, PublicAdmin];

end
