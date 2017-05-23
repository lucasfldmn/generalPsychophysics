%%  Info section
% ----------------------------------------------------------------------- %
%   Author: Lucas Feldmann
%   Version: 0.1
%   Date: 20170510
%   About: Calcuates the size in degrees per pixel
% ----------------------------------------------------------------------- %
%   Function name: 
%   Input parameters:
%       diagonalSize: Diagonal screen size in inches
%       distance: The distance between participant and screen in cm
%       angle: The amount of degrees of field of vision, which the stimulus
%       can be seen in
% ----------------------------------------------------------------------- %
function [degreePerPixel] = lf_calculateSize(diagonalSize, distance, angle)  
    % Get pixel size in cm
    screensize = get( 0, 'Screensize' );
    pixelSize = sqrt(diagonalSize^2 / (screensize(3)^2 + screensize(4)^2)) * 2.54;
    % Get absolute size on screen 
    absSize = 2*distance*tand(angle/2);
    % Get size in pixel
    sizeInPixel = round(absSize / pixelSize);
    % Calculate degrees per pixel
    degreePerPixel = angle / sizeInPixel;
end