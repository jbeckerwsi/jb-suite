clear R;
instrreset;

global R;
R=Rack('agilent');
R.add('KE','GPIB0::9::INSTR','keithley_2000.mdd');
%R.add('KN','GPIB0::10::INSTR','knick_s252.mdd');