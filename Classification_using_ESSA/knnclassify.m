function outClass = knnclassify(sample, TRAIN, group, K, distance,rule)
%KNNCLASSIFY classifies data using the nearest-neighbor method



%nargin(nargin,3,mfilename)

% grp2idx sorts a numeric grouping var ascending, and a string grouping
% var by order of first occurrence
[gindex,groups] = grp2idx(group);
nans = find(isnan(gindex));
if ~isempty(nans)
    TRAIN(nans,:) = [];
    gindex(nans) = [];
end
ngroups = length(groups);

[n,d] = size(TRAIN);
if size(gindex,1) ~= n
    error('Bioinfo:knnclassify:BadGroupLength',...
        'The length of GROUP must equal the number of rows in TRAINING.');
elseif size(sample,2) ~= d
    error('Bioinfo:knnclassify:SampleTrainingSizeMismatch',...
        'SAMPLE and TRAINING must have the same number of columns.');
end
m = size(sample,1);

if nargin < 4
    K = 1;
elseif ~isnumeric(K)
    error('Bioinfo:knnclassify:KNotNumeric',...
        'K must be numeric.');
end
if ~isscalar(K)
    error('Bioinfo:knnclassify:KNotScalar',...
        'K must be a scalar.');
end

if K<1
    error('Bioinfo:knnclassify:KLessThanOne',...
        'K must be greater than or equal to 1.');
end

if isnan(K)
    error('Bioinfo:knnclassify:KNaN',...
        'K cannot be NaN.');
end

if nargin < 5 || isempty(distance)
    distance  = 'euclidean';
elseif ischar(distance)
    distNames = {'euclidean','cityblock','cosine','correlation','hamming'};
    i = find(strncmpi(distance, distNames,numel(distance)));
    if length(i) > 1
        error('Bioinfo:knnclassify:AmbiguousDistance', ...
            'Ambiguous ''distance'' parameter value:  %s.', distance);
    elseif isempty(i)
        error('Bioinfo:knnclassify:UnknownDistance', ...
            'Unknown ''distance'' parameter value:  %s.', distance);
    end
    distance = distNames{i};
else
    error('Bioinfo:knnclassify:InvalidDistance', ...
        'The ''distance'' parameter value must be a string.');
end

if nargin < 6
    rule = 'nearest';
elseif ischar(rule)
    
    % lots of testers misspelled consensus.
    if strncmpi(rule,'conc',4)
        rule(4) = 's';
    end
    ruleNames = {'random','nearest','farthest','consensus'};
    i = find(strncmpi(rule, ruleNames,numel(rule)));
    % %   May need this if we add more rules and introduce the possibility of
    % %   ambiguity.
    %     if length(i) > 1
    %         error('Bioinfo:knnclassify:AmbiguousRule', ...
    %             'Ambiguous ''Rule'' parameter value:  %s.', rule);
    %     else
    if isempty(i)
        error('Bioinfo:knnclassify:UnknownRule', ...
            'Unknown ''Rule'' parameter value:  %s.', rule);
    end
    rule = ruleNames{i};
    %     end
else
    error('Bioinfo:knnclassify:InvalidRule', ...
        'The ''rule'' parameter value must be a string.');
end

% Calculate the distances from all points in the training set to all points
% in the test set.

if strncmpi(distance,'hamming',3)
        if ~all(ismember(sample(:),[0 1]))||~all(ismember(TRAIN(:),[0 1]))
            error('Bioinfo:knnclassify:HammingNonBinary',...
                'Non-binary data cannot be classified using Hamming distance.');
        end
end
dIndex = knnsearch(TRAIN,sample,'distance', distance,'K',K);
% find the K nearest

if K >1
    classes = gindex(dIndex);
    % special case when we have one sample(test) point -- this gets turned into a
    % column vector, so we have to turn it back into a row vector.
    if size(classes,2) == 1
        classes = classes';
    end
    % count the occurrences of the classes
    
    counts = zeros(m,ngroups);
    for outer = 1:m
        for inner = 1:K
            counts(outer,classes(outer,inner)) = counts(outer,classes(outer,inner)) + 1;
        end
    end
    
    [L,outClass] = max(counts,[],2);
    
    % Deal with consensus rule
    if strcmp(rule,'consensus')
        noconsensus = (L~=K);
        
        if any(noconsensus)
            outClass(noconsensus) = ngroups+1;
            if isnumeric(group) || islogical(group)
                groups(end+1) = {'NaN'};
            else
                groups(end+1) = {''};
            end
        end
    else    % we need to check case where L <= K/2 for possible ties
        checkRows = find(L<=(K/2));
        
        for i = 1:numel(checkRows)
            ties = counts(checkRows(i),:) == L(checkRows(i));
            numTies = sum(ties);
            if numTies > 1
                choice = find(ties);
                switch rule
                    case 'random'
                        % random tie break
                        
                        tb = randsample(numTies,1);
                        outClass(checkRows(i)) = choice(tb);
                    case 'nearest'
                        % find the use the closest element of the equal groups
                        % to break the tie
                        for inner = 1:K
                            if ismember(classes(checkRows(i),inner),choice)
                                outClass(checkRows(i)) = classes(checkRows(i),inner);
                                break
                            end
                        end
                    case 'farthest'
                        % find the use the closest element of the equal groups
                        % to break the tie
                        for inner = K:-1:1
                            if ismember(classes(checkRows(i),inner),choice)
                                outClass(checkRows(i)) = classes(checkRows(i),inner);
                                break
                            end
                        end
                end
            end
        end
    end
    
else
    outClass = gindex(dIndex);
end

% Convert back to original grouping variable
if isa(group,'categorical')
    labels = getlabels(group);
    if isa(group,'nominal')
        groups = nominal(groups,[],labels);
    else
        groups = ordinal(groups,[],getlabels(group));
    end
    outClass = groups(outClass);
elseif isnumeric(group) || islogical(group)
    groups = str2num(char(groups)); %#ok
    outClass = groups(outClass);
elseif ischar(group)
    groups = char(groups);
    outClass = groups(outClass,:);
else %if iscellstr(group)
    outClass = groups(outClass);
end