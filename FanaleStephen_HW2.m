%% Homework 2 - Janurary Effect paper. 
% this code makes a bunch of tables and outputs them onto a powerpoint
% because that was the instrumentation I already had in place. The pdf will
% be a cleaned version of these tables. 

% sorry i am less organized on this one


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
B=1220;
B1=1231;
A1=[num2str(d),num2str(B)];
A2=[num2str(d+1),num2str(B1)];
A3=[num2str(d),num2str(B1)];
querry1=['SELECT * FROM CRSPTable WHERE Date > ' A1 ' and Date <=' A3];
out1 = fetch(conn,querry1);
querry2=['SELECT * FROM CRSPTable WHERE Date >' A1 ' and  Date<=' A2];
out2 = fetch(conn,querry2);

temp= cellfun(@(x) double(x),out1,'un',0); % turn the cells into doubles so i can use them
out2= cell2mat(cellfun(@(x) double(x),out2,'un',0)); % turn the cells into doubles so i can use them

value= cell2mat(temp);
value=abs( value(:,3).*value(:,4));
cap=abs(out2(:,3));

if (d==1981||d==1985)
    value=1+value; cap=1+cap; % to handle the sheer number of zeros that year
end

permno= cell2mat(temp(:,1)); dateO=cell2mat(temp(:,2));
OrderUniv=table(permno,dateO,value);
OrderUniv=rmmissing(OrderUniv);
[Dec1, Dec10, Dec2, Dec3, Dec4, Dec5, Dec6, Dec7, Dec8, Dec9]= intoDecs(OrderUniv);  %get tables with permnos of each dec

Jan = [1,0,0,0,0,0,0,0,0,0,0,0];
d=d-startyear;
permno = out2(:,1); date = out2(:,2); 
Univ1= table(permno,date,cap);
Univ1=rmmissing(Univ1);

    Dec1= innerjoin(Univ1,Dec1);
        A= unstack(Dec1, 'cap', 'date') ; 
         A = rmmissing(A);
        Sums=sum(A{:,2:end});
        
        Returns= price2ret(Sums);
        [lamdahat, tstat, S2, ~,~,R2] = ols(Returns', Jan' ,1);
       aJ(d,:,1)=lamdahat; tstats1(d,:,1)=tstat;  S2s1(d,:,1)=[S2 S2]; R2s1(d,:,1)=R2;
      % allReturns(d,:,1)=Returns;
Dec2= innerjoin(Univ1,Dec2);
        
        A= unstack(Dec2, 'cap', 'date');
        A = rmmissing(A);
        Sums=sum(A{:,2:end}); 
        Returns= price2ret(Sums);
        
        [lamdahat, tstat, S2, ~,~,R2] = ols(Returns', Jan' ,1);
       aJ(d,:,2)=lamdahat; tstats1(d,:,2)=tstat;  S2s1(d,:,2)=[S2 S2]; R2s1(d,:,2)=R2;
      % allReturns(d,:,2)=Returns;
 Dec3= innerjoin(Univ1,Dec3);
        A= unstack(Dec3, 'cap', 'date'); 
         A = rmmissing(A);
        Sums=sum(A{:,2:end}); 
        Returns= price2ret(Sums);
        [lamdahat, tstat, S2, ~,~,R2] = ols(Returns', Jan' ,1);
       aJ(d,:,3)=lamdahat; tstats1(d,:,3)=tstat;  S2s1(d,:,3)=[S2 S2]; R2s1(d,:,3)=R2;
     %  allReturns(d,:,3)=Returns;
Dec4= innerjoin(Univ1,Dec4);
        A= unstack(Dec4, 'cap', 'date');  %this reorders to break up by permno in the third dimension
         A = rmmissing(A);
        Sums=sum(A{:,2:end}); 
        Returns= price2ret(Sums);
        [lamdahat, tstat, S2, ~,~,R2] = ols(Returns', Jan' ,1);
       aJ(d,:,4)=lamdahat; tstats1(d,:,4)=tstat;  S2s1(d,:,4)=[S2 S2]; R2s1(d,:,4)=R2;
     %  allReturns(d,:,4)=Returns;
Dec5= innerjoin(Univ1,Dec5);
        A= unstack(Dec5, 'cap', 'date');  %this reorders to break up by permno in the third dimension
         A = rmmissing(A);
        Sums=sum(A{:,2:end}); 
        Returns= price2ret(Sums);
        [lamdahat, tstat, S2, ~,~,R2] = ols(Returns', Jan' ,1);
      aJ(d,:,5)=lamdahat; tstats1(d,:,5)=tstat;  S2s1(d,:,5)=[S2 S2]; R2s1(d,:,5)=R2;
     %  allReturns(d,:,5)=Returns;
