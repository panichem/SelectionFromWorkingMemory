%This is the master script used for presenting behavioral stimuli and
%recording responses in the task described in Figure 1a of Panichello &
%Buschman, 2021
%
%Due to the very large number of dependencies, it is not practical to run
%this code on machines outside the experimental rig, but we hope it
%nevertheless makes our method more transparent 
%
%% Define parameters
sca; clear all; close all; clc;
rng('shuffle');


dev = daq.getDevices;
vnd = daq.getVendors;
ses = daq.createSession(vnd.ID);
chLst = {
    'port0/line0'
    'port0/line1'
    'port0/line2'
    'port0/line3'
    'port0/line4'
    'port0/line5'
    'port0/line6'
    'port0/line7'
    'port1/line0'
    'port1/line1'
    'port1/line2'
    'port1/line3'
    'port1/line4'
    'port1/line5'
    'port1/line6'
    'port1/line7'
    };
ch = addDigitalChannel(ses,dev.ID,chLst,'OutputOnly'); %creates and displays the digital channels assigned to ch.


%Define monkey properties
bhv.ScriptRun = 'MatchToSample_sacc_Waldorf';
bhv.Monkey = 'Waldorf';
bhv.Date = datestr(now, 'yymmdd');

%Define monitor properties
opts.ScreenDiag = 60.96; %in cm %68.58; %in cm %dell u2413f 24"
opts.ScreenDist = 58; %in cm
opts.ScreenNumber = 1;
opts.ScreenDelay = 0.026; % in seconds


%Define parallel port parameters
opts.ParallelPort.Address = hex2dec('D010');
opts.ParallelPort.RewardBit = 1;
opts.ParallelPort.BarBit = 7;
opts.ParallelPort.BarBitMask = uint16(bitset(0, opts.ParallelPort.BarBit, 1));

%Stim for Photodiode
opts.PhotodiodePX = .05;
opts.PhotodiodePY = .05;

%Fixation point
opts.FixRadius = .2/180*pi; %.5 dva (in radians)
opts.FixColor = [1 1 1];
opts.ShowFix = 0;

%Fixation requirements
opts.FixAcquireWindowRadius = 1/180*pi; %dva (in radians)
opts.FixHoldWindowRadius = [2]'/180*pi;%#ok<NBRAK> %[2 2.4]'/180*pi; %dva (in radians)
opts.TargAcquireWindowRadius = 2/180*pi; %dva (in radians)
opts.TargHoldWindowRadius = [2 2]'/180*pi; %dva (in radians) (acquire is same as fix)

opts.TargRingBoxEccentricityDVA = 5/180*pi; %outer eccentricity of ring
opts.ArcWidthDVA = 2/180*pi;
opts.TargetDVA = 4;
opts.DistFade = 0;
opts.ResponseBoundEccentricityDVA = 2.9/180*pi;%opts.TargRingBoxEccentricityDVA - opts.ArcWidthDVA;

%Target Locations
opts.nangles = 64;
opts.angles = deg2rad(linspace(0,360,opts.nangles+1));
opts.angles = opts.angles(1:end-1); [x, y] =  pol2cart(opts.angles,opts.TargetDVA);
opts.TargetLocations = [x' -1.*y']./180*pi;
opts.InitialTargLocProbs = ones(1,size(opts.TargetLocations,1))./size(opts.TargetLocations,1);

%Sample item locations
opts.UpperSampleAngleRange = [-45 -45]/180*pi; % min/max angle of sample item (in radians)
opts.UpperSampleEccentricityDVA = [5 5]/180*pi; %dva (in radians)
opts.LowerSampleAngleRange = [45 45]/180*pi; % min/max angle of sample item (in radians)
opts.LowerSampleEccentricityDVA = [5 5]/180*pi; %dva (in radians)
[opts.UpperSampleLocation(1), opts.UpperSampleLocation(2)] = pol2cart(mean(opts.UpperSampleAngleRange), mean(opts.UpperSampleEccentricityDVA)); %starting value
[opts.LowerSampleLocation(1), opts.LowerSampleLocation(2)] = pol2cart(mean(opts.LowerSampleAngleRange), mean(opts.LowerSampleEccentricityDVA)); %starting value


opts.TargLocWindow = 300;
opts.TargLocStart = 30;
opts.TargLocTemp = .1; %up from .1

%Cue images
opts.CueLocation = [0 0]; %in dva
opts.CueSize = 2/180*pi; %in dva
opts.ALineCueSize = [1 1]./180*pi; %these should be identical and refer to line lenth from center of screen to end of 1 segment
opts.ATailSize = 1;
opts.RLineCueSize = [1 1]./180*pi; %these should be identical and refer to line lenth from center of screen to end of 1 segment
opts.RTailSize = 1;

%Eyelink parameters
opts.DummyEyelink = 0;
opts.RequireFixation = 0;
opts.UseEyelink = 1;
opts.Eyelink_UseEllipse = 1;

%Maximum number of trials
opts.MaximumTrials = 40000;

%Target Location Bias correction
opts.DoTargLocCorr = 1;
opts.RepeatError = 0;


%Trial timing INACCURATE FOR RETRO, se above
opts.ITITime = 2000; % in ms
opts.MaxAcquireFixTime = 4000; % in ms, time allowed to acquire fixation
opts.FixGraceTime = 0; %in ms, time after initial fixation where fixation isn't checked
opts.FixTime = [300 500]; % in ms, time to hold fixation (min max)
opts.CueTime = [300  0   0]; %in ms, how long cue should be on before sample stimulus
opts.CueDelay = {[200 600]  [0]  [0]}; %#ok<NBRAK> %in ms, time after cue before sample stimulus
opts.CueAndStimTime = [0 0 0];
opts.StimTime = [500 500 500]; %in ms, time to display stimulus
opts.CueAndStimTime2 = [0 0 0];
opts.CueDelay2    = {[0 0]       [500 1000] [500 1000]};
opts.CueTime2     = [ 0           300        300];
opts.CueRespDelay = {[1300 2000] [500 700]  [500 700] } ;


opts.FixTotalDelay = 0; %true or false
opts.TotalDelay = [2200 2400];%[1000:1800]; %[2200 2400]; %in ms, time from stimulus offset until target presentation

opts.TargetHoldTime = 50; %in ms, time to hold target before reward
opts.MaxReactionTime = 8000; %in ms, maximum reaction time allowed
opts.FixBreakErrorTimeout =2000; % in ms
%opts.ExpressSaccadeErrorTimeout = 2000; % in ms
opts.IncorrectErrorTimeout = 2000; % in ms
opts.NoFixTimeout = 500;

%Stimulus parameters
opts.StimRectSize = 2/180*pi; %in dva

%color
opts.nColorDraw = 64; %number of colors available;
opts.WheelCenterA = 6;
opts.WheelCenterB = 14;
opts.WheelRadius = 57;
opts.WheelLuminance = 60;
opts.BackgroundLuminance = 30;
opts.deltaAngles = deg2rad((360/opts.nColorDraw).*ones(1,opts.nColorDraw-1));
opts.ColorAngles = cumsum([0 opts.deltaAngles]);
[opts.Color, opts.DisplayBackground] = make_colors_V3(opts.WheelCenterA,opts.WheelCenterB,...
    opts.WheelRadius,opts.WheelLuminance,opts.BackgroundLuminance,opts.ColorAngles);

opts.nWheelColors = 64;
opts.deltaAnglesWheel = deg2rad((360/opts.nWheelColors).*ones(1,opts.nWheelColors-1));
opts.AnglesWheel = cumsum([0 opts.deltaAnglesWheel]);

%Color Bias correction
opts.DoColorCorr = 1; %turn off here
opts.ColorWindow = 300;
opts.ColorStart = 20;
opts.ColorTemp = 1;
opts.InitialColorProbs = ones(1,opts.nColorDraw)./opts.nColorDraw;

%Choosing condition
opts.ConditionList = 1:6; %[pro retroold retronew]*up/down
opts.ChooseNextCondition = 'blocked_ordered';
opts.orderedBlocks = repmat(randperm(3),1,1000);
opts.ConditionSelect.RepeatErrorConditionMaxTimes = 0;
opts.ConditionSelect.BiasedRandomRatio = 1/5; %only applies if choose next condition is biased random 
opts.ConditionSelect.RecentConditionHistory = 100; % # trials to use to calculate recent performance
opts.ConditionSelect.PercSingle = .20; % % of trials with single sample
opts.ConditionSelect.BlockSize = [60 30 30]; %[150 1500 150]; %total correct trials in a block
opts.ConditionSelect.NumCondsPerBlock = 2; %up and down

%probability of condition choice
V = zeros(1,numel(opts.ConditionList));
opts.temp = [.5 .5 .5]; %up from .5, applies to blocked_ordered
numV = numel(V);
opts.Alpha = .1; %set to zero to turn off 
Vs = [];

%Correct/incorrect colors
opts.ErrorBackground = [0 0 0]; %[0.4 0.4 0.8];
opts.FixErrorBackground = [1 1 1]; %[0.8 0.4 0.4];
opts.ExpressSaccadeErrorBackground = [1 1 1]; %[0.8 0.4 0.4];
opts.TargFixNotHeldErrorBackground = [1 1 1]; %[.4 .8 .4];

%Exit/pause keyboard keys
opts.ExitKey = 'ESCAPE';
opts.PauseKey = 'space';

%Encode variables
opts.Encodes.TASKID = 32;

opts.Encodes.START_TRIAL = 1;
opts.Encodes.FIXATE_ON = 2;
opts.Encodes.FIXATE_ACQUIRED = 3;
opts.Encodes.CUE1_ON = 4;
opts.Encodes.DELAY1_START = 5;
opts.Encodes.SAMPLES_ON = 6;
opts.Encodes.DELAY2_START = 7;
opts.Encodes.CUE2_ON = 8;
opts.Encodes.DELAY3_START = 9;
opts.Encodes.WHEEL_ON = 10;
opts.Encodes.TARGET_FIX = 11;
opts.Encodes.FEEDBACK_ON = 12;

opts.Encodes.BLOCK_BREAK = 97;
opts.Encodes.TASK_PAUSED = 98;
opts.Encodes.END_TRIAL = 99;

opts.Encodes.CORRECT_TRIAL = 40;
opts.Encodes.INCORRECT_TRIAL = 41;
opts.Encodes.NO_FIX_TRIAL = 42;
opts.Encodes.FIX_BREAK_TRIAL = 43;
opts.Encodes.NO_RESPONSE_TRIAL = 44;
opts.Encodes.REWARD = 45;

opts.Encodes.TRIAL_NUM_OFFSET = 100;

%Reward timing

opts.rewardtype = 'theta';
opts.RewardDelay = 800; % in ms
opts.NumRewards = 12;
opts.RewardPulse = 40; %in ms %45 50
opts.InterRewardDelay = 50; %in ms

%special options for "theta" rewards
opts.std = 22;
opts.LowerCutoff = 60;
opts.UpperCutoff = 12;
opts.maxdrops = 10; %13 15
opts.mindrops = 1;


%Save data to file?
opts.SaveData = 1;

%Save to task structure
bhv.opts = opts;

beh_fig = figure;
set(beh_fig, 'Position', [70 200 800 600]);


