%% initiate connection
clear R;
R=Rack('ni');
R.add('SCOPE','GPIB0::30::INSTR', 'agilent_54621a.mdd');
connect(R);

%% test