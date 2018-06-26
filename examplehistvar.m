load data
confidence_level = 0.95;
plot_flag = true;
figure
VAR_hist = computeHistoricalVaR(returns,confidence_level,plot_flag)