bhv.thetareward = normpdf(0:180,0,opts.std);
bhv.thetareward = ceil(opts.maxdrops/max(bhv.thetareward).*bhv.thetareward);
bhv.thetareward(1:opts.UpperCutoff) = opts.maxdrops;
bhv.thetareward(bhv.thetareward<opts.mindrops) = opts.mindrops;

%% Create save file
bhv.SaveFilename = sprintf('%s_%s_00_bhv.mat', bhv.Monkey, bhv.Date);
bhv.edfFilename = sprintf('%s%s00.edf', bhv.Monkey(1), bhv.Date(2:end));
count = 0;
while exist(bhv.SaveFilename, 'file') && (count < 100),
    count = count + 1;
    bhv.SaveFilename = sprintf('%s_%s_%02.0f_bhv.mat', bhv.Monkey, bhv.Date, count);
    bhv.edfFilename = sprintf('%s%s%02.0f.edf', bhv.Monkey(1), bhv.Date(2:end), count);
end
if count >= 100, error('Couldn''t find a unique filename for today.'); end

clear count;

%% Initialize screens
[bhv, wPtr, ioObj, el] = InitializeBHV_Waldorf(bhv);

white=WhiteIndex(opts.ScreenNumber);
black=BlackIndex(opts.ScreenNumber);

EyeStruct = [];

%% Initialize task parameters

bhv.TargArcAngle = 360/opts.nWheelColors; %pi/6 *180./pi;

%Conversion functions
bhv.DVAToCM = @(a) tan(a)*opts.ScreenDist; bhv.CMToDVA = @(x) atan(x/opts.ScreenDist);
bhv.DVAToPIX = @(a, res) tan(a)*opts.ScreenDist*res; bhv.PIXToDVA = @(x, res) atan(x/opts.ScreenDist/res);

%Convert fixation location to pixel
bhv.FixRect = [bhv.ScreenCenter(:); bhv.ScreenCenter(:)] + [-bhv.ScreenHorizRes; -bhv.ScreenVertRes; bhv.ScreenHorizRes; bhv.ScreenVertRes]*bhv.DVAToCM(opts.FixRadius);
bhv.FixRect = bhv.FixRect';
[bhv.FixRectCenter(1), bhv.FixRectCenter(2)] = RectCenter(bhv.FixRect);

%Convert Target Ring box to pixel
bhv.TargRingRect = [bhv.ScreenCenter(:); bhv.ScreenCenter(:)] + [-bhv.ScreenHorizRes; -bhv.ScreenVertRes; bhv.ScreenHorizRes; bhv.ScreenVertRes]*bhv.DVAToCM(opts.TargRingBoxEccentricityDVA);
bhv.TargRingRect = bhv.TargRingRect';

%Convert fixation radius to pixels
bhv.FixAcquireWindowRadius = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.FixAcquireWindowRadius);
bhv.TargAcquireWindowRadius = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.TargAcquireWindowRadius);
bhv.FixHoldWindowRadius = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.FixHoldWindowRadius);
bhv.ResponseBoundEccentricityDVA = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.ResponseBoundEccentricityDVA);
bhv.TargHoldWindowRadius = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.TargHoldWindowRadius);
bhv.RingOuterRadius = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.TargRingBoxEccentricityDVA);
bhv.ALineCueSize = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.ALineCueSize)';
bhv.RLineCueSize = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.RLineCueSize)';

%Convert sample locations to pixels
bhv.SampleRect = [bhv.ScreenCenter(:); bhv.ScreenCenter(:)] + [-bhv.ScreenHorizRes; -bhv.ScreenVertRes; bhv.ScreenHorizRes; bhv.ScreenVertRes]*bhv.DVAToCM(opts.StimRectSize/2);
bhv.SampleRect = bhv.SampleRect';

%Convert cue location to pixels
bhv.CueRect = [bhv.ScreenCenter(:); bhv.ScreenCenter(:)] + [-bhv.ScreenHorizRes; -bhv.ScreenVertRes; bhv.ScreenHorizRes; bhv.ScreenVertRes]*bhv.DVAToCM(opts.CueSize/2);
bhv.CueRect = bhv.CueRect';

%Convert arc width to pixels
opts.ArcWidthPix = bhv.DVAToPIX(opts.ArcWidthDVA,bhv.ScreenHorizRes);

