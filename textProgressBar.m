classdef textProgressBar < handle
    % TEXTPROGRESSBAR Text-based progress bar
    % This class implements a customizable text-based progress bar.
    % Features:
    %   - Shows the percentage and the progress bar
    %   - Updates every 100 ms (customizable)
    %   - Shows iterations/second (toggleable)
    %   - Prints optional messages in the command window (toggleable)
    %   - Can add a prefix to the progress bar (toggleable/customizable)
    % 
    % Use:
    %   Constructor:
    %       textProgressBar(nSteps)
    %       textProgressBar(nSteps,Name,Value)
    %
    %   Methods:
    %       step()
    %       step(displayProgress)
    %       step(displayProgress,appendMessage)
    %       step(displayProgress,appendMessage,scrollMessage)
    %       step(displayProgress,appendMessage,scrollMessage,manualStep)
    %
    %   % Inputs:
    %       nSteps          Integer     Expected number of steps.
    %       Name,Value                  Name-value pairs (see below).
    %       displayProgress Logical     Forces behaviour of the print
    %                                   output.
    %       appendMessage   String      Append a custom message at each
    %                                   iteration after the progress bar,
    %                                   or iteration metrics.
    %       scrollMessage   String      Prints a custom message in the
    %                                   command window that will scroll
    %                                   normally.
    %       manualStep      Integer     Forces the progress bar to show a
    %                                   specific percentage instead of the
    %                                   computed one.
    %
    % Name-value pairs:
    %   showitermetrics     Logical     Displays iterations/second
    %   prefix              String      Displays a short message which
    %                                   precedes the progress bar
    %   limitFrequency      number      Upper limit to the update frequency
    %                                   of the text output
    %
    % Examples:
    %   A simple example
    %       n = 100;
    %       tpb = textProgressBar(n)
    %       for ii = 1:n
    %           tpb.step();
    %           pause(0.2);
    %       end
    %
    %   A more complex example
    %       n = 100;
    %       tpb = textProgressBar(n, 'showitermetrics', true, ...
    %           'prefix', 'Dummy cycle', 'limitFrequency', 20);
    %       for ii = 1:n
    %           suffixMsg = sprintf('Custom message (%i)',ii);
    %           scrollMsg = sprintf('Scrolling message (%i/%i)\n',ii,n);
    %           tpb.step(true, suffixMsg, scrollMsg);
    %           pause(0.2);
    %       end
    %
    % Author: Stefano Seriani (serianik(at)gmail(dot)com)
    
    properties
        initTime
        nSteps
        currStep
        nCharsWritten
        msg
        lastMsgTimeStamp
        minUpdateInterval
        showitermetrics
        barChar
        version
    end
    
    methods
        % Constructor
        % =================================================================
        function obj = textProgressBar(nSteps, varargin)
            % Parse inputs
            p = inputParser();
            validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            validLogical = @(x) islogical(x) || isnumeric(x);
            validString = @(x) isstring(x) || ischar(x);
            addRequired(p,'nSteps',validScalarPosNum);
            addParameter(p,'showitermetrics', false, validLogical);
            addParameter(p,'prefix', '', validString);
            addParameter(p,'limitFrequency', 10, validScalarPosNum);
            p.parse(nSteps, varargin{:})
            
            % Save to properties
            obj.nSteps = p.Results.nSteps;
            obj.msg = p.Results.prefix;
            obj.showitermetrics = p.Results.showitermetrics;
            obj.minUpdateInterval = seconds(1/p.Results.limitFrequency);
            obj.initTime = datetime('now');
            obj.currStep = 0;
            obj.nCharsWritten = 0;
            obj.lastMsgTimeStamp = datetime('now');
%             obj.barChar = char(9608); % █
%             obj.barChar = char(9724); % ◼
%             obj.barChar = char(9611); % ▍
%             obj.barChar = char(10714); % ⧚
            obj.barChar = char(9642); % ▪
            obj.version = 'simple';
        end
        
        function obj = step(obj, varargin)
            switch numel(varargin)
                case 0
                    displayProgress = true;
                    appendMessage = '';
                    scrollMessage = '';
                    manualStep = [];
                case 1
                    displayProgress = varargin{1};
                    appendMessage = '';
                    scrollMessage = '';
                    manualStep = [];
                case 2
                    displayProgress = varargin{1};
                    appendMessage = varargin{2};
                    scrollMessage = '';
                    manualStep = [];
                case 3
                    displayProgress = varargin{1};
                    appendMessage = varargin{2};
                    scrollMessage = varargin{3};
                    manualStep = [];
                case 4
                    displayProgress = varargin{1};
                    appendMessage = varargin{2};
                    scrollMessage = varargin{3};
                    manualStep = varargin{4};
            end
            if isempty(manualStep)
                obj.currStep = obj.currStep + 1;
            else
                obj.currStep = manualStep;
            end
            
            % Calculate percentage
            percent_done = obj.currStep/obj.nSteps * 100;
            
            % Now decide if it's time to display
            if displayProgress && percent_done < 100
                elapsedTime = datetime('now') - obj.lastMsgTimeStamp;
                displayProgress = elapsedTime >= obj.minUpdateInterval;
            end
            if displayProgress
                num_char = 21;
                switch obj.version
                    case 'advanced'
                        k = 1/7/num_char;
                        num_barChars = floor(percent_done/100*num_char);
                        percent_rem = percent_done/100 - num_barChars/num_char;
                        if percent_rem < 1*k
                            remChar = char(9615);
                        elseif percent_rem < 2*k
                            remChar = char(9614);
                        elseif percent_rem < 3*k
                            remChar = char(9613);
                        elseif percent_rem < 4*k
                            remChar = char(9611);
                        elseif percent_rem < 5*k
                            remChar = char(9610);
                        elseif percent_rem < 6*k
                            remChar = char(9609);
                        elseif percent_rem < 7*k
                            remChar = char(9608);
                        end
                        num_spaces = num_char - num_barChars;
                        spaces = repmat(' ',1,num_spaces);
                        barChars = [repmat(obj.barChar, 1, num_barChars), remChar];
                    case 'simple'
                        num_barChars = floor(percent_done/100*num_char);
                        num_spaces = num_char - num_barChars;
                        spaces = repmat(' ',1,num_spaces);
                        barChars = repmat(obj.barChar, 1, num_barChars);
                end
                percent = sprintf('%6.2f',percent_done);
                ETAstr = datetime2str(obj.calcETA());
                if obj.showitermetrics
                    elapsedTimeSinceInit = datetime('now') - obj.initTime;
                    iterMetricsStr = sprintf('%.3f iter/s', obj.currStep/seconds(elapsedTimeSinceInit));
                else
                    iterMetricsStr = '';
                end
                strToPrint = sprintf([ ...
                    obj.msg, '[', barChars, spaces, '] ', ...
                    percent, '%%  ETA: ', ETAstr, '  ', ...
                    iterMetricsStr, appendMessage, '  \n']);

                % Build the string to cancel previously written stuff
                cancel_str = repmat(sprintf('\b'), 1, obj.nCharsWritten);
                
                % Update the n. of chars written with the last string
                obj.nCharsWritten = numel(strToPrint);

                % Output the final string
                if percent_done == 100
                    elapsedTime = datetime('now') - obj.initTime;
                    showDecimals = elapsedTime <= 60;
                    out = [cancel_str scrollMessage strcat(strToPrint,sprintf(' done %s',datetime2str(elapsedTime, showDecimals)))];
                    fprintf('%s\n', out)
                else
                    out = [cancel_str scrollMessage strToPrint];
                    fprintf('%s', out)
                end
                obj.lastMsgTimeStamp = datetime('now');
            end
        end
        
        function ETA = calcETA(obj)
            timeElapsed = datetime('now') - obj.initTime;
            timePerStep = timeElapsed/obj.currStep;
            stepsRemaining = obj.nSteps - obj.currStep;
            ETA = timePerStep * stepsRemaining;
        end
    end
end

function out = datetime2str(in, varargin)
    if isempty(varargin)
        decimals = false;
    else
        decimals = varargin{1};
    end
    if decimals
        decPlacesStr = 'HH:MM:SS.FFF';
    else
        decPlacesStr = 'HH:MM:SS';
    end
    out = datestr(in,decPlacesStr);
end




















