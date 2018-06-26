% Create SQL database with monthly stock prices from CRSP.
% The students will have to extract the data from here in order to do HW2.

clear all; close all; clc

%% Input monthly price and market cap data from WRDS - CRSP


[M1, text1] = xlsread('0607.xlsx');
[M2, text2] = xlsread('0708.xlsx');
[M3, text3] = xlsread('0809.xlsx');
[M4, text4] = xlsread('0910.xlsx');
[M5, text5] = xlsread('1011.xlsx');
[M6, text6] = xlsread('1112.xlsx'); % excel doesnt let you have enough rows for this data to be read in from one file :(
[M7, text7] = xlsread('1213.xlsx');
[M8, text8] = xlsread('1314.xlsx');
[M9, text9] = xlsread('1415.xlsx');
[M10, text10] = xlsread('1516.xlsx');
[M11, text11] = xlsread('1617.xlsx');


headers = text1(1,:);

%combine them all
M=[M1;M2;M3;M4;M5;M6;M7;M8;M9;M10;M11];
text=[text1;text2(2:end,:);text3(2:end,:);text4(2:end,:);text5(2:end,:);text6(2:end,:);text7(2:end,:);text8(2:end,:);text9(2:end,:);text10(2:end,:);text11(2:end,:)];

tickers= text(2:end,4);
M=[M(:,1:6) M(:,7)*100]; 
M=num2cell(M);
M(:,4)=tickers;


%% Take to SQL

% Create a blank database 
% Create a SQLite connection conn to a new SQLite database file tutorial.db. Specify the file name in the current working folder.
dbfile = fullfile(pwd,'myData.db');
conn = sqlite(dbfile,'create');

% Create some empty tables, in which we will place data later
 createTable = ['create table CRSPTable ' ...
     '(PERMNO NUMERIC, Date NUMERIC, Sector NUMERIC, Ticker varchar(10), ' ...
     'Price NUMERIC, Shares NUMERIC, Market NUMERIC)'];
 exec(conn,createTable)
 
colnames={'PERMNO','Date','Sector', 'Ticker','Price', 'Shares', 'Market'};
data_table=cell2table(M,'VariableNames',colnames);
data_table=rmmissing(data_table);

% Insert the CRSP data into the "conn" database object, in table CRSPTable
insert(conn,'CRSPTable',colnames,data_table);
    
%Close the connection to the database
close(conn)
clear conn

% I like an output to be made when things are done

'done'  

