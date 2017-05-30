function [trialMatrix] = lf_flashSuppressionQuest()
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
contrastFirstStimulus = 0.8;
% Stimulus 2 - same contrast for both Mondrian patterns
contrastSecondStimulus = contrastFirstStimulus;
% Stimulus 3 - will be variied in the experiment
% contrastThirdStimulus = 1;
% Duration of the fixation phase in seconds
durationFix = 1;
% Duration of the first stimulus in seconds
durationFirstStimulus = 2;
% Duration of the seconds stimulus in seconds
durationSecondStimulus = 0.5;
% Number of trials
numberOfTrials = 50;
% Number of early trial rounds
numberOfEarlyTrialRounds = 5;
% Guess initial threshhold (numeric scale, e.g. 0.05)
initialGuess = 0.50;
% Guess initial sd (log scale, e.g. 10)
initialSd = 5;
% Key for response 'yes'
yes = 'y';
% Key for response 'no'
no = 'n';
% Key for experiment termination
escape = 'ESCAPE';
%% Initialize experiment
% Set QUEST parameters 
pThreshold=0.82; beta=3.5; delta=0.01; gamma=0.5; grain=0.01; range=10;
q=QuestCreate(initialGuess,initialSd,pThreshold,beta,delta,gamma,grain,range);
q.normalizePdf=1;
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
%% Main experiment
%% Create matrix to write repsonse and contrast into
% Get combined number of trials
totalNumberOfTrials = numberOfTrials + ((numberOfEarlyTrialRounds*numberOfEarlyTrialRounds+numberOfEarlyTrialRounds)/2);
% Get side conditions
logicals = zeros(totalNumberOfTrials,1);
logicals(1:round(totalNumberOfTrials/2)) = 1;
logicals_shuffled = Shuffle(logicals);
% Fill trial matrix
trialMatrix = 1:totalNumberOfTrials;
trialMatrix(2,:) = logicals_shuffled;
% Set current trial number
currentTrial = 1;
%% Staircase procedure for the first trials to avoid quest failing due to early errors
for i=numberOfEarlyTrialRounds:-1:1
    %% Set new test intensity using QuestMean as recommended by King-Smith et al. (1994)
    intensityLog = QuestMean(q);    
    % Convert intenstiy to numeric scale
    intensity = 10^intensityLog;
    % Limit intensity to 0-1 range
    intensity=max(0,min(1,intensity));
    % Generate N-up-1-down staircase for suggested intensity 
    % Maximum number of steps in lower intenstity direction are calculated by gaussian sum formula
    % Maximum steps in higher intensity direction = i
    maxSteps = (i*i+i)/2 + i;
    intensityStaircase = 1:maxSteps;
    stepGrain = intensity/maxSteps;
    intensityStaircase = stepGrain.*(maxSteps-intensityStaircase+i)
    % Set step on staircase
    activeStep = i;
    % Set count of steps (for correct answers)
    n = 1;
    for j=1:i        
        %% Experiment procure     
        % Limit intensity to 0-1 range
        intensity=intensityStaircase(activeStep);
        % Get response using the new intensity
        response = lf_showFlashSuppressionSequence(intensity, black, durationFix, durationFirstStimulus, durationSecondStimulus, frameTex, firstStimTex, secondStimTex, thirdStim, LeftPosition, RightPosition, imageRectInLeftFrame, imageRectInRightFrame, escapeKey, yesKey, noKey, trialMatrix(2,currentTrial));
        % End if escape has been pressed
        if response == 99        
            break;
        end   
        % Go up one step if repsonse is no
        if response == 0        
            activeStep = activeStep - 1;
            % Reset step size
            n = 1;
        end   
        % Go up n steps if repsonse is yes
        if response == 1        
            activeStep = activeStep + n;
            % Increase step size
            n = n + 1;
        end 
        %% Log results
        trialMatrix(3,currentTrial) = intensity;
        trialMatrix(4,currentTrial) = response;
        %% Trial complete
        currentTrial = currentTrial + 1;  
    end
    % End if escape has been pressed
    if response == 99        
        break;
    end    
    %% Update quest function with response and mean intensity
    % Use the intensity that has actually been used on logarithmic scale 
    % Response is binary (0 for failure, 1 for success)    
    q=QuestUpdate(q,log10(intensity),response);      
end
% Check if exit is desired
% End if escape has been pressed
if response == 99       
    disp('***Experiment terminated.***');
else
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
    response = lf_showFlashSuppressionSequence(intensity, black, durationFix, durationFirstStimulus, durationSecondStimulus, frameTex, firstStimTex, secondStimTex, thirdStim, LeftPosition, RightPosition, imageRectInLeftFrame, imageRectInRightFrame, escapeKey, yesKey, noKey, trialMatrix(2,currentTrial));
    % End if escape has been pressed
    if response == 99      
        disp('***Experiment terminated.***');
        break;
    end
    %% Update quest function with response
    % Use the intensity that has actually been used on logarithmic scale 
    % Response is binary (0 for failure, 1 for success)
    q=QuestUpdate(q,log10(intensity),response); 
    %% Log results
    trialMatrix(3,currentTrial) = intensity;
    trialMatrix(4,currentTrial) = response;
    %% Trial complete
    currentTrial = currentTrial + 1;    
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
%       side: logical to determine side of presentation
%             0 = left, 1=right
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