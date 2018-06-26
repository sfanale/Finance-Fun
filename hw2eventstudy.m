%% Homework 2 - Janurary Effect paper. - event study 
% this code makes a bunch of tables and outputs them onto a powerpoint
% because that was the instrumentation I already had in place. The pdf will
% be a cleaned version of these tables. 


%% Housekeeping
    clear all; close all; clc; 
    import mlreportgen.ppt.* % import Matlab package to create ppt presentation

     addpath(genpath('C:\Users\Stephen\Documents\MATLAB\MFE\'));

     [factors,textdata]=xlsread('F-F_Research_Data_5_Factors_2x3.csv'); 
startyear=1963;     
     RmRf = factors(8:379,2);
%% Data
%Load in data
% For each year, get all the data then organize it into decile by
% multiplying price by shares

conn = sqlite('CRSPdata.db','readonly');
for d=1:30
d=d+startyear;  %need to find what the first year is
d
B='0131';
B1='0131';
A1=[num2str(d),B];
A2=[num2str(d+1),B1];

querry2=['SELECT * FROM CRSPTable WHERE Date >' A1 ' and  Date<=' A2];
out2 = fetch(conn,querry2);

out2= cell2mat(cellfun(@(x) double(x),out2,'un',0)); % turn the cells into doubles so i can use them

cap=abs(out2(:,3));

if (d==1981||d==1985)
     cap=1+cap; % to handle the sheer number of zeros that year
end

permno = out2(:,1); date = out2(:,2); 
Univ1= table(permno,date,cap);
Univ1=rmmissing(Univ1);

A= unstack(Univ1, 'cap', 'date') ; 
A=rmmissing(A);
A= varfun(@(x) x+1,A); % to solve zero issues
Returns= price2ret(A{:,2:end});
d=d-startyear;
rmrf= RmRf(1+(d-1)*12:d*12);

for i=1:length(Returns)
 [lamdahat, tstat, S2, ~,~,R2] = ols(Returns(i,1:11)', rmrf(1:11) ,0);
       aJ(i,:,d)=lamdahat; janEffect(i,d)=Returns(i,12)-rmrf(12)*lamdahat;    
end




clear temp out1 out2 Sums A Univ1

end

janEffectAve= mean(mean(janEffect))
