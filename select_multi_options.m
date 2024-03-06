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

allRatings = zeros(60,1);
responseTimes = zeros(60, 1);

%% introduction %%
Screen('FillRect', w, backgroundColor); % clear visual buffer


DrawFormattedText(w, 'Before we begin, please close any unnecessary programs or applications on your computer.\nThis will help the study run more smoothly. Also, please close any\nbrowser tabs that could produce popups or alerts that would interfere with the study.\nFinally, once the study has started, DO NOT EXIT\nfullscreen mode or you will terminate the study and not recieve any payment.\nThe study will switch to fullscreen when you press the button below.\nWhen you are ready to begin, press the spacebar. ','center', 'center', textColor);
Screen('Flip', w) ;  % putting experiment instructions on screen
RestrictKeysForKbCheck(keyNumSpace) ; % disregard all keys except space
KbPressWait(-1); % wait till space is pressed

RestrictKeysForKbCheck([]); % goes back to regarding all keys

Screen('FillRect',w,backgroundColor); % overwrite text and start with new screen

%% Exposure %%

DrawFormattedText(w, 'To familiarize you with the set of snack foods in this study, we\n will now briefly show you each one.\n\n Please press the SPACEBAR to begin.','center', 'center', textColor);
Screen('Flip', w) ;  % putting experiment instructions on screen
RestrictKeysForKbCheck(keyNumSpace) ; % disregard all keys except space
KbPressWait(-1); % wait till space is pressed

RestrictKeysForKbCheck([]); % goes back to regarding all keys

Screen('FillRect',w,backgroundColor); % overwrite text and start with new screen
 
% Define the path to the folder containing images
folderPath = 'images/60foods';

% Get a list of all image files in the folder
imageFiles = ls(fullfile(folderPath, '*.jpg')); % Change '*.jpg' to match your image file format
%fileList = strsplit(imageFiles);
imageFileNames = cellstr(imageFiles);
%imageFileNames = imageFileNames(1:60);

% Set the duration to display each image (in seconds)
displayDuration = 0.75;

try
    % Loop through each image  file
    for i = 1:3
        % Load the image
        img = imread(fullfile(folderPath, imageFileNames{i}));
 
    %    imshow(img);
  
         imgWidth = size(img, 2);
         imgHeight = size(img, 1); 
         xPos = (wWidth - imgWidth) / 2;
         yPos = (wHeight - imgHeight) / 2;
%         
%         
%         % Convert the image matrix to a Psychtoolbox texture
         tex = Screen('MakeTexture', w, img);
%         
%         % Display the image in the center of the screen
         Screen('DrawTexture', w, tex, [], [xPos yPos xPos+imgWidth yPos+imgHeight]);
        Screen('Flip', w);
%         
%         % Pause for the specified duration
         WaitSecs(displayDuration);
%          
%         % Close the texture
         Screen('Close', tex);
    end 
    
catch
    % Close the Psychtoolbox window in case of an error
    sca
    psychrethrow(psychlasterror);
end


Screen('FillRect', w, backgroundColor);


%% RATINGS %%


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
blue = [173 216 230];
grey = [128 128 128];

% Here we set the initial position of the mouse to the centre of the screen
SetMouse(xCenter, sliderYpos, w);

% Make a base Rect relative to the size of the screen: this will be the
% toggle we can slide on the slider
dim = wHeight  / 30 ;
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

continueRectYpos = 0.9 * wHeight;
% Define rectangle parameters
rectWidth = 120; % Width of the rectangle
rectHeight = 40; % Height of the rectangle
topExtension = 5; % Extension length for top and bottom sides

% Calculate coordinates for top-left and bottom-right corners
topLeftX = xCenter - rectWidth/2;
topLeftY = yCenter - rectHeight/2 - topExtension;
bottomRightX = xCenter + rectWidth/2;
bottomRightY = yCenter + rectHeight/2 + topExtension;

continueRect = [topLeftX, topLeftY,  bottomRightX, bottomRightY];

continueRect = CenterRectOnPointd(continueRect, xCenter, continueRectYpos);


% Offset toggle. This determines if the offset between the mouse and centre
% of the square has been set. We use this so that we can move the position
% of the square around the screen without it "snapping" its centre to the
% position of the mouse
offsetSet = 0;

% Number of frames to wait before updating the screen
waitframes = 1;

% Define the range of numbers
rangeStart = 1;
rangeEnd = 60;

% Generate a random permutation of numbers from 1 to 60
randomizedArray = randperm(rangeEnd - rangeStart + 1) + rangeStart - 1;


%%%%%%%%%%%%%%% getting ratings
DrawFormattedText(w, 'Rating task', 'center', 'center', textColor); 
Screen('Flip', w) ;  % putting experiment instructions on screen
RestrictKeysForKbCheck(keyNumSpace) ; % disregard all keys except space
KbPressWait(-1); % wait till space is pressed

 
%% displaying ratings

