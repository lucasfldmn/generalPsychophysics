function [trialMatrix, identityContrastMatrix, qNeu, qFea, tNeu, sdNeu, tFea, sdFea] = lf_flashSuppressionQuest()
%%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann
%   Version: 0.6
%   Date: 20170613
%   About: Flash suppression paradigma using QUEST
% ----------------------------------------------------------------------- %

%% Clearing screen, windows, variables and command windows
sca; close all; clear all; clc;

%% Set global variables
% no global variables defined

%% Define nested functions here
function [response] = lf_showFlashSuppressionSequence()
%%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann
%   Version: 1.0
%   Date: 20170606
%   About: Displays one trial procedure of the flash supression experiment
% ----------------------------------------------------------------------- %
%   Function name: lf_showFlashSuppressionSequence
%   Used variables:
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
%       0 = left, 1=right
% ----------------------------------------------------------------------- %     
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
else
    disp('***Invalid side!***');
end 
%% Show message to report response
WaitSecs (durationSecondStimulus);   
Screen(window, 'FillRect', black);
DrawFormattedText(window, 'Bitte geben Sie nun an, ob sie die gezeigte Emotion erkennen konnten.\n''Y'' falls ja. ''N'' falls nein. ''Escape'' zum Abbrechen.', 'center', 'center', 100, [], [], [], 2, [], LeftPosition);
DrawFormattedText(window, 'Bitte geben Sie nun an, ob sie die gezeigte Emotion erkennen konnten.\n''Y'' falls ja. ''N'' falls nein. ''Escape'' zum Abbrechen.', 'center', 'center', 100, [], [], [], 2, [], RightPosition);
Screen('Flip', window);
response = lf_getResponse();
end
function [thirdStim] = lf_getThirdStim()
    %%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann
%   Version: 1.0
%   Date: 20170606
%   About: Return the correct stimulus image based on emotion and intentity
% ----------------------------------------------------------------------- %
%   Function name: lf_getThirdStim
%   Used variables:
%       emotion: Neutral (0) or fearful (1) emotion
%       identity: Number of the identity (1-8 range integer)       
% ----------------------------------------------------------------------- %
if emotion % Fearful emotion
    switch identity
        case 1
            thirdStim = identityID1fea;
        case 2
            thirdStim = identityID2fea;
        case 3
            thirdStim = identityID3fea;
        case 4
            thirdStim = identityID4fea;
        case 5
            thirdStim = identityID5fea;
        case 6
            thirdStim = identityID6fea;                
        case 7
            thirdStim = identityID7fea;
        case 8
            thirdStim = identityID8fea;
    end
else       % Neutral emotion
    switch identity
        case 1
            thirdStim = identityID1neu;
        case 2
            thirdStim = identityID2neu;
        case 3
            thirdStim = identityID3neu;
        case 4
            thirdStim = identityID4neu;
        case 5
            thirdStim = identityID5neu;
        case 6
            thirdStim = identityID6neu;                
        case 7
            thirdStim = identityID7neu;
        case 8
            thirdStim = identityID8neu; 
    end
end
end
function [response] = lf_getResponse()
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
        fprintf('***KeyCode is %.5f.***\n', find(keyCode));
    end  
end
end

%% Set experiment parameters
% Side of the stimulus to appear, 0 for left, 1 for right
side = 0;
% Path to the frame image
frameImagePath = 'X:\Mitarbeiter\Chris\MatLab\CFS_Frame.jpg';
% Path to the image of the first stimulus (e.g. Mondrian)
firstStimulusImagePath = 'X:\Mitarbeiter\Max\Maxlab\ECG\Components\Stimuli\Mondrian.png';
% Path to the image of the second stimulus (usually equals the first stimulus)
secondStimulusImagePath = firstStimulusImagePath;
% Path to Radboud faces
radboudPath = 'X:\Mitarbeiter\Insa\emoCfs\Diverses\Radboud Faces';
% IDs of the Radboud faces to use
% Female face IDs
identityID1 = '001';
identityID2 = '012';
identityID3 = '014';
identityID4 = '061';
% Male face IDs
identityID5 = '010';
identityID6 = '023';
identityID7 = '038';
identityID8 = '071';
% Contrast weights for the three stimuli
% Stimulus 1
contrastFirstStimulus = 0.5;
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
% Number of trials per emotion
numberOfTrials = 35;
% Number of early trial rounds per emotion (3 trials per round)
numberOfEarlyTrialRounds = 5;
% Number of demo trials without response logging
numberOfDemoTrials = 5;
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

