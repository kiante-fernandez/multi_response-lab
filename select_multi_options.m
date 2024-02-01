% Author: Sumedha Goyal

clear all   % clear variables and other settings
clc         % clear command window
rng shuffle % seed random number generator based on clock time
close all   % close figure windows
sca        % close PsychToolbox windows

% suppress PsychToolbox welcome screen
Screen('Preference', 'VisualDebugLevel', 1);

% skip sync testing that causes errors
Screen('Preference', 'SkipSyncTests', 1);

% vector of screen numbers for available monitors
allScreenNums = Screen('Screens');

% screen number of "main" monitor
mainScreenNum = max(allScreenNums);

% PsychDefaultSetup(2) % to use 0-1 scale, 1 for 0-255 scale for RGB values

PsychDebugWindowConfiguration % makes screen transparent to see errors when debugging

backgroundColor = [0 0 0]; % setting background color to black

% open black full-screen window (called "w")
w = PsychImaging('OpenWindow', mainScreenNum, backgroundColor); % add ', [0 0 500 300]' at end to make ...
% rectangle window smaller

% set blend function for anti-aliasing (make drawing smoother)
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% window width and height in pixels
[wWidth, wHeight] = Screen('WindowSize', w);

xmid = round(wWidth/2); % horizontal midpoint of window 'w' in pixels
ymid = round(wHeight/2); % vertical midpoint of window 'w' in pixels

ListenChar(2) % suppresses keyboard input to Matlab windows

textColor = [255 255 255]; % setting text color to white

Screen('TextSize', w, round(wHeight/50)); % text size
Screen('TextFont', w, 'Helvetica');           % text font
Screen('TextStyle', w, 0) ;                % text style 

KbName('UnifyKeyNames'); % using standard keyboard names
keyNumSpace = min(KbName('Space'));   %key number for SPACE key

%% introduction %%
Screen('FillRect', w, backgroundColor); % clear visual buffer

DrawFormattedText(w, "Before we begin, please close any unnecessary programs or applications on ..." + ...
    "your computer.\nThis will help the study run more smoothly. Also, please close any..." + ...
    " browser tabs that could produce popups \nor alerts that would interfere with..." + ...
    " the study. \nFinally, once the study has started, DO NOT EXIT fullscreen mode ..." + ...
    "or you will terminate \nthe study and not receive any payment. The study will switch..." + ...
    " to full screen\n mode when you press the button below. \n\nWhen you are ready to begin, press" + ...
    " the space bar.",'center', 'center', textColor);
Screen('Flip', w) ;  % putting experiment instructions on screen
RestrictKeysForKbCheck(keyNumSpace) ; % disregard all keys except space
KbPressWait(-1); % wait till space is pressed

RestrictKeysForKbCheck([]); % goes back to regarding all keys

Screen('FillRect',w,backgroundColor); % overwrite text and start with new screen

%% Exposure %%

DrawFormattedText(w, "To familiarize you with the set of snack foods in this study\n, we will..." + ...
    " now briefly show you each one.\n\n Please press the SPACEBAR to begin." ,...
    'center', 'center', textColor);
Screen('Flip', w) ;  % putting experiment instructions on screen
RestrictKeysForKbCheck(keyNumSpace) ; % disregard all keys except space
KbPressWait(-1); % wait till space is pressed

RestrictKeysForKbCheck([]); % goes back to regarding all keys

Screen('FillRect',w,backgroundColor); % overwrite text and start with new screen

% Define the path to the folder containing images
folderPath = '/Users/sumedhagoyal/Downloads/60foods';

% Get a list of all image files in the folder
imageFiles = dir(fullfile(folderPath, '*.jpg')); % Change '*.jpg' to match your image file format

% Set the duration to display each image (in seconds)
displayDuration = 0.75;

try
    % Loop through each image file
    for i = 1:numel(imageFiles)
        % Load the image
        img = imread(fullfile(folderPath, imageFiles(i).name));
        
        % Convert the image matrix to a Psychtoolbox texture
        tex = Screen('MakeTexture', windowPtr, img);
        
        % Display the image in the center of the screen
        Screen('DrawTexture', windowPtr, tex, [], CenterRectOnPoint(size(img, 2), size(img, 1), windowRect(3)/2, windowRect(4)/2));
        Screen('Flip', windowPtr);
        
        % Pause for the specified duration
        WaitSecs(displayDuration);
        
        % Close the texture
        Screen('Close', tex);
    end

    % Close the Psychtoolbox window
    sca
    
catch
    % Close the Psychtoolbox window in case of an error
    sca
    psychrethrow(psychlasterror);
end


% displaying thank you screen
Screen('FillRect', w, 0);
DrawFormattedText(w, 'Thank you!', 'center', 'center', 255); 
Screen('Flip', w);

%% EXIT %%

keyCode = zeros(1, 256);
% checking for 'space' to be pressed to exit the thank you screen 
while sum(sum(keyCode(keyNumSpace))) < 1
    [~, ~, keyCode] = KbCheck(-1);
end

sca % close psychtoolbox windows
ListenChar(1); % restore keyboard input