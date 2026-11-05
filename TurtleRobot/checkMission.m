function varargout = checkMission(t, mission, trial)
% CHECKMISSION  Check your robot's work and get a mission code.
%
%   checkMission(t, "square")          % check one task
%   checkMission(t, "tunnel", trial)   % random levels are tested 3 times
%
%   When you pass, write the MISSION CODE on your answer sheet.

if nargin < 3
    trial = [];
end
mission = lower(string(mission));
persistent trials
if isempty(trials)
    trials = struct();
end

if ~isa(t, 'Turtle') || ~isvalid(t)
    error('Turtle:check', 'The first input must be your robot, for example: checkMission(t, "square")');
end

[ok, msg] = runCheck(t, mission);

fprintf('\n');
if isempty(trial)
    printResult(ok, msg, mission);
else
    key = matlab.lang.makeValidName(char(mission));
    if trial == 1 || ~isfield(trials, key)
        trials.(key) = false(1, 0);
    end
    trials.(key)(trial) = ok;
    if ok
        fprintf('Trial %d of 3: PASS\n', trial);
    else
        fprintf(2, 'Trial %d of 3: TRY AGAIN. %s\n', trial, msg);
    end
    if trial == 3
        nPass = sum(trials.(key));
        if nPass == 3
            printResult(true, "Your code worked on 3 different random levels!", mission);
        else
            printResult(false, sprintf("Only %d of 3 trials passed. Your code must work every time.", nPass), mission);
        end
    end
end

if nargout > 0
    varargout{1} = ok;
end
end

% ====================================================================
function printResult(ok, msg, mission)
if ok
    fprintf('==============================================\n');
    fprintf(' PASS: %s\n', msg);
    fprintf(' MISSION CODE for "%s":  %s\n', mission, missionCode(mission));
    fprintf('==============================================\n');
else
    fprintf(2, 'TRY AGAIN: %s\n', msg);
end
end

function code = missionCode(mission)
codes = struct( ...
    'line', 'ZOOM-41', 'fix_bugs', 'BUG-88', 'square', 'BOX-17', ...
    'loop_square', 'LOOP-53', 'hexagon', 'HEX-62', 'star', 'STAR-29', ...
    'two_squares', 'TWIN-75', 'hallway', 'GO-12', 'corner', 'TURN-34', ...
    'stairs', 'STEP-96', 'tunnel', 'SENSE-58', 'mystery', 'DECIDE-21', ...
    'maze', 'ESCAPE-07');
key = strrep(char(mission), '-', '_');
if isfield(codes, key)
    code = codes.(key);
else
    code = '(no code)';
end
end

% ====================================================================
function [ok, msg] = runCheck(t, mission)
mazeMissions = ["hallway", "corner", "stairs", "tunnel", "mystery", "maze"];
if any(mission == mazeMissions)
    [ok, msg] = checkMaze(t, mission);
    return
end
if t.Level.isMaze
    ok = false;
    msg = sprintf('This task uses the drawing canvas. Start with t = Turtle(); not a maze level.');
    return
end
segs = t.Segments(t.Segments(:, 5) == 1, :);
switch mission
    case "line"
        [ok, msg] = checkLine(segs);
    case "fix-bugs"
        [ok, msg] = checkPath(segs, [0 0; 100 0; 100 50], "an L shape: 100 to the right, then 50 up");
    case "square"
        [ok, msg] = checkPolygon(segs, 4, 100, "square");
    case "loop-square"
        [ok, msg] = checkPolygon(segs, 4, 150, "square");
    case "hexagon"
        [ok, msg] = checkPolygon(segs, 6, 80, "hexagon");
    case "star"
        [ok, msg] = checkStar(segs, 150);
    case "two-squares"
        [ok, msg] = checkTwoSquares(segs);
    otherwise
        error('Turtle:check', 'Unknown mission "%s". Check the spelling.', char(mission));
end
end

% --------------------------------------------------------------------
function [ok, msg] = checkMaze(t, mission)
ok = false;
if ~t.Level.isMaze || t.Level.name ~= mission
    msg = sprintf('This check is for the "%s" level. Start with t = Turtle("%s");', mission, mission);
    return
end
if t.Crashed
    msg = "The robot crashed into a wall.";
    return
end
if ~t.atGoal()
    msg = sprintf('The robot stopped at (%g, %g), but the GOAL is at (%d, %d).', ...
        round(t.X), round(t.Y), t.Level.goal(1), t.Level.goal(2));
    return
end
ok = true;
msg = sprintf('The robot reached the GOAL using %d move and %d turn commands.', ...
    t.MoveCount, t.TurnCount);
end

% --------------------------------------------------------------------
function [ok, msg] = checkLine(segs)
ok = false;
if isempty(segs)
    msg = "Nothing was drawn. Did you run t.forward(100)?";
    return
end
if size(segs, 1) > 1
    msg = sprintf('I expected 1 line, but your robot drew %d. Run the whole section again from t = Turtle();', size(segs, 1));
    return
