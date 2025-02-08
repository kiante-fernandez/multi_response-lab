%% MULTI-RESPONSE VALUE-BASED DECSION MAKING TASK%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script runs an four alternative forced choice task to measure
% choose (k) selections while gathering eye tracking data
%
%
% Authors: Sumedha Goyal & Kianté Fernandez (kiante@ucla.edu)
% Last modified: 2025-Feb-07
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all   % clear variables and other settings
clc         % clear command window
rng shuffle % seed random number generator based on clock time
close all   % close figure windows
sca         % close Psychtoolbox windows

subjectNumber = input('Enter subject number: ');

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
keyNumJ = min(KbName('j'));
keyNumI = min(KbName('i'));
keyNumL = min(KbName('l'));
keyNumK = min(KbName('k'));
escKey = KbName('ESCAPE');

greycol = [128 128 128];

% Initialize image numbers
imageNumbers = (1:60)';

% Initialize empty arrays for ratings and response times
allRatings = zeros(60,1);
responseTimes = zeros(60, 1);

% Create the table
dataTable = table(imageNumbers, allRatings, responseTimes);

% if you want to do eye tracking, set this to one, otherwise, set it to
% 0
global trackEye;
trackEye = 0;
trialN = 60; % number of trials

%% Eye Tracking Setup
if trackEye == 1
    % initialize the defaults
    el = EyelinkInitDefaults(w);

    % Initialization of the connection with the Eyelink Gazetracker.
    if ~EyelinkInit(0)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function defined at the end
        return;
    end

    % Name the EDF file
    edfFile = ['S' num2str(subjectNumber) '.edf'];

    % Open file to record data to
    status = Eyelink('OpenFile', edfFile);
    if status ~= 0
        fprintf('OpenFile error, status: %d\n', status);
        cleanup;
        return;
    end

    % make sure we're still connected.
    if Eyelink('IsConnected')~=1
        cleanup;
        return;
    end

    % Set up tracker configuration
    Eyelink('command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, wWidth-1, wHeight-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, wWidth-1, wHeight-1);
    Eyelink('command', 'calibration_type = HV9');
    % Set EDF file contents
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');

    % Set display colors
    el.backgroundcolour = backgroundColor;
    el.foregroundcolour = textColor;
    el.calibrationtargetcolour = textColor;
    el.calibrationtargetsize = 1;
    el.calibrationtargetwidth = 0.5;
    EyelinkUpdateDefaults(el);

    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);

    % Create eye data file
    eyeFile = fopen(['eyeData_' num2str(subjectNumber) '.txt'], 'w');
    fprintf(eyeFile, 'Block\tTrial\tTime\tROI\tFixDur\n');
    % Get eye that's tracked
    eye_used = Eyelink('EyeAvailable');
    if eye_used == el.BINOCULAR
        eye_used = el.LEFT_EYE;
    end

end

%% introduction %%
Screen('FillRect', w, backgroundColor); % clear visual buffer

textPrompt1 = 'Welcome to the study!\n\nToday, you will make some decisions about foods.\n\nThere will be multiple parts to the study, and you will receive instructions before each new part.\n\nIf you have any questions, please contact the experimenter at kiante@ucla.edu. If you are ready to begin, please press the SPACEBAR.'
DrawFormattedText(w, textPrompt1, 'center', 'center', textColor);
Screen('Flip', w) ;  % putting experiment instructions on screen
RestrictKeysForKbCheck(keyNumSpace) ; % disregard all keys except space
KbPressWait(-1); % wait till space is pressed

RestrictKeysForKbCheck([]); % goes back to regarding all keys

Screen('FillRect',w,backgroundColor); % overwrite text and start with new screen

%% Exposure %%

% ask if we need the names of each food?
DrawFormattedText(w, 'To familiarize you with the set of snack foods in this study, we\n will now briefly show you each one.\n\n Please press the SPACEBAR to begin.','center', 'center', textColor);
Screen('Flip', w) ;  % putting experiment instructions on screen
RestrictKeysForKbCheck(keyNumSpace) ; % disregard all keys except space
KbPressWait(-1); % wait till space is pressed

RestrictKeysForKbCheck([]); % goes back to regarding all keys

Screen('FillRect',w,backgroundColor); % overwrite text and start with new screen

% Define the path to the folder containing images
folderPath = 'images/60foods';

