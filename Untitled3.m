% Portfolio Construction & Optimization with Matrix Algebra and Matlab
% Mike Aguilar UNC Economics 12/16
% 
% 
% 
% Simulate some random returns data: $r_{i} \sim N(0,1) \ i\in(1,..,N)$

clear all; close all; clc; % Housekeeping
N = 3; % N = # of assets to simulate
T = 100; % T = # of observations for each assets (e.g. # of days)
seed = 100; rng(seed); %Controls seed in random number generation so that we can replicate results
%mu = [0;.02;.04]; %Mean values for case of N=3
%cov12 = 2; cov13 = -1.5; cov23 = .05; var1 = 2.25; var2 = 2.5; var3 = 1.75; %
%covar = [var1 cov12 cov13; cov12 var2 cov23; cov13 cov23 var3];
%R = chol(covar); 
%z = repmat(mu,T,1)+randn(T,N)*R
r = randn(T,N); % Assume the returns are white noise
plot(r); ylabel('%'); xlabel('days')



%% 
% Compute the sample moments of the simulated data. 
% 
% We know the sample moments will be close, but not exactly equal to the 
% population moments. 
% 
% Recall $\bar{r}=\frac{1}{T}\sum_{t=1}^{T}r_{t}$

SampleMean1 = mean(r) %Matlab's built in "mean"
SampleMean2 = ones(1,T)*r/T %Custom matrix algebra version
%% 
% Similar matrix formulas can be used to create the sample standard deviation

dm=r(:,1)-SampleMean1(1,1) % De-Meaned returns for the first asset
dmsq = dm.^2 % De-Meaned returns for the second asset. Notice the syntax ".^" operates on each element of the vector
StdDev1 = std(r(:,1)) %Matlab's built-in version
StdDev2 = sqrt(ones(1,T)*dmsq/(T-1)) % Custom matrix algebra version
%% 
% 
% 
% Let's compute the covariance matrix. 
% 
% Recall that for any two random variables: $Cov(X,Y)=E[(X-\bar{X})(Y- \bar{Y})]$, 
% with sample counterpart $s_{X,Y}=\frac{1}{T-1}\sum_{t=1}^{T}(X_{t}-\bar{X})(Y_{t}-\bar{Y})$

rA=r(:,1); 
rB = r(:,2); 
rC = r(:,3); 
dmrA = rA-SampleMean1(1,1); % De-Meaned rA 
dmrB = rB-SampleMean2(1,2); % De-Meaned rB
dmrC = rC-SampleMean2(1,3); % De-Meaned rC

SampleCov = dmrA'*dmrB/(T-1) % Custom using matrix algebra for cov(A,B)
%% 
%  We want the sample equivalent of the entire covariance matrix. 
% 
% $$\Sigma =   \pmatrix{\sigma^{2}_{A} & \sigma_{A,B} & \sigma_{A,C}\cr \sigma_{B,A} 
% & \sigma^{2}_{B} & \sigma_{B,C} \cr\sigma_{C,A} & \sigma_{C,B} & \sigma^{2}_{C}} 
% $$

CovMatrix1 = cov([rA rB rC]) %Built-in Matlab Functionality
dmr = [dmrA dmrB dmrC];
CovMatrix2 = (1/(T-1))*dmr'*dmr %Custom matrix algebra version
%% 
% Now we want to create some portfolio objects.  First, let's compute the 
% expected return on the portfolio.  Define  $w =   \pmatrix{w_{A} \cr w_{B} \cr 
% w_{C}}$and $E[r]=\pmatrix{E[r_{A}] \cr E[r_{B}] \cr E[r_{C}]}$. Using matrix 
% algebra we can produce the expected portfolio return as $E[r_{p}]=w'E[r]$

w = ones(N,1)/N %Equal weights
Er = SampleMean1' %Assumes empirical averages are expected returns
Erp = w'*Er
%% 
% Compute the standard deviation of the portfolio.  Recall $\sigma^{2}_{p}=w_{A}^{2}\sigma^{2}_{A}+w_{B}^{2}\sigma^{2}_{B}+w_{C}^{2}\sigma^{2}_{C}+2w_{A}w_{B}Cov(r_{A},r_{B})+2w_{A}w_{C}Cov(r_{A},r_{C})+2w_{B}w_{C}Cov(r_{B},r_{C})$.  
% In matrix algebra this can be written as $\sigma^{2}_{p}=w'\Sigma w = \pmatrix{w_{A} 
% & w_{B} & w_{C}}\pmatrix{\sigma^{2}_{A} & \sigma_{A,B} & \sigma_{A,C}\cr \sigma_{B,A} 
% & \sigma^{2}_{B} & \sigma_{B,C} \cr\sigma_{C,A} & \sigma_{C,B} & \sigma^{2}_{C}} 
% \pmatrix{w_{A} \cr w_{B} \cr w_{C}} $

