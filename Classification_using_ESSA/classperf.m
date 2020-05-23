function CPO = classperf(CP,varargin)
%CLASSPERF evaluates the performance of data classifiers
% 



if nargin == 0
    if nargout 
        error('Bioinfo:classperf:TooManyOutputArguments',...
        'When there are not input arguments, CLASSPERF cannot have output arguments.')
    end
    displayProperties
    return
end

% set some defaults
gpsWereGiven = false;

% if the first input is the GROUNDTRUTH we need to create and initialize
% the new CP object
if ~isequal(class(CP),'classperformance')
    if isa(CP,'ordinal')||isa(CP,'nominal')
        CP = cellstr(CP(:));
    end
    % validate ground truth labels
    gT = CP(:);
    if iscell(gT)
        if any(~cellfun('isclass',gT,'char'))
            error('Bioinfo:classperf:InvalidCellForGT',...
                'Ground truth cell must be all strings.')
        end
        if ismember('',gT)
            error('Bioinfo:classperf:EmptyCellForGT',...
                'Empty strings are not allowed in the ground truth vector.')
        end
        [igT,validGroups] = grp2idx(gT);
    elseif isnumeric(gT) || islogical(gT)
        if islogical(gT)
            gT = double(gT);
        end
        if ~isreal(gT) || any(isnan(gT)) || any(rem(gT,1)) 
            error('Bioinfo:classperf:InvalidNumericForGT',...
                'Ground truth array is not valid.')
        end
        [validGroups,~,igT] = unique(gT); 
    else
        error('Bioinfo:classperf:InvalidTypeForGT',...
            'Ground truth must be a cell of strings or a numeric array.')
    end
    if max(igT)<2
         error('Bioinfo:classperf:InvalidGroupsForGT',...
            'Ground truth must have at least two classes.')
    end
    % Creates and initializes the CP object
    CP = classperformance(validGroups,igT);
end

if nargin == 1 
    CPO=CP; 
    return; 
end
nvarargin =  numel(varargin);

% check if the second input is CLASSOUT and validate it
if ~ischar(varargin{1})
    gps = varargin{1}(:);
    if isa(gps,'ordinal')||isa(gps,'nominal')
        gps = cellstr(gps(:));
    end
    nvarargin = nvarargin-1;
    varargin(1) = [];
    if CP.IsClassLabelTypeNumeric
        if islogical(gps)
            gps = double(gps); %allow gps is logical when groundTruth is double
        end
        if ~isnumeric(gps) || ~isreal(gps) || any(gps(~isnan(gps))<0) || any(rem(gps(~isnan(gps)),1))
            error('Bioinfo:classperf:InvalidNumericForGRP',...
                ['When the class labels of the CP object are numeric, the output\n'...
                'of the classifier must be all non-negative integers or NaN''s.'])
        end
        [~,gps] = ismember(gps,CP.ClassLabels);
    elseif iscell(gps)
        if any(~cellfun('isclass',gps(:),'char'))
            error('Bioinfo:classperf:InvalidCellForGRP',...
                  ['When the classifier output is a cell array of strings,\n',...
                   'all elements must have strings.'])
        end
        [~,gps] = ismember(gps,CP.ClassLabels);
    elseif isnumeric(gps)
        if ~isreal(gps) || any(gps(~isnan(gps))<0) || any(rem(gps(~isnan(gps)),1))
            error('Bioinfo:classperf:InvalidIndicesForGRP',...
                ['When class labels of the CP object is a cell array of strings and\n',...
                 'the classifier output is a numeric array, it must contain valid\n',...
                 'indices of the class labels or NaNs for inconclusive results.'])
        end
    else
        error('Bioinfo:classperf:InvalidTypeForGRP',...
              ['CLASSOUT should be the same type as the ground truth vector\n'...
               'or a vector index to the class labels.'])
    end
    gpsWereGiven = true;
end

% check if the third input is TESTIDX 
if nvarargin && (islogical(varargin{1}) || isnumeric(varargin{1}))
    idx = varargin{1}(:);
    nvarargin = nvarargin-1;
    varargin(1) = [];
elseif gpsWereGiven
    if numel(gps)~=CP.NumberOfObservations
        error('Bioinfo:classperf:IncorrectSizeForClassout',...
            ['The classifier output CLASSOUT does not have the same size\n',...
            'as the ground truth and there was not any TESTIDX provided.']);        
    end
    idx = 1:CP.NumberOfObservations;
end

% the rest should can only be optional arguments (i.e. set
% negative/positive class labels)
if nvarargin
    positiveLabels = CP.TargetClasses;
    negativeLabels = CP.ControlClasses;
    if rem(nvarargin,2)
        error('Bioinfo:classperf:IncorrectNumberOfArguments',...
            'Incorrect number of arguments to %s.',mfilename);
    end
    okargs = {'positive','negative'};
    for j=1:2:nvarargin
        pname = varargin{j};
        pval = varargin{j+1};
        k = find(strncmpi(pname, okargs,length(pname)));
        if isempty(k)
            error('Bioinfo:classperf:UnknownParameterName',...
                'Unknown parameter name: %s.',pname);
        elseif length(k)>1
            error('Bioinfo:classperf:AmbiguousParameterName',...
                'Ambiguous parameter name: %s.',pname);
        else
            switch(k)
                case 1 % positiveLabels
                    if isa(pval,'ordinal')||isa(pval,'nominal')
                        pval = cellstr(pval(:));
                    end
                    if CP.IsClassLabelTypeNumeric
                        [tf,loc] = ismember(pval,CP.ClassLabels);
                        if any(~tf) || isempty(tf)
                            error('Bioinfo:classperf:InvalidPositiveLabels',...
                                'At least one of the positive labels is not within the valid class labels.')
                        end
                        positiveLabels = loc;
                    else
                        if ischar(pval)
                            pval = {pval};
                        end
                        if ~iscell(pval) || ~all(cellfun('isclass',pval,'char'))
                            error('Bioinfo:classperf:InvalidPositiveLabels',...
                                'Invalid type for the positive labels.')
                        end
                        [tf,loc] = ismember(pval,CP.ClassLabels);
                        if any(~tf) || isempty(tf)
                            error('Bioinfo:classperf:InvalidPositiveLabels',...
                                'At least one of the positive labels is not within the valid class labels.')
                        end
                        positiveLabels = loc;
                    end
                case 2 % negativeLabels
                    if isa(pval,'ordinal')||isa(pval,'nominal')
                        pval = cellstr(pval(:));
                    end
                    if CP.IsClassLabelTypeNumeric
                        [tf,loc] = ismember(pval,CP.ClassLabels);
                        if any(~tf) || isempty(tf)
                            error('Bioinfo:classperf:InvalidNegativeLabels',...
                                'At least one of the negative labels is not within the valid class labels.')
                        end
                        negativeLabels = loc;
                    else
                        if ischar(pval)
                            pval = {pval};
                        end
                        if ~iscell(pval) || ~all(cellfun('isclass',pval,'char'))
                            error('Bioinfo:classperf:InvalidNegativeLabels',...
                                'Invalid type for negative labels.')
                        end
                        [tf,loc] = ismember(pval,CP.ClassLabels);
                        if any(~tf) || isempty(tf)
                            error('Bioinfo:classperf:InvalidNegativeLabels',...
                                'At least one of the negative labels is not within the valid class labels.')
                        end
                        negativeLabels = loc;
                    end
            end
        end
    end
    % check that diagnostic test labels do not collide
    if ~isempty(intersect(positiveLabels,negativeLabels))
        error('Bioinfo:classperf:InvalidPositiveNegativeLabels',...
            'Positive and negative class labels must be disjoint sets.')
    else
        CP.TargetClasses  = positiveLabels;
        CP.ControlClasses = negativeLabels;
    end
end

% I am done creating the object with new pos and neg, now I can leave
if ~gpsWereGiven
    CPO = CP;
    return
end

% validate idx
if islogical(idx)
    if numel(idx)~=CP.NumberOfObservations
        error('Bioinfo:classperf:InvalidLogicalIndex',...
              'Size of the logical index vector must be [NumberOfObservations x 1].')
    end
    if sum(idx)~=numel(gps)
        error('Bioinfo:classperf:InvalidLogicalIndex',...
              'There must be as many TRUE indices in TESTIDX as classifier outputs.')
    end
    idx = find(idx);
else % it is a vector of indices
    if numel(unique(idx))~=numel(idx) || max(idx)>CP.NumberOfObservations || min(idx)<0 || any(rem(idx,1)>0)
        error('Bioinfo:classperf:InvalidNumericIndex',...
              'Index vector has invalid values.')
    end
    if numel(idx)~=numel(gps)
        error('Bioinfo:classperf:InvalidNumericIndex',...
              'There must be as many indices in TESTIDX as classifier outputs.')
    end
end

% CP and all input arguments should be valid now, do the update
%updateValidation(CP,gps,idx);
    
CPO = CP;  

                                  

function displayProperties
%blpk = findpackage('biolearning');
cls = findclass('classperformance');
p = get(cls,'Properties');
names = get(p,'Name');
disp('CLASSPERFORMANCE object public properties:')
disp(names(strcmp(get(p,'Visible'),'on')))