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

%PsychDebugWindowConfiguration % makes screen transparent to see errors when debugging

backgroundColor = [255 255 255]; % setting background color to black

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

textColor = [0 0 0]; % setting text color to white

Screen('TextSize', w, round(wHeight/50)); % text size
Screen('TextFont', w, 'Helvetica');           % text font
Screen('TextStyle', w, 0) ;                % text style 

KbName('UnifyKeyNames'); % using standard keyboard names
keyNumSpace = min(KbName('Space'));   %key number for SPACE key

%% SLIDER SET UP %%
%%%% slider set up
ifi = Screen('GetFlipInterval', w);
% Get the centre coordinate of the window
[xCenter, yCenter] = WindowCenter(w);
sliderYpos = 0.8 * wHeight;

% Our slider will span a proportion of the screens x dimension
sliderLengthPix = wHeight/1.05;
sliderHLengthPix = sliderLengthPix / 2;
% Coordiantes of the sliders left and right ends
leftEnd = [xCenter - sliderHLengthPix sliderYpos];
rightEnd = [xCenter + sliderHLengthPix sliderYpos];
sliderLineCoords = [leftEnd' rightEnd'];

% Slider line thickness
sliderLineWidth = 10;

% Define colours
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];
grey = [128 128 128];

% Here we set the initial position of the mouse to the centre of the screen
SetMouse(xCenter, sliderYpos, w);

% Make a base Rect relative to the size of the screen: this will be the
% toggle we can slide on the slider
dim = wHeight  / 25;
hDim = dim / 4;
baseRect = [0 0 dim dim];

% We now set the toggles initial position at a random point on the slider
sx = xCenter + (rand * 2 - 1) * sliderHLengthPix;
centeredRect = CenterRectOnPointd(baseRect, sx, sliderYpos);

% Text labels for the slider scale
sliderLabels = {'Not at all', 'Very much'};

% Get bounding boxes for the slider label text
textBoundsAll = nan(2, 4);
for i = 1:2
    [~, ~, textBoundsAll(i, :)] = DrawFormattedText(w, sliderLabels{i}, 0, 0, textColor);
end

% Width and height of the text
textWidths = textBoundsAll(:, 3)';
halfTextWidths = textWidths / 2;
textHeights = range([textBoundsAll(:, 2) textBoundsAll(:, 4)], 2)';
halfTextHeights = textHeights / 2;

% Position of the text so that it is at the ends of the slider but does
% not overlap with the slider line or silder toggle. Make sure it is also
% centered in the y dimension of the screen. To do this we used the bounding
% boxes of the text, plus a little gap so that the text does not completely
% edge the slider toggle in the x dimension
textPixGap = 10;
leftTextPosX = xCenter - sliderHLengthPix - hDim - textWidths(1) - textPixGap;
rightTextPosX = xCenter + sliderHLengthPix + hDim + textPixGap;

leftTextPosY = sliderYpos + halfTextHeights(1);
rightTextPosY = sliderYpos + halfTextHeights(2);
 
% Define the path to the folder containing images
folderPath = 'images/60foods';

% Get a list of all image files in the folder
imageFiles = ls(fullfile(folderPath, '*.jpg')); % Change '*.jpg' to match your image file format
%fileList = strsplit(imageFiles);
imageFileNames = cellstr(imageFiles);

%% ACTUAL SLIDER SHOWING %%

% Clear the screen
Screen('FillRect', w, backgroundColor);
Screen('Flip', w);

% Draw the slider line
Screen('DrawLines', w, sliderLineCoords, sliderLineWidth, grey);

% Draw the slider toggle
Screen('FillRect', w, grey, centeredRect);

% Draw the slider labels
DrawFormattedText(w, sliderLabels{1}, leftTextPosX, leftTextPosY, textColor);
DrawFormattedText(w, sliderLabels{2}, rightTextPosX, rightTextPosY, textColor);

img = imread(fullfile(folderPath, imageFileNames{1}));
  
imgWidth = size(img, 2);
imgHeight = size(img, 1); 
xPos = (wWidth - imgWidth) / 2;
yPos = (wHeight - imgHeight) / 2;
        
% Convert the image matrix to a Psychtoolbox texture
tex = Screen('MakeTexture', w, img);

% Display the image
Screen('DrawTexture', w, tex, [], [xPos yPos xPos+imgWidth yPos+imgHeight]);

% Flip the screen
Screen('Flip', w);