Dec6= innerjoin(Univ1,Dec6);
        A= unstack(Dec6, 'cap', 'date');  %this reorders to break up by permno in the third dimension
         A = rmmissing(A);
        Sums=sum(A{:,2:end}); 
        Returns= price2ret(Sums);
        [lamdahat, tstat, S2, ~,~,R2] = ols(Returns', Jan' ,1);
      aJ(d,:,6)=lamdahat; tstats1(d,:,6)=tstat;  S2s1(d,:,6)=[S2 S2]; R2s1(d,:,6)=R2;
     %  allReturns(d,:,6)=Returns;
Dec7= innerjoin(Univ1,Dec7);
        A= unstack(Dec7, 'cap', 'date');  %this reorders to break up by permno in the third dimension
         A = rmmissing(A);
        Sums=sum(A{:,2:end}); 
        Returns= price2ret(Sums);
        [lamdahat, tstat, S2, ~,~,R2] = ols(Returns', Jan' ,1);
      aJ(d,:,7)=lamdahat; tstats1(d,:,7)=tstat;  S2s1(d,:,7)=[S2 S2]; R2s1(d,:,7)=R2;
     % allReturns(d,:,7)=Returns;
Dec8= innerjoin(Univ1,Dec8);
        A= unstack(Dec8, 'cap', 'date');  %this reorders to break up by permno in the third dimension
         A = rmmissing(A);
        Sums=sum(A{:,2:end}); 
        Returns= price2ret(Sums);
        [lamdahat, tstat, S2, ~,~,R2] = ols(Returns', Jan' ,1);
      aJ(d,:,8)=lamdahat; tstats1(d,:,8)=tstat;  S2s1(d,:,8)=[S2 S2]; R2s1(d,:,8)=R2;
     % allReturns(d,:,8)=Returns; 
Dec9= innerjoin(Univ1,Dec9); 
        A= unstack(Dec9, 'cap', 'date');  %this reorders to break up by permno in the third dimension
         A = rmmissing(A);
        Sums=sum(A{:,2:end}); 
        Returns= price2ret(Sums);
        [lamdahat, tstat, S2, ~,~,R2] = ols(Returns', Jan' ,1);
      aJ(d,:,9)=lamdahat; tstats1(d,:,9)=tstat;  S2s1(d,:,9)=[S2 S2]; R2s1(d,:,9)=R2;
      % allReturns(d,:,9)=Returns;
Dec10= innerjoin(Univ1,Dec10);
        A= unstack(Dec10, 'cap', 'date');  %this reorders to break up by permno in the third dimension
         A = rmmissing(A);
        Sums=sum(A{:,2:end}); 
        Returns= price2ret(Sums);
        [lamdahat, tstat, S2, ~,~,R2] = ols(Returns', Jan' ,1);
       aJ(d,:,10)=lamdahat; tstats1(d,:,10)=tstat;  S2s1(d,:,10)=[S2 S2]; R2s1(d,:,10)=R2;
%Ew 
        A= unstack(Univ1, 'cap', 'date');  %this reorders to break up by permno in the third dimension
         A = rmmissing(A);
        Sums=sum(A{:,2:end}); 
        Returns= price2ret(Sums);
        [lamdahat, tstat, S2, ~,~,R2] = ols(Returns', Jan' ,1);
       aJ(d,:,11)=lamdahat; tstats1(d,:,11)=tstat;  S2s1(d,:,11)=[S2 S2]; R2s1(d,:,11)=R2;




clear temp out1 out2 Dec1 Dec2 Dec3 Dec4 Dec5 Dec6 Dec7 Dec8 Dec9 Dec10 Sums A Univ1

end

%aJ(isnan(aJ))=0;
Aj= mean(aJ,1);
S2s=mean(S2s1,1);
R2s=mean(R2s1,1);
%average aJ into 6, 5 year blocks


