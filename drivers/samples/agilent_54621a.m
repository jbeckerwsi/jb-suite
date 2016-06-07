%% initiate connection
clear R;
R=Rack('ni');
R.add('SCOPE','GPIB0::30::INSTR', 'agilent_54621a.mdd');
connect(R);

% test
R.SCOPE.Trigger.slope='positive';
R.SCOPE.Trigger.reject='hf';
R.SCOPE.Trigger.coupling='dc';
R.summary