%% Set QUEST parameters 
pThreshold=0.82; beta=3.5; delta=0.01; gamma=0.0; grain=0.01; range=10;
% Initialize both QUEST procedures for the two emotions
qNeu=QuestCreate(initialGuess,initialSd,pThreshold,beta,delta,gamma,grain,range);
qFea=QuestCreate(initialGuess,initialSd,pThreshold,beta,delta,gamma,grain,range);
qNeu.normalizePdf=1;
qFea.normalizePdf=1;

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
% Define black
black = BlackIndex(screenNumber);
% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
% Set text size
Screen('TextSize', window , 15);
Screen('TextFont', window, 'Arial');
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
% Create image textures 
% Frame
frameImage = imread(frameImagePath);
frameImage = mean(frameImage,3);
frameImage(frameImage < 50) = 0;
frameImage(frameImage >= 50) = 127;
frameTex = Screen('MakeTexture', window, uint8(frameImage));
% First stimulus (e.g. Mondrian)
firstStim = imread(firstStimulusImagePath);
firstStim = (firstStim-firstStim(1)).*contrastFirstStimulus + firstStim(1);
firstStimTex = Screen('MakeTexture', window, firstStim);
% Second stimulus 
secondStim = imread(secondStimulusImagePath);
secondStim = (secondStim-secondStim(1)).*contrastSecondStimulus + secondStim(1);
secondStimTex = Screen(window, 'MakeTexture',secondStim);
% Generate frame coordinates to draw images at
[s1, s2] = size(frameImage);
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
% Create textures for each identity and emotion
% Read all neutral faces
identityID1neu = imread(strcat(radboudPath, '\radb_', identityID1, '_neu_f_cauc_fr.png'));
identityID2neu = imread(strcat(radboudPath, '\radb_', identityID2, '_neu_f_cauc_fr.png'));
identityID3neu = imread(strcat(radboudPath, '\radb_', identityID3, '_neu_f_cauc_fr.png'));
identityID4neu = imread(strcat(radboudPath, '\radb_', identityID4, '_neu_f_cauc_fr.png'));
identityID5neu = imread(strcat(radboudPath, '\radb_', identityID5, '_neu_m_cauc_fr.png'));
identityID6neu = imread(strcat(radboudPath, '\radb_', identityID6, '_neu_m_cauc_fr.png'));
identityID7neu = imread(strcat(radboudPath, '\radb_', identityID7, '_neu_m_cauc_fr.png'));
identityID8neu = imread(strcat(radboudPath, '\radb_', identityID8, '_neu_m_cauc_fr.png'));
% Read all fearful faces
identityID1fea = imread(strcat(radboudPath, '\radb_', identityID1, '_fea_f_cauc_fr.png'));
identityID2fea = imread(strcat(radboudPath, '\radb_', identityID2, '_fea_f_cauc_fr.png'));
identityID3fea = imread(strcat(radboudPath, '\radb_', identityID3, '_fea_f_cauc_fr.png'));
identityID4fea = imread(strcat(radboudPath, '\radb_', identityID4, '_fea_f_cauc_fr.png'));
identityID5fea = imread(strcat(radboudPath, '\radb_', identityID5, '_fea_m_cauc_fr.png'));
identityID6fea = imread(strcat(radboudPath, '\radb_', identityID6, '_fea_m_cauc_fr.png'));
identityID7fea = imread(strcat(radboudPath, '\radb_', identityID7, '_fea_m_cauc_fr.png'));
identityID8fea = imread(strcat(radboudPath, '\radb_', identityID8, '_fea_m_cauc_fr.png'));

%% Show first instructions
Screen(window, 'FillRect', black);
DrawFormattedText(window, 'Falls Sie die Instruktionen verstanden haben, beginnen Sie nun\nbitte die Probedurchgänge mit ''Y''. ''Escape'' zum Abbrechen.', 'center', 'center', 100, [], [], [], 2, [], LeftPosition);
DrawFormattedText(window, 'Falls Sie die Instruktionen verstanden haben, beginnen Sie nun\nbitte die Probedurchgänge mit ''Y''. ''Escape'' zum Abbrechen.', 'center', 'center', 100, [], [], [], 2, [], RightPosition);
Screen('Flip', window);
% Get response
response = lf_getResponse();

