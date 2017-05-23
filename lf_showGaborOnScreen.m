%%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann
%   Version: 0.1
%   Date: 20170510
%   About: Displays the gabor matrix on one side of the screen
% ----------------------------------------------------------------------- %
%   Function name: 
%   Input parameters:
%       gaborMatrix: The gabor matrix in imageMatrix from
%       destRect: The desitination rectangle    
% ----------------------------------------------------------------------- %
%% Start of first function
function [] = lf_showGaborOnScreen(gaborMatrix, destRect)    
    global window        
    combinedTexture = Screen(window,'MakeTexture', gaborMatrix, [], [], 0);
    Screen(window, 'DrawTexture', combinedTexture, [], destRect);
    % Flip to the screen
    Screen('Flip', window);
end

