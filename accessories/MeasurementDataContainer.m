classdef MeasurementDataContainer < handle
    % MeasurementDataContainer keeps track of measured parameters and
    % writes data while measuring
    %
    % Created: Jonathan Becker (jonathan.becker@wsi.tum.de) 06.02.2015
    % Last modified: 04.03.2015
    % Version: 1.0: initial release
    % Version: 1.1: 04.03.2015
    %               added support for sections, 
    %               data can now be divided by
    %               any number of comments
    properties (Constant=true)
        version=1.1
    end
    
    properties (SetAccess='private')
        col;
        currentLine=1;
        filename='';
        header;
        headerWritten=0;
        comments={};
        commentLines=[];
        validNaNcurrentLine=[]; % if a NaN-value is added using addData the corresponding cols will be flagged here, in order to allow an auto-advance in this case
        lastTic=0;              % start-tic of last dataset
    end
    
    properties
        data=[];
        rack = [];
        autoAdvance = 1;    % automatically go to next line if all value in current line have been set
        autoWrite   = 1;    % automatically write to output file each time when next() is called
    end
    
    
    methods
        %constructor
        % - filename: file to save to/load from
        % - Rack: instance of Rack-class, used to conduct measurements,
        % this is used to obtain instrument-settings for the file-header
        % if Rack='load', then the data is read from the given file and the
        % object is rebuilt
        function obj=MeasurementDataContainer(filename,Rack)
            load=0; % load data from file
            if nargin > 1
                if isa(Rack,'Rack')
                    obj.rack=Rack;
                elseif strcmp(Rack,'load')
                    load=1;
                end
            end
            
            if load==1
                obj.filename=filename;
                obj.load();
            else
                obj.filename=obj.uniqueFilename(filename);
            end
            obj.lastTic=tic;
        end
        
        function filename=uniqueFilename(obj,filename)
            % if the file already exists append a number, keep increasing
            % number until a unused filename is found
            
            if nargin < 2
                filename=obj.filename;
            end
            
            [pathstr,name,ext]=fileparts(filename);
            i=1;
            while exist(filename,'file')==2
                   if isempty(pathstr)
                       pathstr='.';
                   end
                   filename=sprintf('%s/%s-%03d%s',pathstr,name,i,ext);
                   i=i+1;
            end
        end
        
        % add new column to measurement
        % colname:    name of column
        % unit:       physical unit of data
        % instrument: comma-seperated list of used instruments from Rack for this
        %             channel
        function id=addCol(obj,colname,unit,instrument)
            id=numel(obj.col)+1;
            obj.col{id}.name        = colname;
            obj.col{id}.unit        = unit;
            obj.col{id}.instrument  = instrument;
            obj.data(obj.currentLine,id) = NaN;
        end
        
        % add a data value to column in current row
        % if all columns are set in the current row, the row is advanced
        function line=addData(obj,colID,value)
            obj.data(obj.currentLine,colID)=value;
            line=obj.currentLine;
            
            if isnan(value)
                obj.validNaNcurrentLine(end+1)=colID;
            end
            checkIDX=1:numel(obj.col);
            if ~isempty(obj.validNaNcurrentLine)
                checkIDX=~ismember(checkIDX,obj.validNaNcurrentLine);
            end

            if obj.autoAdvance && ~any(isnan(obj.data(line,checkIDX)))
                obj.next();
            end
        end
        
        % advance line counter
        function line=next(obj)
            line=obj.currentLine+1;
            obj.currentLine=line;
            obj.validNaNcurrentLine=[];
            
            if obj.autoWrite
                obj.writeLine(line-1);
            end
            
            obj.data(line,:)=NaN(numel(obj.col),1);
            
            %rest of this code is the live-display
            if mod(line-2,15)==0 %print header every 15 lines
                for i=1:numel(obj.col)
                    fprintf('%s\t',obj.col{i}.name);
                end
                fprintf('\n');
            end
            for i=1:numel(obj.col)  %print data once line is full
                value=obj.data(line-1,i);
                [factor, prefix]=obj.SiPrefix(value);
                fprintf('%3.3f %s%s\t',value*factor,prefix,obj.col{i}.unit);
            end
            fprintf('\t\t#%d\t\t%.0f ms\n',line-1,toc(obj.lastTic)*1E3);
            obj.lastTic=tic;
        end
        
        %%%%%%% output related methods %%%%%%%%%%%%%%%%%%%
        function h=generateHeader(obj)
            h='';
            if ~isempty(obj.rack)
                instruments={};
                for i=1:numel(obj.col)
                    tmp=strsplit(obj.col{i}.instrument,',');
                    instruments=union(instruments,tmp);
                end
                instruments=unique(instruments);
                h=sprintf('%s',obj.rack.summary(instruments));
            end
            
            h=sprintf('%s#\n#\n#--------------------------------------------------',h);
            for w={'name','unit','instrument'}
                h=sprintf('%s\n# ',h);
                for i=1:numel(obj.col)
                    h=sprintf('%s%s\t',h,obj.col{i}.(w{1}));
                end
            end
            h=sprintf('%s\n#--------------------------------------------------',h);

            obj.header=h;
        end
        
        
        % write header, but only once
        function writeHeader(obj)
            if isempty(obj.filename)
                error('please specify filename');
            end
            
           
            if ~obj.headerWritten % write header when first called
               if isempty(obj.header)
                   warning('no file-header defined, please call generateHeader');
               else
                   f=fopen(obj.filename,'a');
                   fprintf(f,'%s',obj.header);
                   fclose(f);
               end
               obj.headerWritten=1;
            end
        end
        
        % write a single line to the output file.
        % upon the first call the header is also written
        function writeLine(obj,line)
            obj.writeHeader;            
            
            if nargin < 2
                line=obj.currentLine;
            end
            
            
            f=fopen(obj.filename,'a');
            fprintf(f,sprintf('\n%s',obj.genLineStr(line)));
            fclose(f);
        end
        
        %generate string with formated data, seperated by \t
        function str=genLineStr(obj,line)
            lineDataStr={};
            for i=1:numel(obj.col);
                lineDataStr{i}=sprintf('%.15g',obj.data(line,i));
            end
            
            str=strjoin(lineDataStr,'\t');
        end
        
        % add a comment
        function comment(obj,text,line)
            if nargin < 3
                line=obj.currentLine;
            end
            if obj.autoWrite
                obj.writeHeader;

                f=fopen(obj.filename,'a');
                fprintf(f,'\n# %s',text);
                fclose(f);
            end
            
            obj.comments{end+1}=text;
            obj.commentLines(end+1)=line;
        end
        
        %%%%%%%%%% plotting %%%%%%%%%%%%%%%%%%%%%%%%%%
        function listColumns(obj)
            for i=1:numel(obj.col)
                fprintf('%1.0f: %s (%s)\t %s\n',i,obj.col{i}.name,obj.col{i}.unit,obj.col{i}.instrument);
            end
        end
        
        
        function plotSingle(obj,x,y,sectionID)
            if nargin < 4
                sectionID=1:obj.numSections;
            end
            
            %determine all rows to be plotted, this is used to find each
            %maximum value and scale everything to Si-Prefixes, if units
            %are given
            allrows=[];
            for i=1:numel(sectionID)
                rows=obj.sectionLines(sectionID(i));
                allrows=[allrows rows];
            end
            
            
            unitStrX='';
            scalingX=1;
            if ~isempty(obj.col{x}.unit)
                [scalingX, prefix]=obj.SiPrefix(max(abs(obj.data(allrows,x))),1);
                unitStrX=sprintf(' (%s%s)',prefix,obj.col{x}.unit);
            end
            
            unitStrY='';
            scalingY=1;
            if ~isempty(obj.col{y}.unit)
                [scalingY, prefix]=obj.SiPrefix(max(abs(obj.data(allrows,y))),1);
                unitStrY=sprintf(' (%s%s)',prefix,obj.col{y}.unit);
            end
            
            
            for i=1:numel(sectionID)
                rows=obj.sectionLines(sectionID(i));
                plot(obj.data(rows,x)*scalingX,obj.data(rows,y)*scalingY,'DisplayName',obj.sectionHeader(sectionID(i)));
                if i==1
                    hold on;
                end
                if i==numel(sectionID)
                    hold off;
                end
            end
            
                       
           
            xlabel(sprintf('%s%s',obj.col{x}.name,unitStrX));
            ylabel(sprintf('%s%s',obj.col{y}.name,unitStrY));
            grid on;
            axis tight;
            legend('-DynamicLegend','location','best');
        end
        
        %plotyy with 2 columns
        function plotDouble(obj,x,y1,y2,sectionID)
            if nargin < 5
                sectionID=1:obj.numSections;
            end
            
            %determine all rows to be plotted, this is used to find each
            %maximum value and scale everything to Si-Prefixes, if units
            %are given
            allrows=[];
            for i=1:numel(sectionID)
                rows=obj.sectionLines(sectionID(i));
                allrows=[allrows rows];
            end
            
            
            unitStrX='';
            scalingX=1;
            if ~isempty(obj.col{x}.unit)
                [scalingX, prefix]=obj.SiPrefix(max(abs(obj.data(allrows,x))),1);
                unitStrX=sprintf(' (%s%s)',prefix,obj.col{x}.unit);
            end
            
            unitStrY1='';
            scalingY1=1;
            if ~isempty(obj.col{y1}.unit)
                [scalingY1, prefix]=obj.SiPrefix(max(abs(obj.data(allrows,y1))),1);
                unitStrY1=sprintf(' (%s%s)',prefix,obj.col{y1}.unit);
            end
            
            unitStrY2='';
            scalingY2=1;
            if ~isempty(obj.col{y1}.unit)
                [scalingY2, prefix]=obj.SiPrefix(max(obj.data(allrows,y2)),1);
                unitStrY2=sprintf(' (%s%s)',prefix,obj.col{y2}.unit);
            end
            
            for i=1:numel(sectionID)
                rows=obj.sectionLines(sectionID(i));
                [ax,p1,p2] = plotyy(obj.data(rows,x)*scalingX,obj.data(rows,y1)*scalingY1,obj.data(rows,x)*scalingX,obj.data(rows,y2)*scalingY2,'plot','plot','DisplayName',obj.sectionHeader(sectionID(i)));
                if i==1
                    hold on;
                end
                if i==numel(sectionID)
                    hold off;
                end
            end
           
            xlabel(ax(1),sprintf('%s%s',obj.col{x}.name,unitStrX));
            ylabel(ax(1),sprintf('%s%s',obj.col{y1}.name,unitStrY1));
            ylabel(ax(2),sprintf('%s%s',obj.col{y2}.name,unitStrY2));
            grid on;
            axis tight;
            legend('-DynamicLegend','location','best');
        end
        function loglogSingle(obj,x,y,sectionID)
            if nargin < 4
                sectionID=1:obj.numSections;
            end
            loglog(obj.data(:,x),obj.data(:,y));
            
            unitStrX='';
            if ~isempty(obj.col{x}.unit)
                unitStrX=sprintf(' (%s)',obj.col{x}.unit);
            end
            
            unitStrY='';
            if ~isempty(obj.col{y}.unit)
                unitStrY=sprintf(' (%s)',obj.col{y}.unit);
            end
            
            xlabel(sprintf('%s%s',obj.col{x}.name,unitStrX));
            ylabel(sprintf('%s%s',obj.col{y}.name,unitStrY));
            grid on;
            axis tight;
        end        
        %%%%%%%%% input/output %%%%%%%%%%%%%%%%%%%%%%
        function save(obj,filename)
            if nargin < 2
                filename=obj.filename;
            end
           
            if isempty(filename)
                error('please specify filename');
            end
            prevFilename=obj.filename;
            obj.filename=obj.uniqueFilename(filename);
            
            obj.writeHeader;
            f=fopen(filename,'a');
            for line=1:size(obj.data,1)
                if ismember(line,obj.commentLines)
                    fprintf(f,'\n# %s',obj.comments{find(obj.commentLines==line,1)});
                end
                
                %ignore last line, if it only contains NaN's
                if line==size(obj.data,1) && all(isnan(obj.data(line,:)))
                    continue;
                end
                fprintf(f,'\n%s',obj.genLineStr(line));
                
            end
            
            
            obj.filename=prevFilename;
        end
        
        function load(obj,filename)
            if nargin < 2
                filename=obj.filename;
            end
            obj.autoWrite=0;
            
           fprintf('loading %s ... ',filename);
           Tstart=tic;
           if ~exist(filename,'file')
               error('could not restore MeasurementDataContainer: file %s not found',filename);
           end
           
           f=fopen(filename,'r');
           l=fgetl(f);
           hd=1;
           while ischar(l)
               
               if hd==1 && l(1)=='#';
                obj.header=sprintf('%s%s\n',obj.header,l);
               elseif hd==1 && l(1)~='#' % this is the first line after the header, this means the header is completely read and can be parsed
                   %parse header
                   a=strsplit(obj.header,'\n');
                   %start from last line and find colunm-headers: they are
                   % encased in #---- .... 's
                   for i=numel(a):-1:1
                       if ~isempty(a{i})
                           if strcmp(a{i},'#--------------------------------------------------') %the header ends here, we found what we are looking for
                               break;
                           end
                           %if the line didnt match we found a comment for
                           %line 1
                           obj.comment(a{i}(3:end),1);
                       end
                   end
                   % now the header is located at row i-4:i
                   % i-3: variable names
                   % i-2: units
                   % i-1: instruments
                   names=strsplit(a{i-3}(3:end),'\t');
                   units=strsplit(a{i-2}(3:end),'\t');
                   instruments=strsplit(a{i-1}(3:end),'\t');
                   
                   for i=1:numel(names)-1 % -1 because the last value returned by strsplit is always blank
                       obj.col{i}.name        = names{i};
                       obj.col{i}.unit        = units{i};
                       obj.col{i}.instrument  = instruments{i};
                   end
                   
                   hd=0; % when the first non-comment line is reached, the header is over
               end
               
               if hd==0 && numel(l) > 0% not in the header anymore, yay! data ;)
                   if l(1)=='#' %got a comment
                       obj.comment(l(3:end)); % strip off first 2 characters (# + space) because these were automatically added
                   else
                       obj.data(obj.currentLine,:)=sscanf(l,'%f');
                       obj.currentLine=obj.currentLine+1;
                   end
               end
                   
               l=fgetl(f);
           end
           Nkbytes=ftell(f)/1024;
           fclose(f);
           Tstop=toc(Tstart);
           fprintf('done! (%1.0fkb in %1.0fms; %1.2fMb/s)\n',Nkbytes,Tstop*1000,(Nkbytes/1024)/Tstop);
        end
        
        %add: add datapoints of the two objects, if columns are the same
        function obj=plus(obj1,obj2)
           % compare .col's of both objects, if name and unit match, then we can perform the addition
           if numel(obj1.col) ~= numel(obj2.col)
               error('columns do not match');
           end
           
           for i=1:numel(obj1.col)
               if ~strcmp(obj1.col{i}.name,obj2.col{i}.name) || ~strcmp(obj1.col{i}.unit,obj2.col{i}.unit)
                   error('columns do not match');
               end
           end
           
           obj=obj1;
           obj.data(end+1:end+numel(obj2.data(:,1)),:)=obj2.data;
           
        end
        
        % The data is partitioned into sections divided by comments
        % this function returns the data-line-numbers corresponding 
        % to the given sections.
        % if no input is given, all sections are given        
        function sectionsOut=sectionLines(obj,sectionID)
            if nargin < 2
                sectionID=1:obj.numSections;
            end
            
            sections={};
            start=1;
            lines=obj.sectionStart;
            for i=1:numel(lines)-1
                sections{i}=lines(i):lines(i+1)-1;
            end
            if isempty(i) % if we only have one section, then the for-loop didnt do anything
                i=0;
            end
            sections{i+1}=lines(i+1):size(obj.data,1);
            
            for i=1:numel(sectionID)
                sectionsOut{i}=sections{sectionID(i)};
            end
            if i==1
                sectionsOut=sectionsOut{i};
            end
        end
        
        % The data is partitioned into sections divided by comments
        % this function returns number of sections
        % if no input is given, all sections are given         
        function n=numSections(obj)
            lines=unique(obj.commentLines);
            if ~any(lines==1)
                lines=[1 lines];
            end
            n=numel(lines);
        end

        % The data is partitioned into sections divided by comments
        % this function returns the start-index of sections
        % if no input is given, all sections are given         
        function s=sectionStart(obj,sectionID)
            lines=unique(obj.commentLines);
            if ~any(lines==1)
                lines=[1 lines];
            end
            
            if nargin < 2
                sectionID=1:obj.numSections;
            end
            for i=1:numel(sectionID)
                s(i)=lines(sectionID(i));
            end
        end

        % The data is partitioned into sections divided by comments
        % this function returns the info to the corresponding section (i.e.
        % all comments heading this section)
        % if no input is given, all sections are given        
        function header=sectionHeader(obj,sectionID)
            if nargin < 2
                sectionID=1:obj.numSections;
            end
            
           
            for i=1:numel(sectionID)
                n=find(obj.commentLines==obj.sectionStart(sectionID(i)));
                for k=1:numel(n)
                    if k==1
                        header{i}=obj.comments{n(k)};
                    else
                        header{i}=sprintf('%s %s',obj.comments{n(k)},header{i});
                    end
                end
            end
            
        if i==1
            if ~exist('header','var') % if no section has been defined, just return 'data'
                header='data';
            else
                header=header{i};
            end
        end
        end
    
        function d=sectionData(obj,sectionID)
            if nargin < 2
                sectionID=1:obj.numSections;
            end
            d=[];
            for i=1:numel(sectionID)
                d(end+1:end+numel(obj.sectionLines(sectionID(i))),:)=obj.data(obj.sectionLines(sectionID(i)),:);
            end
        end
        
    end
    
    methods(Static)
        % by Jan Simon, Taken from:
        % http://de.mathworks.com/matlabcentral/answers/892-engineering-notation-printed-into-files
        
        function [factor, Str] = SiPrefix(x,greek) % greek: display greek-letters (latex) instead of unicode
            if nargin < 2
                greek=0;
            end
            Exponent = 3 * floor(log10(x) / 3);
            y = x / (10 ^ Exponent);
            ExpValue = [9, 6, 3, 0, -3, -6, -9, -12, -15, -18];
            if greek
                ExpName = {'G', 'M', 'k', '', 'm', '\mu', 'n','p','f','a'};
            else
                ExpName = {'G', 'M', 'k', '', 'm', 'u', 'n','p','f','a'};
            end
            ExpIndex = (Exponent == ExpValue);
            if any(ExpIndex)  % Found in the list:
                Str = ExpName{ExpIndex};
                factor=10^(-Exponent);
            else  % Fallback: Show the numeric value
                % EDITED: Walter refined '%d' to '%+04d':
                Str = '';
                factor=1;
            end
        end
    end
end