%% Experiment execution
if response ~= 99
%% Demo Trials
identity = 1;
emotion = 0;
intensity = 1;
thirdStim = lf_getThirdStim();
for i = 1:numberOfDemoTrials          
        response = lf_showFlashSuppressionSequence();
        % End if escape has been pressed
        if response == 99        
            break;
        end   
end
if response ~= 99
% Show start instructions
Screen(window, 'FillRect', black);
DrawFormattedText(window, 'Beginnen Sie nun das Experiment mit Taste ''Y''.\nSie können jederzeit mit ''Escape'' abbrechen.', 'center', 'center', 100, [], [], [], 2, [], LeftPosition);
DrawFormattedText(window, 'Beginnen Sie nun das Experiment mit Taste ''Y''.\nSie können jederzeit mit ''Escape'' abbrechen.', 'center', 'center', 100, [], [], [], 2, [], RightPosition);
Screen('Flip', window);
% Get response
response = lf_getResponse();
if response ~= 99    
%% Main experiment

% Create matrices to write repsonse and contrast into for each emotion
% Get number of pre trials
numberOfPreTrials = numberOfEarlyTrialRounds*3;
% Get combined number of trials
totalNumberOfTrials = 2*numberOfTrials + 2*numberOfPreTrials;
% Get all identities per emotion and shuffle
identityIDs = repmat((1:8), 1, floor(totalNumberOfTrials/8));
identityIDs = [identityIDs, randi([1, 8], 1, mod(totalNumberOfTrials,8))];
identityIDs = Shuffle(identityIDs);
% Randomize emotion (0 = neutral, 1 = fearful)
emotionRand = zeros(1,totalNumberOfTrials - 2*numberOfPreTrials);
emotionRand(1:totalNumberOfTrials/2) = 1;
emotionRand = Shuffle(emotionRand);
% Fill trial matrix with identities and emotions
trialMatrix = 1:totalNumberOfTrials;
trialMatrix(2,:) = identityIDs;
trialMatrix(3,1:numberOfPreTrials) = 0;
trialMatrix(3,numberOfPreTrials+1:numberOfPreTrials) = 1;
trialMatrix(3,numberOfPreTrials*2+1:totalNumberOfTrials) = emotionRand;
% Set current trial number
currentTrial = 1;
%% Procedures for the first trials to avoid quest failing due to early errors
% Neutral faces
emotion=0;
for i = 1:numberOfEarlyTrialRounds
    %% Set new test intensity using QuestMean as recommended by King-Smith et al. (1994)
    intensityLog = QuestMean(qNeu);    
    % Convert intenstiy to numeric scale
    intensity = 10^intensityLog;
    % Limit intensity to 0-1 range
    intensity=max(0,min(1,intensity));
    %% Show stimulus 3 times, get most frequent response   
    % Reset response count
    countFalse = 0;
    countTrue = 0;
    for j = 1:3       
        %% Experiment procure     
        % Get identity to display
        identity = trialMatrix(2,currentTrial);        
        % Get the correct image for identity
        thirdStim = lf_getThirdStim();       
        % Get response using the new intensity
        response = lf_showFlashSuppressionSequence();
        % End if escape has been pressed
        if response == 99        
            break;
        end   
        % Count false answers
        if response == 0        
            countFalse = countFalse + 1;
        end   
        % Count correct answers
        if response == 1             
            countTrue = countTrue + 1;
        end                    
        %% Log results
        trialMatrix(4,currentTrial) = intensity;
        trialMatrix(5,currentTrial) = response;
        %% Trial complete
        currentTrial = currentTrial + 1;  
    end
    % End if escape has been pressed
    if response == 99        
        break;
    end   
    % Get most frequent response
    if countTrue > countFalse
        response = 1;
    else
        response = 0;    
    end
    %% Update quest function with response and intensity
    % Use the intensity that has actually been used on logarithmic scale 
    % Response is binary (0 for failure, 1 for success)    
    qNeu=QuestUpdate(qNeu,log10(intensity),response);      
end
% Check if exit is desired
% End if escape has been pressed
if response == 99       
    disp('***Experiment terminated.***');
else
    
