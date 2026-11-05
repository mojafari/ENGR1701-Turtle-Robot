%% ENGR 1701 - Week 1: Meet Your Robot (MATLAB basics)
% =========================================================================
% HOW THIS FILE WORKS  (read this first!)
%
%  * This file is split into SECTIONS. Each section starts with a line
%    that begins with two percent signs: %%
%  * Click anywhere inside a section. It turns light yellow.
%  * Press  Ctrl + Enter  (Mac: Cmd + Enter), or click "Run Section"
%    on the EDITOR tab at the top. Only that section runs.
%  * Do NOT press the big green "Run" button (F5). It runs the whole file
%    at once and stops at the first unfinished task.
%  * Lines that start with %  are COMMENTS (green). MATLAB ignores them.
%    They are instructions for you.
%  * Results appear in the COMMAND WINDOW (bottom). Red text = an error.
%    Errors are normal! Read the message: it tells you the line and the
%    problem.
%  * When a task says "MISSION CODE", write the code on your answer sheet.
%
% Do the sections IN ORDER, from top to bottom.
% =========================================================================


%% STEP 0 - Setup check (run this section first)
% Click inside this section and press Ctrl + Enter.
% You should see "SETUP OK!" in the Command Window and a green triangle.
% If you see a pop-up asking to "Change Folder", click Change Folder.

turtleSetupCheck


%% PART A - MATLAB is a calculator
% Run this section. Look at the Command Window after each line.

3 + 4            % MATLAB prints:  ans = 7
side = 100       % store the number 100 in a VARIABLE called side
side * 4         % use the variable
area = side^2;   % a semicolon ; at the end HIDES the output...
disp(area)       % ...and disp() shows a value when you want it

% YOUR TURN: below this line, create a variable called  myNumber  equal to
% your favorite number, then multiply it by 3. Run the section again.



%% TASK 1 - Your first drive
% t = Turtle();   creates a robot called t on an empty canvas.
% t.forward(100)  tells the robot t to drive 100 steps forward.
% Just run this section and watch the robot window.

t = Turtle();
t.forward(100)

checkMission(t, "line")        % -> MISSION CODE


%% TASK 2 - Turning (explore, no check)
% t.left(90)  turns the robot 90 degrees to the LEFT (counterclockwise).
% t.right(90) turns it 90 degrees to the RIGHT (clockwise).
% Run this section. Then change the numbers and run it again.
% Try: different distances, different angles (45? 120? 180?).

t = Turtle();
t.forward(100)
t.left(90)
t.forward(50)
t.right(45)
t.forward(70)


%% TASK 3 - Fix the bugs!
% This code should draw an "L": 100 to the right, turn left, then 50 up.
% It has 3 BUGS (mistakes). Run it, read the red error message, fix the
% line it points to, and run again. Repeat until checkMission says PASS.
% Hint: MATLAB is picky about spelling AND about capital letters.

t = Turtle();
t.foward(100)
t.Left(90)
t.forward(fifty)

checkMission(t, "fix-bugs")    % -> MISSION CODE


%% TASK 4 - Draw a square (by hand)
% A square has 4 sides of 100 and 4 turns of 90 degrees.
% Write the commands below the line "t = Turtle();".
% You will need 8 lines: forward, left, forward, left, ...

t = Turtle();
% write your 8 lines here:



checkMission(t, "square")      % -> MISSION CODE


%% TASK 5 - Square with a FOR LOOP
% Writing the same two lines 4 times is boring. A FOR LOOP repeats code:
%
%     for k = 1:4
%         ...these lines run 4 times...
%     end
%
% Put ONE forward and ONE left inside the loop below.
% Use the variable sideLength instead of typing 150.

t = Turtle();
sideLength = 150;
for k = 1:4
    % your 2 lines here (use sideLength):

end

checkMission(t, "loop-square") % -> MISSION CODE


%% TASK 6 - Any shape: polygons
% A shape with n equal sides turns a total of 360 degrees,
% so each turn is  360 / n  degrees.
% Step 1: replace the 0 in "angle = 0;" with a formula that uses n.
% Step 2: write the loop (copy the idea from Task 5, use side and angle).

t = Turtle();
n = 6;           % number of sides (6 = hexagon)
side = 80;
angle = 0;       % <-- fix this line using n

for k = 1:n
    % your 2 lines here:

end

checkMission(t, "hexagon")     % -> MISSION CODE
% After you pass: change n to 3, 5, 8, or 36 and run again (no check).


% =========================================================================
%  MINI TEST  (work on your own; use what you learned above)
% =========================================================================

%% MINI TEST 1 - Draw a 5-point star
% * 5 lines, each 150 long
% * at each point the robot turns 144 degrees
% * use a for loop
% Write ALL the code yourself below, starting with t = Turtle();



checkMission(t, "star")        % -> MISSION CODE


%% MINI TEST 2 - Two squares, two colors
% * Draw a square with sides of 60.
% * Lift the pen:   t.penUp()
% * Move 100 forward WITHOUT drawing, then put the pen down: t.penDown()
% * Change color:   t.setColor("red")    (also "blue", "green", "orange"...)
% * Draw a second square with sides of 60.
% Write ALL the code yourself below, starting with t = Turtle();



checkMission(t, "two-squares") % -> MISSION CODE


%% BONUS - Be creative (no check; take a screenshot)
% Ideas: a house, your initials, a spiral, a flower made of squares.
% Spiral example to start you off (run it, then change 91 or 5):
%
%     t = Turtle();  t.setSpeed(10);
%     for k = 1:60
%         t.forward(5*k)
%         t.left(91)
%     end
%
% More commands: t.setWidth(4), t.setSpeed(1 to 10), t.backward(50),
%                t.setRobotColor("blue")  (changes the robot, not the pen)

