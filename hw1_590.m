%% Homework 1 - Fama French paper. 
% this code makes a bunch of tables and outputs them onto a powerpoint
% because that was the instrumentation I already had in place. The pdf will
% be a cleaned version of these tables. 


%% Housekeeping
    clear all; close all; clc; 
    import mlreportgen.ppt.* % import Matlab package to create ppt presentation

     addpath(genpath('C:\Users\Stephen\Documents\MATLAB\MFE\'));
%% Data
%Load in data
[factors,textdata]=xlsread('F-F_Research_Data_5_Factors_2x3.csv'); 
[sizeACports,textdata]=xlsread('25_Portfolios_ME_AC_5x5.csv'); 
[sizeBETAports,textdata]=xlsread('25_Portfolios_ME_BETA_5x5.csv');
[sizeNIports,textdata]=xlsread('25_Portfolios_ME_NI_5x5.csv');
[sizeVARports,textdata]=xlsread('25_Portfolios_ME_VAR_5x5.csv');
[sizeRESVARports,textdata]=xlsread('25_Portfolios_ME_RESVAR_5x5.csv');

RmRf = factors(1:618,2); SMB = factors(1:618,3); HML = factors(1:618,4); RMW = factors(1:618,5); CMA = factors(1:618,6); RF=factors(1:618,7);MOM=factors(1:618,8);
%skipping sizeNI for now because it isnt the right size - turns out i dont
%need size NI but i did the rest of these already so im leaving them
combinedport=cat(3,sizeBETAports(1:618,2:26)-RF,sizeVARports(1:618,2:26)-RF, sizeRESVARports(1:618,2:26)-RF,sizeACports(1:618,2:26)-RF);
%make a big combined portfolio and cut out dates
%% Table 1
for i=2:8
means(1,i-1)=mean(factors(1:618,i),1) ;
stds(1,i-1)= std(factors(1:618,i),1);
tstats(:,i-1)=means(1,i-1)/ (stds(1,i-1)/sqrt(618));
end 

temp = zeros(3,6);

temp(1,1:5) = means(1,1:5);
temp(2,1:5) = stds(1,1:5);
temp(3,1:5) = tstats(1,1:5);

temp(1,6) = means(1,7);
temp(2,6) = stds(1,7);
temp(3,6) = tstats(1,7);
temp=arrayfun(@(x) sprintf('%10.2f',x),temp,'un',0);

headers2={ 'Rm-Rf' ; 'SMB';'HML';'RMW';'CMA';'MOM';}';
rownames = {'';'Mean';'SD';'t-statistic';};
data1 = [headers2;temp(1:3,:)];
data = [rownames, data1];
myTable1 = Table(data);


%% Table 2 - see if intercept is zero - p(grs)-average absolute intercept-
port = combinedport;
intercept= ones(618,1);
for j=1:4
for i=1:25
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(1:618,i,j),[RmRf],1);
    coeffs1(i,:,j)=lamdahat;    tstats1(i,:,j)=tstat; res1(i,:,j)= port(1:618,i,j)-([intercept RmRf]*lamdahat);  S2s1(i,:,j)=S2; R2s1(i,:,j)=R2;
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(1:618,i,j),[RmRf, SMB,HML],1);
    coeffs2(i,:,j)=lamdahat;    tstats2(i,:,j)=tstat; res2(i,:,j)= port(1:618,i,j)-([intercept RmRf SMB HML]*lamdahat); S2s2(i,:,j)=S2;R2s2(i,:,j)=R2;
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(1:618,i,j),[RmRf, SMB,HML, RMW],1);
    coeffs3(i,:,j)=lamdahat;    tstats3(i,:,j)=tstat; res3(i,:,j)= port(1:618,i,j)-([intercept RmRf SMB HML RMW]*lamdahat); S2s3(i,:,j)=S2;R2s3(i,:,j)=R2;
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(1:618,i,j),[RmRf, SMB,HML, CMA],1);
    coeffs4(i,:,j)=lamdahat;    tstats4(i,:,j)=tstat; res4(i,:,j)= port(1:618,i,j)-([intercept RmRf SMB HML CMA]*lamdahat); S2s4(i,:,j)=S2;R2s4(i,:,j)=R2;
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(1:618,i,j),[RmRf, SMB,RMW, CMA],1);
    coeffs5(i,:,j)=lamdahat;    tstats5(i,:,j)=tstat; res5(i,:,j)= port(1:618,i,j)-([intercept RmRf SMB RMW CMA]*lamdahat); S2s5(i,:,j)=S2;R2s5(i,:,j)=R2;
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(1:618,i,j),[RmRf, SMB,HML,RMW,CMA],1);
    coeffs6(i,:,j)=lamdahat;    tstats6(i,:,j)=tstat; res6(i,:,j)= port(1:618,i,j)-([intercept RmRf SMB HML RMW CMA]*lamdahat); S2s6(i,:,j)=S2;R2s6(i,:,j)=R2;
