# textProgressBar
A MATLAB class that implements a text-based progress bar.
# Features:
  - Shows the percentage and the progress bar
  - Updates every 100 ms (customizable) to avoid flooding the command window buffer
  - Shows iterations/second (toggleable)
  - Prints optional messages in the command window (toggleable)
  - Can add a prefix to the progress bar (toggleable/customizable)

# Use:
This is a class of type handle, so it is persistent and requires instantiation. The class has a constructor method that is used to configure it, and a `step` method that has to be called at every iteration that needs to be tracked.

## Constructor:
```
textProgressBar(nSteps)
textProgressBar(nSteps,Name,Value)
```

## Methods:
```
step()
step(displayProgress)
step(displayProgress,appendMessage)
step(displayProgress,appendMessage,scrollMessage)
step(displayProgress,appendMessage,scrollMessage,manualStep)
```

## Inputs:
```
nSteps                Integer     Expected number of steps.

Name, Value             -         Name-value pairs (see below).

displayProgress       Logical     Forces behaviour of the print
                                  output.

appendMessage         String      Append a custom message at each
                                  iteration after the progress bar,
                                  or iteration metrics.

scrollMessage         String      Prints a custom message in the
                                  command window that will scroll
                                  normally.

manualStep            Integer     Forces the progress bar to show a
                                  specific percentage instead of the
                                  computed one.
```

## Name-value pairs:
```
showitermetrics       Logical     Displays iterations/second

prefix                String      Displays a short message which
                                  precedes the progress bar

limitFrequency        Float       Upper limit to the update frequency
                                  of the text output
```

# Examples:
A simple example
```
n = 100;
tpb = textProgressBar(n)
for ii = 1:n
    tpb.step();
    pause(0.2);
end
```

A more complex example
```
n = 100;
tpb = textProgressBar(n, 'showitermetrics', true, ...
    'prefix', 'Dummy cycle', 'limitFrequency', 20);
for ii = 1:n
    suffixMsg = sprintf('Custom message (%i)',ii);
    scrollMsg = sprintf('Scrolling message (%i/%i)\n',ii,n);
    tpb.step(true, suffixMsg, scrollMsg);
    pause(0.2);
end
```

## Copyright
Copyright 2021 Stefano Seriani
