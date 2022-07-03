function slice = selectSlice(V)

global slice

s = sliceViewer(V);

% Listen for mouse clicks on the ROI
l = addlistener(s,'SliderValueChanged',@allevents);

% Block program execution
uiwait;

% Remove listener
delete(l);


end

function allevents(src,evt)
    global slice
    evname = evt.EventName;
    switch(evname)
        case{'SliderValueChanged'}
            slice = evt.CurrentValue;
    end
end