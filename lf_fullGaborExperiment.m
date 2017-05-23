%%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann
%   Version: 0.1
%   Date: 20170510
%   About:
% ----------------------------------------------------------------------- %
%% Clearing windows, variables and command windows
close all; clear all; clc;
%% Add relevant paths to script
% addpath();
%% Set global vars
global window
%% PTB standard setup
% Setup PTB with some default values
PsychDefaultSetup(2);
% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));
%% Colour definition
% Define black, white and grey
white = WhiteIndex(screenNumber);  % pixel value for white
black = BlackIndex(screenNumber); % pixel value for black
midgray = (white+black)/2;
inc = white-midgray;
%% Set trial parameters
% set code for invalid trials
invalidTrialCode = 99;
% set initial contrast
contrast = 1;
% set defaul orientation
orientation = 0;
% set size in degreeperpixel
degreeSize = 10;
degreePerPixelSize = lf_calculateSize(23, 60, 10);
% generate left or right condition vector (1=right, 0=left)
numberOfTrials = 40; 
trialMatrix = round(rand(1,numberOfTrials));
%% Set QUEST parameters
tGuess=log10(0.05);
tGuessSd=10;
pThreshold=0.82;
beta=3.5;delta=0.01;gamma=0.5;grain=0.01;range=8;
q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,grain,range);
q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
%% Main trial procedure
% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, midgray, [], 32, [],... 
    [], []);
% set gamma correction
load MyGammaTable
Screen('LoadNormalizedGammaTable', window, gammaTable*[1 1 1]);
% get screen centers
[xCenter, yCenter] = RectCenter(windowRect);
% get screen pixel size
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
% set x position for both conditions
xPosLeft = screenXpixels * 0.25;
xPosRight = screenXpixels * 0.75;
% Calculate grating and gabor pixel matrix
grating = mb_compoundCircularGrating_V3('shape','disk','envelope','gauss','or',orientation,'sf',1,'phase',0,'co',contrast,'noise',0,'degreeperpixel',degreePerPixelSize,'radius',degreeSize/2);
gaborMatrix(:,:) = round((midgray+inc*grating)*256);
% set base rectangle the size of the gabor
baseRect = [xCenter yCenter size(gaborMatrix,1)+xCenter, size(gaborMatrix,2)+yCenter];
% set left and right destination rectangles
destRectLeft = CenterRectOnPointd(baseRect, xPosLeft, yCenter);
destRectRight = CenterRectOnPointd(baseRect, xPosRight, yCenter);
% set keycodes for keys to press
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
% loop through trial conditions
for i = 1:numberOfTrials
    % Set new contrast using QuestMean as recommended by King-Smith et al. (1994)
    contrastLog = QuestMean(q);
    trialMatrix(6,i) = contrastLog;
    contrast = 10^contrastLog;
    % Restrict contrast to 0-1 range - shouldnt be needed but is here for
    % additional safety
    contrast=max(0,min(1,contrast));
    % Calculate grating and gabor pixel matrix
    grating = mb_compoundCircularGrating_V3('shape','disk','envelope','gauss','or',orientation,'sf',1,'phase',0,'co',contrast,'noise',0,'degreeperpixel',degreePerPixelSize,'radius',degreeSize/2);
    gaborMatrix = round((midgray+inc*grating)*256);
    % show gabor depending on condition
    if trialMatrix(1,i)==1
        lf_showGaborOnScreen(gaborMatrix, destRectRight)
    else 
        lf_showGaborOnScreen(gaborMatrix, destRectLeft)
    end
    startTime = GetSecs;
    [sec , keyCode, deltaSecs] = KbWait;  
    rt = GetSecs - startTime;
    if keyCode(leftKey)
        % gabor detected on left side
        trialMatrix(2,i) = 0;
        trialMatrix(3,i) = rt*1000;
    elseif keyCode(rightKey)
        % gabor detected on right side
        trialMatrix(2,i) = 1;
        trialMatrix(3,i) = rt*1000;
    elseif keyCode(escapeKey)
        % exit 
        disp('***Experiment terminated.***');
        break;
    else
        % different key press, trial invalid
        trialMatrix(2,i) = invalidTrialCode;
    end    
    % remove gabor and display fixation cross for one second
    % no exiting prossible during this timeframe -> might have to be
    % changed
    lf_showFixationCrossOnScreen(40,5,black, [xCenter, yCenter]);   
    WaitSecs(1);
    % write current contrast to cond
    trialMatrix(4,i) = contrast;
    % Set new contrast based on previous trial response (correct = contrast
    % gets halved, wrong = contrast gets tripled, invalid = contrast stays the same)
    %if trialMatrix(2,i)==invalidTrialCode
    %elseif trialMatrix(1,i)==trialMatrix(2,i)
    %    contrast = contrast/3;
    %else        
    %    contrast = contrast*2;
    %    % attention: contrast must not be greater than 1
    %     if contrast > 1
    %        contrast = 1;
    %    end
    %end
    % Update QUEST pdf function and set new contrast using QuestMean as recommended by King-Smith et al. (1994)
    if trialMatrix(2,i)==invalidTrialCode
    elseif trialMatrix(1,i)==trialMatrix(2,i)
        response = 1;
        q=QuestUpdate(q,log10(contrast),response);
    else        
        response = 0;   
        q=QuestUpdate(q,log10(contrast),response);
    end    
end
sca;
% Ask Quest for the final estimate of threshold.
t=10^QuestMean(q);
sd=QuestSd(q);
fprintf('Final contrast threshhold estimate (mean+-sd) is %.5f +- %.5f\n',t,sd);
%% data evaluation
% flag trials
for i = 1:numberOfTrials
    if trialMatrix(2,i)==invalidTrialCode %trials with invalid result
        trialMatrix(5,i) = 99;
    elseif trialMatrix(1,i)==trialMatrix(2,i)
        trialMatrix(5,i) = 1; %trials with correct result
    else
        trialMatrix(5,i) = 0; %trials with flase result
    end
end
% generate vector of correct trial indices
correctTrials = trialMatrix(5,:) == 1;
% generate vector of correct trial indices
falseTrials = trialMatrix(5,:) == 0;
% calculate mean rt correct trials
meanRTCorrect = mean(trialMatrix(3,correctTrials));
% calculate mean rt false trials
meanRTFalse = mean(trialMatrix(3,falseTrials));