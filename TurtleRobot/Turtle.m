classdef Turtle < handle
    % TURTLE  A tiny turtle robot simulator for ENGR 1701.
    %
    %   t = Turtle();            % empty drawing canvas (Week 1)
    %   t = Turtle("hallway");   % a maze level (Week 2)
    %   t = Turtle("tunnel");    % random level: changes every run
    %
    %   MOVING                      DRAWING
    %   t.forward(100)              t.penUp()      t.penDown()
    %   t.backward(50)              t.setColor("red")
    %   t.left(90)    t.left()      t.setWidth(3)
    %   t.right(45)   t.right()     t.setSpeed(10)   % 1 = slow ... 10 = fast
    %                               t.setRobotColor("blue")
    %
    %   SENSORS (maze levels)       INFO
    %   t.wallAhead()   -> true/false      t.report()
    %   t.wallLeft()    -> true/false      t.X, t.Y, t.Heading
    %   t.wallRight()   -> true/false
    %   t.distanceAhead() -> free cells ahead
    %   t.atGoal()      -> true/false
    %
    %   In maze levels one step = one grid cell, and turns must be
    %   multiples of 90 degrees.
    %
    %   See also turtleLevels, checkMission, turtleSetupCheck.

    properties (SetAccess = private)
        X = 0               % robot x position
        Y = 0               % robot y position
        Heading = 0         % degrees: 0 = east (right), 90 = north (up)
        PenIsDown = true
        PenColor = [0.12 0.23 0.37]
        PenWidth = 2
        RobotColor = [0.96 0.65 0.15]
        Speed = 6
        Level               % struct describing the world
        Crashed = false
        ReachedGoal = false
        MoveCount = 0       % number of forward/backward commands
        TurnCount = 0       % number of left/right commands
        Distance = 0        % total distance traveled
        Segments = zeros(0, 9)  % [x1 y1 x2 y2 penDown r g b width]
    end

    properties (Constant, Hidden)
        MaxCommands = 3000
        MaxSensorReads = 30000
    end

    properties (Access = private)
        Fig
        Ax
        Body            % hgtransform holding the robot shape
        BodyPatch
        CommandCount = 0
        SensorCount = 0
        Start = [0 0 0]
    end

    methods
        % ------------------------------------------------------------
        function t = Turtle(level, seed)
            if nargin < 1 || isempty(level)
                level = "canvas";
            end
            if nargin < 2
                seed = [];
            end
            t.Level = turtleLevels(level, seed);
            t.X = t.Level.start(1);
            t.Y = t.Level.start(2);
            t.Heading = t.Level.start(3);
            t.Start = t.Level.start;
            t.setupFigure();
            if t.Level.isMaze
                fprintf('Level "%s": %s\n', t.Level.name, t.Level.description);
            end
        end

        % ------------------------------------------------------------
        function forward(t, distance)
            % FORWARD  Move the robot forward. Example: t.forward(100)
            if nargin < 2
                error('Turtle:input', ...
                    'forward needs a distance. Example: t.forward(100)');
            end
            t.checkNumber(distance, "forward");
            t.move(distance);
        end

        function backward(t, distance)
            % BACKWARD  Move the robot backward. Example: t.backward(50)
            if nargin < 2
                error('Turtle:input', ...
                    'backward needs a distance. Example: t.backward(50)');
            end
            t.checkNumber(distance, "backward");
            t.move(-distance);
        end

        function left(t, angle)
            % LEFT  Turn left (counterclockwise). t.left() turns 90 degrees.
            if nargin < 2
                angle = 90;
            end
            t.checkNumber(angle, "left");
            t.turn(angle);
        end

        function right(t, angle)
            % RIGHT  Turn right (clockwise). t.right() turns 90 degrees.
            if nargin < 2
                angle = 90;
            end
            t.checkNumber(angle, "right");
            t.turn(-angle);
        end

        % ------------------------------------------------------------
        function penUp(t)
            % PENUP  Stop drawing while moving.
            t.PenIsDown = false;
        end

        function penDown(t)
            % PENDOWN  Start drawing again.
            t.PenIsDown = true;
        end

        function setColor(t, c)
            % SETCOLOR  Pen color: "red", "blue", "green", "black", "orange",
            % "purple", "magenta", "cyan", or an [r g b] vector (0 to 1).
            t.PenColor = Turtle.toRGB(c);
        end

        function setWidth(t, w)
            % SETWIDTH  Pen width in points, for example t.setWidth(4).
            t.checkNumber(w, "setWidth");
            t.PenWidth = max(0.5, w);
        end

        function setRobotColor(t, c)
            % SETROBOTCOLOR  Color of the robot itself, for example
            % t.setRobotColor("blue"). Same color names as setColor.
            t.RobotColor = Turtle.toRGB(c);
            if t.figureOK() && ~t.Crashed
                t.BodyPatch.FaceColor = t.RobotColor;
                drawnow;
            end
        end

        function setSpeed(t, s)
            % SETSPEED  1 = slowest ... 10 = fastest, 0 = no animation.
            t.checkNumber(s, "setSpeed");
            t.Speed = min(10, max(0, round(s)));
        end

        % ------------------------------------------------------------
        function tf = wallAhead(t)
            % WALLAHEAD  true if the cell in front of the robot is a wall.
            tf = t.isWallInDirection(t.Heading);
        end

        function tf = wallLeft(t)
            % WALLLEFT  true if the cell to the robot's left is a wall.
            tf = t.isWallInDirection(t.Heading + 90);
        end

        function tf = wallRight(t)
            % WALLRIGHT  true if the cell to the robot's right is a wall.
            tf = t.isWallInDirection(t.Heading - 90);
        end

        function n = distanceAhead(t)
            % DISTANCEAHEAD  Number of free cells in front of the robot.
            t.countSensor();
            n = 0;
            if ~t.Level.isMaze
                n = Inf;
                return
            end
            [dx, dy] = Turtle.unitStep(t.Heading);
            while ~t.isWallCell(round(t.X) + (n + 1) * dx, round(t.Y) + (n + 1) * dy)
                n = n + 1;
            end
        end

        function tf = atGoal(t)
            % ATGOAL  true if the robot is on the goal cell.
            t.countSensor();
            tf = t.Level.isMaze && ~t.Crashed && ...
                round(t.X) == t.Level.goal(1) && round(t.Y) == t.Level.goal(2);
        end

        % ------------------------------------------------------------
        function report(t)
            % REPORT  Print what the robot has done so far.
            fprintf('\n--- Robot report ---\n');
            fprintf('Position: (%.1f, %.1f)   Heading: %g degrees\n', ...
                t.X, t.Y, mod(t.Heading, 360));
            fprintf('Move commands: %d   Turn commands: %d   Distance: %.1f\n', ...
                t.MoveCount, t.TurnCount, t.Distance);
            if t.Level.isMaze
                if t.Crashed
                    fprintf('Status: CRASHED\n');
                elseif t.atGoal()
                    fprintf('Status: at the goal\n');
                else
                    fprintf('Status: not at the goal yet\n');
                end
            end
            fprintf('--------------------\n');
        end
    end

    % ================================================================
    methods (Access = private)
        function setupFigure(t)
            fig = findobj(groot, 'Type', 'figure', 'Tag', 'TurtleRobotFig');
            if isempty(fig)
                fig = figure('Name', 'Turtle Robot', 'NumberTitle', 'off', ...
                    'Tag', 'TurtleRobotFig', 'Color', 'w');
                try
                    fig.WindowStyle = 'docked';   % keep the robot inside the MATLAB window
                catch
                end
            else
                fig = fig(1);
                clf(fig);
                figure(fig);
            end
            t.Fig = fig;
            ax = axes('Parent', fig);
            t.Ax = ax;
            hold(ax, 'on');
            axis(ax, 'equal');
            ax.Box = 'on';
            ax.Layer = 'top';

            if t.Level.isMaze
                t.drawMaze();
                s = 0.36;
            else
                ax.XLim = [-200 200];
                ax.YLim = [-200 200];
                grid(ax, 'on');
                ax.GridAlpha = 0.12;
                plot(ax, 0, 0, '+', 'Color', [0.7 0.7 0.7], 'MarkerSize', 10);
                s = 12;
            end

            t.Body = hgtransform('Parent', ax);
            t.BodyPatch = patch('Parent', t.Body, ...
                'XData', s * [1.2 -0.8 -0.4 -0.8], ...
                'YData', s * [0 0.75 0 -0.75], ...
                'FaceColor', t.RobotColor, 'EdgeColor', [0.3 0.2 0.05], ...
                'LineWidth', 1.2);
            t.updateBody();
            t.updateTitle();
            drawnow;
        end

        function drawMaze(t)
            ax = t.Ax;
            map = t.Level.map;
            [ny, nx] = size(map);
            rgb = ones(ny, nx, 3);
            wall = [0.22 0.27 0.35];
            floorc = [0.97 0.97 0.97];
            for k = 1:3
                layer = floorc(k) * ones(ny, nx);
                layer(map) = wall(k);
                rgb(:, :, k) = layer;
            end
            g = t.Level.goal;
            rgb(g(2), g(1), :) = reshape([0.55 0.85 0.55], 1, 1, 3);
            image(ax, 'XData', [1 nx], 'YData', [1 ny], 'CData', rgb);
            ax.YDir = 'normal';
            ax.XLim = [0.5 nx + 0.5];
            ax.YLim = [0.5 ny + 0.5];
            ax.XTick = 1:nx;
            ax.YTick = 1:ny;
            ax.FontSize = 8;
            for k = 0.5:1:(nx + 0.5)
                plot(ax, [k k], [0.5 ny + 0.5], 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
            end
            for k = 0.5:1:(ny + 0.5)
                plot(ax, [0.5 nx + 0.5], [k k], 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
            end
            text(ax, g(1), g(2), 'GOAL', 'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold', 'FontSize', 8, 'Color', [0.1 0.4 0.1]);
            plot(ax, t.Level.start(1), t.Level.start(2), 'o', ...
                'Color', [0.5 0.5 0.5], 'MarkerSize', 14);
        end

        % ------------------------------------------------------------
        function move(t, d)
            t.countCommand();
            t.MoveCount = t.MoveCount + 1;
            if t.Level.isMaze
                t.mazeMove(d);
            else
                t.canvasMove(d);
            end
        end

        function canvasMove(t, d)
            x0 = t.X; y0 = t.Y;
            x1 = x0 + d * cosd(t.Heading);
            y1 = y0 + d * sind(t.Heading);
            t.animateSegment(x0, y0, x1, y1);
            t.X = x1; t.Y = y1;
            t.Distance = t.Distance + abs(d);
            t.Segments(end + 1, :) = [x0 y0 x1 y1 t.PenIsDown t.PenColor t.PenWidth];
            t.growCanvas();
            t.updateTitle();
        end

        function mazeMove(t, d)
            if abs(d - round(d)) > 1e-9
                error('Turtle:input', ...
                    'In maze levels the robot moves whole cells. Use a whole number, like t.forward(3). You used %g.', d);
            end
            n = round(d);
            stepSign = sign(n);
            [dx, dy] = Turtle.unitStep(t.Heading);
            dx = dx * stepSign; dy = dy * stepSign;
            for k = 1:abs(n)
                x0 = round(t.X); y0 = round(t.Y);
                x1 = x0 + dx; y1 = y0 + dy;
                if t.isWallCell(x1, y1)
                    t.crash(x0, y0, dx, dy);
                    return
                end
                t.animateSegment(x0, y0, x1, y1);
                t.X = x1; t.Y = y1;
                t.Distance = t.Distance + 1;
                t.Segments(end + 1, :) = [x0 y0 x1 y1 t.PenIsDown t.PenColor t.PenWidth];
                if x1 == t.Level.goal(1) && y1 == t.Level.goal(2) && ~t.ReachedGoal
                    t.ReachedGoal = true;
                    fprintf('*** GOAL REACHED! (%d move commands, %d turn commands) ***\n', ...
                        t.MoveCount, t.TurnCount);
                end
                t.updateTitle();
            end
        end

        function crash(t, x0, y0, dx, dy)
            % small bump animation, then stop the robot
            if t.Speed > 0 && t.figureOK()
                for f = [0.15 0.3 0.15 0]
                    t.X = x0 + f * dx; t.Y = y0 + f * dy;
                    t.updateBody();
                    drawnow;
                    pause(0.03);
                end
            end
            t.X = x0; t.Y = y0;
            t.Crashed = true;
            if t.figureOK()
                t.BodyPatch.FaceColor = [0.85 0.1 0.1];
                t.updateBody();
            end
            t.updateTitle();
            fprintf(2, ['CRASH! The robot hit a wall while moving from cell (%d, %d).\n' ...
                'Look at the picture, fix your code, and run the section again.\n'], x0, y0);
        end

        function turn(t, angle)
            t.countCommand();
            if t.Level.isMaze && abs(mod(angle, 90)) > 1e-9 && abs(mod(angle, 90) - 90) > 1e-9
                error('Turtle:input', ...
                    'In maze levels the robot can only turn by 90 degrees (or 180, 270...). You used %g.', angle);
            end
            t.TurnCount = t.TurnCount + 1;
            h0 = t.Heading;
            if t.Speed > 0 && t.figureOK()
                nSub = max(1, ceil(abs(angle) / 15));
                for k = 1:nSub
                    t.Heading = h0 + angle * k / nSub;
                    t.updateBody();
                    t.frame();
                end
            end
            t.Heading = mod(h0 + angle, 360);
            if abs(t.Heading - 360) < 1e-9
                t.Heading = 0;
            end
            t.updateBody();
            t.updateTitle();
        end

        % ------------------------------------------------------------
        function animateSegment(t, x0, y0, x1, y1)
            if ~t.figureOK()
                return
            end
            hLine = [];
            if t.PenIsDown
                hLine = plot(t.Ax, [x0 x0], [y0 y0], '-', 'Color', t.PenColor, ...
                    'LineWidth', t.PenWidth);
                try
                    uistack(t.Body, 'top');
                catch
                end
            end
            if t.Speed > 0
                len = hypot(x1 - x0, y1 - y0);
                if t.Level.isMaze
                    nSub = 5;
                else
                    nSub = max(1, ceil(len / 6));
                end
                for k = 1:nSub
                    xs = x0 + (x1 - x0) * k / nSub;
                    ys = y0 + (y1 - y0) * k / nSub;
                    if ~isempty(hLine)
                        hLine.XData = [x0 xs];
                        hLine.YData = [y0 ys];
                    end
                    t.X = xs; t.Y = ys;
                    t.updateBody();
                    t.frame();
                end
            end
            if ~isempty(hLine)
                hLine.XData = [x0 x1];
                hLine.YData = [y0 y1];
            end
            t.X = x1; t.Y = y1;
            t.updateBody();
            if t.Speed == 0
                drawnow limitrate;
            end
        end

        function frame(t)
            delays = [0.05 0.04 0.03 0.022 0.016 0.011 0.007 0.004 0.002 0];
            if t.Speed >= 10
                drawnow limitrate;
            else
                drawnow;
                pause(delays(t.Speed));
            end
        end

        function updateBody(t)
            if t.figureOK()
                t.Body.Matrix = makehgtform('translate', [t.X t.Y 0], ...
                    'zrotate', deg2rad(t.Heading));
            end
        end

        function updateTitle(t)
            if ~t.figureOK()
                return
            end
            if t.Level.isMaze
                status = '';
                if t.Crashed
                    status = '   CRASHED!';
                elseif round(t.X) == t.Level.goal(1) && round(t.Y) == t.Level.goal(2)
                    status = '   GOAL REACHED!';
                end
                str = sprintf('Level: %s   |   moves: %d   turns: %d%s', ...
                    t.Level.name, t.MoveCount, t.TurnCount, status);
            else
                str = sprintf('Canvas   |   position (%.0f, %.0f)   heading %g%s', ...
                    t.X, t.Y, mod(round(t.Heading, 6), 360), char(176));
            end
            title(t.Ax, str, 'Interpreter', 'none', 'FontSize', 11);
        end

        function growCanvas(t)
            if ~t.figureOK()
                return
            end
            m = max(abs([t.X t.Y])) + 40;
            if m > t.Ax.XLim(2)
                lim = 100 * ceil(m / 100);
                t.Ax.XLim = [-lim lim];
                t.Ax.YLim = [-lim lim];
            end
        end

        function ok = figureOK(t)
            ok = ~isempty(t.Fig) && isvalid(t.Fig) && ~isempty(t.Ax) && isvalid(t.Ax);
        end

        % ------------------------------------------------------------
        function tf = isWallInDirection(t, heading)
            t.countSensor();
            if ~t.Level.isMaze
                tf = false;
                return
            end
            [dx, dy] = Turtle.unitStep(heading);
            tf = t.isWallCell(round(t.X) + dx, round(t.Y) + dy);
        end

        function tf = isWallCell(t, x, y)
            map = t.Level.map;
            [ny, nx] = size(map);
            if x < 1 || y < 1 || x > nx || y > ny
                tf = true;
            else
                tf = map(y, x);
            end
        end

        function countCommand(t)
            if t.Crashed
                error('Turtle:crashed', ...
                    'The robot already crashed, so it cannot keep moving. Fix your code and run the section again.');
            end
            t.CommandCount = t.CommandCount + 1;
            if t.CommandCount > t.MaxCommands
                error('Turtle:tooMany', ...
                    'Stopped: the robot used more than %d commands. Is your loop running forever?', t.MaxCommands);
            end
        end

        function countSensor(t)
            t.SensorCount = t.SensorCount + 1;
            if t.SensorCount > t.MaxSensorReads
                error('Turtle:tooMany', ...
                    'Stopped: the sensors were read more than %d times. Is your loop running forever without moving?', ...
                    t.MaxSensorReads);
            end
        end

        function checkNumber(~, v, name)
            if ~isnumeric(v) || ~isscalar(v) || ~isfinite(v)
                error('Turtle:input', ...
                    '%s needs one number inside the parentheses, for example t.%s(90).', name, name);
            end
        end
    end

    % ================================================================
    methods (Static, Access = private)
        function [dx, dy] = unitStep(heading)
            h = mod(round(heading), 360);
            switch h
                case 0
                    dx = 1; dy = 0;
                case 90
                    dx = 0; dy = 1;
                case 180
                    dx = -1; dy = 0;
                case 270
                    dx = 0; dy = -1;
                otherwise
                    dx = round(cosd(h)); dy = round(sind(h));
            end
        end

        function rgb = toRGB(c)
            if isnumeric(c) && numel(c) == 3
                rgb = min(1, max(0, double(c(:)')));
                return
            end
            names = ["red", "green", "blue", "black", "white", "orange", ...
                "purple", "magenta", "cyan", "yellow", "gray", "brown", "pink"];
            vals = [0.85 0.1 0.1; 0.1 0.6 0.2; 0.1 0.3 0.85; 0 0 0; 1 1 1; ...
                1 0.55 0; 0.5 0.2 0.7; 0.9 0.1 0.7; 0 0.7 0.8; 0.95 0.8 0; ...
                0.5 0.5 0.5; 0.55 0.33 0.15; 1 0.5 0.7];
            idx = find(strcmpi(string(c), names), 1);
            if isempty(idx)
                error('Turtle:input', ...
                    'Unknown color "%s". Try one of: %s', char(string(c)), char(strjoin(names, ', ')));
            end
            rgb = vals(idx, :);
        end
    end
end