Sigma = CovMatrix2; 
sigmaSqp = w'*Sigma*w

%% 
% Let's find the optimal weights for the standard Markowitz style allocation 
% problem: $\min_{w} \sigma^{2}_{p} \ s.t. \ r_{p}=r^{*};  \ \sum_{i=1}^{N}w_{i}=1$ 
% the Lagrangian for which can be written with matrix notation as $L(w,\lambda)=w'\Sigma 
% w+\lambda_{1}(w'E[r]-r^{*})+\lambda_{2}(w'{\bf{1}}-1)$. The associated FOC's 
% can be written as 
% 
% $$\matrix{\frac{\delta L}{\delta w}=2\Sigma w+\lambda_{1}E[r]+\lambda_{2}{\bf{1}}=0 
% \cr\frac{\delta L}{\delta \lambda_{1}}=w'E[r]-r^{*}=0 \cr\frac{\delta L}{\delta 
% \lambda_{2}}=w'{\bf{1}}-1=0}$$
% 
% This is a system of five equations (3 assets + 2 constraints), whiich can 
% be formed into a linear system of equations
% 
% $$\pmatrix{2\Sigma & E[r] & {\bf{1}} \crE[r]' & 0 & 0 \cr{\bf{1'}} & 0 
% & 0 }\pmatrix{w \cr \lambda_{1} \cr \lambda_{2}}=\pmatrix{ {\bf{0}} \cr r^{*} 
% \cr 1}$$
% 
% Define $A = \pmatrix{2\Sigma & E[r] & {\bf{1}} \crE[r]' & 0 & 0 \cr{\bf{1'}} 
% & 0 & 0 }$, $z = \pmatrix{w \cr \lambda_{1} \cr \lambda_{2}}$, and $b = \pmatrix{ 
% {\bf{0}} \cr r^{*} \cr 1}$. The problem is then $Az=b$, the solution to which 
% is $z=A^{-1}b$.  The first 3 elements of the $z$ vector are the optimal portfolio 
% weights given this objective and constraints.  
% 
% Let's solve for the optimal weights analytically

A=[2*Sigma Er ones(3,1); Er' 0 0; ones(1,3) 0 0]
rstar = mean(mean(r)); % Set the target rate of return
b = [ones(3,1); rstar; 1]
z = inv(A)*b
optw = z(1:3,1); 
rp = optw'*Er %Form the return on the portfolio given the optimal weights
%% 
% Solving analytically isn't always tractable in the face of inequality 
% constraints, etc... An alternative is to solve numerically, for which we can 
% use the fmincon command. See https://www.mathworks.com/help/optim/ug/fmincon.html 

clear w
portvar=@(w)w'*cov(r)*w; %In-line function to compute portfolio variance
A=[]; b=[]; %No inequality constraints
lb=[]; ub=[]; %No boundary conditions
Aeq = [Er' ; ones(1,N)]; 
beq = [rstar; 1];
w0 = ones(N,1)/N; %Starting valuess for weights
optwNum = fmincon(portvar,w0,A,b,Aeq,beq,lb,ub); 
[optw optwNum]
%% 
% 
% 
% We can also compute optimal weights by using Matlab's built-in portfolio 
% optimization tools. See https://www.mathworks.com/help/finance/examples/portfolio-optimization-examples.html 

p=Portfolio; %Create a portfolio object
p=setAssetMoments(p,Er,Sigma); %Set the mean and (co)variance of returns
p=setDefaultConstraints(p); % Default constraints: fully invested. Careful: also includes positive weights
pwgt = estimateFrontierByReturn(p,rstar); %Estimates the weights from the Efficient Frontier
[optw optwNum pwgt]
%% 
% 
% 
% Let's visualize with an efficient frontier


plotFrontier(p, 40);
hold on
scatter(estimatePortRisk(p, pwgt), estimatePortReturn(p, pwgt), 'filled', 'y');
hold on; 
scatter(sqrt(diag(Sigma)),Er,[],'r');
legend('Efficient Frontier','Optimal Portfolio','Assets','location', 'best');
hold off;




%% 
% ||