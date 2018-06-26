%% Modern Portfolio Theory
%for my learning purposes, he will post a better one to use on Sakai

clear all; close all; clc; 


%% Generate random return data
N=3;
T=100;
Ri= randn(T,N);
rAve = mean(Ri);
rAve= rAve';
w = [1/3;1/3;1/3];
plot(Ri);

%% Construct "equal weight portfolio"
ErP = w'*rAve;
Sig= cov(Ri)
sigmaP = w'*Sig*w;

%% minimize varience of portfolio
rStar= ErP;
lb= [0;0;0];
ub=[1.5;1.5;1.5];
beq= [rStar; 1];
%Aeq= [ [Ri(:,1);1] [Ri(:,2);1] [Ri(:,3);1]]
Aeq= [ [rAve(1);1] [rAve(2);1] [rAve(3);1]];

portVar=@(w)w'*cov(Ri)*w;

wStar= fmincon(portVar, w, [],[], Aeq, beq, lb, ub)









