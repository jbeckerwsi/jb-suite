classdef Rack < dynamicprops
    % Rack represents a rack with icdevices used to perform measurements
    %
    % Created: Jonathan Becker (jonathan.becker@wsi.tum.de) 18.01.2015
    % Last modified: 06.02.2015
    % 
    % ---- changelog -------
    % Version: 1.0 -jb
    %   initial release
    %
    % Version: 1.1 -jb
    %   added properties integration_done (readonly), operator
    %   added method 'summary': human readable string containing all set
    %       properties of all connected instruments
    properties (Constant=true)
        version=1.1
    end
    
    properties (SetAccess='private')
        devices = [];         % list of devices attached to the rack
        interfaces = [];      % list of interfaces corresponding to devices
        VISAvendor = '';      % Type of GPIB controller: 'tek', 'ni' or 'agilent'
        connected  = false;   % indication wether associated instruments are connected
        integration_done = 0  % indication wether 'integration_done' is true for all connected instruments supporting this property
    end
    
    properties
        operator = 'NN';      % name of person conducting the measurement, for protocol
        filename = '';        % filename of current configuration (used by RackEditor.m)
    end
    
    methods 
        function obj=Rack(vendor)
            obj.VISAvendor=vendor;
        end
        %%%%%%%%% get & set's %%%%%%%%%%%%%%%%
        function value = get.connected(obj)
            if obj.connected
                value=true;
                return
            end
            value=false;
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function add(obj,name,visaResource,driver)
            obj.addprop(name);
            
            if isempty(visaResource) || strcmp(visaResource,'generic') %generic driver
                obj.(name)=icdevice(driver);
            else
                %m=regexp(visaResource,'GPIB(?<interface>\d)::(?<address>\d+)::INSTR','names');
                %obj.interfaces{end+1}=gpib(obj.VISAvendor,str2double(m.interface),str2double(m.address));
                if strcmp(obj.VISAvendor,'dummy')
                    obj.interfaces{end+1}='dummy';
                    obj.(name)='dummy';
                else
                    obj.interfaces{end+1}=visa(obj.VISAvendor,visaResource);
                    obj.(name)=icdevice(driver,obj.interfaces{end});
                end
            end
            obj.devices{end+1}=name;
            
        end
        
              
        
        function connect(obj)
            fprintf('Connecting:\n');
            a=tic;
            i=0;
            for d=obj.devices
                if strcmp(obj.(d{1}).Status,'open')
                    continue;
                end
                i=i+1;
                fprintf('\t%-12s via %-25s ... ',d{1},obj.(d{1}).DriverName);
                b=tic;
                connect(obj.(d{1}));
                fprintf('(%2.1fs)\n',toc(b));
            end
            fprintf('Total: %1.0f Instruments in %2.1fs\n',i,toc(a));
        end
        
        function disconnect(obj)
            fprintf('Disconnecting: ');
            a=tic;
            for d=obj.devices
                if strcmp(obj.(d{1}).Status,'closed')
                    continue;
                end                
                fprintf(' %s ',d{1});
                disconnect(obj.(d{1}));
            end
            fprintf(' ... done! (%2.1fs)\n',toc(a));
        end
        
        function get(obj)
            for d=obj.devices
                get(obj.(d{1}));
            end
        end
        
        function delete(obj)
            disconnect(obj);
        end
        
        %%%% determine if the integration is done on every instrument
        %%%% supporting the property 'integration_done'
        
        function r=get.integration_done(obj)
            r=1;
            for k=1:numel(obj.devices)
                if strcmp(obj.(obj.devices{k}).Status,'open') && isfield(propinfo(obj.(obj.devices{k})),'integration_done')
                    if ~obj.(obj.devices{k}).integration_done
                        r=0;
                        break;
                    end
                end
            end
        end
        
        % invoke 'integration_start' on all instruments given by the
        % cell-array devices, that are connected and support the method
        % is instruments is not specified all instruments are addressed
        function integration_start(obj,devices)
            if nargin < 2
                devices=obj.devices;
            else
                if ~iscell(devices)
                    devices=strsplit(devices,',');
                end
                devices=intersect(devices,obj.devices);
            end  
            
            for i=1:numel(devices)
                d=obj.(devices{i});
                if strcmp(d.Status,'closed') || ~any(strcmp(d.methods,'integration_start'))
                    continue;
                end
                invoke(d,'integration_start');
            end
        end

        % invoke 'getX' on all instruments given by the
        % cell-array devices, that are connected and support the method
        % is instruments is not specified all instruments are addressed
        % data is returned as stuct for multiple instruments, or as double
        % for a single instrument
        function data=getX(obj,devices)
            if nargin < 2
                devices=obj.devices;
            else
                if ~iscell(devices)
                    devices=strsplit(devices,',');
                end
                devices=intersect(devices,obj.devices);
            end  
            
            for i=1:numel(devices)
                d=obj.(devices{i});
                if strcmp(d.Status,'closed') || ~any(strcmp(d.methods,'integration_start'))
                    continue;
                end
                data.(devices{i})=invoke(d,'getX');
            end
            
            if numel(devices)==1
                data=data.(devices{1});
            end
        end        
                
        function out=summary(obj,devices)
            fprintf('Fetching intrument configuration summary: ');
            str{1}='----------- instrument configuration summary -----------';
            str{2}=sprintf('operator: %s',obj.operator);
            str{3}=sprintf('date: %s',datestr(datetime));
            
            if nargin < 2
                devices=obj.devices;
            else
                if ~iscell(devices)
                    devices=strsplit(devices,',');
                end
                devices=intersect(devices,obj.devices);
            end
            
  
            
            defaultProperties={'ConfirmationFcn','DriverName','DriverType','InstrumentModel','Interface','LogicalName','Name','ObjectVisibility','RsrcName','Status','Tag','Timeout','Type','UserData'};
            for i=1:numel(devices)
                d=obj.(devices{i});
                if strcmp(d.Status,'closed')
                    continue;
                end
                fprintf(' %s ',devices{i}');
                d=get(d);
                str{end+1}='';
                str{end+1}=sprintf('------------ Device: %s -------------',devices{i});
                str{end+1}=sprintf('driver: %s, Interface: %s',d.DriverName,d.Interface.Name);
                str{end+1}=sprintf('Model: %s',d.InstrumentModel);
                
                props=setdiff(fieldnames(d),defaultProperties); % list of properties, except common properties for all instruments -> gets only special properties
                for k=1:numel(props)
                    if isa(d.(props{k}),'icgroup')
                        g=d.(props{k});
                        for j=1:size(g,2)
                            str{end+1}=sprintf('%d : %s',g(j).HwIndex,g(j).HwName);
                            dontDisplay={'HwIndex','HwName','Parent','Name'};
                            gprops=setdiff(fieldnames(g(j)),dontDisplay);
                            for l=1:numel(gprops)
                                val=g(j).(gprops{l});
                                if isnumeric(val)
                                    val=sprintf('%d',val);
                                end
                                str{end+1} = sprintf('\t%s = %s',gprops{l},val);
                            end
                        end
                    else
                        val=d.(props{k});
                        if isnumeric(val)
                            val=sprintf('%d',val);
                        end
                        str{end+1}=sprintf('%s = %s',props{k},val);
                    end
                end
            end
            
            out='';
            for i=1:numel(str)
                out=sprintf('%s# %s\n',out,str{i});
            end
            fprintf(' done. :)\n');
        end
    end
end
    