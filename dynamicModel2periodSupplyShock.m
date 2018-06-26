%Purpose: 
%   Illustrate shocks inside of a Closed DyEM via Impulse Response
%   Functions
%Author: 
%   Mike Aguilar, UNC-CH Economics, Dec'16


%Housekeeping
    clear all; close all; clc

%Set length of time for the IRF
    T = 25; 

%Exogenous Variable Settings
    etabar = 0.05*ones(T,1);
    eta = etabar;
    v = zeros(T,1); 
        v(4)= -1; v(5)=-1;
    pihat = ones(T,1)*2; 

    eps = zeros(T,1); 
    ybar = ones(T,1)*2; 
    rbar1 = ones(T,1)*2; 

%Parameter Settings
    thetapi = 0.5; 
    thetay = 0.5; 
    delta = 0.5; 
    alpha = 1; 
    %gamma = 0.5; 


%Macro Equilibrium 
    %Prepopulate
    ystar = ybar ;
    pistar = pihat; 
    i1(1,1) = rbar1(1,1)+pihat(1,1); 
    
    for t = 2:T
        ystar(t,1) = ybar(t,1) + (1/ (1+alpha*thetay+delta*alpha*thetapi))*(( alpha*thetapi)*pihat(t,1) + (-alpha*thetapi)*pistar(t-1,1)-alpha*(eta(t,1)-etabar(t,1))+eps(t,1)-alpha*thetapi*v(t,1)); 
        pistar(t,1) = (1/ (1+alpha*thetay+delta*alpha*thetapi))*( (delta*alpha*thetapi)*pihat(t,1)+(1+alpha*thetay)*pistar(t-1,1)-alpha*delta*(eta(t,1)-etabar(t-1,1))+delta*eps(t,1)+(1+alpha*thetay)*v(t,1)); 
        i1(t,1) = rbar1(t,1) + pistar(t,1) + thetapi*(pistar(t,1)-pihat(t,1)) + thetay*(ystar(t,1)-ybar(t,1)); 
    end

%Plot the shock
    subplot(2,3,1), plot(v), title('Supply')
    ylim([-2,1])
%Macro IRF
    subplot(2,3,2), plot(ystar), title('y^{*}')
    subplot(2,3,3), plot(pistar), title('\pi^{*}')
    
 
%Yield Curve
    %Parameter Setting
        M = 10; %Maximum maturity
        %liq = linspace(0,.02,M)'; %Liq Premium. Each entry is the liq premium for another maturity. 
        liq = [0.1:.1:1]'; 

    %Rates matrix: rows are time; columns are maturity; Row is yield curve
    %at a particular time. 
    Rates = zeros(T,size(liq,1)); 
    Rates(:,1) = i1; 
    for t = 1:T
        for m = 2:size(liq,1)
            Rates(t,m) = Rates(t,1)+liq(m,1); 
        end
    end
    %Fixed Income Plots
        subplot(2,3,4), plot(Rates(:,1)), title('i^{(1)}'); 
       % hold on 
        %subplot(2,2,3), plot(Rates(:,end),'r') 
        subplot(2,3,5), plot(Rates(:,end)), title('i^{(10)}'); 
    
    
    
%Equities
    %Settings
        beta = 0.1; 
        c = 0.4; 
        Phi = .5; %Backward looking behavior in growth expectations
        G = (pihat+ybar)*(1+beta); 
    %Prepopulate
        EPS = zeros(T,1); 
        EPS(1,1) = 100; 
        
    %Construct earnings
        for t = 2:T
            EPS(t,1) = EPS(t-1,1)*(1+ystar(t,1)/100+pistar(t,1)/100)*(1+beta);
        end
    %Dividends
        for t = 1:T
            Div(t,1) = EPS(t,1)*(1-c); 
        end
    %Exp Output; Rows=time; Columns=forecast maturity; 
        ExpY(1,1:M) = repmat(ybar(1,1)/100,1,M); 
        for t = 2:T
            for m = 1:M
                ExpY(t,m) = Phi^(t*m)*ystar(t-1,1)/100+(1-Phi^(t*m))*(ybar(t,1)/100);
            end
        end
    %Exp Inflation; Rows=time; Columns=forecast maturity; 
        ExpPi(1,1:M) = repmat(pihat(1,1)/100,1,M); 
        for t = 2:T
            for m = 1:M
                ExpPi(t,m) = Phi^(t*m)*pistar(t-1,1)/100+(1-Phi^(t*m))*(pihat(t,1)/100);
            end
        end
    %Expected Market Premium
        for t = 1:T
            MRP(t,1) = ((prod(1+ExpY(t,:)))^(1/M)-1)-Rates(t,M)/100; 
        end
    % k 
        for t = 1:T
            k(t,1) = Rates(t,M) + beta*MRP(t,1); 
        end
        
    %  PDV
        for t = 1:T
            PDV(t,1) = Div(t,1) ./ (k(t,1)/100-G(t,1)/100); 
        end
        %Returns
            Ret = (PDV(2:end,1)./PDV(1:end-1,1) - 1)*100; 
        
    %Equity Plot
        subplot(2,3,6),plot(Ret),title('Equity PDV %'); 
