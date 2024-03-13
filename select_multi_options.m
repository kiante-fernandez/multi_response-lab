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
keyNumJ = min(KbName('j'));
keyNumI = min(KbName('i'));
keyNumL = min(KbName('l'));
keyNumK = min(KbName('k'));


% Initialize image numbers
imageNumbers = (1:60)';

% Initialize empty arrays for ratings and response times
allRatings = zeros(60,1);
responseTimes = zeros(60, 1);

% Create the table
dataTable = table(imageNumbers, allRatings, responseTimes);

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
    currentImg = randomizedArray(i);
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
    %  maybe use tick tock here
    tStart = tic;

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
                dataTable.allRatings(currentImg) = currentRating;
                % to-do - make sure the image id is being collected along
                % with the rating and response time
                dataTable.responseTimes(currentImg) = toc(tStart);
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

orange = [255 95 31];

% selects 4 images to display
% Define the size of the matrix
rows = 50;
cols = 4;
total_elements = rows * cols;

% Generate a pool of unique numbers from 1 to 60
num_pool = repmat(1:60, 1, ceil(total_elements/60));
num_pool = num_pool(randperm(length(num_pool)));

% Create an empty matrix to store the numbers
rand4Img = zeros(rows, cols);

% Fill each column with unique numbers
for j = 1:cols
    % Determine the start and end indices for the current column
    start_idx = (j - 1) * rows + 1;
    end_idx = min(j * rows, length(num_pool));
    
    % Assign unique numbers to the current column
    rand4Img(:, j) = num_pool(start_idx:end_idx)';
end

% Ensure each row contains unique numbers
for i = 1:rows
    % Get unique numbers in the current row
    unique_numbers = unique(rand4Img(i, :));
    
    % If the number of unique numbers is less than 4, fill the row
    if numel(unique_numbers) < 4
        % Numbers that are already present in the row
        present_numbers = unique_numbers(unique_numbers ~= 0);
        
        % Numbers that are not present in the row
        available_numbers = setdiff(1:60, present_numbers);
        
        % Shuffle the available numbers
        available_numbers = available_numbers(randperm(length(available_numbers)));
        
        % Fill the remaining slots in the row with unique numbers
        remaining_slots = 4 - numel(present_numbers);
        rand4Img(i, (end-remaining_slots+1):end) = available_numbers(1:remaining_slots);
    end
end


% Initialize empty arrays for ratings and response times
trials = (1:50)';
firstFood = zeros(50, 1);
firstResponse = zeros(50, 1);
secondFood = zeros(50, 1);
secondResponse = zeros(50, 1);

% Create the table
selectDataTable = table(trials, firstFood, firstResponse, secondFood, secondResponse);

% rand4Img is a matrix where the columns are the items and each row is a
% trial (100 rows x 4 columns)
% should come from some function that takes the most liked images but for
% now, an image shouldn't be shown more than 4 times