% Fearful faces
emotion=1;
for i = 1:numberOfEarlyTrialRounds
    %% Set new test intensity using QuestMean as recommended by King-Smith et al. (1994)
    intensityLog = QuestMean(qFea);    
    % Convert intenstiy to numeric scale
    intensity = 10^intensityLog;
    % Limit intensity to 0-1 range
    intensity=max(0,min(1,intensity));
    %% Show stimulus 3 times, get most frequent response   
    % Reset response count
    countFalse = 0;
    countTrue = 0;
    for j = 1:3       
        %% Experiment procure     
        % Get identity to display
        identity = trialMatrix(2,currentTrial);        
        % Get the correct image for identity
        thirdStim = lf_getThirdStim();       
        % Get response using the new intensity
        response = lf_showFlashSuppressionSequence();
        % End if escape has been pressed
        if response == 99        
            break;
        end   
        % Count false answers
        if response == 0        
            countFalse = countFalse + 1;
        end   
        % Count correct answers
        if response == 1             
            countTrue = countTrue + 1;
        end                    
        %% Log results
        trialMatrix(4,currentTrial) = intensity;
        trialMatrix(5,currentTrial) = response;
        %% Trial complete
        currentTrial = currentTrial + 1;  
    end
    % End if escape has been pressed
    if response == 99        
        break;
    end   
    % Get most frequent response
    if countTrue > countFalse
        response = 1;
    else
        response = 0;    
    end
    %% Update quest function with response and intensity
    % Use the intensity that has actually been used on logarithmic scale 
    % Response is binary (0 for failure, 1 for success)    
    qFea=QuestUpdate(qFea,log10(intensity),response);      
end
% Check if exit is desired
% End if escape has been pressed
if response == 99       
    disp('***Experiment terminated.***');
else  
    
%% Main QUEST procedure
for i = 1:numberOfTrials*2
    %% Get current emotion and identity to display
    emotion = trialMatrix(3,currentTrial);
    identity = trialMatrix(2,currentTrial);
    thirdStim = lf_getThirdStim();
    %% Set new test intensity using QuestMean as recommended by King-Smith et al. (1994) 
    if emotion % Fearful emotion
        intensityLog = QuestMean(qFea);   
    else       % Neutral emotion
        intensityLog = QuestMean(qNeu);   
    end      
    % Convert intenstiy to numeric scale
    intensity = 10^intensityLog;
    %% Experiment procure 
    % Limit intensity to 0-1 range    
    intensity=max(0,min(1,intensity));   
    % Get response using the new intensity    
    response = lf_showFlashSuppressionSequence();
    % End if escape has been pressed
    if response == 99      
        disp('***Experiment terminated.***');
        break;
    end
    %% Update quest function with response
    % Use the intensity that has actually been used on logarithmic scale 
    % Response is binary (0 for failure, 1 for success)
    if emotion % Fearful emotion
        qFea=QuestUpdate(qFea,log10(intensity),response);    
    else       % Neutral emotion
        qNeu=QuestUpdate(qNeu,log10(intensity),response);   
    end    
    %% Log results
    trialMatrix(4,currentTrial) = intensity;
    trialMatrix(5,currentTrial) = response;
    %% Trial complete
    currentTrial = currentTrial + 1;    
end
end
end
end
end
end
sca;

%% Get final estimate of thresholds
tLogNeu=QuestMean(qNeu);
tNeu=10^tLogNeu;
sdNeu=QuestSd(qNeu);
fprintf('Final threshhold estimate for neutral faces (mean+-sd) is %.5f +- %.5f\n', tNeu, sdNeu);
tLogFea=QuestMean(qFea);
tFea=10^tLogFea;
sdFea=QuestSd(qFea);
fprintf('Final threshhold estimate for fearful faces (mean+-sd) is %.5f +- %.5f\n', tFea, sdFea);

%% Evalate differences betweeen faces 
if response ~= 99   
% Group all faces based on identity and calculate quest threshhold guess for each
% identity 
identityContrastMatrix = zeros(1,8);
for i = 1:8
    ind = trialMatrix(2,:) == i;      
    identityMatrix = trialMatrix(:,ind); 
    %% Generate QUEST guess
    q=QuestCreate(initialGuess,initialSd,pThreshold,beta,delta,gamma,grain,range);
    q.normalizePdf=1;
    for j = 1:size(identityMatrix,2)
         q=QuestUpdate(q,log10(identityMatrix(4,j)),identityMatrix(5,j));         
    end
    tLog=QuestMean(q);
    t=10^tLog;
    sd=QuestSd(q);
    fprintf('Final threshhold estimate for identity %.5f (mean+-sd) is %.5f +- %.5f\n', i, t, sd);
    identityContrastMatrix(1,i) = t;
end
end
end