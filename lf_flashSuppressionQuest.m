function [] = lf_flashSuppressionQuest()
%%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann
%   Version: 0.1
%   Date: 20170524
%   About: Flash suppression paradigma using QUEST
% ----------------------------------------------------------------------- %
%% Clearing screen, windows, variables and command windows
sca; close all; clear all; clc;
%% Set global variables
global window;
%% Set experiment parameters
% Side of the stimulus to appear, 0 for left, 1 for right
side = 1;
% Path to the frame image
frameImagePath = 'X:\Mitarbeiter\Chris\MatLab\CFS_Frame.jpg';
% Path to the image of the first stimulus (e.g. Mondrian)
firstStimulusImagePath = 'X:\Mitarbeiter\Max\Maxlab\ECG\Components\Stimuli\Mondrian.png';
% Path to the image of the second stimulus (usually equals the first stimulus)
secondStimulusImagePath = firstStimulusImagePath;
% Path to the image of the second stimulus (e.g. Face)
thirdStimulusImagePath = 'X:\Mitarbeiter\Chris\MatLab\RadboudFaces\radb_002_ang_f_cauc_fr.png';
% Contrast weights for the three stimuli
% Stimulus 1
contrastFirstStimulus = 1;
% Stimulus 2
contrastSecondStimulus = 1;
% Stimulus 3 - will be variied in the experiment
% contrastThirdStimulus = 1;
% Duration of the fixation phase in seconds
durationFix = 1;
% Duration of the first stimulus in seconds
durationFirstStimulus = 2;
% Duration of the seconds stimulus in seconds
durationSecondStimulus = 0.5;
% Total number of trials
numberOfTrials = 50;
% Number of pre trials
numberOfPreTrials = 10;
% Guess initial threshhold (numeric scale, e.g. 0.05)
initialGuess = 0.20;
% Guess initial sd (log scale, e.g. 10)
initialSd = 10;
% Key for response 'yes'
yes = 'y';
% Key for response 'no'
no = 'n';
% Key for experiment termination
escape = 'ESCAPE';
%% Set pre QUEST parameters
pThresholdpre=0.82; betapre=3.5; deltapre=0.01; gammapre=0.5; grainpre=0.1; rangepre=8;
qpre=QuestCreate(log10(initialGuess),initialSd,pThresholdpre,betapre,deltapre,gammapre,grainpre,rangepre);
qpre.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
%% Initialize experiment
% Set keycodes for keys to press
KbName('UnifyKeyNames');
escapeKey = KbName(escape);
yesKey = KbName(yes);
noKey = KbName(no); 
% PTB setup
PsychDefaultSetup(2);
% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));
% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
% Show black screen
Screen(window, 'FillRect', black);
Screen('Flip', window);
WaitSecs(1);
% Create image textures 
% Frame
frameImage = imread(frameImagePath);
frameImage = mean(frameImage,3);
frameImage(frameImage < 50) = 0;
frameImage(frameImage >= 50) = 92;
frameTex = Screen('MakeTexture', window, uint8(frameImage));
% First stimulus (e.g. Mondrian)
firstStim = imread(firstStimulusImagePath);
firstStim = (firstStim-firstStim(1)).*contrastFirstStimulus + firstStim(1);
firstStimTex = Screen('MakeTexture', window, firstStim);
% Second stimulus 
secondStim = imread(secondStimulusImagePath);
secondStim = (secondStim-secondStim(1)).*contrastSecondStimulus + secondStim(1);
secondStimTex = Screen(window, 'MakeTexture',secondStim);
% Third stimulus
% Only read image, generate texture based on varying contrast
thirdStim = imread(thirdStimulusImagePath);
% Generate frame coordinates to draw images at
[s1, s2, s3] = size(frameImage);
baseRect = [0 0 400 400];
hori = round(40/100*xCenter);
Xlinks = round(xCenter-hori);
Xrechts = round (xCenter+hori);
imageScaleFactor = 0.3;
imageScaleFactor2 = 0.3;
imageRect = round([0,0,s2,s1]*imageScaleFactor);
imageRect2 = round([0,0,400,400]*imageScaleFactor2);
imageRectInLeftFrame = CenterRectOnPoint(imageRect2,Xlinks,yCenter);
imageRectInRightFrame = CenterRectOnPoint(imageRect2,Xrechts,yCenter);
LeftPosition = CenterRectOnPointd(imageRect, Xlinks, yCenter);
RightPosition = CenterRectOnPointd(imageRect, Xrechts, yCenter);
% Set alpha blending
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%% Pre trial QUEST procedure
for i = 1:numberOfPreTrials
    %% Set new test intensity using QuestMean as recommended by King-Smith et al. (1994)
    intensityLog = QuestMean(qpre);    
    % Convert intenstiy to numeric scale
    intensity = 10^intensityLog;
    %% Experiment procure     
    % Limit intensity to 0-1 range
    intensity=max(0,min(1,intensity));
    % Get response using the new intensity
    response = lf_showFlashSuppressionSequence(intensity, black, durationFix, durationFirstStimulus, durationSecondStimulus, frameTex, firstStimTex, secondStimTex, thirdStim, LeftPosition, RightPosition, imageRectInLeftFrame, imageRectInRightFrame, escapeKey, yesKey, noKey, side);
    % End if escape has been pressed
    if response == 99        
        break;
    end
    %% Update quest function with response
    % Use the intensity that has actually been used on logarithmic scale 
    % Response is binary (0 for failure, 1 for success)    
    qpre=QuestUpdate(qpre,log10(intensity),response);    
end
% Check if exit is desired
% End if escape has been pressed
if response == 99       
    disp('***Experiment terminated.***');
