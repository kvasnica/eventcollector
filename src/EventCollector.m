classdef EventCollector < handle
    % Local storage of all events for a particular object
    %
    % C = EventCollector(OBJECT, EVENTNAME) creates a new event collector
    % which listenes to the event EVENTNAME of objec OBJECT. Once the
    % observed event is triggered, the collector stores the event object in
    % a local event store. Stored events can be accessed as follows:
    %
    %   N=numel(C)  returns the number N of stored events
    %   E=last(C)   returns the last received event E
    %   E=pop(C)    returns the last event E and removes it from the event store
    %   E=all(C)    returns all stored events as a cell array
    %   clear(C)    clears all stored events
    %
    % Once created, the collector is enabled and listenes for events. To
    % temporarily stop event collection, call stop(C). To resume
    % collection, use start(C). 
    %
    % Incomming events can be parsed before they are stored in the
    % collector. Parsing can be enabled by 
    %   C = EventCollector(OBJECT, EVENTNAME, 'EventParser', EPFUN)
    % where EPFUN is a function handle which takes the event to be parsed
    % as the input and returns the parsed event as the output. As an
    % example, using "EPFUN = @(e) e.Message" will cause the collector to
    % store only the Message component of the event instead of the event
    % object itself.
    %
    % By default, the number of stored events is limited to 1 million.
    % Once this limit is reached and a new event arrives, the oldest one is
    % removed to make room for the new one. The storage limit can be
    % changed by 
    %   C = EventCollector(OBJECT, EVENTNAME, 'MaxEntries', NEWLIMIT)
    % where NEWLIMIT is a positive integer.
    
    % Copyright (c) 2014, Michal Kvasnica (michal.kvasnica@stuba.sk)
    %
    % Legal note:
    %   This program is free software; you can redistribute it and/or
    %   modify it under the terms of the GNU General Public
    %   License as published by the Free Software Foundation; either
    %   version 2.1 of the License, or (at your option) any later version.
    %
    %   This program is distributed in the hope that it will be useful,
    %   but WITHOUT ANY WARRANTY; without even the implied warranty of
    %   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    %   General Public License for more details.
    %
    %   You should have received a copy of the GNU General Public
    %   License along with this library; if not, write to the
    %   Free Software Foundation, Inc.,
    %   59 Temple Place, Suite 330,
    %   Boston, MA  02111-1307  USA
    
    properties(SetAccess=private)
        Store
    end
    properties(Access=private, Hidden)
        Object
        Event
        Running = false
        EventParser
        Listener
    end
    
    properties(Hidden)
        MAX_ENTRIES
    end
    
    methods
        function this = EventCollector(varargin)
            % EventCollector object constructor
            
            p = inputParser;
            p.addRequired('object');
            p.addRequired('event');
            p.addParamValue('MaxEntries', 1e6);
            p.addParamValue('EventParser', [], @(x) isa(x, 'function_handle'));
            p.parse(varargin{:});
            inputs = p.Results;
            
            this.Object = inputs.object;
            this.Event = inputs.event;
            this.EventParser = inputs.EventParser;
            this.MAX_ENTRIES = inputs.MaxEntries;
            
            this.Listener = inputs.object.addlistener(this.Event, @(h, e) this.receive(h, e));
            this.start();
        end

        function display(obj)
            % Overloaded display method for EventCollector
            
            if obj.isRunning()
                status = 'running';
            else
                status = 'stopped';
            end
            fprintf('        Listening to: %s of %s\n', obj.Event, class(obj.Object));
            if ~isempty(obj.EventParser)
                fprintf('           Parsed by: %s\n', char(obj.EventParser));
            end
            fprintf('  Collector''s status: %s\n', status);
            fprintf('    Number of events: %d\n', obj.numel());
        end
        
        function s = isRunning(this)
            % Returns status of the collector
            %
            % Returns true if the collector is running, false otherwise.
            
            s = this.Running;
        end
            
        function n = numel(this)
            % Number of elements in the collector
            
            n = numel(this.Store);
        end
        
        function start(this)
            % Starts the collector
            
            this.Running = true;
        end
        
        function stop(this)
            % Stops the collector
            
            this.Running = false;
        end
        
        function clear(this)
            % Clears all collected events
            
            this.Store = {};
        end
        
        function out = last(this)
            % Returns the last stored event
            %
            % V=last(COLLECTOR) returns V=[] if the collector is empty.
            
            if numel(this.Store)>0
                out = this.Store{end};
            else
                out = [];
            end
        end
        
        function out = pop(this)
            % Pops the last received value
            
            out = this.last();
            this.Store = this.Store(1:end-1);
        end
        
        function out = all(this)
            % Returns all collected events as a cell array
            
            out = this.Store;
        end
        
        function delete(this)
            % Delete the collector
            
            delete(this.Listener);
            this.Running = false;
        end
    end
    
    methods(Access=private)
        function receive(this, ~, event)
            % Adds a message to the store
            
            if this.Running
                % parse the event
                if ~isempty(this.EventParser)
                    event = this.EventParser(event);
                end
                
                % add to store
                this.Store{end+1} = event;
                
                % truncate the store
                if numel(this.Store)>this.MAX_ENTRIES
                    this.Store = this.Store(2:end);
                end
            end
        end
    end
end