% Get a list of all image files in the folder
% imageFiles = ls(fullfile(folderPath, '*.jpg'));
% imageFileNames = cellstr(imageFiles);
imageFiles = dir(fullfile(folderPath, '*.jpg'));
imageFileNames = {imageFiles.name};

% Set the duration to display each image (in seconds)
displayDuration = 0.75;

try
    % Loop through each image  file
    for i = 1:trialN
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
DrawFormattedText(w, 'Rating task\n\nNow you will make decisions about each snack food one by one.\nFor each snack food, please rate it on a scale from "Not at all" to "Very much" based on how much you would like this as a daily snack.\nA "Not at all" means that you would neither like nor dislike to eat this food.\nA "Very much" means that you would really love to eat this food.\nTo rate an item, use the mouse to click anywhere along the slider scale. When you have rated an item, press continue to move to proceed.\n\nWhen you are ready, press the SPACEBAR to start.', 'center', 'center', textColor);
Screen('Flip', w) ;  % putting experiment instructions on screen
RestrictKeysForKbCheck(keyNumSpace) ; % disregard all keys except space
KbPressWait(-1); % wait till space is pressed


%% displaying ratings

for i = 1:trialN
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

        % Center the slider toggle on its new screen position
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

%% CHOICE TASK SETUP
% Task parameters
nTrialsPerBlock = 100;
nBlocks = 3;
blockTypes = {'choose1', 'choose2', 'choose3'};
blockOrder = randperm(nBlocks); % Randomize block order

% Initialize data tables for each block type
trials = (1:nTrialsPerBlock)';
firstFood = zeros(nTrialsPerBlock, 1);
firstResponse = zeros(nTrialsPerBlock, 1);
secondFood = zeros(nTrialsPerBlock, 1);
secondResponse = zeros(nTrialsPerBlock, 1);
thirdFood = zeros(nTrialsPerBlock, 1);
thirdResponse = zeros(nTrialsPerBlock, 1);

% Create tables for each block type
choose1Data = table(trials, firstFood, firstResponse);
choose2Data = table(trials, firstFood, firstResponse, secondFood, secondResponse);
choose3Data = table(trials, firstFood, firstResponse, secondFood, secondResponse, thirdFood, thirdResponse);

% Setup fixation cross
fixCrossDimPix = 40;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
lineWidthPix = 4;
% Add these color definitions
black = [0 0 0];
orange = [255 95 31];

%% MAIN TASK LOOP
% Define the size of the matrix
rows = 100; % Changed for 100 trials per block
cols = 4;
total_elements = rows * cols;

% Generate a pool of unique numbers from 1 to 60
num_pool = repmat(1:60, 1, ceil(total_elements/60));
num_pool = num_pool(randperm(length(num_pool)));

% Create matrix for 4-option trials
% Prevent double use of images!
% Fill each column with unique numbers
rand4Img = zeros(nTrialsPerBlock, 4);
for trial = 1:nTrialsPerBlock
    rand4Img(trial, :) = randperm(60, 4);
end