for i=1:3

    % showing fixation cross
    Screen('DrawLines', w, allCoords,...
        lineWidthPix, black, [xCenter yCenter], 2);

    % Flip to the screen
    Screen('Flip', w);
    WaitSecs(0.4);
    selectStart = tic;

    % creating rects for the 4 images

    % top image
    topImg = imread(fullfile(folderPath, imageFileNames{rand4Img(i, 2)}));
    [oTopImgHeight, oTopImgWidth, ~] = size(topImg);
    topImgHeight = round(oTopImgHeight * 0.5);
    topImgWidth = round(oTopImgWidth * 0.5);
    newSizeT = [topImgHeight, topImgWidth];
    topImg = imresize(topImg, newSizeT);

    topTex = Screen('MakeTexture', w, topImg);
    topXpos = (wWidth - topImgWidth) / 2;
    topYpos = 0.07*wHeight;
    topRect = [topXpos topYpos topXpos+topImgWidth topYpos+topImgHeight];

    % right image
    rightImg = imread(fullfile(folderPath, imageFileNames{rand4Img(i, 3)}));
    [oRightImgHeight, oRightImgWidth, ~] = size(rightImg);
    rightImgHeight = round(oRightImgHeight * 0.5);
    rightImgWidth = round(oRightImgWidth * 0.5);
    newSizeR = [rightImgHeight, rightImgWidth];
    rightImg = imresize(rightImg, newSizeR);

    rightTex = Screen('MakeTexture', w, rightImg);
    rightXpos = 0.7*wWidth;
    rightYpos = (wHeight - rightImgHeight) / 2;
    rightRect = [rightXpos rightYpos rightXpos+rightImgWidth rightYpos+rightImgHeight];

    % bottom image
    botImg = imread(fullfile(folderPath, imageFileNames{rand4Img(i, 4)}));
    [oBotImgHeight, oBotImgWidth, ~] = size(botImg);
    botImgHeight = round(oBotImgHeight * 0.5);
    botImgWidth = round(oBotImgWidth * 0.5);
    newSizeB = [botImgHeight, botImgWidth];
    botImg = imresize(botImg, newSizeB);

    botTex = Screen('MakeTexture', w, botImg);
    botXpos = (wWidth - botImgWidth) / 2;
    botYpos = 0.7*wHeight;
    botRect = [botXpos botYpos botXpos+botImgWidth botYpos+botImgHeight];


    % left image
    leftImg = imread(fullfile(folderPath, imageFileNames{rand4Img(i, 1)}));
    [oLeftImgHeight, oLeftImgWidth, ~] = size(leftImg);
    leftImgHeight = round(oLeftImgHeight * 0.5);
    leftImgWidth = round(oLeftImgWidth * 0.5);
    newSizeL = [leftImgHeight, leftImgWidth];
    leftImg = imresize(leftImg, newSizeL);

    leftTex = Screen('MakeTexture', w, leftImg);
    leftXpos = 0.2*wWidth;
    leftYpos = (wHeight - leftImgHeight) / 2;
    leftRect = [leftXpos leftYpos leftXpos+leftImgWidth leftYpos+leftImgHeight];


    % drawing all the images
    Screen('DrawTextures', w, topTex, [], topRect);
    Screen('DrawTextures', w, botTex, [], botRect);
    Screen('DrawTextures', w, rightTex, [], rightRect);
    Screen('DrawTextures', w, leftTex, [], leftRect);
    Screen('Flip', w);


    keyPressed = zeros(1, 4);
    % J = 1, I = 2, L = 3, K = 4
    % J = left, I = top, L = right, K = bottom

    RestrictKeysForKbCheck([keyNumJ keyNumI keyNumL keyNumK]);

    % checks first key press

    keyCode = zeros(1, 256);
    while ~keyCode(keyNumJ) && ~keyCode(keyNumI) && ~keyCode(keyNumL) && ~keyCode(keyNumK)
        [~, ~, keyCode] = KbCheck(-1);
    end
    
    selectEnd = toc(selectStart);
    selectDataTable.firstResponse(i) = selectEnd;
    if keyCode(keyNumJ)
        keyPressed(1) = 1;
        selectDataTable.firstFood(i) = rand4Img(i, 1);
        Screen('DrawTextures', w, topTex, [], topRect);
        Screen('DrawTextures', w, botTex, [], botRect);
        Screen('DrawTextures', w, rightTex, [], rightRect);
        Screen('DrawTextures', w, leftTex, [], leftRect);
        Screen('FrameRect', w, orange, leftRect, 4);
        Screen('Flip', w);
    elseif keyCode(keyNumI)
        keyPressed(2) = 1;
        selectDataTable.firstFood(i) = rand4Img(i, 2);
        Screen('DrawTextures', w, topTex, [], topRect);
        Screen('DrawTextures', w, botTex, [], botRect);
        Screen('DrawTextures', w, rightTex, [], rightRect);
        Screen('DrawTextures', w, leftTex, [], leftRect);
        Screen('FrameRect', w, orange, topRect, 4);
        Screen('Flip', w);
    elseif keyCode(keyNumL)
        keyPressed(3) = 1;
        selectDataTable.firstFood(i) = rand4Img(i, 3);
        Screen('DrawTextures', w, topTex, [], topRect);
        Screen('DrawTextures', w, botTex, [], botRect);
        Screen('DrawTextures', w, rightTex, [], rightRect);
        Screen('DrawTextures', w, leftTex, [], leftRect);
        Screen('FrameRect', w, orange, rightRect, 4);
        Screen('Flip', w);
    elseif keyCode(keyNumK)
        keyPressed(4) = 1;
        selectDataTable.firstFood(i) = rand4Img(i, 4);
        Screen('DrawTextures', w, topTex, [], topRect);
        Screen('DrawTextures', w, botTex, [], botRect);
        Screen('DrawTextures', w, rightTex, [], rightRect);
        Screen('DrawTextures', w, leftTex, [], leftRect);
        Screen('FrameRect', w, orange, botRect, 4);
        Screen('Flip', w);
    end
    
    select2Start = tic;
    RestrictKeysForKbCheck([]);
    KbReleaseWait;

    excludeKey = find(keyPressed);
    restrictedKeys = [keyNumJ keyNumI keyNumL keyNumK];
    restrictedKeys(excludeKey) = [];

    keyCode2 = zeros(1, 256);
    RestrictKeysForKbCheck(restrictedKeys);
    while ~any(keyCode2(restrictedKeys))
        [~, ~, keyCode2] = KbCheck(-1);
    end
    select2End = toc(select2Start);
    selectDataTable.secondResponse(i) = select2End;
    if keyCode2(keyNumJ) && ~keyPressed(1)
        keyPressed(1) = 1;
        selectDataTable.secondFood(i) = rand4Img(i, 1);
    elseif keyCode2(keyNumI) && ~keyPressed(2)
        keyPressed(2) = 1;
        selectDataTable.secondFood(i) = rand4Img(i, 2);
    elseif keyCode2(keyNumL) && ~keyPressed(3)
        keyPressed(3) = 1;
        selectDataTable.secondFood(i) = rand4Img(i, 3);
    elseif keyCode2 (keyNumK) && ~keyPressed(4)
        keyPressed(4) = 1;
        selectDataTable.secondFood(i) = rand4Img(i, 4);
    end

    Screen('DrawTextures', w, topTex, [], topRect);
    Screen('DrawTextures', w, botTex, [], botRect);
    Screen('DrawTextures', w, rightTex, [], rightRect);
    Screen('DrawTextures', w, leftTex, [], leftRect);

    if keyPressed(1)
        Screen('FrameRect', w, orange, leftRect, 4);
    end
    if keyPressed(2)
        Screen('FrameRect', w, orange, topRect, 4);
    end
    if keyPressed(3)
        Screen('FrameRect', w, orange, rightRect, 4);
    end
    if keyPressed(4)
        Screen('FrameRect', w, orange, botRect, 4);
    end

    Screen('Flip', w);
    WaitSecs(0.3);

end
%% EXIT %%

% displaying thank you screen
Screen('FillRect', w, backgroundColor);
DrawFormattedText(w, 'Thank you!', 'center', 'center', textColor); 
Screen('Flip', w);
RestrictKeysForKbCheck(keyNumSpace); % disregard all keys except space
KbPressWait(-1); % wait till space is pressed

sca % close psychtoolbox windows
ListenChar(1); % restore keyboard input




