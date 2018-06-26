clear all;    %clear all variables
close all;   %close figures
clc;  %clear command window
%% two percent signs for a new section
%Load in Data
inputfile = [pwd,'\Lesson1data'];
[num, txt,raw]=xlsread(inputfile,'GOOG');
txtheadings=txt(1,:);


