%% ENGR 1701 - Week 2: Robot Missions (sensors, loops, decisions)
% =========================================================================
% Same rules as Week 1:
%  * Click inside a section, press Ctrl + Enter (Mac: Cmd + Enter).
%  * Do NOT press the big green "Run" button (F5).
%  * Red text in the Command Window = an error. Read it, fix, run again.
%  * Write every MISSION CODE on your answer sheet.
%
% This week the robot drives in MAZE levels:
%  * Dark cells are WALLS. The green cell is the GOAL.
%  * One step = one cell, so  t.forward(3)  moves 3 cells.
%  * Turns must be 90 degrees:  t.left()  and  t.right()  turn 90.
%  * If the robot hits a wall it CRASHES (turns red). Fix and rerun.
%  * The numbers on the sides of the picture help you count cells.
% =========================================================================


%% WARM-UP - Meet the sensors (run, then read the Command Window)
% A real robot uses SENSORS to know what is around it.
% Our robot has these sensors. Each one answers with true (1) or false (0):
%     t.wallAhead()    is there a wall right in front of me?
%     t.wallLeft()     ...on my left?
%     t.wallRight()    ...on my right?
%     t.atGoal()       am I on the goal?
% and one that answers with a number:
%     t.distanceAhead()   how many free cells are in front of me?

t = Turtle("hallway");
wallInFront = t.wallAhead()
freeCells   = t.distanceAhead()
amIHome     = t.atGoal()


%% MISSION 1 - Hallway
% Drive straight to the GOAL. Use distanceAhead() above, or count cells.

t = Turtle("hallway");
% your code here:


checkMission(t, "hallway")     % -> MISSION CODE


%% MISSION 2 - Corner
% Drive to the corner, turn, and drive to the GOAL.
% Count the cells in the picture before you write code.

t = Turtle("corner");
% your code here:


checkMission(t, "corner")      % -> MISSION CODE


%% MISSION 3 - Stairs (use a FOR loop)
% Each step of the staircase is: 1 cell right, then 1 cell up.
% Step 1: run this section once to see the stairs.
% Step 2: write the commands for ONE step inside the loop
%         (forward, turn, forward, turn back).
% Step 3: set how many times the loop repeats (count the steps!).

t = Turtle("stairs");
for k = 1:1        % <-- change the 1 at the end to the number of steps
    % commands for ONE step:

end

checkMission(t, "stairs")      % -> MISSION CODE


%% NEW IDEA - The WHILE loop (demo: just run it)
% A FOR loop repeats a FIXED number of times.
% A WHILE loop repeats AS LONG AS a condition is true:
%
%     while  condition
%         ...repeat this...
%     end
%
% The symbol  ~  means NOT. So  ~t.wallAhead()  means "no wall ahead".
% Read the loop below out loud: "while there is no wall ahead, move 1."

t = Turtle("hallway");
while ~t.wallAhead()
    t.forward(1)
end
disp("The robot stopped because a wall is ahead.")


%% MISSION 4 - Tunnel of unknown length (tested on 3 random tunnels)
% The tunnel is a different length EVERY time you run this section,
% so counting cells will not work. Use sensors and a while loop:
%   1. drive until there is a wall ahead
%   2. turn left
%   3. drive until there is a wall ahead (you are now at the GOAL)
% Write your code between the two lines of stars. Do not change the rest.

for trial = 1:3
    t = Turtle("tunnel");
    t.setSpeed(9);
    % ********** YOUR CODE STARTS HERE **********


    % ********** YOUR CODE ENDS HERE ************
    checkMission(t, "tunnel", trial);
end
% -> MISSION CODE appears only if all 3 trials pass


%% NEW IDEA - Making decisions with IF / ELSE (demo: just run it)
%
%     if  condition
%         ...do this when the condition is true...
%     else
%         ...do this when it is false...
%     end

t = Turtle("corner");
t.forward(4)
if t.wallLeft()
    disp("Wall on my left, so I will turn RIGHT.")
    t.right()
else
    disp("No wall on my left, so I will turn LEFT.")
    t.left()
end


%% MISSION 5 - Mystery turn (tested on 3 random tunnels)
% This tunnel turns LEFT or RIGHT, and you never know which one.
%   1. drive until there is a wall ahead
%   2. IF there is a wall on the left, turn right. ELSE turn left.
%   3. drive until there is a wall ahead
% Tip: copy your Mission 4 code and add an if / else in the middle.

for trial = 1:3
    t = Turtle("mystery");
    t.setSpeed(9);
    % ********** YOUR CODE STARTS HERE **********


    % ********** YOUR CODE ENDS HERE ************
    checkMission(t, "mystery", trial);
end


%% MISSION 6 - FINAL BOSS: escape a random maze (tested on 3 mazes)
% Robots (and people!) can escape many mazes with the RIGHT-HAND RULE:
% keep your right hand on the wall and keep walking.
%
% In code, repeat until you reach the goal:
%   * if there is NO wall on your right  ->  turn right, move 1
%   * else if there is NO wall ahead     ->  move 1
%   * else (walls right and ahead)       ->  turn left
%
% The decisions are already written. Fill in the ACTIONS (empty lines).
% If you leave them empty, the robot never moves and MATLAB stops the loop
% with an error: that is normal, it means you still have to fill them in.

for trial = 1:3
    t = Turtle("maze");
    t.setSpeed(10);
    % ********** YOUR CODE STARTS HERE **********
    while ~t.atGoal()
        if ~t.wallRight()
            % turn right, then move 1:

        elseif ~t.wallAhead()
            % move 1:

        else
            % turn left:

        end
    end
    % ********** YOUR CODE ENDS HERE ************
    checkMission(t, "maze", trial);
end


%% BONUS A - Fewest commands
% Solve Mission 4 again using as FEW commands as possible.
% Hint: t.forward(t.distanceAhead()) drives all the way to the wall in ONE
% command. After the mission, type  t.report()  to see your counts.


%% BONUS B - Design your own maze
% Draw a map with text. Every row must be the same length.
%   #  wall     .  floor     G  goal     >  start (robot faces right)
% Then paste your Mission 6 code below and see if it escapes YOUR maze.

myMap = ["###########"
         "#>..#.....#"
         "###.#.###.#"
         "#...#...#.#"
         "#.#####.#.#"
         "#.......#G#"
         "###########"];
t = Turtle(myMap);
% paste your Mission 6 while loop here:

