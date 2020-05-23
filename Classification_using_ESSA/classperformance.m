function h = classperformance(CL,GT)
%CLASSPERFORMANCE class constructor for CP objects


% construct a CP object

h.ListenerEnable = false;
%h = bio.classperformance;
h.ClassLabels = CL;
h.GroundTruth = GT;
h.IsClassLabelTypeNumeric = isnumeric(CL);
h.NumberOfObservations = numel(GT);
h.ValidationCounter = 0;
numClasses = numel(CL);
h.TargetClasses = 1;
h.ControlClasses = (2:numClasses)';
h.SampleDistribution = zeros(h.NumberOfObservations,1);
h.ErrorDistribution = zeros(h.NumberOfObservations,1);
numClasses = numel(CL);
h.CountingMatrix = zeros(numClasses+1,numClasses);
h.CorrectRate = numel(GT);
h.ErrorRate = numel(GT);
h.SampleDistributionByClass = zeros(numClasses,1);
h.ErrorDistributionByClass = zeros(numClasses,1);
h.ListenerEnable = true;


