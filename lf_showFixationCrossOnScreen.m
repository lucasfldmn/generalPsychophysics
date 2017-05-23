%%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann
%   Version: 0.1
%   Date: 20170523
%   About: Displays a fixation cross in the screen center
% ----------------------------------------------------------------------- %
%   Function name: 
%   Input parameters:
%       size: Size in pixel
%       width: The width of the lines
% ----------------------------------------------------------------------- %
%% Start of first function
function [] = lf_showFixationCrossOnScreen(size, width, color, center)    
    global window 
    xCoords = [-size size 0 0];
    yCoords = [0 0 -size size];
    allCoords = [xCoords; yCoords];
    Screen('DrawLines', window, allCoords, width, color, center);
    % Flip to the screen
    Screen('Flip', window);   
end