end
end

plot(RmRf,port(1:618,1,1),'r.',RmRf, [intercept RmRf]*coeffs1(1,:,1)', 'b-.')
coeffs=cat(4,coeffs1(:,1,:),coeffs2(:,1,:),coeffs3(:,1,:),coeffs4(:,1,:),coeffs5(:,1,:),coeffs6(:,1,:));
S2s= cat(4, S2s1, S2s2,S2s3,S2s4,S2s5,S2s6);
R2s= cat(4, R2s1, R2s2,R2s3,R2s4,R2s5,R2s6);

for j=1:4
   [grs, p]= fGRS(coeffs1(:,1,j),res1(:,:,j)' ,RmRf ); 
   fgrs(1+6*(j-1))=grs; pGrs(1+6*(j-1),:)=p; 
   [grs, p]= fGRS(coeffs2(:,1,j),res2(:,:,j)' ,[RmRf SMB HML] ); 
   fgrs(2+6*(j-1))=grs; pGrs(2+6*(j-1),:)=p; 
   [grs, p]= fGRS(coeffs3(:,1,j),res3(:,:,j)' ,[ RmRf SMB HML RMW] ); 
   fgrs(3+6*(j-1))=grs; pGrs(3+6*(j-1),:)=p; 
   [grs, p]= fGRS(coeffs4(:,1,j),res4(:,:,j)' ,[ RmRf SMB HML CMA] ); 
   fgrs(4+6*(j-1))=grs; pGrs(4+6*(j-1),:)=p; 
   [grs, p]= fGRS(coeffs5(:,1,j),res5(:,:,j)' ,[ RmRf SMB RMW CMA] ); 
   fgrs(5+6*(j-1))=grs; pGrs(5+6*(j-1),:)=p; 
   [grs, p]= fGRS(coeffs6(:,1,j),res6(:,:,j)' ,[ RmRf SMB HML RMW CMA] );
   fgrs(6+6*(j-1))=grs; pGrs(6+6*(j-1),:)=p; 
    
end


%% actually make table 2
temp = zeros(24,7);

temp(1:24,1) = fgrs';
temp(1:24,2) = pGrs;

for j=1:4
for n=1:6
    temp(n+6*(j-1),3)=mean(abs(coeffs(:,1,j,n)),1);
    temp(n+6*(j-1),4)=mean(abs(coeffs(:,1,j,n)),1)/ mean(abs( mean(port(1:618,:,j),1)-mean(RmRf) )) ;
    temp(n+6*(j-1),5)=mean((coeffs(:,1,j,n)).^2)/ mean(( mean(port(1:618,:,j),1)-mean(RmRf) ).^2) ;
    temp(n+6*(j-1),6)=mean(S2s(:,:,j,n),1) / mean((coeffs(:,1,j,n)).^2) ;
    temp(n+6*(j-1),7)=mean(R2s(:,:,j,n),1);
end
end

%temp=arrayfun(@(x) sprintf('%10.2',x),temp,'un',0);
temp = num2cell(temp);
%headers1 = {'25 Size-B regressions'; 'CAPM';}';
headers2={ 'GRS' ; 'p(GRS)';'A|ai|';'A|ai|/A|ri|';'Aa2/Ar2'; 'As2(ai)/Aai2' ; 'A(R2)';}';
headers3 = {'';'';'';'';'';'';''}';

rownames = {'';'25 Size B';'mkt';'mkt SMB HML';'mkt SMB HML RMW';'mkt SMB HML CMA';'mkt SMB RMW CMA';'mkt SMB HML RMW CMA';'25 Size var';'mkt';'mkt SMB HML';'mkt SMB HML RMW';'mkt SMB HML CMA';'mkt SMB RMW CMA';'mkt SMB HML RMW CMA';'25 Size R var';'mkt';'mkt SMB HML';'mkt SMB HML RMW';'mkt SMB HML CMA';'mkt SMB RMW CMA';'mkt SMB HML RMW CMA';'25 Size AC';'mkt';'mkt SMB HML';'mkt SMB HML RMW';'mkt SMB HML CMA';'mkt SMB RMW CMA';'mkt SMB HML RMW CMA';};
data1 = [headers2 ;headers3 ;temp(1:6,:);headers3 ;temp(7:12,:);headers3 ;temp(13:18,:);headers3 ;temp(19:24,:)];
data = [rownames, data1];
myTable2 = Table(data);



%% Table 3 - 25 size B portfolio stats 



sizeBetaport=sizeBETAports(1:618,2:26)-RF;
aves= mean(sizeBetaport,1);
sds= std(sizeBetaport,0,1);
temp = zeros(5,10);

temp(1,1:5) = aves(1,1:5);
temp(2,1:5) = aves(1,6:10);
temp(3,1:5) = aves(1,11:15);
temp(4,1:5) = aves(1,16:20);
temp(5,1:5) = aves(1,21:25);
temp(1,6:10) = sds(1,1:5);
temp(2,6:10) = sds(1,6:10);
temp(3,6:10) = sds(1,11:15);
temp(4,6:10) = sds(1,16:20);
temp(5,6:10) = sds(1,21:25);
temp=arrayfun(@(x) sprintf('%10.2f',x),temp,'un',0);

%headers1 = {'25 Size-B regressions'; 'CAPM';}';
headers2={ 'Low B' ; '2';'3';'4';'High B'; 'Low B' ; '2';'3';'4';'High B';}';
headers3 = {'';'';'Mean';'';'';'';'';'SD';'';'';}';
rownames = {'';'';'Small';'2';'3';'4';'Big';};
data1 = [headers2 ;headers3 ;temp(1:5,:)];
data = [rownames, data1];
myTable3 = Table(data);



%% Table 4 - 25 size B portfolio regression stats -- market then all five

temp = zeros(10,10);

temp(6,1:5) = coeffs1(1:5,2,1)';
temp(7,1:5) = coeffs1(6:10,2,1)';
temp(8,1:5) = coeffs1(11:15,2,1)';
temp(9,1:5) = coeffs1(16:20,2,1)';
temp(10,1:5) = coeffs1(21:25,2,1)';
temp(6,6:10) = tstats1(1:5,2,1)';
temp(7,6:10) = tstats1(6:10,2,1)';
temp(8,6:10) = tstats1(11:15,2,1)';
temp(9,6:10) = tstats1(16:20,2,1)';
temp(10,6:10) = tstats1(21:25,2,1)';

temp(1,1:5) = coeffs1(1:5,1,1);
temp(2,1:5) = coeffs1(6:10,1,1);
temp(3,1:5) = coeffs1(11:15,1,1);
temp(4,1:5) = coeffs1(16:20,1,1);
temp(5,1:5) = coeffs1(21:25,1,1);
temp(1,6:10) = tstats1(1:5,1,1);
temp(2,6:10) = tstats1(6:10,1,1);
temp(3,6:10) = tstats1(11:15,1,1);
temp(4,6:10) = tstats1(16:20,1,1);
temp(5,6:10) = tstats1(21:25,1,1);
temp=arrayfun(@(x) sprintf('%10.2f',x),temp,'un',0);

%headers1 = {'25 Size-B regressions'; 'CAPM';}';
headers2={ 'Low B' ; '2';'3';'4';'High B'; 'Low B' ; '2';'3';'4';'High B';}';
headers3 = {'';'';'a';'';'';'';'';'t(a)';'';'';}';
headers4 = {'';'';'b';'';'';'';'';'t(b)';'';'';}';
rownames = {'';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';};
data1 = [headers2 ;headers3 ;temp(1:5,:);headers4;temp(6:10,:)];
data = [rownames, data1];
myTable4 = Table(data);


temp = zeros(30,10);

temp(1,1:5) = coeffs6(1:5,1,1);
temp(2,1:5) = coeffs6(6:10,1,1);
temp(3,1:5) = coeffs6(11:15,1,1);
temp(4,1:5) = coeffs6(16:20,1,1);
temp(5,1:5) = coeffs6(21:25,1,1);
temp(1,6:10) = tstats6(1:5,1,1);
temp(2,6:10) = tstats6(6:10,1,1);
temp(3,6:10) = tstats6(11:15,1,1);
temp(4,6:10) = tstats6(16:20,1,1);
temp(5,6:10) = tstats6(21:25,1,1);

temp(6,1:5) = coeffs6(1:5,2,1)';
temp(7,1:5) = coeffs6(6:10,2,1)';
temp(8,1:5) = coeffs6(11:15,2,1)';
temp(9,1:5) = coeffs6(16:20,2,1)';
temp(10,1:5) = coeffs6(21:25,2,1)';
temp(6,6:10) = tstats6(1:5,2,1)';
temp(7,6:10) = tstats6(6:10,2,1)';
temp(8,6:10) = tstats6(11:15,2,1)';
temp(9,6:10) = tstats6(16:20,2,1)';
temp(10,6:10) = tstats6(21:25,2,1)';

temp(11,1:5) = coeffs6(1:5,3,1);
temp(12,1:5) = coeffs6(6:10,3,1);
temp(13,1:5) = coeffs6(11:15,3,1);
temp(14,1:5) = coeffs6(16:20,3,1);
temp(15,1:5) = coeffs6(21:25,3,1);
temp(11,6:10) = tstats6(1:5,3,1);
temp(12,6:10) = tstats6(6:10,3,1);
temp(13,6:10) = tstats6(11:15,3,1);
temp(14,6:10) = tstats6(16:20,3,1);
temp(15,6:10) = tstats6(21:25,3,1);

temp(16,1:5) = coeffs6(1:5,4,1)';
temp(17,1:5) = coeffs6(6:10,4,1)';
temp(18,1:5) = coeffs6(11:15,4,1)';
temp(19,1:5) = coeffs6(16:20,4,1)';
temp(20,1:5) = coeffs6(21:25,4,1)';
temp(16,6:10) = tstats6(1:5,4,1)';
temp(17,6:10) = tstats6(6:10,4,1)';
temp(18,6:10) = tstats6(11:15,4,1)';
temp(19,6:10) = tstats6(16:20,4,1)';
temp(20,6:10) = tstats6(21:25,4,1)';

temp(21,1:5) = coeffs6(1:5,5,1);
temp(22,1:5) = coeffs6(6:10,5,1);
temp(23,1:5) = coeffs6(11:15,5,1);
temp(24,1:5) = coeffs6(16:20,5,1);
temp(25,1:5) = coeffs6(21:25,5,1);
temp(21,6:10) = tstats6(1:5,5,1);
temp(22,6:10) = tstats6(6:10,5,1);
temp(23,6:10) = tstats6(11:15,5,1);
temp(24,6:10) = tstats6(16:20,5,1);
temp(25,6:10) = tstats6(21:25,5,1);

temp(26,1:5) = coeffs6(1:5,6,1)';
temp(27,1:5) = coeffs6(6:10,6,1)';
temp(28,1:5) = coeffs6(11:15,6,1)';
temp(29,1:5) = coeffs6(16:20,6,1)';
temp(30,1:5) = coeffs6(21:25,6,1)';
temp(26,6:10) = tstats6(1:5,6,1)';
temp(27,6:10) = tstats6(6:10,6,1)';
temp(28,6:10) = tstats6(11:15,6,1)';
temp(29,6:10) = tstats6(16:20,6,1)';
temp(30,6:10) = tstats6(21:25,6,1)';

temp=arrayfun(@(x) sprintf('%10.2f',x),temp,'un',0);

%headers1 = {'25 Size-B regressions'; 'CAPM';}';
headers2={ 'Low B' ; '2';'3';'4';'High B'; 'Low B' ; '2';'3';'4';'High B';}';
headers3 = {'';'';'a';'';'';'';'';'t(a)';'';'';}';
headers4 = {'';'';'b';'';'';'';'';'t(b)';'';'';}';
headers5 = {'';'';'c';'';'';'';'';'t(c)';'';'';}';
headers6 = {'';'';'d';'';'';'';'';'t(d)';'';'';}';
headers7 = {'';'';'e';'';'';'';'';'t(e)';'';'';}';
headers8 = {'';'';'f';'';'';'';'';'t(f)';'';'';}';
rownames = {'';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';};
data1 = [headers2 ;headers3 ;temp(1:5,:);headers4;temp(6:10,:);headers5;temp(11:15,:);headers6;temp(16:20,:);headers7;temp(21:25,:);headers8;temp(26:30,:)];
data = [rownames, data1];
myTable5 = Table(data);


%% risk premia

      %regress Beta and F 
      for i= 1:25    % portfolios   N
      [betahat, tstatB]=ols(sizeBetaport(:,i),[RmRf, SMB,HML,RMW,CMA],0);   %returns of a portfolio vs factors 
      betahats(:,i)= betahat;   % F x N
      end
      
      
     for i=1:618   % time   T
     [FamaLambda , tstasFL] = ols(sizeBetaport(i,:)', betahats',0);    % return for each portfolio at a time vs FxN size factor coefficients
     FamaLambdas(:,i)= FamaLambda;  % F x T
     end
     LambdaMean14= mean(FamaLambdas,2);
%% now again through 2015
clear coeffs1 coeffs2 coeffs3 coeffs4 coeffs5 coeffs6
clear tstats1 tstats2 tstats3 tstats4 tstats5 tstats6
clear res1 res2 res3 res4 res5 res6
clear S2s1 S2s2 S2s3 S2s4 S2s5 S2s6
clear R2s1 R2s2 R2s3 R2s4 R2s5 R2s6
     
%% Data
%Load in data
[factors,textdata]=xlsread('F-F_Research_Data_5_Factors_2x3.csv'); 
[sizeACports,textdata]=xlsread('25_Portfolios_ME_AC_5x5.csv'); 
[sizeBETAports,textdata]=xlsread('25_Portfolios_ME_BETA_5x5.csv');
[sizeNIports,textdata]=xlsread('25_Portfolios_ME_NI_5x5.csv');
[sizeVARports,textdata]=xlsread('25_Portfolios_ME_VAR_5x5.csv');
[sizeRESVARports,textdata]=xlsread('25_Portfolios_ME_RESVAR_5x5.csv');

RmRf = factors(1:630,2); SMB = factors(1:630,3); HML = factors(1:630,4); RMW = factors(1:630,5); CMA = factors(1:630,6); RF=factors(1:630,7);MOM=factors(1:630,8);
%skipping sizeNI for now because it isnt the right size
combinedport=cat(3,sizeBETAports(1:630,2:26)-RF,sizeVARports(1:630,2:26)-RF, sizeRESVARports(1:630,2:26)-RF,sizeACports(1:630,2:26)-RF);
%make a big combined portfolio and cut out dates
%% Table 1
for i=2:8
means(1,i-1)=mean(factors(1:630,i),1) ;
stds(1,i-1)= std(factors(1:630,i),1);
tstats(:,i-1)=means(1,i-1)/ (stds(1,i-1)/sqrt(630));
end 

temp = zeros(3,6);

temp(1,1:5) = means(1,1:5);
temp(2,1:5) = stds(1,1:5);
temp(3,1:5) = tstats(1,1:5);

temp(1,6) = means(1,7);
temp(2,6) = stds(1,7);
temp(3,6) = tstats(1,7);
temp=arrayfun(@(x) sprintf('%10.2f',x),temp,'un',0);

headers2={ 'Rm-Rf' ; 'SMB';'HML';'RMW';'CMA';'MOM';}';
rownames = {'';'Mean';'SD';'t-statistic';};
data1 = [headers2;temp(1:3,:)];
data = [rownames, data1];
myTable1b = Table(data);


%% Table 2 - see if intercept is zero - p(grs)-average absolute intercept-
port = combinedport;
intercept= ones(630,1);
for j=1:4
for i=1:25
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(:,i,j),[RmRf],1);
    coeffs1(i,:,j)=lamdahat;    tstats1(i,:,j)=tstat; res1(i,:,j)= port(:,i,j)-([intercept RmRf]*lamdahat);  S2s1(i,:,j)=S2; R2s1(i,:,j)=R2;
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(:,i,j),[RmRf, SMB,HML],1);
    coeffs2(i,:,j)=lamdahat;    tstats2(i,:,j)=tstat; res2(i,:,j)= port(:,i,j)-([intercept RmRf SMB HML]*lamdahat); S2s2(i,:,j)=S2;R2s2(i,:,j)=R2;
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(:,i,j),[RmRf, SMB,HML, RMW],1);
    coeffs3(i,:,j)=lamdahat;    tstats3(i,:,j)=tstat; res3(i,:,j)= port(:,i,j)-([intercept RmRf SMB HML RMW]*lamdahat); S2s3(i,:,j)=S2;R2s3(i,:,j)=R2;
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(:,i,j),[RmRf, SMB,HML, CMA],1);
    coeffs4(i,:,j)=lamdahat;    tstats4(i,:,j)=tstat; res4(i,:,j)= port(:,i,j)-([intercept RmRf SMB HML CMA]*lamdahat); S2s4(i,:,j)=S2;R2s4(i,:,j)=R2;
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(:,i,j),[RmRf, SMB,RMW, CMA],1);
    coeffs5(i,:,j)=lamdahat;    tstats5(i,:,j)=tstat; res5(i,:,j)= port(:,i,j)-([intercept RmRf SMB RMW CMA]*lamdahat); S2s5(i,:,j)=S2;R2s5(i,:,j)=R2;
    [lamdahat, tstat, S2, VCV,VCVw,R2] = ols(port(:,i,j),[RmRf, SMB,HML,RMW,CMA],1);
    coeffs6(i,:,j)=lamdahat;    tstats6(i,:,j)=tstat; res6(i,:,j)= port(:,i,j)-([intercept RmRf SMB HML RMW CMA]*lamdahat); S2s6(i,:,j)=S2;R2s6(i,:,j)=R2;
end
end


coeffs=cat(4,coeffs1(:,1,:),coeffs2(:,1,:),coeffs3(:,1,:),coeffs4(:,1,:),coeffs5(:,1,:),coeffs6(:,1,:));
S2s= cat(4, S2s1, S2s2,S2s3,S2s4,S2s5,S2s6);
R2s= cat(4, R2s1, R2s2,R2s3,R2s4,R2s5,R2s6);

for j=1:4
   [grs, p]= fGRS(coeffs1(:,1,j),res1(:,:,j)' ,RmRf ); 
   fgrs(1+6*(j-1))=grs; pGrs(1+6*(j-1),:)=p; 
   [grs, p]= fGRS(coeffs2(:,1,j),res2(:,:,j)' ,[RmRf SMB HML] ); 
   fgrs(2+6*(j-1))=grs; pGrs(2+6*(j-1),:)=p; 
   [grs, p]= fGRS(coeffs3(:,1,j),res3(:,:,j)' ,[ RmRf SMB HML RMW] ); 
   fgrs(3+6*(j-1))=grs; pGrs(3+6*(j-1),:)=p; 
   [grs, p]= fGRS(coeffs4(:,1,j),res4(:,:,j)' ,[ RmRf SMB HML CMA] ); 
   fgrs(4+6*(j-1))=grs; pGrs(4+6*(j-1),:)=p; 
   [grs, p]= fGRS(coeffs5(:,1,j),res5(:,:,j)' ,[ RmRf SMB RMW CMA] ); 
   fgrs(5+6*(j-1))=grs; pGrs(5+6*(j-1),:)=p; 
   [grs, p]= fGRS(coeffs6(:,1,j),res6(:,:,j)' ,[ RmRf SMB HML RMW CMA] );
   fgrs(6+6*(j-1))=grs; pGrs(6+6*(j-1),:)=p; 
    
end


%% actually make table 2
temp = zeros(24,7);

temp(1:24,1) = fgrs';
temp(1:24,2) = pGrs;

for j=1:4
for n=1:6
    temp(n+6*(j-1),3)=mean(abs(coeffs(:,1,j,n)),1);
    temp(n+6*(j-1),4)=mean(abs(coeffs(:,1,j,n)),1)/ mean(abs( mean(port(:,:,j),1)-mean(RmRf) )) ;
    temp(n+6*(j-1),5)=mean((coeffs(:,1,j,n)).^2)/ mean(( mean(port(:,:,j),1)-mean(RmRf) ).^2) ;
    temp(n+6*(j-1),6)=mean(S2s(:,:,j,n),1) / mean((coeffs(:,1,j,n)).^2) ;
    temp(n+6*(j-1),7)=mean(R2s(:,:,j,n),1);
end
end

%temp=arrayfun(@(x) sprintf('%10.2',x),temp,'un',0);
temp = num2cell(temp);
%headers1 = {'25 Size-B regressions'; 'CAPM';}';
headers2={ 'GRS' ; 'p(GRS)';'A|ai|';'A|ai|/A|ri|';'Aa2/Ar2'; 'As2(ai)/Aai2' ; 'A(R2)';}';
headers3 = {'';'';'';'';'';'';''}';

rownames = {'';'25 Size B';'mkt';'mkt SMB HML';'mkt SMB HML RMW';'mkt SMB HML CMA';'mkt SMB RMW CMA';'mkt SMB HML RMW CMA';'25 Size var';'mkt';'mkt SMB HML';'mkt SMB HML RMW';'mkt SMB HML CMA';'mkt SMB RMW CMA';'mkt SMB HML RMW CMA';'25 Size R var';'mkt';'mkt SMB HML';'mkt SMB HML RMW';'mkt SMB HML CMA';'mkt SMB RMW CMA';'mkt SMB HML RMW CMA';'24 Size AC';'mkt';'mkt SMB HML';'mkt SMB HML RMW';'mkt SMB HML CMA';'mkt SMB RMW CMA';'mkt SMB HML RMW CMA';};
data1 = [headers2 ;headers3 ;temp(1:6,:);headers3 ;temp(7:12,:);headers3 ;temp(13:18,:);headers3 ;temp(19:24,:)];
data = [rownames, data1];
myTable2b = Table(data);



%% Table 3 - 25 size B portfolio stats 



sizeBetaport=sizeBETAports(1:630,2:26)-RF;
aves= mean(sizeBetaport,1);
sds= std(sizeBetaport,0,1);
temp = zeros(5,10);

temp(1,1:5) = aves(1,1:5);
temp(2,1:5) = aves(1,6:10);
temp(3,1:5) = aves(1,11:15);
temp(4,1:5) = aves(1,16:20);
temp(5,1:5) = aves(1,21:25);
temp(1,6:10) = sds(1,1:5);
temp(2,6:10) = sds(1,6:10);
temp(3,6:10) = sds(1,11:15);
temp(4,6:10) = sds(1,16:20);
temp(5,6:10) = sds(1,21:25);
temp=arrayfun(@(x) sprintf('%10.2f',x),temp,'un',0);

%headers1 = {'25 Size-B regressions'; 'CAPM';}';
headers2={ 'Low B' ; '2';'3';'4';'High B'; 'Low B' ; '2';'3';'4';'High B';}';
headers3 = {'';'';'Mean';'';'';'';'';'SD';'';'';}';
rownames = {'';'';'Small';'2';'3';'4';'Big';};
data1 = [headers2 ;headers3 ;temp(1:5,:)];
data = [rownames, data1];
myTable3b = Table(data);



%% Table 4 - 25 size B portfolio regression stats -- market then all five

temp = zeros(10,10);

temp(6,1:5) = coeffs1(1:5,2,1)';
temp(7,1:5) = coeffs1(6:10,2,1)';
temp(8,1:5) = coeffs1(11:15,2,1)';
temp(9,1:5) = coeffs1(16:20,2,1)';
temp(10,1:5) = coeffs1(21:25,2,1)';
temp(6,6:10) = tstats1(1:5,2,1)';
temp(7,6:10) = tstats1(6:10,2,1)';
temp(8,6:10) = tstats1(11:15,2,1)';
temp(9,6:10) = tstats1(16:20,2,1)';
temp(10,6:10) = tstats1(21:25,2,1)';

temp(1,1:5) = coeffs1(1:5,1,1);
temp(2,1:5) = coeffs1(6:10,1,1);
temp(3,1:5) = coeffs1(11:15,1,1);
temp(4,1:5) = coeffs1(16:20,1,1);
temp(5,1:5) = coeffs1(21:25,1,1);
temp(1,6:10) = tstats1(1:5,1,1);
temp(2,6:10) = tstats1(6:10,1,1);
temp(3,6:10) = tstats1(11:15,1,1);
temp(4,6:10) = tstats1(16:20,1,1);
temp(5,6:10) = tstats1(21:25,1,1);
temp=arrayfun(@(x) sprintf('%10.2f',x),temp,'un',0);

%headers1 = {'25 Size-B regressions'; 'CAPM';}';
headers2={ 'Low B' ; '2';'3';'4';'High B'; 'Low B' ; '2';'3';'4';'High B';}';
headers3 = {'';'';'a';'';'';'';'';'t(a)';'';'';}';
headers4 = {'';'';'b';'';'';'';'';'t(b)';'';'';}';
rownames = {'';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';};
data1 = [headers2 ;headers3 ;temp(1:5,:);headers4;temp(6:10,:)];
data = [rownames, data1];
myTable4b = Table(data);


temp = zeros(30,10);

temp(1,1:5) = coeffs6(1:5,1,1);
temp(2,1:5) = coeffs6(6:10,1,1);
temp(3,1:5) = coeffs6(11:15,1,1);
temp(4,1:5) = coeffs6(16:20,1,1);
temp(5,1:5) = coeffs6(21:25,1,1);
temp(1,6:10) = tstats6(1:5,1,1);
temp(2,6:10) = tstats6(6:10,1,1);
temp(3,6:10) = tstats6(11:15,1,1);
temp(4,6:10) = tstats6(16:20,1,1);
temp(5,6:10) = tstats6(21:25,1,1);

temp(6,1:5) = coeffs6(1:5,2,1)';
temp(7,1:5) = coeffs6(6:10,2,1)';
temp(8,1:5) = coeffs6(11:15,2,1)';
temp(9,1:5) = coeffs6(16:20,2,1)';
temp(10,1:5) = coeffs6(21:25,2,1)';
temp(6,6:10) = tstats6(1:5,2,1)';
temp(7,6:10) = tstats6(6:10,2,1)';
temp(8,6:10) = tstats6(11:15,2,1)';
temp(9,6:10) = tstats6(16:20,2,1)';
temp(10,6:10) = tstats6(21:25,2,1)';

temp(11,1:5) = coeffs6(1:5,3,1);
temp(12,1:5) = coeffs6(6:10,3,1);
temp(13,1:5) = coeffs6(11:15,3,1);
temp(14,1:5) = coeffs6(16:20,3,1);
temp(15,1:5) = coeffs6(21:25,3,1);
temp(11,6:10) = tstats6(1:5,3,1);
temp(12,6:10) = tstats6(6:10,3,1);
temp(13,6:10) = tstats6(11:15,3,1);
temp(14,6:10) = tstats6(16:20,3,1);
temp(15,6:10) = tstats6(21:25,3,1);

temp(16,1:5) = coeffs6(1:5,4,1)';
temp(17,1:5) = coeffs6(6:10,4,1)';
temp(18,1:5) = coeffs6(11:15,4,1)';
temp(19,1:5) = coeffs6(16:20,4,1)';
temp(20,1:5) = coeffs6(21:25,4,1)';
temp(16,6:10) = tstats6(1:5,4,1)';
temp(17,6:10) = tstats6(6:10,4,1)';
temp(18,6:10) = tstats6(11:15,4,1)';
temp(19,6:10) = tstats6(16:20,4,1)';
temp(20,6:10) = tstats6(21:25,4,1)';

temp(21,1:5) = coeffs6(1:5,5,1);
temp(22,1:5) = coeffs6(6:10,5,1);
temp(23,1:5) = coeffs6(11:15,5,1);
temp(24,1:5) = coeffs6(16:20,5,1);
temp(25,1:5) = coeffs6(21:25,5,1);
temp(21,6:10) = tstats6(1:5,5,1);
temp(22,6:10) = tstats6(6:10,5,1);
temp(23,6:10) = tstats6(11:15,5,1);
temp(24,6:10) = tstats6(16:20,5,1);
temp(25,6:10) = tstats6(21:25,5,1);

temp(26,1:5) = coeffs6(1:5,6,1)';
temp(27,1:5) = coeffs6(6:10,6,1)';
temp(28,1:5) = coeffs6(11:15,6,1)';
temp(29,1:5) = coeffs6(16:20,6,1)';
temp(30,1:5) = coeffs6(21:25,6,1)';
temp(26,6:10) = tstats6(1:5,6,1)';
temp(27,6:10) = tstats6(6:10,6,1)';
temp(28,6:10) = tstats6(11:15,6,1)';
temp(29,6:10) = tstats6(16:20,6,1)';
temp(30,6:10) = tstats6(21:25,6,1)';

temp=arrayfun(@(x) sprintf('%10.2f',x),temp,'un',0);

%headers1 = {'25 Size-B regressions'; 'CAPM';}';
headers2={ 'Low B' ; '2';'3';'4';'High B'; 'Low B' ; '2';'3';'4';'High B';}';
headers3 = {'';'';'a';'';'';'';'';'t(a)';'';'';}';
headers4 = {'';'';'b';'';'';'';'';'t(b)';'';'';}';
headers5 = {'';'';'c';'';'';'';'';'t(c)';'';'';}';
headers6 = {'';'';'d';'';'';'';'';'t(d)';'';'';}';
headers7 = {'';'';'e';'';'';'';'';'t(e)';'';'';}';
headers8 = {'';'';'f';'';'';'';'';'t(f)';'';'';}';
rownames = {'';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';'';'Small';'2';'3';'4';'Big';};
data1 = [headers2 ;headers3 ;temp(1:5,:);headers4;temp(6:10,:);headers5;temp(11:15,:);headers6;temp(16:20,:);headers7;temp(21:25,:);headers8;temp(26:30,:)];
data = [rownames, data1];
myTable5b = Table(data);


%% risk premia

      %regress Beta and F 
      for i= 1:25    % portfolios   N
      [betahat, tstatB]=ols(sizeBetaport(:,i),[RmRf, SMB,HML,RMW,CMA],0);   %returns of a portfolio vs factors 
      betahats(:,i)= betahat;   % F x N
      end
      
      
     for i=1:630   % time   T
     [FamaLambda , tstasFL] = ols(sizeBetaport(i,:)', betahats',0);    % return for each portfolio at a time vs FxN size factor coefficients
     FamaLambdas(:,i)= FamaLambda;  % F x T
     end
     LambdaMean15= mean(FamaLambdas,2);

     
temp = zeros(2,5);

temp(1,1:5) = LambdaMean14;
temp(2,1:5) = LambdaMean15;

temp=arrayfun(@(x) sprintf('%10.4f',x),temp,'un',0);

headers2={ 'Rm-Rf' ; 'SMB';'HML';'RMW';'CMA';}';
rownames = {'';'2014';'2015';};
data1 = [headers2 ;temp(:,:)];
data = [rownames, data1];
myTable6 = Table(data);

%% Build Presentation
PresName = 'FanaleStephen_Homework1.pptx'; % name of ppt file
slides = Presentation(PresName); % create ppt presentation
student_name=strcat('Stephen Fanale');
replace(slides,'Footer',student_name); % Not working

%% Title Slide
slide0 = add(slides,'Title Slide'); % 'Title Slide' tells the type of slide

contents = find(slides,'Title'); % find Title object and assign to placeholder variable
replace(contents(1),'590 Homework 1'); % replace contents with text
contents(1).FontColor = 'red';
replace(slide0,'Subtitle',student_name);

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Table 1-2014');
replace(tableSlide,'Table',myTable1); 

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Table 1-2015');
replace(tableSlide,'Table',myTable1b);

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Table 2-2014');
replace(tableSlide,'Table',myTable2); 

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Table 2-2015');
replace(tableSlide,'Table',myTable2b); 

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Table 3-2014');
replace(tableSlide,'Table',myTable3); 

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Table 3-2015');
replace(tableSlide,'Table',myTable3b); 

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Table 4 part 1 -2014');
replace(tableSlide,'Table',myTable4); 

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Table 4 part 2 -2014');
replace(tableSlide,'Table',myTable5); 

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Table 4 part 1 -2015');
replace(tableSlide,'Table',myTable4b); 

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Table 4 part 2 -2015');
replace(tableSlide,'Table',myTable5b); 

% Create slide and insert table
tableSlide = add(slides,'Title and Table');
replace(tableSlide,'Title','Risk Premia for Factors');
replace(tableSlide,'Table',myTable6); 

%% Generate and open the presentation
close(slides);

if ispc % if this machine is Windows
    winopen(PresName);
end