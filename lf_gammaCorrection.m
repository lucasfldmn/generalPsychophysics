%%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann
%   Version: 0.1
%   Date: 20170523
%   About: Saves the gamme correction to a table
%% Clearing windows, variables and command windows
close all; clear all; clc;
%% Add relevant paths to script
% addpath();
%% Unifiy key names
KbName('UnifyKeyNames');
%% Get gamma tables
numberOfReadings = 9;
[gammaModel, splineInterpolation] = CalibrateMonitorPhotometer(numberOfReadings,[]);
% Look at the outputted graphs to see which one gives a better fit
% Then save the corresponding gamma table for later use
% Select model here
gammaTable = gammaModel;
% Save under MyGammaTable
save MyGammaTable.mat gammaTable

%% Use gamma table in other scripts (check workpath)
%load MyGammaTable
%Screen('LoadNormalizedGammaTable', window, gammaTable*[1 1 1]);
