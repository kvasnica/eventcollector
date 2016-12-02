# EventCollector #

Local storage of all events for Matlab objects.

## Installation

The package can be installed by [tbxmanager](http://www.tbxmanager.com):
```
#!matlab
tbxmanager install eventcollector
```

## Updating

To update the eventcollector package (and other installed packages as well) to the latest version, use
```
#!matlab
tbxmanager update
```


## Usage

`collector = EventCollector(OBJECT, EVENTNAME)` creates a new event collector
which listenes to the event `EVENTNAME` of object `OBJECT`. Once the
observed event is triggered, the collector stores the event object in
a local event store. Stored events can be accessed as follows:
 
* `N = collector.numel()` returns the number `N` of stored events
* `E = collector.last()` returns the last received event `E`
* `E = collector.pop()` returns the last event `E` and removes it from the event store
* `E = collector.all()` returns all stored events as a cell array
* `collector.clear()` clears all stored events
 
Once created, the collector is enabled and listenes for events. To
temporarily stop event collection, call `collector.stop()`. To resume
collection, use `collector.start()`. 
 
Incomming events can be parsed before they are stored in the
collector. Parsing can be enabled by 
```
#!matlab
collector = EventCollector(OBJECT, EVENTNAME, 'EventParser', EPFUN)
```
where `EPFUN` is a function handle which takes the event to be parsed
as the input and returns the parsed event as the output. As an
example, using `EPFUN = @(e) e.Message` will cause the collector to
store only the Message component of the event instead of the event
object itself.
 
By default, the number of stored events is limited to 1 million.
Once this limit is reached and a new event arrives, the oldest one is
removed to make room for the new one. The storage limit can be
changed by 
```
#!matlab
collector = EventCollector(OBJECT, EVENTNAME, 'MaxEntries', NEWLIMIT)
```
where `NEWLIMIT` is a positive integer.