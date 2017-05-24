%%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann
%   Version: 0.1
%   Date: 20170524
%   About: Generic quest routine with pre-quest run to be more robust against
%   early errors
% ----------------------------------------------------------------------- %
%% Clearing windows, variables and command windows
close all; clear all; clc;
%% Set experiment parameters
% set number of trials
numberOfTrials = 40;
% set number of pre trials
numberOfPreTrials = 10;
% guess initial threshhold (numeric scale, e.g. 0.05)
initialGuess = 0.05;
% guess initial sd (log scale, e.g. 10)
initialSd = 10;
%% Set pre QUEST parameters
pThresholdpre=0.82; betapre=3.5; deltapre=0.01; gammapre=0.5; grainpre=0.1; rangepre=8;
qpre=QuestCreate(log10(initialGuess),initialSd,pThresholdpre,betapre,deltapre,gammapre,grainpre,rangepre);
qpre.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
%% Initialize experiment
% Setup PsychToolbox, open screen, generate textures etc. here
%% Pre trial QUEST procedure
for i = 1:numberOfPreTrials
    %% Set new test intensity using QuestMean as recommended by King-Smith et al. (1994)
    intensityLog = QuestMean(qpre);    
    % Convert intenstiy to numeric scale
    intensity = 10^intensityLog;
    %% Experiment procure 
    % Get response using the new intensity
    %% Update quest function with response
    % Use the intensity that has actually been used on logarithmic scale 
    % Response is binary (0 for failure, 1 for success)
    qpre=QuestUpdate(qpre,intensityLog,response);    
end
% Get preliminary estimate of threshold.
tpreLog=QuestMean(qpre);
tpre=10^tpreLog;
sdpre=QuestSd(qpre);
fprintf('Preliminary threshhold estimate (mean+-sd) is %.5f +- %.5f\n',tpre,sdpre);
%% Set main QUEST parameters based on preliminary test
tGuess=tpre;
tGuessSd=initialSd;
pThreshold=0.82; beta=3.5; delta=0.01; gamma=0.5; grain=0.01; range=10;
q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,grain,range);
q.normalizePdf=1;
%% Main QUEST procedure
for i = 1:numberOfTrials
    %% Set new test intensity using QuestMean as recommended by King-Smith et al. (1994)
    intensityLog = QuestMean(q);    
    % Convert intenstiy to numeric scale
    intensity = 10^intensityLog;
    %% Experiment procure 
    % Get response using the new intensity
    %% Update quest function with response
    % Use the intensity that has actually been used on logarithmic scale 
    % Response is binary (0 for failure, 1 for success)
    q=QuestUpdate(q,intensityLog,response);    
end
% Get final estimate of threshold.
tLog=QuestMean(q);
t=10^tLog;
sd=QuestSd(q);
fprintf('Final threshhold estimate (mean+-sd) is %.5f +- %.5f\n',t,sd);