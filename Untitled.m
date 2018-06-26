
%% Housekeeping
    clear all; close all; clc; 
    import mlreportgen.ppt.* % import Matlab package to create ppt presentation

     addpath(genpath('C:\Users\Stephen\Documents\MATLAB\MFE\'));
startyear=1963;     
conn = sqlite('CRSPdata.db','readonly');
a=19660131;

querry2=['SELECT * FROM CRSPTable where date = 19820129'];
out2 = fetch(conn,querry2);
out2= cell2mat(cellfun(@(x) double(x),out2,'un',0)); % turn the cells into doubles so i can use them
