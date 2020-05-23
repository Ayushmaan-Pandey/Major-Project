function schema


cls = schema.class('classperformance');
% user properties
p = schema.prop(cls,'Label','string');  %#ok
p = schema.prop(cls,'Description','string'); %#ok

% properties needed at initialization
p = schema.prop(cls,'IsClassLabelTypeNumeric','bool');   p.Visible = 'off';
                                  p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls,'ListenerEnable','bool');   p.Visible = 'off';
                                  p.AccessFlags.PublicSet = 'off';
                                  p.FactoryValue = false;
p = schema.prop(cls,'ClassLabels','MATLAB array');
                                  p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls,'GroundTruth','MATLAB array'); 
                                  p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls,'NumberOfObservations','double');
                                  p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls,'ControlClasses','MATLAB array'); %#ok
p = schema.prop(cls,'TargetClasses','MATLAB array'); %#ok


% properties for updating
p = schema.prop(cls,'ValidationCounter','double');  
                                  p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls,'SampleDistribution','MATLAB array');
                                  p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls,'ErrorDistribution','MATLAB array');
                                  p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls,'SampleDistributionByClass','MATLAB array');
                                  p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls,'ErrorDistributionByClass','MATLAB array');
                                  p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls,'CountingMatrix','MATLAB array');
                                  p.AccessFlags.PublicSet = 'off';

% properties for reporting 
p = schema.prop(cls,'CorrectRate','double'); 
                                  p.GetFunction = @calculateCorrectRate;
                                  p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls,'ErrorRate','double');
                                  p.GetFunction = @calculateErrorRate;
                                  p.AccessFlags.PublicSet = 'off';
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function v = calculateCorrectRate(h,w) %#ok
v = NAN;
if ~h.ListenerEnable
return
end
CM = h.CountingMatrix(1:end-1,:);
M = size(CM,1);
N = sum(sum(CM));
if  N ~= 0
    v = 1-sum(sum(CM.*(1-eye(M))))/N;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