for block = 1:nBlocks
    currentBlockType = blockTypes{blockOrder(block)};
    disp(['Starting Block ' num2str(block) ' of ' num2str(nBlocks) ': ' currentBlockType]);

    blockNum = ones(nTrialsPerBlock, 1) * block;
    choose1Data.blockNum = blockNum;
    choose2Data.blockNum = blockNum;
    choose3Data.blockNum = blockNum;

    if trackEye == 1
        % Perform drift check at start of block
        EyelinkDoDriftCorrection(el);
    end

    % After drift correction, before instructions:
    if trackEye == 1
        Eyelink('Message', 'BLOCK_START_%d', block);
        Eyelink('Message', 'BLOCK_TYPE_%s', currentBlockType);
    end

    % Display block instructions
    instructStr = '';
    switch currentBlockType
        case 'choose1'
            instructStr = ['Food Choice Task: Choose One\n\n' ...
                'In this block, you will select ONE food you''d most like to eat.\n\n' ...
                'Use these keys to select foods:\n' ...
                'J key - Left food\n' ...
                'I key - Top food\n' ...
                'L key - Right food\n' ...
                'K key - Bottom food\n\n' ...
                'Selected food will have an orange outline.\n\n' ...
                'Press SPACE to begin.'];
        case 'choose2'
            instructStr = ['Food Choice Task: Choose Two\n\n' ...
                'In this block, you will select TWO foods you''d most like to eat.\n\n' ...
                'Use these keys to select foods:\n' ...
                'J key - Left food\n' ...
                'I key - Top food\n' ...
                'L key - Right food\n' ...
                'K key - Bottom food\n\n' ...
                'Selected foods will have an orange outline.\n' ...
                'Once you select a food, you cannot deselect it.\n\n' ...
                'Press SPACE to begin.'];
        case 'choose3'
            instructStr = ['Food Choice Task: Choose Three\n\n' ...
                'In this block, you will select THREE foods you''d most like to eat.\n\n' ...
                'Use these keys to select foods:\n' ...
                'J key - Left food\n' ...
                'I key - Top food\n' ...
                'L key - Right food\n' ...
                'K key - Bottom food\n\n' ...
                'Selected foods will have an orange outline.\n' ...
                'Once you select a food, you cannot deselect it.\n\n' ...
                'Press SPACE to begin.'];
    end

    DrawFormattedText(w, instructStr, 'center', 'center', textColor);
    Screen('Flip', w);
    KbStrokeWait;

    % Run trials for current block
    for trial = 1:nTrialsPerBlock
        % Show fixation cross
        Screen('DrawLines', w, allCoords, lineWidthPix, black, [xCenter yCenter], 2);
        Screen('Flip', w);
        WaitSecs(0.4);
        trialStart = tic;
        if trackEye == 1
            err = Eyelink('CheckRecording');
            if err ~= 0
                error('Problem with recording: %d', err);
            end
        end
        % Prepare images for this trial
        % Load and prepare the 4 images
        topImg = imread(fullfile(folderPath, imageFileNames{rand4Img(trial, 2)}));
        rightImg = imread(fullfile(folderPath, imageFileNames{rand4Img(trial, 3)}));
        botImg = imread(fullfile(folderPath, imageFileNames{rand4Img(trial, 4)}));
        leftImg = imread(fullfile(folderPath, imageFileNames{rand4Img(trial, 1)}));

        % Resize and create textures
        try
            [images, rects] = prepareImages(w, topImg, rightImg, botImg, leftImg, wWidth, wHeight);
        catch
            sca;
            psychrethrow(psychlasterror);
        end
        % Eye tracking trial setup
        if trackEye == 1
            lastROI = 0;
            fixStartTime = GetSecs();
            if trial == 1
                blockStartTime = GetSecs();
            end

            % Start recording
            Eyelink('command', 'record_status_message "TRIAL %d/%d"', trial, nTrialsPerBlock);
            Eyelink('StartRecording');
            WaitSecs(0.1);

            Eyelink('Message', 'BLOCK_%d_TRIAL_%d', block, trial);
            Eyelink('Message', 'TRIAL_CONDITION_%s', currentBlockType);

            % Mark trial start
            Eyelink('Message', 'TRIALID %d', trial);

            % Define ROIs
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, rects.leftRect(1), rects.leftRect(2), rects.leftRect(3), rects.leftRect(4), 'left');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 2, rects.topRect(1), rects.topRect(2), rects.topRect(3), rects.topRect(4), 'top');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 3, rects.rightRect(1), rects.rightRect(2), rects.rightRect(3), rects.rightRect(4), 'right');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 4, rects.botRect(1), rects.botRect(2), rects.botRect(3), rects.botRect(4), 'bottom');
        end

        % Draw initial image display
        % Screen('DrawTextures', w, [images.topTex, images.botTex, images.rightTex, images.leftTex], [], ...
        %     [rects.topRect; rects.botRect; rects.rightRect; rects.leftRect]');
        Screen('DrawTextures', w, [images.leftTex, images.topTex, images.rightTex, images.botTex], [], ...
            [rects.leftRect; rects.topRect; rects.rightRect; rects.botRect]');
        Screen('Flip', w);

        % Initialize response collection
        response = 0;
        keyPressed = zeros(1, 4);
        nRequired = str2double(currentBlockType(end)); % Get number of required choices
        nSelected = 0;

        % Collect responses
        while nSelected < nRequired
            % Add eye tracking sample collection here
            if trackEye == 1
                if Eyelink('NewFloatSampleAvailable') > 0
                    % Get the sample in the form of an event structure
                    evt = Eyelink('NewestFloatSample');
                    if evt.gx(eye_used+1) ~= el.MISSING_DATA && evt.gy(eye_used+1) ~= el.MISSING_DATA
                        eyeX = evt.gx(eye_used+1);
                        eyeY = evt.gy(eye_used+1);

                        % Check which ROI the gaze is in
                        currentROI = 0;
                        if IsInRect(eyeX, eyeY, rects.leftRect)
                            currentROI = 1;
                        elseif IsInRect(eyeX, eyeY, rects.topRect)
                            currentROI = 2;
                        elseif IsInRect(eyeX, eyeY, rects.rightRect)
                            currentROI = 3;
                        elseif IsInRect(eyeX, eyeY, rects.botRect)
                            currentROI = 4;
                        end

                        % Record fixation data
                        if currentROI ~= lastROI
                            fixEndTime = GetSecs();
                            if lastROI > 0
                                fixDur = fixEndTime - fixStartTime;
                                fprintf(eyeFile, '%d\t%d\t%.3f\t%d\t%.3f\n', ...
                                    block, trial, fixStartTime - blockStartTime, lastROI, fixDur);
                            end
                            if currentROI > 0
                                fixStartTime = fixEndTime;
                            end
                            lastROI = currentROI;
                        end
                    end
                end
            end
            % Check for key press
            [keyIsDown, secs, keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(keyNumJ) && ~keyPressed(1)
                    keyPressed(1) = 1;
                    nSelected = nSelected + 1;
                    % Record response based on block type
                    switch nSelected
                        case 1
                            firstFood = rand4Img(trial, 1);
                            firstResponse = toc(trialStart);
                        case 2
                            secondFood = rand4Img(trial, 1);
                            secondResponse = toc(trialStart);
                        case 3
                            thirdFood = rand4Img(trial, 1);
                            thirdResponse = toc(trialStart);
                    end
                elseif keyCode(keyNumI) && ~keyPressed(2)
                    keyPressed(2) = 1;
                    nSelected = nSelected + 1;
                    % Record response based on block type
                    switch nSelected
                        case 1
                            firstFood = rand4Img(trial, 2);  % Note: 2 for top image
                            firstResponse = toc(trialStart);
                        case 2
                            secondFood = rand4Img(trial, 2);
                            secondResponse = toc(trialStart);
                        case 3
                            thirdFood = rand4Img(trial, 2);
                            thirdResponse = toc(trialStart);
                    end
                elseif keyCode(keyNumL) && ~keyPressed(3)
                    keyPressed(3) = 1;
                    nSelected = nSelected + 1;
                    % Record response based on block type
                    switch nSelected
                        case 1
                            firstFood = rand4Img(trial, 3);  % Note: 3 for right image
                            firstResponse = toc(trialStart);
                        case 2
                            secondFood = rand4Img(trial, 3);
                            secondResponse = toc(trialStart);
                        case 3
                            thirdFood = rand4Img(trial, 3);
                            thirdResponse = toc(trialStart);
                    end
                elseif keyCode(keyNumK) && ~keyPressed(4)
                    keyPressed(4) = 1;
                    nSelected = nSelected + 1;
                    % Record response based on block type
                    switch nSelected
                        case 1
                            firstFood = rand4Img(trial, 4);  % Note: 4 for bottom image
                            firstResponse = toc(trialStart);
                        case 2
                            secondFood = rand4Img(trial, 4);
                            secondResponse = toc(trialStart);
                        case 3
                            thirdFood = rand4Img(trial, 4);
                            thirdResponse = toc(trialStart);
                    end
                elseif keyCode(escKey)
                    ListenChar(0);
                    sca;
                    error('User terminated script with ESCAPE key.');
                end

                % Redraw images with selected items highlighted
                % Screen('DrawTextures', w, [images.topTex, images.botTex, images.rightTex, images.leftTex], [], ...
                %     [rects.topRect; rects.botRect; rects.rightRect; rects.leftRect]');
                Screen('DrawTextures', w, [images.leftTex, images.topTex, images.rightTex, images.botTex], [], ...
                    [rects.leftRect; rects.topRect; rects.rightRect; rects.botRect]');

                % Draw orange frames around selected images
                if keyPressed(1)
                    Screen('FrameRect', w, orange, rects.leftRect, 4);
                end
                if keyPressed(2)
                    Screen('FrameRect', w, orange, rects.topRect, 4);
                end
                if keyPressed(3)
                    Screen('FrameRect', w, orange, rects.rightRect, 4);
                end
                if keyPressed(4)
                    Screen('FrameRect', w, orange, rects.botRect, 4);
                end

                Screen('Flip', w);
                WaitSecs(0.3); % Brief pause after selection
            end
        end

        % Store trial data based on block type
        switch currentBlockType
            case 'choose1'
                choose1Data.firstFood(trial) = firstFood;
                choose1Data.firstResponse(trial) = firstResponse;
            case 'choose2'
                choose2Data.firstFood(trial) = firstFood;
                choose2Data.firstResponse(trial) = firstResponse;
                choose2Data.secondFood(trial) = secondFood;
                choose2Data.secondResponse(trial) = secondResponse;
            case 'choose3'
                choose3Data.firstFood(trial) = firstFood;
                choose3Data.firstResponse(trial) = firstResponse;
                choose3Data.secondFood(trial) = secondFood;
                choose3Data.secondResponse(trial) = secondResponse;
                choose3Data.thirdFood(trial) = thirdFood;
                choose3Data.thirdResponse(trial) = thirdResponse;
        end
        % Eye tracking cleanup
        if trackEye == 1
            % Record final fixation of trial
            if lastROI > 0
                fixDur = GetSecs() - fixStartTime;
                fprintf(eyeFile, '%d\t%d\t%.3f\t%d\t%.3f\n', ...
                    block, trial, fixStartTime - blockStartTime, lastROI, fixDur);
            end
            Eyelink('StopRecording');
        end
        % Clean up textures
        Screen('Close', [images.topTex, images.botTex, images.rightTex, images.leftTex]);

        % Break every 50 trials
        if mod(trial, 50) == 0 && trial < nTrialsPerBlock
            DrawFormattedText(w, ['You may take a short break.\n\n' ...
                'Press SPACE when you are ready to continue.'], 'center', 'center', textColor);
            Screen('Flip', w);
            KbStrokeWait;
        end
    end
end
% Save data
try
    %    save(['Subject_' num2str(subjectNumber) '_BlockData.mat'], 'choose1Data', 'choose2Data', 'choose3Data');
    save(['Subject_' num2str(subjectNumber) '_Data.mat'], 'dataTable', 'choose1Data', 'choose2Data', 'choose3Data');
catch
    warning('Could not save data file. Check permissions and disk space.');
end

%% EXIT %%
% displaying thank you screen
Screen('FillRect', w, backgroundColor);
DrawFormattedText(w, 'Thank you!', 'center', 'center', textColor);
Screen('Flip', w);
RestrictKeysForKbCheck(keyNumSpace); % disregard all keys except space
KbPressWait(-1); % wait till space is pressed

if trackEye == 1
    fclose(eyeFile);
    Eyelink('CloseFile');
    Eyelink('ReceiveFile');
    Eyelink('ShutDown');
end

sca % close Psychtoolbox windows
ListenChar(1); % restore keyboard input

%% Helper function to prepare images
function [images, rects] = prepareImages(w, topImg, rightImg, botImg, leftImg, wWidth, wHeight)
% Resize images
[images.top, rects.topRect] = resizeImage(topImg, wWidth, wHeight, 'top');
[images.right, rects.rightRect] = resizeImage(rightImg, wWidth, wHeight, 'right');
[images.bot, rects.botRect] = resizeImage(botImg, wWidth, wHeight, 'bottom');
[images.left, rects.leftRect] = resizeImage(leftImg, wWidth, wHeight, 'left');

% Create textures
images.topTex = Screen('MakeTexture', w, images.top);
images.rightTex = Screen('MakeTexture', w, images.right);
images.botTex = Screen('MakeTexture', w, images.bot);
images.leftTex = Screen('MakeTexture', w, images.left);
end

function [resizedImg, rect] = resizeImage(img, wWidth, wHeight, position)
scaleFactor = 0.5;
[oHeight, oWidth, ~] = size(img);
newHeight = round(oHeight * scaleFactor);
newWidth = round(oWidth * scaleFactor);
resizedImg = imresize(img, [newHeight newWidth]);

% Position-specific rectangles
switch position
    case 'top'
        xPos = (wWidth - newWidth) / 2;
        yPos = 0.07 * wHeight;
    case 'right'
        xPos = 0.7 * wWidth;
        yPos = (wHeight - newHeight) / 2;
    case 'bottom'
        xPos = (wWidth - newWidth) / 2;
        yPos = 0.7 * wHeight;
    case 'left'
        xPos = 0.2 * wWidth;
        yPos = (wHeight - newHeight) / 2;
end

rect = [xPos yPos xPos+newWidth yPos+newHeight];
end

function cleanup
% Cleanup function to handle errors
sca;
global trackEye;

if trackEye == 1
    Eyelink('ShutDown');
end
ListenChar(1);
end
