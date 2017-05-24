%%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann & Chris
%   Version: 0.1
%   Date: 20170523
%   About:
% ----------------------------------------------------------------------- %
%% Clearing screen, windows, variables and command windows
sca; close all; clear all; clc;
%% Add relevant paths to script
addpath('X:\Mitarbeiter\Max\Maxlab\General\');
%% Define variables for this experiment
% Path to the frame image
frameImagePath = ['X:\Mitarbeiter\Chris\MatLab\CFS_Frame.jpg'];
% Path to the image of the first stimulus (e.g. Mondrian)
firstStimulusImagePath = 'X:\Mitarbeiter\Max\Maxlab\ECG\Components\Stimuli\Mondrian.png';
% Path to the image of the second stimulus (usually equals the first stimulus)
secondStimulusImagePath = firstStimulusImagePath;
% Path to the image of the second stimulus (e.g. Face)
thirdStimulusImagePath = ['X:\Mitarbeiter\Chris\MatLab\RadboudFaces\radb_002_ang_f_cauc_fr.png'];
% Contrast weights for the three stimuli
% Stimulus 1
contrastFirstStimulus = 1;
% Stimulus 2
contrastSecondStimulus = 1;
% Stimulus 3
contrastThirdStimulus = 1;
% Duration of the fixation phase in seconds
durationFix = 1;
% Duration of the first stimulus in seconds
durationFirstStimulus = 2;
% Duration of the seconds stimulus in seconds
durationSecondStimulus = 0.3;
% Number of trials
numberOfTrials = 10;
%% PTB setup
% Setup PTB with some default values
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
%% Show black screen
Screen(window, 'FillRect', black);
Screen('Flip', window);
WaitSecs(1);
%% Create image textures - fixed contrast values for now
%Frame
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
thirdStim = imread(thirdStimulusImagePath);
thirdStim = (thirdStim-thirdStim(1)).*contrastThirdStimulus + thirdStim(1);
thirdStimTex = Screen('MakeTexture', window, thirdStim);
%% Generate frame coordinates to draw images at
[s1, s2, s3] = size(frameImage);
imageRect = [0,0,s2,s1];
baseRect = [0 0 400 400];
hori = round([40/100*xCenter]);
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
%% Set alpha blending
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%% Main trial procedure
for i = 1:numberOfTrials     
    % Show just the empty frames 
    Screen('DrawTexture', window, frameTex, [], LeftPosition, 0);
    Screen('DrawTexture', window, frameTex, [], RightPosition, 0);
    Screen('Flip', window);
    WaitSecs (durationFix); 
    % Update textures with new contrast during wait
    % NOT IMPLEMENTED YET
    % Show first stimulus 
    Screen('DrawTexture', window, frameTex, [], LeftPosition, 0);
    Screen('DrawTexture', window, frameTex, [], RightPosition, 0);
    Screen('DrawTexture', window, firstStimTex, [], imageRectInLeftFrame, 0);
    Screen('Flip', window);
    WaitSecs (durationFirstStimulus);    
    % Show second and third stimulus
    Screen('DrawTexture', window, frameTex, [], LeftPosition, 0);
    Screen('DrawTexture', window, frameTex, [], RightPosition, 0);
    Screen('DrawTexture', window, secondStimTex, [], imageRectInRightFrame, 0);
    Screen('DrawTexture', window, thirdStimTex, [], imageRectInLeftFrame, 0);
    Screen('Flip', window);
    WaitSecs (durationSecondStimulus)   
    Screen(window, 'FillRect', black);
    Screen('Flip', window);
    WaitSecs(1);
    if KbCheck
        break;
    end    
end
% Clear the screen
sca;