y1 = [mean(aJ(1:5,2,1)) mean(aJ(5:10,2,1)) mean(aJ(11:15,2,1)) mean(aJ(16:20,2,1)) mean(aJ(21:25,2,1)) mean(aJ(26:30,2,1))] ; %make a grouped bar graph
y2 = [mean(aJ(1:5,2,2)) mean(aJ(5:10,2,2)) mean(aJ(11:15,2,2)) mean(aJ(16:20,2,2)) mean(aJ(21:25,2,2)) mean(aJ(26:30,2,2))];
y3 = [mean(aJ(1:5,2,3)) mean(aJ(5:10,2,3)) mean(aJ(11:15,2,3)) mean(aJ(16:20,2,3)) mean(aJ(21:25,2,3)) mean(aJ(26:30,2,3))];
y4 = [mean(aJ(1:5,2,4)) mean(aJ(5:10,2,4)) mean(aJ(11:15,2,4)) mean(aJ(16:20,2,4)) mean(aJ(21:25,2,4)) mean(aJ(26:30,2,4))];
y5 = [mean(aJ(1:5,2,5)) mean(aJ(5:10,2,5)) mean(aJ(11:15,2,5)) mean(aJ(16:20,2,5)) mean(aJ(21:25,2,5)) mean(aJ(26:30,2,5))];
y6 = [mean(aJ(1:5,2,6)) mean(aJ(5:10,2,6)) mean(aJ(11:15,2,6)) mean(aJ(16:20,2,6)) mean(aJ(21:25,2,6)) mean(aJ(26:30,2,6))];
y7 = [mean(aJ(1:5,2,7)) mean(aJ(5:10,2,7)) mean(aJ(11:15,2,7)) mean(aJ(16:20,2,7)) mean(aJ(21:25,2,7)) mean(aJ(26:30,2,7))];
y8 = [mean(aJ(1:5,2,8)) mean(aJ(5:10,2,8)) mean(aJ(11:15,2,8)) mean(aJ(16:20,2,8)) mean(aJ(21:25,2,8)) mean(aJ(26:30,2,8))];
y9 = [mean(aJ(1:5,2,9)) mean(aJ(5:10,2,9)) mean(aJ(11:15,2,9)) mean(aJ(16:20,2,9)) mean(aJ(21:25,2,9)) mean(aJ(26:30,2,9))];
y10 = [mean(aJ(1:5,2,10)) mean(aJ(5:10,2,10)) mean(aJ(11:15,2,10)) mean(aJ(16:20,2,10)) mean(aJ(21:25,2,10)) mean(aJ(26:30,2,10))];
 y= [y1;y2;y3;y4;y5;y6;y7;y8;y9;y10];

bar(y)
legend('1964-68','1969-73','1974-78','1979-83','1984-88','1989-93');
title('Excess Janurary Returns');
xlabel('Decile');
ylabel('Excess Return');


 temp = zeros(22,4);


temp(1,3:4)=Aj(:,:,1);  temp(2,3:4)=S2s(:,:,1);  temp(1,2)=R2s(:,:,1);
temp(3,3:4)=Aj(:,:,2); temp(4,3:4)=S2s(:,:,2);   temp(3,2)=R2s(:,:,2);
temp(5,3:4)=Aj(:,:,3);temp(6,3:4)=S2s(:,:,3);   temp(5,2)=R2s(:,:,3);
temp(7,3:4)=Aj(:,:,4);temp(8,3:4)=S2s(:,:,4);    temp(7,2)=R2s(:,:,4);
temp(9,3:4)=Aj(:,:,5);  temp(10,3:4)=S2s(:,:,5);   temp(9,2)=R2s(:,:,5);
temp(11,3:4)=Aj(:,:,6); temp(12,3:4)=S2s(:,:,6);  temp(11,2)=R2s(:,:,6);
temp(13,3:4)=Aj(:,:,7); temp(14,3:4)=S2s(:,:,7);   temp(13,2)=R2s(:,:,7);
temp(15,3:4)=Aj(:,:,8); temp(16,3:4)=S2s(:,:,8);    temp(15,2)=R2s(:,:,8);
temp(17,3:4)=Aj(:,:,9); temp(18,3:4)=S2s(:,:,9);   temp(17,2)=R2s(:,:,9);
temp(19,3:4)=Aj(:,:,10);  temp(20,3:4)=S2s(:,:,10);   temp(19,2)=R2s(:,:,10);
temp(21,3:4)=Aj(:,:,11);    temp(22,3:4)=S2s(:,:,11);   temp(21,2)=R2s(:,:,11);

%temp=arrayfun(@(x) sprintf('%10.4',x),temp,'un',0);
temp = num2cell(temp);
headers2={ 'Size Decile' ; 'R2';'a0; s(a0)';'a1; s(a1)';}';

data1 = [headers2 ;temp(1,:) ; {'1',''},temp(2,3:end); temp(3,:);  {'2',''},temp(4,3:end); temp(5,:); {'3',''},temp(6,3:end); temp(7,:); {'4',''},temp(8,3:end); temp(9,:); {'5',''},temp(10,3:end); temp(11,:); {'6',''},temp(12,3:end); temp(13,:);  {'7',''},temp(14,3:end); temp(15,:); {'8',''},temp(16,3:end); temp(17,:); {'9',''},temp(18,3:end); temp(19,:); {'10',''},temp(20,3:end); temp(21,:); {'Ew',''},temp(22,3:end);];
data = [data1];
myTable1 = Table(data);



%% Build Presentation
PresName = 'FanaleStephen_Homework2.pptx'; % name of ppt file
slides = Presentation(PresName); % create ppt presentation
student_name=strcat('Stephen Fanale');
replace(slides,'Footer',student_name); % Not working

%% Title Slide
slide0 = add(slides,'Title Slide'); % 'Title Slide' tells the type of slide

contents = find(slides,'Title'); % find Title object and assign to placeholder variable
replace(contents(1),'590 Homework 2'); % replace contents with text
contents(1).FontColor = 'red';
replace(slide0,'Subtitle',student_name);

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Table 1-Jan effect regression');
replace(tableSlide,'Table',myTable1); 

%% Generate and open the presentation
close(slides);

if ispc % if this machine is Windows
    winopen(PresName);
end