else
% Get preliminary estimate of threshold.
tpreLog=QuestMean(qpre);
tpre=max(0,min(1,10^tpreLog));
sdpre=QuestSd(qpre);
fprintf('Preliminary threshhold estimate (mean+-sd) is %.5f +- %.5f\n',tpre,sdpre);
%% Set main QUEST parameters based on preliminary test
tGuess=log10(tpre);
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
    % Limit intensity to 0-1 range    
    intensity=max(0,min(1,intensity));   
    % Get response using the new intensity    
    response = lf_showFlashSuppressionSequence(intensity, black, durationFix, durationFirstStimulus, durationSecondStimulus, frameTex, firstStimTex, secondStimTex, thirdStim, LeftPosition, RightPosition, imageRectInLeftFrame, imageRectInRightFrame, escapeKey, yesKey, noKey, side);
    % End if escape has been pressed
    if response == 99      
        disp('***Experiment terminated.***');
        break;
    end
    %% Update quest function with response
    % Use the intensity that has actually been used on logarithmic scale 
    % Response is binary (0 for failure, 1 for success)
    q=QuestUpdate(q,log10(intensity),response);    
end
% Get final estimate of threshold.
tLog=QuestMean(q);
t=10^tLog;
sd=QuestSd(q);
fprintf('Final threshhold estimate (mean+-sd) is %.5f +- %.5f\n',t,sd);
end
sca;
end

function [response] = lf_showFlashSuppressionSequence(intensity, black, durationFix, durationFirstStimulus, durationSecondStimulus, frameTex, firstStimTex, secondStimTex, thirdStim, LeftPosition, RightPosition, imageRectInLeftFrame, imageRectInRightFrame, escapeKey, yesKey, noKey, side)
%%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann
%   Version: 0.1
%   Date: 20170524
%   About: Displays one trial procedure of the flash supression experiment
% ----------------------------------------------------------------------- %
%   Function name: 
%   Input parameters:
%       intensity: The contrast of the third stimulus (weight)
%       black: Black background color
%       durationFix: Duration of the fixation phase
%       durationFirstStimulus: Duration of first stimulus presentation
%       durationSecondStimulus: Duration of second stimulus presentation
%       frameTex: Texture of the frame
%       firstStimTex: Texture of the first stimlus
%       secondStimTex: Texture of the second stimulus
%       thirdStim: Image map of the third stimulus (no texture!)
%       LeftPosition: Left frame position
%       RightPosition: Right frame position
%       imageRectInLeftFrame: Left image rectangle
%       imageRectInRightFrame: Right image rectangle
%       escapeKey: Keycode for the key to terminate the experiment
%       yesKey: Keycode for response 'yes' 
%       noKey: Keycode for response 'no'
% ----------------------------------------------------------------------- %
global window        
%% Show just the empty frames 
Screen('DrawTexture', window, frameTex, [], LeftPosition, 0);
Screen('DrawTexture', window, frameTex, [], RightPosition, 0);
Screen('Flip', window);
WaitSecs (durationFix); 
%% Update textures with new contrast during wait
thirdStimWithContrast = (thirdStim-thirdStim(1)).*intensity + thirdStim(1);
thirdStimTex = Screen('MakeTexture', window, thirdStimWithContrast);
%% Show stimuli depending on side
if side == 0 % left side
    %% Show first stimulus 
    Screen('DrawTexture', window, frameTex, [], LeftPosition, 0);
    Screen('DrawTexture', window, frameTex, [], RightPosition, 0);
    Screen('DrawTexture', window, firstStimTex, [], imageRectInLeftFrame, 0);
    Screen('Flip', window);
    WaitSecs (durationFirstStimulus);    
    %% Show second and third stimulus
    Screen('DrawTexture', window, frameTex, [], LeftPosition, 0);
    Screen('DrawTexture', window, frameTex, [], RightPosition, 0);
    Screen('DrawTexture', window, secondStimTex, [], imageRectInRightFrame, 0);
    Screen('DrawTexture', window, thirdStimTex, [], imageRectInLeftFrame, 0);
    Screen('Flip', window);
    WaitSecs (durationSecondStimulus);   
    Screen(window, 'FillRect', black);
    Screen('Flip', window);
elseif side == 1 % right side
    %% Show first stimulus 
    Screen('DrawTexture', window, frameTex, [], LeftPosition, 0);
    Screen('DrawTexture', window, frameTex, [], RightPosition, 0);
    Screen('DrawTexture', window, firstStimTex, [], imageRectInRightFrame, 0);
    Screen('Flip', window);
    WaitSecs (durationFirstStimulus);    
    %% Show second and third stimulus
    Screen('DrawTexture', window, frameTex, [], LeftPosition, 0);
    Screen('DrawTexture', window, frameTex, [], RightPosition, 0);
    Screen('DrawTexture', window, secondStimTex, [], imageRectInLeftFrame, 0);
    Screen('DrawTexture', window, thirdStimTex, [], imageRectInRightFrame, 0);
    Screen('Flip', window);
    WaitSecs (durationSecondStimulus);   
    Screen(window, 'FillRect', black);
    Screen('Flip', window);
else
    disp('***Invalid side!***');
end   
%% Get response 
% show message to vps to report whether they have seen the face or not
% loop through keypresses until a correct key is pressed
while 1
    [~ , keyCode, ~] = KbWait([], 2);   
    if keyCode(yesKey)        
        response = 1;  
        break;
    elseif keyCode(noKey)
        response = 0;  
        break;
    elseif keyCode(escapeKey)            
        response = 99;              
        break;
    else           
        disp('***Invalid key press.***');            
    end   
end
end