end
p1 = segs(1, 3:4);
if norm(segs(1, 1:2)) > 0.5 || norm(p1 - [100 0]) > 0.5
    msg = sprintf('The line should go from (0, 0) to (100, 0). Yours ends at (%.0f, %.0f).', p1(1), p1(2));
    return
end
ok = true;
msg = "Your robot drove 100 steps forward.";
end

function [ok, msg] = checkPath(segs, pts, what)
ok = false;
n = size(pts, 1) - 1;
if size(segs, 1) ~= n
    msg = sprintf('I expected %d lines (%s), but your robot drew %d.', n, what, size(segs, 1));
    return
end
for k = 1:n
    if norm(segs(k, 1:2) - pts(k, :)) > 0.5 || norm(segs(k, 3:4) - pts(k + 1, :)) > 0.5
        msg = sprintf('Line %d should go from (%g, %g) to (%g, %g). Check that line of code.', ...
            k, pts(k, 1), pts(k, 2), pts(k + 1, 1), pts(k + 1, 2));
        return
    end
end
ok = true;
msg = "All bugs fixed. The robot drew " + what + ".";
end

function [ok, msg] = checkPolygon(segs, n, side, shapeName)
ok = false;
if size(segs, 1) ~= n
    msg = sprintf('A %s has %d sides, but your robot drew %d lines. Run the whole section again from t = Turtle();', ...
        shapeName, n, size(segs, 1));
    return
end
lens = hypot(segs(:, 3) - segs(:, 1), segs(:, 4) - segs(:, 2));
if any(abs(lens - side) > 0.5)
    msg = sprintf('Every side should be %g long. Your sides are: %s', side, mat2str(round(lens', 1)));
    return
end
[closed, turns] = shapeTurns(segs);
if ~closed
    msg = "The shape does not end where it started. Check your turning angle.";
    return
end
target = 360 / n;
if any(abs(abs(turns) - target) > 0.5) || ~(all(turns > 0) || all(turns < 0))
    msg = sprintf('Each turn of a %s should be %g degrees, always in the same direction.', shapeName, target);
    return
end
ok = true;
msg = sprintf('Perfect %s with sides of %g.', shapeName, side);
end

function [ok, msg] = checkStar(segs, side)
ok = false;
if size(segs, 1) ~= 5
    msg = sprintf('A 5-point star has 5 lines, but your robot drew %d.', size(segs, 1));
    return
end
lens = hypot(segs(:, 3) - segs(:, 1), segs(:, 4) - segs(:, 2));
if any(abs(lens - side) > 0.5)
    msg = sprintf('Every line should be %g long. Yours are: %s', side, mat2str(round(lens', 1)));
    return
end
[closed, turns] = shapeTurns(segs);
if ~closed || any(abs(abs(turns) - 144) > 0.5)
    msg = "Not a star yet. Hint: a 5-point star turns 144 degrees at each point.";
    return
end
ok = true;
msg = "Beautiful 5-point star!";
end

function [ok, msg] = checkTwoSquares(segs)
ok = false;
if size(segs, 1) ~= 8
    msg = sprintf('Two squares have 8 sides in total, but your robot drew %d lines. Use penUp() while moving between them.', size(segs, 1));
    return
end
a = segs(1:4, :);
b = segs(5:8, :);
[okA, mA] = checkPolygon(a, 4, 60, "square");
[okB, mB] = checkPolygon(b, 4, 60, "square");
if ~okA
    msg = "First square: " + mA;
    return
end
if ~okB
    msg = "Second square: " + mB;
    return
end
if norm(a(1, 6:8) - b(1, 6:8)) < 1e-6
    msg = "Both squares have the same color. Use t.setColor(...) before the second square.";
    return
end
boxA = [min([a(:, 1); a(:, 3)]) max([a(:, 1); a(:, 3)]) min([a(:, 2); a(:, 4)]) max([a(:, 2); a(:, 4)])];
boxB = [min([b(:, 1); b(:, 3)]) max([b(:, 1); b(:, 3)]) min([b(:, 2); b(:, 4)]) max([b(:, 2); b(:, 4)])];
overlap = boxA(1) < boxB(2) - 0.5 && boxB(1) < boxA(2) - 0.5 && ...
    boxA(3) < boxB(4) - 0.5 && boxB(3) < boxA(4) - 0.5;
if overlap
    msg = "The squares overlap. Move farther with the pen up before drawing the second one.";
    return
end
ok = true;
msg = "Two separate squares in two colors.";
end

function [closed, turns] = shapeTurns(segs)
n = size(segs, 1);
connected = true;
for k = 1:n - 1
    connected = connected && norm(segs(k, 3:4) - segs(k + 1, 1:2)) < 0.5;
end
closed = connected && norm(segs(n, 3:4) - segs(1, 1:2)) < 0.5;
d = [segs(:, 3) - segs(:, 1), segs(:, 4) - segs(:, 2)];
turns = zeros(n, 1);
for k = 1:n
    u = d(k, :);
    v = d(mod(k, n) + 1, :);
    turns(k) = atan2d(u(1) * v(2) - u(2) * v(1), u(1) * v(1) + u(2) * v(2));
end
end
