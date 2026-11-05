function turtleSetupCheck()
% TURTLESETUPCHECK  Make sure MATLAB can find the Turtle robot files.
%   Type  turtleSetupCheck  in the Command Window and press Enter.

fprintf('\nChecking your setup...\n');
fprintf('  MATLAB version: %s\n', version);

needed = ["Turtle", "turtleLevels", "checkMission"];
missing = strings(0);
for f = needed
    if isempty(which(f))
        missing(end + 1) = f; %#ok<AGROW>
    end
end
if ~isempty(missing)
    fprintf(2, ['\n  PROBLEM: MATLAB cannot find: %s\n' ...
        '  Fix: in the "Current Folder" panel (left side), go into the\n' ...
        '  TurtleRobot folder so you can see Turtle.m, then try again.\n'], ...
        strjoin(missing, ', '));
    return
end
fprintf('  Turtle files found in: %s\n', fileparts(which('Turtle')));

t = Turtle();
t.setSpeed(8);
t.setColor("green");
for k = 1:3
    t.forward(80);
    t.left(120);
end
fprintf(['\n  SETUP OK! You should see a window called "Turtle Robot"\n' ...
    '  with a green triangle. If it is hidden, look for it on the taskbar.\n' ...
    '  Your first code word is:  READY-01\n\n']);
end
