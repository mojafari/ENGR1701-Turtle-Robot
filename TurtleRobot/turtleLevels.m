function level = turtleLevels(name, seed)
% TURTLELEVELS  World definitions for the Turtle robot simulator.
%
%   level = turtleLevels("hallway")
%   level = turtleLevels("maze", 7)       % random level with a fixed seed
%   level = turtleLevels(myMap)           % your own map (string array)
%
%   Built-in levels
%     "canvas"   empty drawing canvas (Week 1)
%     "hallway"  straight hallway
%     "corner"   hallway with one corner
%     "stairs"   staircase with 6 steps
%     "tunnel"   RANDOM: a tunnel of unknown length that turns left
%     "mystery"  RANDOM: a tunnel that turns left OR right
%     "maze"     RANDOM: a new maze every time
%
%   Your own map: a string array, one string per row (top row first).
%     #  wall      .  floor      G  goal
%     >  ^  <  v   start, with the robot facing right/up/left/down
%   Example:
%     myMap = ["#######"
%              "#>..#G#"
%              "##....#"
%              "#######"];       % all rows must have the same length
%     t = Turtle(myMap);

if nargin < 1 || isempty(name)
    name = "canvas";
end
if nargin < 2
    seed = [];
end
if isempty(seed)
    rs = RandStream('mt19937ar', 'Seed', 'shuffle');
else
    rs = RandStream('mt19937ar', 'Seed', seed);
end

if (isstring(name) && numel(name) > 1) || iscell(name)
    level = parseMap(string(name), "custom", "Your own map.");
    return
end

switch lower(string(name))
    case "canvas"
        level = struct('name', "canvas", 'description', "Empty drawing canvas.", ...
            'isMaze', false, 'map', false(0, 0), 'start', [0 0 0], 'goal', [NaN NaN]);

    case "hallway"
        rows = ["########"
                "#>....G#"
                "########"];
        level = parseMap(rows, "hallway", ...
            "Drive straight to the green GOAL cell.");

    case "corner"
        rows = ["#######"
                "#####G#"
                "#####.#"
                "#####.#"
                "#>....#"
                "#######"];
        level = parseMap(rows, "corner", ...
            "Drive to the corner, turn, and reach the GOAL.");

    case "stairs"
        nSteps = 6;
        n = nSteps + 3;
        map = true(n, n);
        x = 2; y = 2;
        map(y, x) = false;
        for k = 1:nSteps
            x = x + 1; map(y, x) = false;
            y = y + 1; map(y, x) = false;
        end
        level = makeLevel("stairs", "Climb the 6 steps to the GOAL. A loop will help!", ...
            map, [2 2 0], [x y]);

    case "tunnel"
        L1 = randi(rs, [3 10]);
        L2 = randi(rs, [2 6]);
        map = true(L2 + 3, L1 + 3);
        map(2, 2:(2 + L1)) = false;
        map(2:(2 + L2), 2 + L1) = false;
        level = makeLevel("tunnel", ...
            "The tunnel length changes every run. Use the sensors!", ...
            map, [2 2 0], [2 + L1, 2 + L2]);

    case "mystery"
        L1 = randi(rs, [3 10]);
        L2 = randi(rs, [2 5]);
        yc = L2 + 2;
        map = true(2 * L2 + 3, L1 + 3);
        map(yc, 2:(2 + L1)) = false;
        if randi(rs, 2) == 1
            ys = yc:(yc + L2);           % turn left (up)
            goal = [2 + L1, yc + L2];
        else
            ys = (yc - L2):yc;           % turn right (down)
            goal = [2 + L1, yc - L2];
        end
        map(ys, 2 + L1) = false;
        level = makeLevel("mystery", ...
            "The tunnel turns LEFT or RIGHT. Your robot must decide!", ...
            map, [2 yc 0], goal);

    case "maze"
        W = 6; H = 5;                      % maze size in rooms
        map = makeMaze(W, H, rs);
        level = makeLevel("maze", "A new random maze every run. Find the GOAL!", ...
            map, [2 2 0], [2 * W, 2 * H]);

    otherwise
        error('Turtle:level', ...
            'Unknown level "%s". Try "canvas", "hallway", "corner", "stairs", "tunnel", "mystery", or "maze".', ...
            char(string(name)));
end
end

% ====================================================================
function level = makeLevel(name, description, map, start, goal)
level = struct('name', string(name), 'description', string(description), ...
    'isMaze', true, 'map', logical(map), 'start', start, 'goal', goal);
end

function level = parseMap(rows, name, description)
rows = string(rows(:));
widths = strlength(rows);
if any(widths ~= widths(1))
    error('Turtle:level', 'Every row of the map must have the same number of characters.');
end
ny = numel(rows);
nx = widths(1);
map = false(ny, nx);
start = [];
goal = [];
for r = 1:ny
    chars = char(rows(r));
    y = ny - r + 1;                 % top row of text = highest y
    for x = 1:nx
        c = chars(x);
        switch c
            case '#'
                map(y, x) = true;
            case 'G'
                goal = [x y];
            case {'>', '^', '<', 'v', 'S'}
                headings = struct('gt', 0, 'up', 90, 'lt', 180, 'dn', 270);
                switch c
                    case '^'
                        h = headings.up;
                    case '<'
                        h = headings.lt;
                    case 'v'
                        h = headings.dn;
                    otherwise
                        h = headings.gt;
                end
                start = [x y h];
        end
    end
end
if isempty(start)
    error('Turtle:level', 'The map needs a start: one of the characters > ^ < v');
end
if isempty(goal)
    error('Turtle:level', 'The map needs a goal: the character G');
end
level = makeLevel(name, description, map, start, goal);
end

function map = makeMaze(W, H, rs)
% Random "perfect" maze (exactly one path between any two rooms),
% built with a depth-first search. Rooms are at even grid positions.
map = true(2 * H + 1, 2 * W + 1);
visited = false(H, W);
stack = [1 1];
visited(1, 1) = true;
map(2, 2) = false;
moves = [1 0; -1 0; 0 1; 0 -1];
while ~isempty(stack)
    cur = stack(end, :);
    order = randperm(rs, 4);
    advanced = false;
    for k = order
        nxt = cur + moves(k, :);           % [col row] of the next room
        if nxt(1) >= 1 && nxt(1) <= W && nxt(2) >= 1 && nxt(2) <= H && ...
                ~visited(nxt(2), nxt(1))
            visited(nxt(2), nxt(1)) = true;
            map(2 * nxt(2), 2 * nxt(1)) = false;                         % new room
            map(cur(2) + nxt(2), cur(1) + nxt(1)) = false;               % open the wall between
            stack(end + 1, :) = nxt; %#ok<AGROW>
            advanced = true;
            break
        end
    end
    if ~advanced
        stack(end, :) = [];
    end
end
end
