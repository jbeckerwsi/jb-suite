classdef temperatureCalibration < handle
    %temperatureCalibration
    % Jonathan Becker <jonathan.becker@wsi.tum.de>
    % 26.02.2015, Garching: sunny weather, few °C. Quite a nice day!
    % This class will provide a handler for calibration of several types of
    % temperature sensor.
    %
    % Supported sensors:
    %  - Lakeshore DT670
    %  - resistive Nickel thermometer (~100nm thickness, ~10Ohm @ 300K)
    %
    % Version: 0.1, last modified 26.02.2015
    
    properties %(SetAccess='private')
        calibrationData; % for Nickel: rho_0, lA (which corresponds to l/A of the resistor)
        sensorType;
        refMode=1; % 1: use literature or datasheet reference and offset data using calibration points. 0: just use calibration points and interpolate
        referencePoints=[]; % reference values: temperature, measured value
    end
    
    methods
        function obj=temperatureCalibration(type)
            if ~any(strcmp(type,{'Ni','DT670','PT100'}))
                error('unsupported sensor type. exiting.');
            end
            switch(type)
                case 'Ni'
                    obj.calibrationData.lA=(30E-6)/(3E-6*100E-9);
                    obj.calibrationData.rho_0=0;
                    obj.refMode=0;
                case 'DT670'
                    obj.calibrationData='';
            end
            
            obj.sensorType=type;
        end
        
        function addReference(obj,T,val) % add a reference point for calibration
            if ~isnan(T) && ~isnan(val) && T > 0
                obj.referencePoints(end+1,:)=[T val];
            end
        end
        
        function x=calibrate(obj)
            switch obj.sensorType
                case 'Ni'
                   if obj.refMode==0
                        obj.calibrationData.R=fit(obj.referencePoints(:,1),obj.referencePoints(:,2),'smoothingspline');
                        obj.calibrationData.T=fit(obj.referencePoints(:,2),obj.referencePoints(:,1),'smoothingspline');
                   else
                       opt=optimoptions('lsqcurvefit');
                       opt.TolFun = 1e-6;
                       opt.TolX   = 1e-6;
                       opt.MaxFunEvals=4000;
                       opt.MaxIter=4000;
                       opt.Algorithm='levenberg-marquardt';
                       x0=[obj.calibrationData.lA*1E-8 obj.calibrationData.rho_0*1E8];
                       xdata=obj.referencePoints(:,1);
                       ydata=obj.referencePoints(:,2);
                       nanMask=~(isnan(xdata) | isnan(ydata));
                       xdata=xdata(nanMask);
                       ydata=ydata(nanMask);
                       f=@(x,xdata)obj.nickel(xdata,1,x(1)*1E8,x(2)*1E-8)';
                       x=lsqcurvefit(f,x0,xdata,ydata,[],[],opt);
                       obj.calibrationData.lA=x(1)*1E8;
                       obj.calibrationData.rho_0=x(2)*1E-8;
                   end
            end
        end
                        
        
        function T=Temperature(obj,SensorReading)
            switch obj.sensorType
                case 'DT670'
                    T=obj.dt670(SensorReading);
                case 'Ni'
                    if obj.refMode==1
                         T=obj.nickel(SensorReading);
                    else
                        if any(SensorReading < min(obj.referencePoints(:,1))) && any(SensorReading > max(obj.referencePoints(:,1)))
                            error('requested value out of calibrated range!!');
                        end
                        T=obj.calibrationData.T(SensorReading);
                    end
                case 'PT100'
                    T=obj.pt100(SensorReading);
            end
        end
        
        function Reading=SensorReading(obj,Temperature)
            switch obj.sensorType
                case 'DT670'
                    Reading=obj.dt670(Temperature,1);
                case 'Ni'
                    if obj.refMode==1
                        Reading=obj.nickel(Temperature,1);
                    else
                        if any(Temperature <= min(obj.referencePoints(:,1))) && any(Temperature >= max(obj.referencePoints(:,1)))
                            error('requested value out of calibrated range!!');
                        end
                        Reading=obj.calibrationData.R(Temperature);
                    end
                case 'PT100'
                    Reading=obj.pt100(Temperature,1);
            end
        end
        
        
        
        function T=nickel(obj,resistivity,reverse,lA,rho_0)
            if nargin < 5
                lA    = obj.calibrationData.lA;
            end

            if nargin < 4
                rho_0 = obj.calibrationData.rho_0;
            end

            if nargin < 3
                reverse = 0;
            end
          
            % ideal resistivity (rho_i = rho - rho_0(T=0K) )
            % taken from: Kemp, W. R. G., Klemens, P. G., & White, G. K. (1956). Thermal and Electrical Conductivities of Iron, Nickel, Titanium, and Zircomium at low Temperatures. Australian Journal of Physics, 9, 180. doi:10.1071/PH560180
            % units: K, ohm cm x 10^6
            %
            %point 0,0 has been added as this is the ideal resistivity
            rho_i = ...
                [
                0 0;
                13.555917594067267 0.0044613261947641751;
                16.082170431194768 0.0055177349216615941;
                18.683921379104742 0.0075490771489063807;
                24.188943725547105 0.016775466612733572;
                28.090957034947113 0.024385012415244066;
                33.92225609892418 0.044269680358472376;
                38.984159502968772 0.067681947493002881;
                57.46660344897753 0.20164716376840702;
                66.7367664642851 0.29311665097046746;
                78.25003503287067 0.46194188870798947;
                92.66558096006392 0.7504179854032198;
                116.58560984251039 1.2694946004686196;
                136.8172209561846 1.7545313867312906;
                170.60316254342908 2.4747502690218535;
                188.51030357910727 3.1226296413410894;
                228.06785101609205 4.2726661364553982;
             %   292.99079690110239 6.60049179825924;
             %   292.83455725368174 7.1558860623976264];
            mean([292.99079690110239 292.83455725368174]) mean([6.60049179825924 7.1558860623976264])];
                % the last two values in the paper were different
                % resistivities for quite the same temperature, i am taking
                % an average point of these two. Otherwise the
                % extrapolation gets really weird
            % make it SI ;)
            rho_i(:,2)=rho_i(:,2)*1E-8; % ohm cm x 10^6 --> ohm m
            
            % rho_0 from the same paper:
            %rho_0 = 0.0347E-8;
            
            rho(:,1) = rho_i(:,1);
            rho(:,2) = rho_i(:,2) + rho_0;
            if reverse==1
                %get resistance for given temp
                for i=1:numel(resistivity)
                    T(i)=lA*interp1(rho(:,1),rho(:,2),resistivity(i),'spline','extrap');
                end
            else
                %made my life simple ... but hey; close enough
                for i=1:numel(resistivity)                
                    T(i)=interp1(rho(:,2),rho(:,1),resistivity(i)/lA,'spline','extrap');
                end
            end
        end
        
    end
    methods(Static)
        function T=dt670(voltage,reverse)
            if nargin < 3
                reverse=0;
            end
            
            DT600StandardCurveInterpolationTable = [...
                1.4 1.64429;
                1.5 1.64299;
                1.6 1.64157;
                1.7 1.64003;
                1.8 1.63837;
                1.9 1.6366;
                2 1.63472;
                2.1 1.63274;
                2.2 1.63067;
                2.3 1.62852;
                2.4 1.62629;
                2.5 1.624;
                2.6 1.62166;
                2.7 1.61928;
                2.8 1.61687;
                2.9 1.61445;
                3 1.612;
                3.1 1.60951;
                3.2 1.60697;
                3.3 1.60438;
                3.4 1.60173;
                3.5 1.59902;
                3.6 1.59626;
                3.7 1.59344;
                3.8 1.59057;
                3.9 1.58764;
                4 1.58465;
                4.2 1.57848;
                4.4 1.57202;
                4.6 1.56533;
                4.8 1.55845;
                5 1.55145;
                5.2 1.54436;
                5.4 1.53721;
                5.6 1.53;
                5.8 1.52273;
                6 1.51541;
                6.5 1.49698;
                7 1.47868;
                7.5 1.46086;
                8 1.44374;
                8.5 1.42747;
                9 1.41207;
                9.5 1.39751;
                10 1.38373;
                10.5 1.37065;
                11 1.3582;
                11.5 1.34632;
                12 1.33499;
                12.5 1.32416;
                13 1.31381;
                13.5 1.3039;
                14 1.29439;
                14.5 1.28526;
                15 1.27645;
                15.5 1.26794;
                16 1.25967;
                16.5 1.25161;
                17 1.24372;
                17.5 1.23596;
                18 1.2283;
                18.5 1.2207;
                19 1.21311;
                19.5 1.20548;
                20 1.19774;
                21 1.18154;
                22 1.16279;
                23 1.14081;
                24 1.12592;
                25 1.11944;
                26 1.11565;
                27 1.11281;
                28 1.11042;
                29 1.10826;
                30 1.10624;
                31 1.10432;
                32 1.10247;
                33 1.10068;
                34 1.09893;
                35 1.09721;
                36 1.09553;
                37 1.09387;
                38 1.09224;
                39 1.09062;
                40 1.08902;
                42 1.08584;
                44 1.08266;
                46 1.07949;
                48 1.0763;
                50 1.07309;
                52 1.06988;
                54 1.06665;
                56 1.0634;
                58 1.06014;
                60 1.05686;
                65 1.04858;
                70 1.04018;
                75 1.03165;
                77.35 1.02759;
                80 1.02298;
                85 1.01418;
                90 1.00524;
                95 0.99617;
                100 0.98697;
                105 0.97765;
                110 0.9682;
                115 0.95865;
                120 0.949;
                125 0.93924;
                130 0.92939;
                135 0.91944;
                140 0.90941;
                145 0.8993;
                150 0.88911;
                155 0.87885;
                160 0.86851;
                165 0.85812;
                170 0.84765;
                175 0.83713;
                180 0.82656;
                185 0.81592;
                190 0.80524;
                195 0.7945;
                200 0.78372;
                205 0.77288;
                210 0.762;
                215 0.75108;
                220 0.74011;
                225 0.7291;
                230 0.71805;
                235 0.70696;
                240 0.69583;
                245 0.68466;
                250 0.67346;
                255 0.66222;
                260 0.65094;
                265 0.63964;
                270 0.6283;
                273.15 0.62114;
                275 0.61693;
                280 0.60552;
                285 0.59409;
                290 0.58263;
                295 0.57115;
                300 0.55963;
                305 0.5481;
                310 0.53654;
                315 0.52496;
                320 0.51336;
                325 0.50174;
                330 0.4901;
                335 0.47844;
                340 0.46676;
                345 0.45506;
                350 0.44337;
                355 0.43167;
                360 0.41996;
                365 0.40823;
                370 0.3965;
                375 0.38475;
                380 0.373;
                385 0.36123;
                390 0.34945;
                395 0.33765;
                400 0.32583;
                405 0.314;
                410 0.30216;
                415 0.29029;
                420 0.27841;
                425 0.26651;
                430 0.25459;
                435 0.24265;
                440 0.23069;
                445 0.21873;
                450 0.20675;
                455 0.19478;
                460 0.18283;
                465 0.1709;
                470 0.15901;
                475 0.14719;
                480 0.13548;
                485 0.12391;
                490 0.11255;
                495 0.10145];
            
            
            if reverse
                %get voltage for given temp
                T=interp1(DT600StandardCurveInterpolationTable(:,1),DT600StandardCurveInterpolationTable(:,2),voltage);
            else
                %made my life simple ... but hey; close enough
                T=interp1(DT600StandardCurveInterpolationTable(:,2),DT600StandardCurveInterpolationTable(:,1),voltage);
            end
        end
        
        function T=pt100(resistance,reverse)
            if nargin < 2
                reverse=0;
            end
            
            %source:
            %grundpraktikum.physik.uni-saarland.de/scripts/Platin_Widerstandsthermometer.pdf
            % 28.01.2016
            A=3.9083E-3;
            B=-5.775E-7;
            C=-4.183E-12;
            
            R0=100;
            if reverse == 1
                %calculate resistance from temperature
                T=resistance;
                R=[];
                for i=1:numel(T)
                    
                    if T(i) > 73.15 && T(i) <= 273.15
                        Tc=T(i)-273.15; %convert to celsius
                        R(i)=R0*(1+A*Tc+B*Tc^2+C*(Tc-100)*Tc^3);
                    elseif( T(i) > 273.15)
                        Tc=T(i)-273.15; %convert to celsius
                        R(i)=R0*(1+A*Tc+B*Tc^2);
                    else
                        error('T=%f out of range for PT100 calibration',T(i));
                    end
                    
                end
                T=R;
            else
                R=resistance;
                %needed to interpolate for R<R0
                Tt=73.15:0.1:273.15;
                Tct=Tt-273.15; %convert to celsius
                Rt=R0*(1+A.*Tct+B.*Tct.^2+C.*(Tct-100).*Tct.^3);
                
                T=NaN(numel(R),1);
                for i=1:numel(R)
                    
                    if R(i) > R0 %T > 0°C
                        Tc=(-A*R0+sqrt((A*R0)^2-4*B*R0*(R0-R(i))))/(2*B*R0);
                        T(i)=Tc+273.15;
                    else
                        %this is not trivial, so we take the easy, numeric way out ;)
                        
                        T(i)=interp1(Rt,Tt,R(i),'pchip');
                    end
                end
            end
        end  
    end
end