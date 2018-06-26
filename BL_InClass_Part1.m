%Housekeeping
clear all; close all; 
%Set Case #, which are defined within the in-class breakouts
Case = 1; 
%// Take the values from He & Litterman, 1999.
weq = [0.016,0.022,0.052,0.055,0.116,0.124,0.615];
C = [ 1.000 0.488 0.478 0.515 0.439 0.512 0.491;
      0.488 1.000 0.664 0.655 0.310 0.608 0.779;
      0.478 0.664 1.000 0.861 0.355 0.783 0.668;
      0.515 0.655 0.861 1.000 0.354 0.777 0.653;
      0.439 0.310 0.355 0.354 1.000 0.405 0.306;
      0.512 0.608 0.783 0.777 0.405 1.000 0.652;
      0.491 0.779 0.668 0.653 0.306 0.652 1.000];
S = [0.160 0.203 0.248 0.271 0.210 0.200 0.187];
%refPi = [0.039 0.069 0.084 0.090 0.043 0.068 0.076];
assets={'Australia';'Canada   ';'France   ';'Germany  ';'Japan    ';'UK       ';'USA      '};
labels={'q        ';'omega/tau';'lambda   ';'vw theta ';'prior theta';...
    'Theil Dst ';'Theil Prb ';'FM Dst   ';'FM Prob  ';'TEV     '};
Sigma = (S' * S) .* C;
%[m,n]=size(refPi);
 
%Case 1
if Case == 1
%// Risk tolerance of the market from the paper (page 10)
delta= 2.5;
%// Coefficient of uncertainty in the prior estimate of the mean
%// From footnote (8) on page 11
tau = 0.05;
%Set the views
%P = [0 0 -.295 1.00 0 -.705 0 ];
P = [ 1 0 0 0 0 0 0 ];
Q = [0.05];
%Set the uncertainty in the views
Omega = P * tau * Sigma * P' .* eye(1,1);
%Feed into the BL function
[er, ps, w, pw, lambda, theta, tmahal, tmahal_q, tsens, fmahal, fmahal_q, fsens, tev, tevs] = hlblacklitterman(delta, weq, Sigma, tau, P, Q, Omega);
%Display the output
PriorW = weq';
Output = table(PriorW,pw,er,'VariableNames',{'PriorW','PosteriorW','PosteriorReturn'});
td = ['Case #',num2str(Case)];
disp(td);
disp(Output)

end