for i = 1:3
    img = imread(fullfile(folderPath, imageFileNames{randomizedArray(i)}));

    imgWidth = size(img, 2);
    imgHeight = size(img, 1);
    xPosR = (wWidth - imgWidth) / 2;
    yPosR = (wHeight - imgHeight) / 2;

    % Convert the image matrix to a Psychtoolbox texture
    texR = Screen('MakeTexture', w, img);

    % Sync us and get a time stamp. We blank the window first to remove the
    % text that we drew to get the bounding boxes.
    Screen('FillRect', w, backgroundColor)
    vbl = Screen('Flip', w);

    mousePressed = true; 
    sx = xCenter + (rand * 2 - 1) * sliderHLengthPix;
    centeredRect = CenterRectOnPointd(baseRect, sx, sliderYpos);


    while mousePressed

        % Get the current position of the mouse

        [mx, my, buttons] = GetMouse(w);


        % Find the central position of the square
        [cx, cy] = RectCenter(centeredRect);
        

        % See if the mouse cursor is inside the square 
        inside = IsInRect(mx, my, centeredRect);

        % If the mouse cursor is inside the square and a mouse button is being
        % pressed and the offset has not been set, set the offset and signal
        % that it has been set
        if inside == 1 && sum(buttons) > 0 && offsetSet == 0
            dx = mx - cx;
            offsetSet = 1;
        end

        % If the person has clicked, yoke the square to the mouse cursor in its
        % x dimension
        if offsetSet
            sx = mx - dx;
        end

        % Restrict the x position to be on the slider 
        if sx > xCenter + sliderHLengthPix
            sx = xCenter + sliderHLengthPix;
        elseif sx < xCenter - sliderHLengthPix
            sx = xCenter - sliderHLengthPix;
        end

        % Center the slidre toggle on its new screen position
        centeredRect = CenterRectOnPointd(baseRect, sx, sliderYpos);

        % Draw the slider line
        Screen('DrawLines', w, sliderLineCoords, sliderLineWidth, grey);

        % Draw the rect to the screen
        Screen('FillRect', w, grey, centeredRect);

        Screen('FillRect', w, blue, continueRect);


        % Text for the ends of the slider
        DrawFormattedText(w, 'Continue', 'center', 'center',textColor, [], [], [], [], [], continueRect);
        DrawFormattedText(w, sliderLabels{1}, leftTextPosX, leftTextPosY, textColor);
        DrawFormattedText(w, sliderLabels{2}, rightTextPosX, rightTextPosY, textColor);

        % Display the image in the center of the screen
        Screen('DrawTexture', w, texR, [], [xPosR yPosR xPosR+imgWidth yPosR+imgHeight]);


        % Flip to the screen
        vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);

        % Check to see if the mouse button has been released and if so reset
        % the offset cue
        if sum(buttons) <= 0
            offsetSet = 0;
        end

        if IsInRect(mx, my, continueRect)
            if buttons(1) == 1
                buttonPress = GetSecs;
                currentRating = (sx - (xCenter - sliderHLengthPix)) / sliderLengthPix;
                allRatings(i) = currentRating;
                responseTimes(i) = GetSecs - vbl;
                WaitSecs(0.2); 
                mousePressed = false;
            end
        end


    end
    

end


%% select 3 out of 4 options
DrawFormattedText(w, 'Selecting 3 options', 'center', 'center', textColor); 
Screen('Flip', w) ;  % putting experiment instructions on screen
RestrictKeysForKbCheck(keyNumSpace) ; % disregard all keys except space
KbPressWait(-1); % wait till space is pressed

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

black = [0 0 0];

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
Screen('DrawLines', w, allCoords,...
    lineWidthPix, black, [xCenter yCenter], 2);

% Flip to the screen
Screen('Flip', w);
WaitSecs(0.4);

% selects 4 images to display
rand4Img = randi([1, 60], 1, 4);

% creating rects for the 4 images

% top image
topImg = imread(fullfile(folderPath, imageFileNames{rand4Img(1)}));
[oTopImgHeight, oTopImgWidth, ~] = size(topImg);
topImgHeight = round(oTopImgHeight * 0.5);
topImgWidth = round(oTopImgWidth * 0.5);
newSize = [topImgHeight, topImgWidth];
topImg = imresize(topImg, newSize);

topTex = Screen('MakeTexture', w, topImg);
topXpos = (wWidth - topImgWidth) / 2;
topYpos = 0.07 *wHeight;
topRect = [topXpos topYpos topXpos+topImgWidth topYpos+topImgHeight];

% right image

% bottom image
botImg = imread(fullfile(folderPath, imageFileNames{rand4Img(3)}));
[oBotImgHeight, oBotImgWidth, ~] = size(botImg);
botImgHeight = round(oBotImgHeight * 0.5);
botImgWidth = round(oBotImgWidth * 0.5);
newSize = [botImgHeight, botImgWidth];
botImg = imresize(botImg, newSize);

botTex = Screen('MakeTexture', w, botImg);
botXpos = (wWidth - botImgWidth) / 2;
botYpos = 0.7*wHeight;
botRect = [botXpos botYpos botXpos+botImgWidth botYpos+botImgHeight];


% left image


% drawing all the images
Screen('DrawTextures', w, topTex, [], topRect);
Screen('DrawTextures', w, botTex, [], botRect);
Screen('Flip', w); 
WaitSecs(3);
   
%% EXIT %%

% displaying thank you screen
Screen('FillRect', w, backgroundColor);
DrawFormattedText(w, 'Thank you!', 'center', 'center', textColor ); 
Screen('Flip', w);
RestrictKeysForKbCheck(keyNumSpace) ; % disregard all keys except space
KbPressWait(-1); % wait till space is pressed

sca % close psychtoolbox windows
ListenChar(1); % restore keyboard input