%photodiode stim (left top right bottom
bhv.pdRect = round([0, bhv.ScreenRect(4)-bhv.ScreenRect(4).*opts.PhotodiodePY, ...
    bhv.ScreenRect(3).*opts.PhotodiodePX, bhv.ScreenRect(4)]);


%Target Location Probability
%Convert target locations to pixels
bhv.TargetRect = repmat(bhv.SampleRect, [size(opts.TargetLocations, 1) 1]); %this is our fixation
for i = 1:size(opts.TargetLocations, 1),
    bhv.TargetRect(i, :) = CenterRectOnPoint(bhv.TargetRect(i, :), ...
        bhv.ScreenCenter(1) + bhv.ScreenHorizRes.*bhv.DVAToCM(opts.TargetLocations(i, 1)), ...
        bhv.ScreenCenter(2) + bhv.ScreenVertRes.*bhv.DVAToCM(opts.TargetLocations(i, 2)));
    [bhv.TargetRectCenter(i, 1), bhv.TargetRectCenter(i, 2)] = RectCenter(bhv.TargetRect(i, :));
end
%% Initialize keyboard and mouse and parallel port

%Keypress settings
KbName('UnifyKeyNames');
KbDeviceIndex = [];

exitKey = KbName(opts.ExitKey);
pauseKey = KbName(opts.PauseKey);
keysOfInterest=zeros(1,256);
keysOfInterest([exitKey pauseKey])=1;

%Allow special keys to be hit to break out of loop
KbQueueCreate(KbDeviceIndex, keysOfInterest);
KbQueueStart(KbDeviceIndex);

HideCursor;

%% Initialize task variables
bhv.CurrentTrial = 0;
bhv.StartTime = GetSecs;

%Save to file
if opts.SaveData,
    save(bhv.SaveFilename, 'bhv', '-v7.3');
end


%% Loop through trials

%Start recording eye position

KbQueueFlush(KbDeviceIndex);

run_task = 1;

bhv.pd_state = 0;

send_trigger(ses,opts.Encodes.TASKID);
send_trigger(ses,opts.Encodes.TASKID);
send_trigger(ses,opts.Encodes.TASKID);


while run_task,
    
    bhv.CurrentTrial = bhv.CurrentTrial + 1;
    first_trial = bhv.CurrentTrial ==1;
    
            
    %Have we done all of our trials?
    if bhv.CurrentTrial >= opts.MaximumTrials,
        if opts.UseEyelink,
            send_trigger(ses,opts.Encodes.BLOCK_BREAK);
            Eyelink('message', 'BLOCK_BREAK');
            Eyelink('StopRecording');
            WaitSecs(0.1);
        end
        
        fprintf('Exiting: all done!\n');
        run_task = 0; %done
        continue;
    end
    
    if ~first_trial %update Eyedata
        EyeStruct = [EyeStruct TempEyeStruct]; %#ok<AGROW>
    end
    
    %Did user press a key?
    [keyIsDown, firstKeyPressTimes] = KbQueueCheck(KbDeviceIndex);
    if keyIsDown,
        if firstKeyPressTimes(pauseKey)
            if opts.UseEyelink,
                send_trigger(ses,opts.Encodes.TASK_PAUSED);
                Eyelink('message', 'TASK_PAUSED');
                Eyelink('StopRecording');
                WaitSecs(0.1);
            end
            
            %Pause running
            Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white));
            Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
            Screen('Flip', wPtr);
            
            disp('pausing program');
            action = 0;
            while action ~= 1
                disp('1 = resume, 2 = view options, 3 = change options');
                action =input('what would you like to do: ');
                
                if action == 2;
                    disp(opts);
                elseif action == 3;
                    fieldname = input('please enter the name of the field \n you would like to change','s');
                    disp(['the current value of ' fieldname 'is : '])
                    disp(opts.(fieldname));
                    newvalue = input('please enter a new value: ');
                    opts.(fieldname) = newvalue;
                    disp('value updated');
                    
                    %% Initialize task parameters
                    
                    %Conversion functions
                    bhv.DVAToCM = @(a) tan(a)*opts.ScreenDist; bhv.CMToDVA = @(x) atan(x/opts.ScreenDist);
                    bhv.DVAToPIX = @(a, res) tan(a)*opts.ScreenDist*res; bhv.PIXToDVA = @(x, res) atan(x/opts.ScreenDist/res);
                    
                    %Convert fixation location to pixel
                    bhv.FixRect = [bhv.ScreenCenter(:); bhv.ScreenCenter(:)] + [-bhv.ScreenHorizRes; -bhv.ScreenVertRes; bhv.ScreenHorizRes; bhv.ScreenVertRes]*bhv.DVAToCM(opts.FixRadius);
                    bhv.FixRect = bhv.FixRect';
                    [bhv.FixRectCenter(1), bhv.FixRectCenter(2)] = RectCenter(bhv.FixRect);
                    %Convert fixation radius to pixels
                    bhv.FixAcquireWindowRadius = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.FixAcquireWindowRadius);
                    bhv.TargAcquireWindowRadius = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.TargAcquireWindowRadius);
                    bhv.FixHoldWindowRadius = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.FixHoldWindowRadius);
                    bhv.TargHoldWindowRadius = [bhv.ScreenHorizRes; bhv.ScreenVertRes].*bhv.DVAToCM(opts.TargHoldWindowRadius);
                    
                    %Convert sample locations to pixels
                    bhv.SampleRect = [bhv.ScreenCenter(:); bhv.ScreenCenter(:)] + [-bhv.ScreenHorizRes; -bhv.ScreenVertRes; bhv.ScreenHorizRes; bhv.ScreenVertRes]*bhv.DVAToCM(opts.StimRectSize/2);
                    bhv.SampleRect = bhv.SampleRect';
                    
                    %Convert cue location to pixels
                    bhv.CueRect = [bhv.ScreenCenter(:); bhv.ScreenCenter(:)] + [-bhv.ScreenHorizRes; -bhv.ScreenVertRes; bhv.ScreenHorizRes; bhv.ScreenVertRes]*bhv.DVAToCM(opts.CueSize/2);
                    bhv.CueRect = bhv.CueRect';
                    
                    %Convert target locations to pixels
                    bhv.TargetRect = repmat(bhv.SampleRect, [size(opts.TargetLocations, 1) 1]); %this is our fixation
                    for i = 1:size(opts.TargetLocations, 1),
                        bhv.TargetRect(i, :) = CenterRectOnPoint(bhv.TargetRect(i, :), ...
                            bhv.ScreenCenter(1) + bhv.ScreenHorizRes.*bhv.DVAToCM(opts.TargetLocations(i, 1)), ...
                            bhv.ScreenCenter(2) + bhv.ScreenVertRes.*bhv.DVAToCM(opts.TargetLocations(i, 2)));
                        [bhv.TargetRectCenter(i, 1), bhv.TargetRectCenter(i, 2)] = RectCenter(bhv.TargetRect(i, :));
                    end
                    
                elseif action ~=1
                    disp('please enter 1,2,or 3');
                end
            end
            
            
            
            %Wait for another keypress
            % [secs, keyCode, deltaSecs] = KbWait(KbDeviceIndex, 2); %2 is important to make sure the pause key was released first
            
            %If user pressed the escape key, just quit now
            %if keyCode(exitKey), run_task = 0; end
            KbQueueFlush(KbDeviceIndex);
            
            Screen('FillRect', wPtr, floor(opts.DisplayBackground.*black));
            Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
            Screen('Flip', wPtr);
            
            %Do quick check of eye calibration here
            result = 0;
            while ~result,
                result = red_green_el_calib(el, ioObj, 'ParallelPort_Address', bhv.opts.ParallelPort.Address,'HoldTime', [.5 1]);
            end
            
            WaitSecs(0.1);
            Eyelink('StartRecording');
            WaitSecs(1);
            
            %Clear screen
            Screen('FillRect', wPtr, floor(opts.DisplayBackground.*black));
            Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
            Screen('Flip', wPtr);
            KbQueueFlush(KbDeviceIndex);
            
        elseif firstKeyPressTimes(exitKey),
            %End running
            fprintf('Exiting because exit key was pressed.\n');
            if opts.SaveData, save(bhv.SaveFilename, 'bhv','-append'); end
            run_task = 0;
            continue;
        end
    end
    KbQueueFlush(KbDeviceIndex);
    
    
    %Save file to disk
    if opts.SaveData && bhv.CurrentTrial>1
        tempName = ['trial_' num2str(bhv.CurrentTrial-1)];
        eval([tempName '= temp_trial;']);
        save(bhv.SaveFilename, tempName,'-append'); 
        eval(['clear ' tempName]);
    end
    
    %Initialize temp_trial
    temp_trial = struct('StartTime', NaN, 'FixTime', NaN, 'SampleLocation', NaN, 'SampleAngleDeg', NaN, 'TargetLocation', NaN, 'StopCondition', NaN, ...
        'FixOnset_VBLTimestamp', NaN, 'FixOnset_StimulusOnsetTime', NaN, ...
        'Cue1Onset_VBLTimestamp', NaN, 'Cue1Onset_StimulusOnsetTime', NaN, 'Delay1Onset_VBLTimestamp', NaN, 'Delay1Onset_StimulusOnsetTime', NaN,'Delay2Onset_VBLTimestamp', NaN, 'Delay2Onset_StimulusOnsetTime', NaN,'Delay3Onset_VBLTimestamp', NaN, 'Delay3Onset_StimulusOnsetTime', NaN, ...
        'StimOnset_VBLTimestamp', NaN, 'StimOnset_StimulusOnsetTime', NaN, 'Cue2Onset_VBLTimestamp', NaN, 'Cue2Onset_StimulusOnsetTime', NaN, ...
        'TargetOnset_VBLTimestamp', NaN, 'TargetOnset_StimulusOnsetTime', NaN, 'TargetOffset_VBLTimestamp', NaN, 'TargetOffset_StimulusOnsetTime', NaN, ...
        'AcquireFixWaitStart', NaN, 'AcquireFixTime', NaN, 'AcquireTargetWaitStart', NaN, 'AcquireTargetTime', NaN, ...
        'TotalDelay', NaN, 'HoldFixWaitStart', NaN, 'Condition', NaN, 'ReactionTime', NaN, 'tempcontrast', NaN,'is_one_sample_displayed',NaN, ...
        'RewardOnset_VBLTimestamp', NaN, 'RewardOnset_StimulusOnsetTime', NaN, 'TrialEndTime',NaN,'ResponseLocationIndex',NaN, ...
        'Color', NaN,'ResponseCoordinate', NaN,'ResponseTheta',NaN,'ResponseRadius',NaN,'deltaTheta',NaN,'deltaTheta_dist',NaN,'InterAngles',NaN,'fadein',NaN,'distractor_index',NaN, ...
        'ColorAngles',NaN,'CueAppearance',NaN,'ColorID',NaN,'TargetTheta',NaN,'DistTheta',NaN, ...
        'LABthetaTarget',NaN,'LABthetaDist',NaN,'LABthetaResp',NaN,'ColorTarget',NaN,'ColorDist',NaN,'WheelLABtheta',NaN,'WheelRGB',NaN, ...
        'CueDelay',NaN,'CueDelay2',NaN,'CueRespDelay',NaN);
    
      
    TempEyeStruct.Eye = struct('Samples', [], 'Events', []);
    
    
    %Mark start of trial
    StartTime = GetSecs;
    send_trigger(ses,opts.Encodes.START_TRIAL);
    send_trigger(ses,opts.Encodes.START_TRIAL);
    send_trigger(ses,opts.Encodes.START_TRIAL);
    Eyelink('message', 'START_TRIAL');
    
    send_trigger(ses,opts.Encodes.TRIAL_NUM_OFFSET + bhv.CurrentTrial);  
    send_trigger(ses,opts.Encodes.TRIAL_NUM_OFFSET + bhv.CurrentTrial);  
    send_trigger(ses,opts.Encodes.TRIAL_NUM_OFFSET + bhv.CurrentTrial); 
    
    Eyelink('message', sprintf('TRIAL_NUM=%4.0f', bhv.CurrentTrial));
    
    %% Pick block and condition for this trial (used to determine  pro/retro/retro and up/down)
    if bhv.CurrentTrial == 1,
        if ~strcmpi(opts.ChooseNextCondition, {'blocked_ordered'}),
            prev_cond = []; num_cond_repeats = 0;
            cur_block = randsample(length(opts.ConditionList)./opts.ConditionSelect.NumCondsPerBlock, 1);
            cur_cond = randsample(opts.ConditionSelect.NumCondsPerBlock, 1) + (cur_block-1)*opts.ConditionSelect.NumCondsPerBlock;
            block_counter = 0;
        else
            cur_block = opts.orderedBlocks(1);
            block_counter = 0;%n correct trials
            i_orderedBlock = 1;
            cur_cond = randsample(opts.ConditionSelect.NumCondsPerBlock, 1) + (cur_block-1)*opts.ConditionSelect.NumCondsPerBlock;
        end
    else
        prev_cond = [bhv.Trials(:).Condition];
        if strcmpi(opts.ChooseNextCondition, 'repeat_errors'),
            if (bhv.Trials(end).StopCondition ~= 1) && (num_cond_repeats < opts.ConditionSelect.RepeatErrorConditionMaxTimes),
                %Error previously, repeat condition
                num_cond_repeats = num_cond_repeats + 1;
                cur_cond = prev_cond(end);
            else
                cur_cond = randsample(opts.ConditionList, 1, 1);
                num_cond_repeats = 0;
            end
            cur_block = floor((cur_cond-1)./opts.ConditionSelect.NumCondsPerBlock)+1;
        elseif any(strcmpi(opts.ChooseNextCondition, {'random', 'biased_random'})),
            if strcmpi(opts.ChooseNextCondition, 'biased_random'),
                %Set probability distribution to be biased by number of incorrects
                prct_error = zeros(length(opts.ConditionList), 1);
                for i = 1:length(opts.ConditionList),
                    cur_trial_ind = find([bhv.Trials(:).Condition] == opts.ConditionList(i));
                    cur_trial_ind = cur_trial_ind(cur_trial_ind >= bhv.CurrentTrial - opts.ConditionSelect.RecentConditionHistory);
                    if ~isempty(cur_trial_ind),
                        prct_error(i) = mean([bhv.Trials(cur_trial_ind).StopCondition] ~= 1);
                    end
                end
                fprintf('Percent Error: %s', mat2str(prct_error));
                prct_error = prct_error + opts.ConditionSelect.BiasedRandomRatio; %don't want to be exclusively driven by error
                if sum(prct_error) == 0,
                    choice_prob = ones(length(opts.ConditionList), 1)./length(opts.ConditionList); %flat distribution
                else
                    choice_prob = prct_error./sum(prct_error);
                end
                fprintf('   Choice Probability: %s\n', mat2str(choice_prob));
            else
                choice_prob = ones(length(opts.ConditionList), 1)./length(opts.ConditionList); %flat distribution
            end
            cur_cond = opts.ConditionList(find(rand <= cumsum(choice_prob), 1, 'first'));
            cur_block = floor((cur_cond-1)./opts.ConditionSelect.NumCondsPerBlock)+1;
        elseif strcmpi(opts.ChooseNextCondition, {'blocked_random'}),
            %Choose a block
            correct_trials = ([bhv.Trials(:).StopCondition] == 1);
            if opts.ConditionSelect.BlockSize(cur_block) == block_counter;%(mod(sum(correct_trials), opts.ConditionSelect.BlockSize(cur_block)) == 0) && ((correct_trials(end) == 1) || isempty(correct_trials)),
                %Just finished a block, switch blocks
                num_blocks = length(opts.ConditionList)./opts.ConditionSelect.NumCondsPerBlock;
                block_sel = [1:num_blocks];
                if length(bhv.Trials) > 1,
                    block_sel = block_sel(~(block_sel == bhv.Trials(end).Block)); %don't repeat a block (for now)
                end
                cur_block = block_sel(randsample(length(block_sel), 1));
                block_counter = 0;
            else
                cur_block = bhv.Trials(end).Block;
                block_counter = block_counter + (bhv.Trials(end).StopCondition == 1);
            end
            
            previous_condition = bhv.Trials(end).Condition;
            previous_outcome = bhv.Trials(end).StopCondition;
            if abs(previous_outcome) ~= 1;
                prediction_error = 0; %don't want break fix or no response to influence value
            else
                prediction_error = -1*previous_outcome - V(previous_condition); %-1 because we want incorrects to increase value so that they are selected more
            end
            
            V(previous_condition) = V(previous_condition) + opts.Alpha.*prediction_error;
            
            Vs(end+1,:) = V;
            %identify the conditions that correspond to the current block
            %and set the value of all other conditions to zero
            mask_index = ((cur_block-1)*opts.ConditionSelect.NumCondsPerBlock + 1):((cur_block-1)*opts.ConditionSelect.NumCondsPerBlock + opts.ConditionSelect.NumCondsPerBlock);
            mask = zeros(1,numV); mask(mask_index) = 1;
            tempV = V;
            tempV(~mask) = NaN;
            
            
            %calc probs
            temp = opts.temp(cur_block);
            p = custom_softmax(tempV,temp);
            p(isnan(p)) = 0;
            cur_cond = discretesample(p, 1);
        elseif strcmpi(opts.ChooseNextCondition, {'blocked_ordered'}), %same as above but go thro blocks in order
            %Choose a block
            correct_trials = ([bhv.Trials(:).StopCondition] == 1);
            block_counter = block_counter + (bhv.Trials(end).StopCondition == 1);
            if opts.ConditionSelect.BlockSize(cur_block) == block_counter;
                %Just finished a block, switch blocks
                i_orderedBlock = i_orderedBlock + 1;
                cur_block = opts.orderedBlocks(i_orderedBlock);
                block_counter = 0;
            else
                cur_block = bhv.Trials(end).Block;
            end
            
            previous_condition = bhv.Trials(end).Condition;
            previous_outcome = bhv.Trials(end).StopCondition;
            if abs(previous_outcome) ~= 1;
                prediction_error = 0; %don't want break fix or no response to influence value
            else
                prediction_error = -1*previous_outcome - V(previous_condition); %-1 because we want incorrects to increase value so that they are selected more
            end
            
            V(previous_condition) = V(previous_condition) + opts.Alpha.*prediction_error;
            
            Vs(end+1,:) = V;
            %identify the conditions that correspond to the current block
            %and set the value of all other conditions to zero
            mask_index = ((cur_block-1)*opts.ConditionSelect.NumCondsPerBlock + 1):((cur_block-1)*opts.ConditionSelect.NumCondsPerBlock + opts.ConditionSelect.NumCondsPerBlock);
            mask = zeros(1,numV); mask(mask_index) = 1;
            tempV = V;
            tempV(~mask) = NaN;
            
            
            %calc probs
            temp = opts.temp(cur_block);
            p = custom_softmax(tempV,temp);
            p(isnan(p)) = 0;
            cur_cond = discretesample(p, 1);
        end
    end
    fprintf('Current condition %d, Current block: %d\n', cur_cond, cur_block);
    temp_trial.Condition = cur_cond;
    temp_trial.Block = cur_block;
    %% pick ColorID for this Trial
    if opts.DoColorCorr 
        if first_trial
            ColorProbs = opts.InitialColorProbs;
        elseif bhv.Trials(end).StopCondition == -2;
            ColorProbs = ColorProbs;
        else
            CompletedVector = ([bhv.Trials.StopCondition]==1)|([bhv.Trials.StopCondition]==-1); %grab completed trials
            Ncompleted = sum(CompletedVector); %how many have we completed
            if Ncompleted <= opts.ColorStart %opts.ColorWindow; %don't update ColorProbs untill we have enough trials to make an informed decision
                ColorProbs = opts.InitialColorProbs;
            else %if we have enough trials...
                CompletedTrials = bhv.Trials(CompletedVector);
                
                if Ncompleted <= opts.ColorWindow
                    CompletedTrials = CompletedTrials( 1:end);
                else
                    CompletedTrials = CompletedTrials( (end-(opts.ColorWindow-1)):end);
                end
                
                
                Correct = ([CompletedTrials.StopCondition] == 1);
                Incorrect = ([CompletedTrials.StopCondition] == -1);
                
                NColors = opts.nColorDraw;
                ColorProbs = NaN(1,NColors);
                
                responses = [CompletedTrials.ColorID];
                for i = 1:NColors;
                    ColorProbs(i) = nansum(responses==i);
                end
                smoothing = 1;
                ColorProbs = ColorProbs/max(ColorProbs); %1 = most responses
                ColorProbs(isnan(ColorProbs)) = 0; %give locations with no trials a high value
                if 0
                    ColorProbs =  circshift(cconv(ColorProbs,ones(1,smoothing)./smoothing,length(ColorProbs))',-(median(1:smoothing)-1))';
                end
            end
        end
        temp_trial.ColorProbs = custom_softmax(1-ColorProbs,opts.ColorTemp);
        temp_trial.ColorID = discretesample(temp_trial.ColorProbs, 1);
    else
        temp_trial.ColorID = randsample(NColors, 1); %Pick target location randomly now
    end
    
    
    %%
    
    

    
    %Determine the sample location on this trial
    temp_trial.UpperSampleAngle = opts.UpperSampleAngleRange(1) + rand.*diff(opts.UpperSampleAngleRange); %defines the random degree difference in sample location
    temp_trial.UpperSampleEccentricityDVA = opts.UpperSampleEccentricityDVA(1) + rand.*diff(opts.UpperSampleEccentricityDVA); %defines the random degree difference in sample location
    [temp_trial.UpperSampleLocation(1), temp_trial.UpperSampleLocation(2)] = pol2cart(temp_trial.UpperSampleAngle, temp_trial.UpperSampleEccentricityDVA);
    bhv.UpperSampleRect = CenterRectOnPoint(bhv.SampleRect, ...
        bhv.ScreenCenter(1) + bhv.ScreenHorizRes.*bhv.DVAToCM(temp_trial.UpperSampleLocation(1)), ...
        bhv.ScreenCenter(2) + bhv.ScreenVertRes.*bhv.DVAToCM(temp_trial.UpperSampleLocation(2)));
    temp_trial.LowerSampleAngle = opts.LowerSampleAngleRange(1) + rand.*diff(opts.LowerSampleAngleRange); %defines the random degree difference in sample location
    temp_trial.LowerSampleEccentricityDVA = opts.LowerSampleEccentricityDVA(1) + rand.*diff(opts.LowerSampleEccentricityDVA); %defines the random degree difference in sample location
    [temp_trial.LowerSampleLocation(1), temp_trial.LowerSampleLocation(2)] = pol2cart(temp_trial.LowerSampleAngle, temp_trial.LowerSampleEccentricityDVA);
    bhv.LowerSampleRect = CenterRectOnPoint(bhv.SampleRect, ...
        bhv.ScreenCenter(1) + bhv.ScreenHorizRes.*bhv.DVAToCM(temp_trial.LowerSampleLocation(1)), ...
        bhv.ScreenCenter(2) + bhv.ScreenVertRes.*bhv.DVAToCM(temp_trial.LowerSampleLocation(2)));
    
    %Determine which sample will be eventual target
    temp_trial.IsUpperSample = 1;
    if mod(temp_trial.Condition,2) == 0; %if is even
        temp_trial.IsUpperSample = 0;
    end
    
    
    %% Target bias correction
    if opts.DoTargLocCorr %do we want to dynamically update the probability that the target is on the right?
        if first_trial
            TargLocProbs = opts.InitialTargLocProbs;
        elseif bhv.Trials(end).StopCondition == -2;
            TargLocProbs = TargLocProbs;
        else
            CompletedVector = ([bhv.Trials.StopCondition]==1)|([bhv.Trials.StopCondition]==-1); %grab completed trials
            Ncompleted = sum(CompletedVector); %how many have we completed
            if Ncompleted <= opts.TargLocStart %opts.TargLocWindow; %don't update TargLocProbs untill we have enough trials to make an informed decision
                TargLocProbs = opts.InitialTargLocProbs;
            else %if we have enough trials...
                CompletedTrials = bhv.Trials(CompletedVector);
                
                if Ncompleted <= opts.TargLocWindow
                    CompletedTrials = CompletedTrials( 1:end);
                else
                    CompletedTrials = CompletedTrials( (end-(opts.TargLocWindow-1)):end);
                end
                
                
                Correct = ([CompletedTrials.StopCondition] == 1);
                Incorrect = ([CompletedTrials.StopCondition] == -1);
                
                NLocations = size(opts.TargetLocations,1);
                TargLocProbs = NaN(1,NLocations);
                
                responses = [CompletedTrials.ResponseLocationIndex];
                for r = 1:numel(responses)
                    if responses(r) == 1
                        responses(r) = CompletedTrials(r).TargetLocation;
                    elseif responses(r)>1;
                        responses(r) = CompletedTrials(r).DistractLocations(responses(r)-1);
                    end
                end
                for i = 1:NLocations;
                    
                    TargLocProbs(i) = nansum(responses==i);
                end
                smoothing = 5;
                TargLocProbs = TargLocProbs/max(TargLocProbs); %1 = most responses
                TargLocProbs(isnan(TargLocProbs)) = 0; %give locations with no trials a high value
                TargLocProbs =  circshift(cconv(TargLocProbs,ones(1,smoothing)./smoothing,length(TargLocProbs))',-(median(1:smoothing)-1))';
            end
        end
        temp_trial.TargLocProbs = custom_softmax(1-TargLocProbs,opts.TargLocTemp);
        temp_trial.TargetLocation = discretesample(temp_trial.TargLocProbs, 1);
    else
        temp_trial.TargetLocation = randsample(size(opts.TargetLocations, 1), 1); %Pick target location randomly now
    end
    
    
    
    %% pick final locations and colors

    %scalar reference
    temp_trial.LocationsFinal = temp_trial.TargetLocation : opts.nangles/opts.nWheelColors : temp_trial.TargetLocation+(opts.nWheelColors-1)*(opts.nangles./opts.nWheelColors);
    temp_trial.LocationsFinal = temp_trial.LocationsFinal - opts.nangles.*(floor(temp_trial.LocationsFinal./(opts.nangles+1)));
    temp_trial.DistractLocations = temp_trial.LocationsFinal(2:end);
    %actual angle in radians
    temp_trial.TargetTheta = opts.angles(temp_trial.TargetLocation);
    temp_trial.AnglesFinal = temp_trial.TargetTheta : 2*pi/opts.nWheelColors : temp_trial.TargetTheta+(opts.nWheelColors-1)*(2*pi/opts.nWheelColors);
    temp_trial.AnglesFinal = temp_trial.AnglesFinal - 2*pi.*(floor(temp_trial.AnglesFinal./(2*pi)));
    temp_trial.InterAngles    = temp_trial.AnglesFinal +  wrap(difc(temp_trial.AnglesFinal))/2;
    %transforms for display
    temp_trial.AnglesForDrawCom = [temp_trial.AnglesFinal ] - pi/opts.nWheelColors ; %draw line segments between secotions
    temp_trial.AnglesFinalPsychToolbox    = 90 - ((temp_trial.AnglesFinal .*180./pi) + bhv.TargArcAngle./2);%in degreese and shifted to start of arc
    
    %pick the wheel colors and target/distractor sample identity and location
    temp_trial.distractor_index   = randsample(opts.nColorDraw,1);
    temp_trial.LABthetaTarget     = opts.ColorAngles(temp_trial.ColorID);
    temp_trial.LABthetaDist       = opts.ColorAngles(temp_trial.distractor_index);
    
    temp_trial.ColorTarget = opts.Color(temp_trial.ColorID,:);
    temp_trial.ColorDist   = opts.Color(temp_trial.distractor_index,:);
   
        temp_trial.WheelLABtheta = temp_trial.LABthetaTarget : 2*pi/opts.nWheelColors : temp_trial.LABthetaTarget+(opts.nWheelColors-1)*(2*pi/opts.nWheelColors);
        temp_trial.WheelLABtheta = temp_trial.WheelLABtheta - 2*pi.*(floor(temp_trial.WheelLABtheta./(2*pi)));

    
    [mn index] = min(abs(wrap(temp_trial.WheelLABtheta-temp_trial.LABthetaDist))); temp_trial.DistTheta = temp_trial.AnglesFinal(index);
    
    [temp_trial.WheelRGB, toto] = make_colors_V3(opts.WheelCenterA,opts.WheelCenterB,...
         opts.WheelRadius,opts.WheelLuminance,opts.BackgroundLuminance,temp_trial.WheelLABtheta);
    %% Determine delay on this trial
%     if length(opts.TargetDelay(temp_trial.Block,:)) > 1,
%         temp_trial.TargetDelay = randi([opts.TargetDelay(temp_trial.Block,1), opts.TargetDelay(temp_trial.Block,2)], 1, 1);
%     else
%         temp_trial.TargetDelay = opts.TargetDelay(temp_trial.Block);
%     end
    temp_trial.TotalDelay = datasample(opts.TotalDelay,1);

    
    
    %% Plot behavior to this point
    if bhv.CurrentTrial > 5,
        figure(beh_fig); clf;
        subplot(2,3,1:2);
        sm_kern = ones(1, 20); sm_kern = sm_kern./sum(sm_kern);
        plot(convn([bhv.Trials(:).StopCondition] == 1, sm_kern, 'valid')); hold all;
        leg_str = {'Correct'};
        uniq_resp = unique([bhv.Trials(:).StopCondition]);
        uniq_resp = uniq_resp(uniq_resp ~= 1);
        for i = 1:length(uniq_resp),
            plot(convn([bhv.Trials(:).StopCondition] == uniq_resp(i), sm_kern, 'valid'));
            leg_str = cat(1, leg_str, {sprintf('Error %d', uniq_resp(i))});
        end
        xlabel('Trials'); ylabel('Percent Correct'); title('Behavioral Performance over Trials');
        legend(leg_str,'Location','SouthWest'); hold off;
        
        subplot(2,3,3);
        cond_beh = zeros(6, 5);
        cond_list = [bhv.Trials(:).Condition];
        for i = 1:6,
            cond_beh(i, 1) = sum([bhv.Trials(cond_list == i).StopCondition] == 1); %correct
            cond_beh(i, 2) = sum([bhv.Trials(cond_list == i).StopCondition] == -1); %incorrect
            cond_beh(i, 3) = sum([bhv.Trials(cond_list == i).StopCondition] == -2); %no response
            cond_beh(i, 4) = sum([bhv.Trials(cond_list == i).StopCondition] == -3); %break fixation
            cond_beh(i, 5) = sum([bhv.Trials(cond_list == i).StopCondition] == -4); %es
        end
        cond_beh = cond_beh./repmat(sum(cond_beh, 2), [1 5]);
        bar(1:6, cond_beh, 'stacked')
        legend('C', 'I', 'N', 'BF', 'ES','Location','SouthWest');
        xlabel('Condition'); ylabel('Percent of Trials');
        
        subplot(2,3,4); cla;
        good_trials = find(abs([bhv.Trials(:).StopCondition]) == 1);
        sm_kern = ones(1, 20); sm_kern = sm_kern./sum(sm_kern);
        plot(convn(good_trials, sm_kern, 'valid'), convn([bhv.Trials(good_trials).ReactionTime], sm_kern, 'valid')); hold all;
        xlabel('Trials'); ylabel('RT'); title('Reaction over Completed Trials');
        
        subplot(2,3,5)
        title('location bias correction');
        plot(temp_trial.TargLocProbs,'r'); hold on
        plot(TargLocProbs,'b');
        legend('pchoose','accuracy');
        axis tight
        
        subplot(2,3,6)
        title('color bias correction');
        plot(temp_trial.ColorProbs,'r'); hold on
        plot(ColorProbs,'b');
        legend('pchoose','accuracy');
        axis tight
        
        drawnow;
    end
    
    Eyelink('command','clear_screen 0');
    [x y] =ellipse_coords(bhv.FixAcquireWindowRadius(1),bhv.FixAcquireWindowRadius(2),0,bhv.FixRectCenter(1),bhv.FixRectCenter(2),'r');
    [a b] =ellipse_coords(bhv.FixHoldWindowRadius(1),bhv.FixHoldWindowRadius(2),0,bhv.FixRectCenter(1),bhv.FixRectCenter(2),'r');
    [a1 b1] = ellipse_coords(bhv.ResponseBoundEccentricityDVA(1),bhv.ResponseBoundEccentricityDVA(2),0,bhv.FixRectCenter(1),bhv.FixRectCenter(2),'r');
    [a2 b2] = ellipse_coords(bhv.RingOuterRadius(1),bhv.RingOuterRadius(2),0,bhv.FixRectCenter(1),bhv.FixRectCenter(2),'r');
    
    
    
    for i = 2:4:301;
        Eyelink('Command',sprintf('draw_line %f %f %f %f 15',x(i-1), y(i-1),x(i),y(i)));%DRAWCOM
        Eyelink('Command',sprintf('draw_line %f %f %f %f 15',a(i-1), b(i-1),a(i),b(i)));
        Eyelink('Command',sprintf('draw_line %f %f %f %f 15',a1(i-1), b1(i-1),a1(i),b1(i)));
        Eyelink('Command',sprintf('draw_line %f %f %f %f 15',a2(i-1), b2(i-1),a2(i),b2(i)));
        
    end
    
    for i = 1:length(temp_trial.AnglesForDrawCom);
        [starta startb] = pol2cart(temp_trial.AnglesForDrawCom(i),bhv.ResponseBoundEccentricityDVA(1));
        starta = starta +bhv.FixRectCenter(1);
        startb = -startb +bhv.FixRectCenter(2);
        [endpa endpb] = pol2cart(temp_trial.AnglesForDrawCom(i),bhv.RingOuterRadius(1));
        endpa = endpa+bhv.FixRectCenter(1);
        endpb = -endpb+bhv.FixRectCenter(2);
        Eyelink('Command',sprintf('draw_line %f %f %f %f 15',starta, startb,endpa,endpb));
    end
    %Finish ITI
    if ~first_trial
        time_to_wait = (opts.ITITime - (GetSecs - StartTime)*1000)/1000;
        WaitSecs(time_to_wait);
        if time_to_wait < 0;
            sprintf('WARNING, over ITI by %.1f seconds',abs(time_to_wait));
        end
    end
    ShowCursor;
    if opts.RepeatError
        if ~first_trial
            if bhv.Trials(end).StopCondition ~= 1;
                beep;
                temp_trial = bhv.Trials(end);
            end
        end
    end
    temp_trial.StartTime = StartTime;
    
    
    %Display fixation
    Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white));
    Screen('FillOval', wPtr, floor(opts.FixColor*white), bhv.FixRect);
    Eyelink('Command',sprintf('draw_box %f %f %f %f 15',bhv.FixRect));%DRAWCOM
    
    Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
    [temp_trial.FixOnset_VBLTimestamp, temp_trial.FixOnset_StimulusOnsetTime] = Screen('Flip', wPtr);
    
    
    
    if opts.UseEyelink,
        %Get initial eye position
        [mx, my, Tms, pup] = EyelinkGetEyeSample(el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = [Tms, mx, my, pup]';
        
        WaitSecs(opts.ScreenDelay);
        send_trigger(ses,opts.Encodes.FIXATE_ON);
        Eyelink('message', 'FIXATE_ON');
    end
    [x,y] = RectCenter(bhv.FixRect);
    fprintf('Fixation at (%d, %d)\n', x, y);
    
    
    %Wait fixation time
    finished = 0;
    absolute_start = GetSecs;
    while ~finished
        %Acquire fixation
        temp_trial.AcquireFixWaitStart = GetSecs;
        disp('starting');
        [fix_acquired, eye_sig] = Eyelink_AcquireFixation_new(bhv.FixRectCenter(1), bhv.FixRectCenter(2), bhv.FixAcquireWindowRadius(1), bhv.FixAcquireWindowRadius(2), ...
            temp_trial.AcquireFixWaitStart, opts.MaxAcquireFixTime, el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
        if ~fix_acquired,
            [finished, nofix, bhv, TempEyeStruct, temp_trial] = error_nofix(white,ses,opts,el,bhv,temp_trial,TempEyeStruct,wPtr);
            continue;
        end    
        temp_trial.AcquireFixTime = GetSecs;
        send_trigger(ses,opts.Encodes.FIXATE_ACQUIRED);
        fprintf('Fixation acquired.\n');
        Eyelink('command','print_position 20 12'); %DRAWCOM
        Eyelink('command','echo fix_acq');%DRAWCOM
        %Wait fixation grace time
        WaitSecs(opts.FixGraceTime/1000);
        temp_trial.FixTime =  round(rand(1)*diff(opts.FixTime) + opts.FixTime(1));
        
        time_out = 5;
        nofix = 0;
        
        temp_trial.HoldFixWaitStart = GetSecs;
        [fix_acquired, eye_sig] = Eyelink_HoldFixation_new(bhv.FixRectCenter(1), bhv.FixRectCenter(2), bhv.FixHoldWindowRadius(1), bhv.FixHoldWindowRadius(2), ...
            temp_trial.HoldFixWaitStart, temp_trial.FixTime, el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
        
        
        if fix_acquired
            finished = 1;     
        elseif (absolute_start+time_out) < GetSecs
            [finished, nofix, bhv, TempEyeStruct, temp_trial] = error_nofix(white,ses,opts,el,bhv,temp_trial,TempEyeStruct,wPtr);
        else
            finished = 0;
        end
    end
    if nofix
        continue %#ok<UNRCH>
    end
    
    %Display cue stimulus at center
    if (opts.CueTime(temp_trial.Block) > 0),
        %Draw and wait
        Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white)); %clear screen
        if temp_trial.IsUpperSample,
            [sampx, sampy] = RectCenter(bhv.UpperSampleRect);
            coords = [bhv.ScreenCenter(1)-sqrt(.5).*bhv.ALineCueSize(1).*opts.ATailSize,     bhv.ScreenCenter(2)+sqrt(.5).*bhv.ALineCueSize(1).*opts.ATailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.ALineCueSize(2),      bhv.ScreenCenter(2)-sqrt(.5).*bhv.ALineCueSize(2)];
            Screen('DrawLine',wPtr,[0 0 0]./255,     bhv.ScreenCenter(1)-sqrt(.5).*bhv.ALineCueSize(1).*opts.ATailSize,     bhv.ScreenCenter(2)+sqrt(.5).*bhv.ALineCueSize(1).*opts.ATailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.ALineCueSize(2),      bhv.ScreenCenter(2)-sqrt(.5).*bhv.ALineCueSize(2),      16);
        else
            [sampx, sampy] = RectCenter(bhv.LowerSampleRect);
            coords = [ bhv.ScreenCenter(1)-sqrt(.5).*bhv.ALineCueSize(1).*opts.ATailSize,     bhv.ScreenCenter(2)-sqrt(.5).*bhv.ALineCueSize(1).*opts.ATailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.ALineCueSize(2),      bhv.ScreenCenter(2)+sqrt(.5).*bhv.ALineCueSize(2)];
            Screen('DrawLine',wPtr,[0 0 0]./255,     bhv.ScreenCenter(1)-sqrt(.5).*bhv.ALineCueSize(1).*opts.ATailSize,     bhv.ScreenCenter(2)-sqrt(.5).*bhv.ALineCueSize(1).*opts.ATailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.ALineCueSize(2),      bhv.ScreenCenter(2)+sqrt(.5).*bhv.ALineCueSize(2),      16);
        end
        Screen('FillOval', wPtr, floor(opts.FixColor*white), bhv.FixRect);
        Eyelink('Command',sprintf('draw_line %f %f %f %f 15',coords(1),coords(2),coords(3), coords(4)));
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        [temp_trial.Cue1Onset_VBLTimestamp, temp_trial.Cue1Onset_StimulusOnsetTime] = Screen('Flip', wPtr);
        send_trigger(ses,opts.Encodes.CUE1_ON);

        %Wait cue time
        [fix_acquired, eye_sig] = Eyelink_HoldFixation_new(bhv.FixRectCenter(1), bhv.FixRectCenter(2), bhv.FixHoldWindowRadius(1), bhv.FixHoldWindowRadius(2), ...
            [], opts.CueTime(temp_trial.Block), el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
        
        if ~fix_acquired,
            [bhv, TempEyeStruct, temp_trial] = error_fb(white,ses,opts,el,bhv,temp_trial,TempEyeStruct,wPtr);
            continue;
        end
    end %cue time
    
    %CueDelay
    %temp_trial.CueDelay = datasample(opts.CueDelay{temp_trial.Block},1);
    temp_trial.CueDelay = round(rand(1)*diff(opts.CueDelay{temp_trial.Block}) + opts.CueDelay{temp_trial.Block}(1));
    if  temp_trial.CueDelay>0,
        %Clear screen
        Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white)); %clear screen
        Screen('FillOval', wPtr, floor(opts.FixColor*white), bhv.FixRect);
        
        Eyelink('Command',sprintf('draw_box %f %f %f %f 0',bhv.CueRect));%DRAWCOM
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        [temp_trial.Delay1Onset_VBLTimestamp, temp_trial.Delay1Onset_StimulusOnsetTime] = Screen('Flip', wPtr);
        send_trigger(ses,opts.Encodes.DELAY1_START);
        
        %Wait cue delay time
        [fix_acquired, eye_sig] = Eyelink_HoldFixation_new(bhv.FixRectCenter(1), bhv.FixRectCenter(2), bhv.FixHoldWindowRadius(1), bhv.FixHoldWindowRadius(2), ...
            [], temp_trial.CueDelay, el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
        
        if ~fix_acquired,
            [bhv, TempEyeStruct, temp_trial] = error_fb(white,ses,opts,el,bhv,temp_trial,TempEyeStruct,wPtr);
            continue;
        end
    end
    
    %Display sample stimulus
    Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white)); %clear screen
    
    temp_trial.is_one_sample_displayed = 0;
    if 1%bhv.CurrentTrial<10;
        temp_trial.fadein = 1;
    else
        tempsc = [bhv.Trials.StopCondition]; tempc = tempsc==1;tempi = tempsc==-1;
        temp_trial.fadein = .6 + .01*sum(tempc) - .02*sum(tempi);
    end
    if temp_trial.fadein>1; temp_trial.fadein = 1; end;
    if temp_trial.fadein<0; temp_trial.fadein = 0; end;
    
    
    if rand < opts.ConditionSelect.PercSingle;
        tempcontrast = floor(opts.DisplayBackground.*white);
        temp_trial.is_one_sample_displayed = 1;
    else
        tempcontrast =  floor((temp_trial.fadein.*temp_trial.ColorDist+(1-temp_trial.fadein).*opts.DisplayBackground)*white)'; %9 is halfway around a 16 color circle
    end
    temp_trial.tempcontrast = tempcontrast;
    
    if opts.CueAndStimTime(temp_trial.Block)>0
        %Displaying the actual stimulus
        if temp_trial.IsUpperSample,
            Screen('FillRect', wPtr, floor(temp_trial.ColorTarget*white)', bhv.UpperSampleRect);
            Screen('FillRect', wPtr, tempcontrast, bhv.LowerSampleRect);
            upcol  = 14;
            if temp_trial.is_one_sample_displayed
                downcol = 0;
            else
                downcol = 15; %DRAWCOM
            end
        else
            Screen('FillRect', wPtr, floor(temp_trial.ColorTarget*white)', bhv.LowerSampleRect);
            Screen('FillRect', wPtr, tempcontrast, bhv.UpperSampleRect);
            downcol = 14; %DRAWCOM
            if temp_trial.is_one_sample_displayed
                upcol = 0;
            else
                upcol = 15; %DRAWCOM
            end
        end
        
        if temp_trial.IsUpperSample,
            Screen('DrawLine',wPtr,[0 0 0]./255,     bhv.ScreenCenter(1)-sqrt(.5).*bhv.LineCueSize(1).*opts.TailSize,     bhv.ScreenCenter(2)+sqrt(.5).*bhv.LineCueSize(1).*opts.TailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.LineCueSize(2),      bhv.ScreenCenter(2)-sqrt(.5).*bhv.LineCueSize(2),      16);
        else
            Screen('DrawLine',wPtr,[0 0 0]./255,     bhv.ScreenCenter(1)-sqrt(.5).*bhv.LineCueSize(1).*opts.TailSize,     bhv.ScreenCenter(2)-sqrt(.5).*bhv.LineCueSize(1).*opts.TailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.LineCueSize(2),      bhv.ScreenCenter(2)+sqrt(.5).*bhv.LineCueSize(2),      16);
        end
        
        Screen('FillOval', wPtr, floor(opts.FixColor*white), bhv.FixRect);
        Eyelink('Command',sprintf('draw_box %f %f %f %f %d',bhv.UpperSampleRect,upcol));%DRAWCOM
        Eyelink('Command',sprintf('draw_box %f %f %f %f %d',bhv.LowerSampleRect,downcol));%DRAWCOM
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        [temp_trial.StimOnset_VBLTimestamp, temp_trial.StimOnset_StimulusOnsetTime] = Screen('Flip', wPtr);
        send_trigger(ses,opts.Encodes.SAMPLES_ON);
        
        %Hold fixation for stim time
        [fix_acquired, eye_sig] = Eyelink_HoldFixation_new(bhv.FixRectCenter(1), bhv.FixRectCenter(2), bhv.FixHoldWindowRadius(1), bhv.FixHoldWindowRadius(2), ...
            [], opts.CueAndStimTime(temp_trial.Block), el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
        
        if ~fix_acquired,
            [bhv, TempEyeStruct, temp_trial] = error_fb(white,ses,opts,el,bhv,temp_trial,TempEyeStruct,wPtr);
            continue;
        end
    end
    
    if opts.StimTime(temp_trial.Block)>0
        %Displaying the actual stimulus
        if temp_trial.IsUpperSample,
            Screen('FillRect', wPtr, floor(temp_trial.ColorTarget*white)', bhv.UpperSampleRect);
            Screen('FillRect', wPtr, tempcontrast, bhv.LowerSampleRect);
            upcol  = 14;
            if temp_trial.is_one_sample_displayed
                downcol = 0;
            else
                downcol = 15; %DRAWCOM
            end
        else
            Screen('FillRect', wPtr, floor(temp_trial.ColorTarget*white)', bhv.LowerSampleRect);
            Screen('FillRect', wPtr, tempcontrast, bhv.UpperSampleRect);
            downcol = 14; %DRAWCOM
            if temp_trial.is_one_sample_displayed
                upcol = 0;
            else
                upcol = 15; %DRAWCOM
            end
        end
        Screen('FillOval', wPtr, floor(opts.FixColor*white), bhv.FixRect);
        Eyelink('Command',sprintf('draw_box %f %f %f %f %d',bhv.UpperSampleRect,upcol));%DRAWCOM
        Eyelink('Command',sprintf('draw_box %f %f %f %f %d',bhv.LowerSampleRect,downcol));%DRAWCOM
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        [temp_trial.StimOnset_VBLTimestamp, temp_trial.StimOnset_StimulusOnsetTime] = Screen('Flip', wPtr);
        send_trigger(ses,opts.Encodes.SAMPLES_ON);
        
        %Hold fixation for stim time
        [fix_acquired, eye_sig] = Eyelink_HoldFixation_new(bhv.FixRectCenter(1), bhv.FixRectCenter(2), bhv.FixHoldWindowRadius(1), bhv.FixHoldWindowRadius(2), ...
            [], opts.StimTime(temp_trial.Block), el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
        
        if ~fix_acquired,
            [bhv, TempEyeStruct, temp_trial] = error_fb(white,ses,opts,el,bhv,temp_trial,TempEyeStruct,wPtr)
            continue;
        end
    end
    
    %CueAndStimTime2
    if opts.CueAndStimTime2(temp_trial.Block)>0
        %Displaying the actual stimulus
        if temp_trial.IsUpperSample,
            Screen('FillRect', wPtr, floor(temp_trial.ColorTarget*white)', bhv.UpperSampleRect);
            Screen('FillRect', wPtr, tempcontrast, bhv.LowerSampleRect);
            upcol  = 14;
            if temp_trial.is_one_sample_displayed
                downcol = 0;
            else
                downcol = 15; %DRAWCOM
            end
        else
            Screen('FillRect', wPtr, floor(temp_trial.ColorTarget*white)', bhv.LowerSampleRect);
            Screen('FillRect', wPtr, tempcontrast, bhv.UpperSampleRect);
            downcol = 14; %DRAWCOM
            if temp_trial.is_one_sample_displayed
                upcol = 0;
            else
                upcol = 15; %DRAWCOM
            end
        end
        if temp_trial.IsUpperSample,
            %Screen('DrawLine',wPtr,[0 0 0]./255,     bhv.ScreenCenter(1)-sqrt(.5).*bhv.LineCueSize(1).*opts.TailSize,     bhv.ScreenCenter(2)+sqrt(.5).*bhv.LineCueSize(1).*opts.TailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.LineCueSize(2),      bhv.ScreenCenter(2)-sqrt(.5).*bhv.LineCueSize(2),      16);
            Screen('DrawLine',wPtr,[0 0 0]./255,     bhv.ScreenCenter(1)-sqrt(.5).*bhv.LineCueSize(1).*opts.TailSize,     bhv.ScreenCenter(2)+sqrt(.5).*bhv.LineCueSize(1).*opts.TailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.LineCueSize(2),      bhv.ScreenCenter(2)-sqrt(.5).*bhv.LineCueSize(2),      16);
        else
            Screen('DrawLine',wPtr,[0 0 0]./255,     bhv.ScreenCenter(1)-sqrt(.5).*bhv.LineCueSize(1).*opts.TailSize,     bhv.ScreenCenter(2)-sqrt(.5).*bhv.LineCueSize(1).*opts.TailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.LineCueSize(2),      bhv.ScreenCenter(2)+sqrt(.5).*bhv.LineCueSize(2),      16);
        end
        Screen('FillOval', wPtr, floor(opts.FixColor*white), bhv.FixRect);
        Eyelink('Command',sprintf('draw_box %f %f %f %f %d',bhv.UpperSampleRect,upcol));%DRAWCOM
        Eyelink('Command',sprintf('draw_box %f %f %f %f %d',bhv.LowerSampleRect,downcol));%DRAWCOM
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        [temp_trial.StimOnset_VBLTimestamp, temp_trial.StimOnset_StimulusOnsetTime] = Screen('Flip', wPtr);
        send_trigger(ses,opts.Encodes.SAMPLES_ON);
        
        %Hold fixation for stim time
        [fix_acquired, eye_sig] = Eyelink_HoldFixation_new(bhv.FixRectCenter(1), bhv.FixRectCenter(2), bhv.FixHoldWindowRadius(1), bhv.FixHoldWindowRadius(2), ...
            [], opts.CueAndStimTime2(temp_trial.Block), el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
        
        if ~fix_acquired,
            [bhv, TempEyeStruct, temp_trial] = error_fb(white,ses,opts,el,bhv,temp_trial,TempEyeStruct,wPtr);
            continue;
        end
    end
    
    temp_trial.CueDelay2 = datasample(opts.CueDelay2{temp_trial.Block},1);
    if temp_trial.CueDelay2>0,
        %Clear screen
        Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white)); %clear screen
        Screen('FillOval', wPtr, floor(opts.FixColor*white), bhv.FixRect);
        
        Eyelink('Command',sprintf('draw_box %f %f %f %f 0',bhv.CueRect));%DRAWCOM
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        [temp_trial.Delay2Onset_VBLTimestamp, temp_trial.Delay2Onset_StimulusOnsetTime] = Screen('Flip', wPtr);
        send_trigger(ses,opts.Encodes.DELAY2_START);
        
        %Wait cue delay time
        [fix_acquired, eye_sig] = Eyelink_HoldFixation_new(bhv.FixRectCenter(1), bhv.FixRectCenter(2), bhv.FixHoldWindowRadius(1), bhv.FixHoldWindowRadius(2), ...
            [], temp_trial.CueDelay2, el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
        
        if ~fix_acquired,
            [bhv, TempEyeStruct, temp_trial] = error_fb(white,ses,opts,el,bhv,temp_trial,TempEyeStruct,wPtr);
            continue;
        end
    end
    
    %CueTime2
    if (opts.CueTime2(temp_trial.Block) > 0),
        %Draw and wait
        Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white)); %clear screen
        toto=0;
        
        if temp_trial.IsUpperSample
            coords = [bhv.ScreenCenter(1)-sqrt(.5).*bhv.RLineCueSize(1).*opts.RTailSize,     bhv.ScreenCenter(2)+sqrt(.5).*bhv.RLineCueSize(1).*opts.RTailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.RLineCueSize(2),      bhv.ScreenCenter(2)-sqrt(.5).*bhv.RLineCueSize(2)];
            if temp_trial.Block == 2;
                Screen('DrawLine',wPtr,[0 0 0]./255,     bhv.ScreenCenter(1)-sqrt(.5).*bhv.RLineCueSize(1).*opts.RTailSize,     bhv.ScreenCenter(2)+sqrt(.5).*bhv.RLineCueSize(1).*opts.RTailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.RLineCueSize(2),      bhv.ScreenCenter(2)-sqrt(.5).*bhv.RLineCueSize(2),      16);
                temp_trial.CueAppearance = 1;
            elseif temp_trial.Block == 3;
                Screen('FillOval',wPtr, [0 0 0]./255,bhv.CueRect);
                temp_trial.CueAppearance = 2;
            end
        else
            coords = [bhv.ScreenCenter(1)-sqrt(.5).*bhv.RLineCueSize(1).*opts.RTailSize,     bhv.ScreenCenter(2)-sqrt(.5).*bhv.RLineCueSize(1).*opts.RTailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.RLineCueSize(2),      bhv.ScreenCenter(2)+sqrt(.5).*bhv.RLineCueSize(2)];
            if temp_trial.Block == 2;
                Screen('DrawLine',wPtr,[0 0 0]./255,     bhv.ScreenCenter(1)-sqrt(.5).*bhv.RLineCueSize(1).*opts.RTailSize,     bhv.ScreenCenter(2)-sqrt(.5).*bhv.RLineCueSize(1).*opts.RTailSize,      bhv.ScreenCenter(1)+sqrt(.5).*bhv.RLineCueSize(2),      bhv.ScreenCenter(2)+sqrt(.5).*bhv.RLineCueSize(2),      16);
                temp_trial.CueAppearance = 1;
            elseif temp_trial.Block == 3;
                [hor, vert] = pol2cart([pi/2 7*pi/6 11*pi/6]',repmat(bhv.RLineCueSize(1),3,1));
                hor = hor+bhv.ScreenCenter(1); vert = bhv.ScreenCenter(2) + vert;
                Screen('FillPoly',wPtr, [0 0 0]./255,[hor vert]);
                temp_trial.CueAppearance = 2;
            end
        end
        
        Screen('FillOval', wPtr, floor(opts.FixColor*white), bhv.FixRect);
        Eyelink('Command',sprintf('draw_line %f %f %f %f 15',coords(1),coords(2),coords(3), coords(4)));
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        [temp_trial.Cue2Onset_VBLTimestamp, temp_trial.Cue2Onset_StimulusOnsetTime] = Screen('Flip', wPtr);
        send_trigger(ses,opts.Encodes.CUE2_ON);
        
        %Wait cue time
        [fix_acquired, eye_sig] = Eyelink_HoldFixation_new(bhv.FixRectCenter(1), bhv.FixRectCenter(2), bhv.FixHoldWindowRadius(1), bhv.FixHoldWindowRadius(2), ...
            [], opts.CueTime2(temp_trial.Block), el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
        
        if ~fix_acquired,
            [bhv, TempEyeStruct, temp_trial] = error_fb(white,ses,opts,el,bhv,temp_trial,TempEyeStruct,wPtr)
            continue;
        end
    end %cue time
    
    %Delay
    if opts.FixTotalDelay;
        temp_trial.CueRespDelay = temp_trial.TotalDelay - temp_trial.CueDelay2 - opts.CueTime2(temp_trial.Block);
    else
        temp_trial.CueRespDelay = round(rand(1)*diff(opts.CueRespDelay{temp_trial.Block}) + opts.CueRespDelay{temp_trial.Block}(1));
    end
    
    if (temp_trial.CueRespDelay > 0),
        Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white));
        Screen('FillOval', wPtr, floor(opts.FixColor*white), bhv.FixRect);
        Eyelink('Command',sprintf('draw_box %f %f %f %f 0',bhv.UpperSampleRect));%DRAWCOM
        Eyelink('Command',sprintf('draw_box %f %f %f %f 0',bhv.LowerSampleRect));%DRAWCOM
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        [temp_trial.Delay3Onset_VBLTimestamp, temp_trial.Delay3Onset_StimulusOnsetTime] = Screen('Flip', wPtr);
        send_trigger(ses,opts.Encodes.DELAY3_START); 
        fprintf('sample off.\n');
        
        %Hold fixation for stim time
        [fix_acquired, eye_sig] = Eyelink_HoldFixation_new(bhv.FixRectCenter(1), bhv.FixRectCenter(2), bhv.FixHoldWindowRadius(1), bhv.FixHoldWindowRadius(2), ...
            [], temp_trial.CueRespDelay, el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
        
        if ~fix_acquired,
            [bhv, TempEyeStruct, temp_trial] = error_fb(white,ses,opts,el,bhv,temp_trial,TempEyeStruct,wPtr);
            continue;
        end
    end %target delay
    
    
    
    %Display target stimuli
    [x, y] = pol2cart(temp_trial.AnglesFinal(1),bhv.ResponseBoundEccentricityDVA(1));
    Eyelink('Command',sprintf('draw_cross %f %f 15',x+bhv.ScreenCenter(1),-y+bhv.ScreenCenter(2)));
    Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white));
    for i = 1:size(temp_trial.WheelRGB,1);
        Screen('FrameArc',wPtr,floor(temp_trial.WheelRGB(i,:)*white),bhv.TargRingRect,temp_trial.AnglesFinalPsychToolbox(i),bhv.TargArcAngle,opts.ArcWidthPix);
    end
    Screen('FillOval', wPtr, [0 0 0], bhv.FixRect); %black fixation spot
    Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
    [temp_trial.TargetOnset_VBLTimestamp, temp_trial.TargetOnset_StimulusOnsetTime] = Screen('Flip', wPtr);
    send_trigger(ses,opts.Encodes.WHEEL_ON); 
    fprintf('targets displayed.\n');
   

    
    
    
    %Make saccade to target location - see where he "breaks" on a ring just
    %shy of the target ring
    [fix_acquired, eye_sig] = Eyelink_HoldFixation_new(bhv.FixRectCenter(1), bhv.FixRectCenter(2), bhv.ResponseBoundEccentricityDVA,bhv.ResponseBoundEccentricityDVA, ...
        [], opts.MaxReactionTime, el, bhv.EyeUsed);
    
    TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
    if any(fix_acquired), %he didnt look at the ring
        %One last eye sample
        [mx, my, Tms, pup] = EyelinkGetEyeSample(el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, [Tms, mx, my, pup]');
        
        fprintf('no acquire fixation.\n');
        Eyelink('message', 'NO_RESPONSE_TRIAL');
        send_trigger(ses,opts.Encodes.NO_RESPONSE_TRIAL); 
        %Display Error
        Screen('FillRect', wPtr, floor(opts.ErrorBackground.*white));
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        Screen('Flip', wPtr);
        temp_trial.StopCondition = -2; %no response
        
        
        
        WaitSecs(opts.FixBreakErrorTimeout/1000);
        Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white));
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        Screen('Flip', wPtr);
        
        send_trigger(ses,opts.Encodes.END_TRIAL);  %flush
        Eyelink('message', 'END_TRIAL');
        send_trigger(ses,opts.Encodes.END_TRIAL);  %flush
        send_trigger(ses,opts.Encodes.END_TRIAL);  %flush
        drained = 0; TempEyeStruct.Eye.Samples = []; TempEyeStruct.Eye.Events = [];
        while ~drained,
            [samples, events, drained] = Eyelink('GetQueuedData');
            TempEyeStruct.Eye.Samples = cat(2, TempEyeStruct.Eye.Samples, samples);
            TempEyeStruct.Eye.Events = cat(1, TempEyeStruct.Eye.Events, events);
        end
        
        %increment bhv
        bhv.Trials(bhv.CurrentTrial) = temp_trial;
        
        continue;
    end
    
    %if we got here, he looked at the ring. calculate RT and dT
    temp_trial.AcquireTargetTime = GetSecs;
    send_trigger(ses,opts.Encodes.TARGET_FIX);
    fprintf('Fixation acquired on ring.\n');
    %Reaction Time
    temp_trial.ReactionTime = (temp_trial.AcquireTargetTime - temp_trial.TargetOnset_VBLTimestamp);    
    %response angle
    temp_trial.ResponseCoordinate = eye_sig(2:3,end)' - bhv.ScreenCenter;
    [temp_trial.ResponseTheta, temp_trial.ResponseRadius] = cart2pol(temp_trial.ResponseCoordinate(1),-1*temp_trial.ResponseCoordinate(2));
    if temp_trial.ResponseTheta<0;temp_trial.ResponseTheta=temp_trial.ResponseTheta+2*pi;end
    [toto, temp_trial.ResponseLocationIndex] = min(abs(wrap(temp_trial.ResponseTheta - temp_trial.AnglesFinal)));
    temp_trial.deltaTheta = wrap(temp_trial.ResponseTheta - temp_trial.TargetTheta);
    temp_trial.deltaTheta_dist = wrap(temp_trial.ResponseTheta - temp_trial.DistTheta);
    temp_trial.LABthetaResp = wrap(temp_trial.ResponseTheta+wrap(temp_trial.LABthetaTarget-temp_trial.TargetTheta));
    
    if (abs(temp_trial.deltaTheta)*180/pi>opts.LowerCutoff) %if error
        
        %One last eye sample
        [mx, my, Tms, pup] = EyelinkGetEyeSample(el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, [Tms, mx, my, pup]');
        
        fprintf('Fixation acquired at distractor.\n');
        Eyelink('message', 'INCORRECT_TRIAL');
        send_trigger(ses,opts.Encodes.INCORRECT_TRIAL);
        
        Eyelink('command','print_position 20 13'); %DRAWCOM
        Eyelink('command','echo incorrect');%DRAWCOM
        
        %remove fixation and distractor
        Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white));
        
        
        Screen('FillOval', wPtr, floor(opts.FixColor*black), bhv.FixRect); %fixation spot
        
        %diplay selected region:
        % Screen('FrameArc',wPtr,floor(temp_trial.Color(temp_trial.ResponseLocationIndex,:)*white),bhv.TargRingRect,temp_trial.AnglesFinalPsychToolbox(temp_trial.ResponseLocationIndex),bhv.TargArcAngle,opts.ArcWidthPix);
        %diplay correct location:
        Screen('FrameArc',wPtr,floor(temp_trial.ColorTarget*white),bhv.TargRingRect,temp_trial.AnglesFinalPsychToolbox(1),bhv.TargArcAngle,opts.ArcWidthPix);

        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        Screen('Flip', wPtr);
        send_trigger(ses,opts.Encodes.FEEDBACK_ON);
        fprintf('feedback on.\n');
        pause(1)
        
        %Display Error
        Screen('FillRect', wPtr, floor(opts.ErrorBackground.*white));
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        Screen('Flip', wPtr);
        temp_trial.StopCondition = -1; %incorrect
        
        
        
        WaitSecs(opts.IncorrectErrorTimeout/1000);
        Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white));
        Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
        Screen('Flip', wPtr);
        
        send_trigger(ses,opts.Encodes.END_TRIAL); %flush
        Eyelink('message', 'END_TRIAL');
        send_trigger(ses,opts.Encodes.END_TRIAL);  %flush
        send_trigger(ses,opts.Encodes.END_TRIAL);  %flush
        drained = 0; TempEyeStruct.Eye.Samples = []; TempEyeStruct.Eye.Events = [];
        while ~drained,
            [samples, events, drained] = Eyelink('GetQueuedData');
            TempEyeStruct.Eye.Samples = cat(2, TempEyeStruct.Eye.Samples, samples);
            TempEyeStruct.Eye.Events = cat(1, TempEyeStruct.Eye.Events, events);
        end
        
        %increment bhv
        bhv.Trials(bhv.CurrentTrial) = temp_trial;
        
        continue;
    end
    
    %Hold fixation at target for a bit
    if (opts.TargetHoldTime > 0),
        
        
        
        [fix_acquired, eye_sig] = Eyelink_HoldFixation_new(bhv.TargetRectCenter(temp_trial.LocationsFinal(temp_trial.ResponseLocationIndex), 1), bhv.TargetRectCenter(temp_trial.LocationsFinal(temp_trial.ResponseLocationIndex), 2), bhv.TargHoldWindowRadius(1), bhv.TargHoldWindowRadius(2), ...
            [], opts.TargetHoldTime, el, bhv.EyeUsed);
        TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, eye_sig);
        
        
        
        if ~fix_acquired,
            %One last eye sample
            [mx, my, Tms, pup] = EyelinkGetEyeSample(el, bhv.EyeUsed);
            TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, [Tms, mx, my, pup]');
            
            fprintf('target fixation not held.\n');
            Eyelink('message', 'FIX_BREAK_TRIAL');
            send_trigger(ses,opts.Encodes.FIX_BREAK_TRIAL);
            
            Eyelink('command','print_position 20 13'); %DRAWCOM
            Eyelink('command','echo targ_fix_not_held');%DRAWCOM
            %Display Error
            
            Screen('FillRect', wPtr, floor(opts.TargFixNotHeldErrorBackground.*white));
            Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
            Screen('Flip', wPtr);
            temp_trial.StopCondition = -3; %fixation lost
            
            
            
            WaitSecs(opts.FixBreakErrorTimeout/1000);
            Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white));
            Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
            Screen('Flip', wPtr);
            
            send_trigger(ses,opts.Encodes.END_TRIAL);  %flush
            Eyelink('message', 'END_TRIAL');
            send_trigger(ses,opts.Encodes.END_TRIAL);  %flush
            send_trigger(ses,opts.Encodes.END_TRIAL);  %flush
            drained = 0; TempEyeStruct.Eye.Samples = []; TempEyeStruct.Eye.Events = [];
            while ~drained,
                [samples, events, drained] = Eyelink('GetQueuedData');
                TempEyeStruct.Eye.Samples = cat(2, TempEyeStruct.Eye.Samples, samples);
                TempEyeStruct.Eye.Events = cat(1, TempEyeStruct.Eye.Events, events);
            end
            
            %increment bhv
            bhv.Trials(bhv.CurrentTrial) = temp_trial;
            
            continue;
        end
    end
    %remove fixation and distractor
    Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white));
    
    Screen('FillOval', wPtr, floor(opts.FixColor*black), bhv.FixRect); %fixation spot
    %diplay selected region:
    % Screen('FrameArc',wPtr,floor(temp_trial.Color(temp_trial.ResponseLocationIndex,:)*white),bhv.TargRingRect,temp_trial.AnglesFinalPsychToolbox(temp_trial.ResponseLocationIndex),bhv.TargArcAngle,opts.ArcWidthPix);
    %diplay correct location:
    Screen('FrameArc',wPtr,floor(temp_trial.ColorTarget*white),bhv.TargRingRect,temp_trial.AnglesFinalPsychToolbox(1),bhv.TargArcAngle,opts.ArcWidthPix);
    Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
    Screen('Flip', wPtr);
    send_trigger(ses,opts.Encodes.FEEDBACK_ON);
    %Eyelink('Command',sprintf('draw_box %f %f %f %f 0',bhv.TargetRect(temp_trial.DistractLocations, :)));%DRAWCOM
    fprintf('targets displayed.\n');
    
    %If we got here, correct trial
    if opts.UseEyelink,
        Eyelink('message', 'CORRECT');
        send_trigger(ses,opts.Encodes.CORRECT_TRIAL);
    end
    temp_trial.StopCondition = 1; %completed trial
    
    
    
    
    switch opts.rewardtype
        case 'standard'
            TempRewards = opts.NumRewards;
        case 'delta'
            TempRewards = ceil(1./([temp_trial.deltaTheta]+.1));
        case 'theta'
            TempRewards = bhv.thetareward(ceil((abs(temp_trial.deltaTheta)+.001)*180/pi));
        case 'jackpot'
            if rand > .95
                TempRewards = 25;
            else
                TempRewards = opts.NumRewards;
            end
        case 'rt-dependent'
            if temp_trial.ReactionTime > .15
                TempRewards = opts.NumRewards*2;
            else
                TempRewards = opts.NumRewards;
            end
        case 'hold-dependent'
            if rand > .99
                TempRewards = 30;
            else
                TempRewards = floor(temp_trial.presaccade_hold/100)*2 - 5;
            end
        case 'climbing'
            
            if first_trial;
                TempRewards = opts.NumRewards;
            elseif bhv.Trials(end).StopCondition == 1;
                TempRewards = TempRewards *2;
            elseif bhv.Trials(end).StopCondition ~= 1;
                TempRewards = opts.NumRewards;
            else
                error('bad if statement');
            end
            
            if TempRewards > 32;
                TempRewards = 32;
            end
            
        case 'targloc'
            rewards = [9 9 9 9 18];
            TempRewards = rewards(temp_trial.TargetLocation);
    end
    
    %Deliver rewards
    WaitSecs(opts.RewardDelay./1000 - temp_trial.ReactionTime);
    temp_trial.RewardOnset_StimulusOnsetTime = GetSecs;
    send_trigger(ses,opts.Encodes.REWARD);
    
    for cur_drop = 1:TempRewards
        data_in = io32(ioObj, opts.ParallelPort.Address);
        base_data_out = bitset(data_in, opts.ParallelPort.RewardBit, 0);
        rew_data_out = bitset(data_in, opts.ParallelPort.RewardBit, 1);
        
        %Give reward
        io32(ioObj, opts.ParallelPort.Address, rew_data_out);
        WaitSecs(opts.RewardPulse/1000);
        io32(ioObj, opts.ParallelPort.Address, base_data_out);
        WaitSecs(opts.InterRewardDelay/1000);
    end
    Screen('FillRect', wPtr, floor(opts.DisplayBackground.*white));
    Screen('FillRect',wPtr,[white white white].*mod(bhv.pd_state,2),bhv.pdRect); bhv.pd_state = bhv.pd_state+1;
    [toto, temp_trial.TrialEndTime] = Screen('Flip', wPtr);
    
    %One last eye sample
    [mx, my, Tms, pup] = EyelinkGetEyeSample(el, bhv.EyeUsed);
    TempEyeStruct.EyeSig = cat(2, TempEyeStruct.EyeSig, [Tms, mx, my, pup]');
    
    %Update Eyelink
    send_trigger(ses,opts.Encodes.END_TRIAL);  %flush
    Eyelink('message', 'END_TRIAL');
    send_trigger(ses,opts.Encodes.END_TRIAL);  %flush
    send_trigger(ses,opts.Encodes.END_TRIAL);  %flush
    drained = 0; TempEyeStruct.Eye.Samples = []; TempEyeStruct.Eye.Events = [];
    while ~drained,
        [samples, events, drained] = Eyelink('GetQueuedData');
        TempEyeStruct.Eye.Samples = cat(2, TempEyeStruct.Eye.Samples, samples);
        TempEyeStruct.Eye.Events = cat(1, TempEyeStruct.Eye.Events, events);
    end
    
    
    %Compress eye signal a bit
    %[~, uniq_ind] = unique(TempEyeStruct.EyeSig(1, :));
    %TempEyeStruct.EyeSig = single(TempEyeStruct.EyeSig(:,uniq_ind));
    TempEyeStruct.EyeSig = single(TempEyeStruct.EyeSig);
    
    %increment bhv
    bhv.Trials(bhv.CurrentTrial) = temp_trial;
    
    fprintf('Trial %4.0f [%s]: %d correct, RT: %3.2f (Avg. RT: %3.1f)\n', bhv.CurrentTrial, datestr(now, 'HH:MM:SS'), sum([bhv.Trials(:).StopCondition] == 1), bhv.Trials(end).ReactionTime*1000, nanmean([bhv.Trials(:).ReactionTime]*1000));
    
    
    
end

send_trigger(ses,opts.Encodes.TASKID);
send_trigger(ses,opts.Encodes.TASKID);
send_trigger(ses,opts.Encodes.TASKID);


bhv.EndTime = GetSecs;
bhv.EyeStruct = EyeStruct;
%% Save to file and clear everything
if opts.UseEyelink,
    Eyelink('message', 'END_TASK');
    Eyelink('command', 'close_data_file');
    Eyelink('Shutdown');
end
Screen('CloseAll');
ShowCursor;
KbQueueStop(KbDeviceIndex);

%Create some simple statistics
bhv.NumTrials = length(bhv.Trials);

%Update options
bhv.opts = opts;
bhv.V = Vs;
if opts.SaveData,
    ColorAngles = bhv.Trials(end).ColorAngles; save('ColorAngles','ColorAngles');
    save(bhv.SaveFilename, 'bhv','-append');
    copyfile([mfilename '.m'],[bhv.SaveFilename(1:end-4) '.txt']);
end


