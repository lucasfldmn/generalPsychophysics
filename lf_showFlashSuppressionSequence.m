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
%% Start of first function
function [response] = lf_showFlashSuppressionSequence(intensity, black, durationFix, durationFirstStimulus, durationSecondStimulus, frameTex, firstStimTex, secondStimTex, thirdStim, LeftPosition, RightPosition, imageRectInLeftFrame, imageRectInRightFrame, escapeKey, yesKey, noKey, side)    
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