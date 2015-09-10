classdef MeasurementVariable < handle
   % This class is used to link devices and variables during measurement
   % it also allows to link devices using the according transfer-method in
   % the driver.
   %
   % Creates: Jonathan Becker (jonathan.becker@wsi.tum.de), 28.05.2015
   % Last modified: 28.05.2015
   %
   % ---- changelog --------
   % Version: 1.0 -jb
   %    initial release
   
   properties (Constant=true)
       version=1.0
   end
   
   properties(SetAccess='private')
       linearTransferCache=NaN;
   end    
   
   properties
       type = 'input'; %type: input or output
       transferChain = struct('string',{},'handle',{},'method',{});
       instrument;
       channel;         %struct; id:field-in edit-form
                        %        handle:handle to channel
                        %        string: string to display in overview 
       instr_property;  %struct; id: field in edit-form
                        %        name: name of property/method
                        %        type: prop or method, determines wether to
                        %              execute a method or a property
       name='test';
       unit='';
       
       lastValue=NaN;   % last read value
   end
   
   methods
       function out=transfer(obj,input)
           if isnan(obj.linearTransferCache)
               out=input;
               for i=1:numel(obj.transferChain)
                   out=invoke(obj.transferChain(i).handle,obj.transferChain(i).method,out);
               end
           else
               out=obj.linearTransferCache*input;
           end
       end
       
       function out=read(objs,varname)
           if numel(objs) == 1 && nargin < 2
               varname=objs.name;
           elseif numel(objs) > 1 && nargin ==2
               objs=findobj(objs,'name',varname);
           else
               varname='*all*'; %...and dont care ;)
           end
            
           out={};
           for obj=objs
                      
               if ~strcmp(obj.type,'input')
                   out{end+1}=obj.lastValue;
                   if ~strcmp(varname,'*all*')
                        warning('variable %s is defined as output',varname);
                   end
                   continue
               end

               if ~isempty(obj.channel) || isfield(obj.channel,'handle')
                   global R;
                   if strcmp(R.(obj.instrument).status,'closed')
                       warning('%s is not connected.',obj.instrument);
                       out{end+1}=NaN;
                       continue
                   end
                   if strcmp(obj.instr_property.type,'prop')
                       out{end+1}=obj.channel.handle.(obj.instr_property.name);
                   elseif strcmp(obj.instr_property.type,'method')
                       out{end+1}=invoke(obj.channel.handle,obj.instr_property.name);
                   end
                   
                   %apply transfer-chain
                   out{end}=obj.transfer(out{end});
               else
                   out{end+1}=NaN;
                   error('%s has no instrument.',varname);
               end
               obj.lastValue=out{end};
           end
           
           if numel(out)==1
               out=out{1};
           end
       end
       
       function set(objs,varname,value)
           if numel(objs) == 1 && nargin < 3
               value=varname;
               varname=objs.name;
           elseif numel(objs) > 1 && nargin ==3
               objs=findobj(objs,'name',varname);
           end
           
           for obj=objs
                      
               if ~strcmp(obj.type,'output')
                   warning('variable %s is defined as input',varname);
                   continue
               end

               if ~isempty(obj.channel) || isfield(obj.channel,'handle')
                   global R;
                   if strcmp(R.(obj.instrument).status,'closed')
                       warning('%s is not connected.',obj.instrument);
                       continue
                   end
                   if strcmp(obj.instr_property.type,'prop')
                       obj.channel.handle.(obj.instr_property.name)=value;
                   elseif strcmp(obj.instr_property.type,'method')
                       invoke(obj.channel.handle,obj.instr_property.name,value);
                   end
               else
                   error('%s has no instrument.',varname);
               end
               obj.lastValue=value;
           end
       end
               
   end
end