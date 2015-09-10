classdef temperatureController < handle
    % PID-Temperature contoller for temperature-dependent measurements
    % using on-chip resistive temperature-sensing ans on-carrier resistive heating 
    
    properties
        rawSetPoint=0;  % set point in value of resistance meter (ohms, most likely)
        heatingSupply; % Instrument handle of power supply connected to heater, will be used in CC mode (one channel of HP4145b)
        tempSensor;    % Instrument handle for resistance meter (e.g. HP 34420a)
        PID;           % PID parameters (struct: p,i,d)
        maxCurrent=100E-3; %current limit
    end
    
    properties (SetAccess='private')
        iteration=0;     % iteration counter
        
        lastSensorValues; % last (raw) values of temperature sensor
        timestamps;       % according timestamps (usefull for calculating the derivative)
        outputValues;     % record of output values, this is proportional to the output power, since we set out current source to sqrt(value); P=RI^2 <=> I \propto sqrt(P)
        errors;           % difference between SensorValue and SetPoint
        sensorScaling=1/30E-6;  % scaling factor for sensor-reading
    end
    
    methods
        function obj=temperatureController(heatingSupply,tempSensor)
            obj.heatingSupply=heatingSupply;
            obj.tempSensor=tempSensor;
            obj.PID.p=0;
            obj.PID.i=0;
            obj.PID.d=0;
            

            obj.heatingSupply.mode='CC';        % constant current
            obj.heatingSupply.Compliance=100;   % voltage limit 100V
            obj.heatingSupply.range=100E-3;     % 100mA-range
            obj.heatingSupply.value=0;          % start at zero ;) ... often not a bad idea
            
        end
        
        function rawSensorValue=iter(obj) % perform a control-loop iteration, this is what will be called in the main programm-loop and is aimed to be non-blocking
            % to be non blocking this function is alternating between
            % integration_start and readout/regulation for even&odd
            % iterations
            if mod(obj.iteration,2) ==0
                invoke(obj.tempSensor,'integration_start');
                if obj.iteration == 0
                    rawSensorValue=NaN;
                else
                    rawSensorValue=obj.lastSensorValues(end);
                end
                obj.iteration=obj.iteration+1;
                return
            end
            
            obj.lastSensorValues(end+1)=invoke(obj.tempSensor,'getX')*obj.sensorScaling;
            obj.timestamps(end+1)=now;
            obj.errors(end+1)=obj.rawSetPoint-obj.lastSensorValues(end);
            
            s=1.1597e-05; %if two values of 'now' differ by this value, the time difference is reasonably close to 1second
            time=(obj.timestamps-obj.timestamps(1))./s;
            
            
            % dynamic scaling of PID-parameters with loop-time (time
            % between 2 calls of iter)
            % initial calibration was performed for dt=0.56s, so we are
            % normalizing to this value. Also if last datapoint is older
            % than 15s skip this step. Here it is assumed, that the data is
            % from another, earlier run
            if numel(time) > 1 && (time(end)-time(end-1)) < 15
                timeFactor=(time(end)-time(end-1))/0.56;
            else
                timeFactor=1;
            end
            
            PID.p=timeFactor*obj.PID.p;
            PID.i=timeFactor*obj.PID.i;
            PID.d=timeFactor*obj.PID.d;
            
            
            prop=obj.errors(end)*PID.p;
            if numel(time) > 1
                diff=PID.d*(obj.errors(end)-obj.errors(end-1))/(time(end)-time(end-1));
            else
                diff=0;
            end
            
            if numel(obj.errors) > 15
                int=PID.i*sum(obj.errors(end-14:end))/15;
            else
                int=PID.i*sum(obj.errors)/numel(obj.errors);
            end
            
            new_value=obj.heatingSupply.value^2+prop+int+diff;
            if new_value < 0
                new_value=0; %cant heat, just cool
            end
            
            if new_value > obj.maxCurrent^2   %current limit
                new_value = obj.maxCurrent^2;
            end
            obj.outputValues(end+1)=new_value;
            obj.heatingSupply.value=sqrt(new_value); % as we want to regulate power and not current we have to take P=RI^2 into account
            fprintf('%s:d\t o:%d\t e:%d\t p:%d\t i:%d\n',obj.lastSensorValues(end),sqrt(new_value),obj.errors(end),prop,int);
            rawSensorValue=obj.lastSensorValues(end);
            
            obj.iteration=obj.iteration+1;
        end
        
        function e=errorIntegral(obj,lastN)
            if nargin < 2
                lastN=numel(obj.errors);
            end
            if lastN > numel(obj.errors)
                lastN=numel(obj.errors);
            end
            e=sum(obj.errors(end-lastN:end));
        end
            
        
        function plotResponce(obj,ax_handle)
            if nargin < 2
                ax_handle=gca;
            end
            s=1.1597e-05; %if two values of 'now' differ by this value, the time difference is reasonably close to 1second

            if numel(obj.errors) < 1 %if there is nothing to plot, well, then don't!
                return
            end
            time=(obj.timestamps-obj.timestamps(1))./s;
            [hAx,hLine1,hLine2]=plotyy(ax_handle,time,obj.lastSensorValues,time,obj.outputValues);
            hold on;
            plot(hAx(1),time,obj.lastSensorValues + obj.errors);
            legend('sensor','output','set point','location','best');
            title('Temperature Controller');
            xlabel('Time (s)');

            ylabel(hAx(1),'Sensor Value'); % left y-axis
            ylabel(hAx(2),'Output'); % right y-axis
            hold off;
         end
            
    end
end