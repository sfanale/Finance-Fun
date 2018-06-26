clear all
clc
addpath(genpath('C:\Users\Stephen\Documents\MATLAB\MFE\'));
format long
delP=[25 36 49 34 42 16 30];
Nair=[13 19 18 11 19 7 12];
lenV=5/100; 
lenVe= 5.5/100;
lam=632.8*(10^-9);
lame=(632.8+.1)*(10^-9);
t=1.5/1000;

delT=[4 8 7 12 12 8 8];
Narc=[10 23 15 36 31 14 18];
delT=delT.*(2*pi/360);
delT=delT.^2;
[lamdahat, tstat, S2, ~,~,R2] = ols(Nair', delP' )


[lamdahat2, tstat2, S22, ~,~,R22] = ols(Narc', delT' )


nA= 1+((lamdahat(2))*lam*99.5) /(2*lenV)
nAe= 1+((lamdahat(2)+.01)*lame*99.5) /(2*lenVe);
nAe-nA

nArc = t/( t- lamdahat2(2)*lam)
nArce = t/( t- (lamdahat2(2)+8.3)*lame);
nArce-nArc
