%%Use datafeed to get data from yahoo



%%housekeeping
clear all
close all
clc
%%
c=yahoo;

%%
sym='AAPL';
d=fetch(c,sym);
d %display output

symbols= {'AAPL','GOOG','YHOO'};
d= fetch(c, symbols);
d

%% Retrieve historical data
fromdate= '01/01/2012';
todate='06/30/2012';
field='Close';

d=fetch(c,sym,field,fromdate,todate);
d(1:5,:) %display first five rows

d=struct;
for j=1:length(symbols)
        symbol=symbols(j);
        ticker=char(symbol) %displays the ticker for each stock in loop
        d.(char(symbol))=fetch(c,symbol,field,fromdate,todate);
        d.(char(symbol))(1:3,:)
end

close(c)











