# ENGR 1701 – Program a Robot with MATLAB

A tiny turtle robot simulator for **MATLAB R2025a** or above. In **Week 1** you drive the robot with commands and draw shapes. In **Week 2** the robot uses **sensors** to escape tunnels and mazes.

No programming experience is needed. Every step is explained inside the files, and MATLAB checks your work and gives you a **mission code** each time you finish a task.

---

## 1. Download the files

1. At the top of this page, click the green **`<> Code`** button.
2. Click **Download ZIP**.
3. **Unzip it** (this step is important):
   - **Windows:** right-click the downloaded file → **Extract All** → **Extract**.
   - **Mac:** double-click the downloaded file.
4. You now have a folder called **`ENGR1701-Turtle-Robot-main`**. Inside it is the folder **`TurtleRobot`**. That is the folder you will use in MATLAB.

> If you can download the files from the course page instead, that works too. Either way, you need the **`TurtleRobot`** folder.

## 2. Open it in MATLAB

1. Start **MATLAB R2025a**. The first start can take 1–3 minutes.
2. Find the panel that lists files (called **Current Folder** or **Files**). Use its folder/browse button to open the **`TurtleRobot`** folder.
   You should see `Turtle.m`, `checkMission.m`, `Week1_Meet_Your_Robot.m`, and more.
3. Double-click the file for this week:
   - Week 1: **`Week1_Meet_Your_Robot.m`**
   - Week 2: **`Week2_Robot_Missions.m`**
4. Click inside the first section and press **Ctrl + Enter** (Mac: **Cmd + Enter**).
   In Week 1 you should see **SETUP OK!** and a robot drawing a green triangle.

## 3. How to work in the files

- The files are split into **sections**. A section starts with a line that begins with `%%`.
- Click inside a section (it turns light yellow) and press **Ctrl + Enter**, or click **Run Section** on the **Editor** tab. Only that section runs.
- **Do not** press the big green **Run** button (F5). It runs the whole file at once and stops at the first unfinished task.
- Green lines that start with `%` are instructions for you. MATLAB ignores them.
- **Red text is an error. That's normal!** Read the message, fix the line it points to, and run the section again.
- A loop that runs forever? Click in the Command Window and press **Ctrl + C**.

## 4. Robot commands

| Command | What it does |
|---|---|
| `t = Turtle();` | New robot on an empty canvas (Week 1) |
| `t = Turtle("maze");` | New robot in a level: `"hallway"`, `"corner"`, `"stairs"`, `"tunnel"`, `"mystery"`, `"maze"` |
| `t.forward(100)` / `t.backward(50)` | Drive forward / backward (in mazes the number is cells) |
| `t.left(90)` / `t.right(45)` | Turn left / right in degrees (`t.left()` turns 90) |
| `t.penUp()` / `t.penDown()` | Stop / start drawing |
| `t.setColor("red")` | Pen color |
| `t.setRobotColor("blue")` | Color of the robot itself |
| `t.setWidth(4)` / `t.setSpeed(10)` | Thicker pen / faster robot (1 = slow, 10 = fast) |
| `t.wallAhead()`, `t.wallLeft()`, `t.wallRight()` | Sensors: `true` if there is a wall there |
| `t.distanceAhead()` | Number of free cells in front of the robot |
| `t.atGoal()` | `true` if the robot is on the goal |
| `t.report()` | How many commands the robot used |
| `checkMission(t, "square")` | Check your work and get a mission code |

## 5. Hand in your work

Open the answer sheet for this week from the [`docs`](docs) folder (or the course page):

- [`docs/Week1_Answer_Sheet.docx`](docs/Week1_Answer_Sheet.docx)
- [`docs/Week2_Answer_Sheet.docx`](docs/Week2_Answer_Sheet.docx)

Type your mission codes and answers, save the file, and upload it to the course page.

Handouts: [`Week 1`](docs/ENGR1701_MATLAB_Turtle_Week1_Handout.pdf) · [`Week 2`](docs/ENGR1701_MATLAB_Turtle_Week2_Handout.pdf)

## Common problems

| Problem | Fix |
|---|---|
| `Unrecognized function or variable 'turtleSetupCheck'`, or a **Change Folder** pop-up | MATLAB is in the wrong folder. Click **Change Folder**, or open the `TurtleRobot` folder in the Current Folder panel. |
| Files look like they are "inside" the zip | You didn't unzip it. Extract first (step 1.3). |
| I can't see the robot | It is a tab called **Turtle Robot** inside MATLAB. Click it. |
| `Unrecognized method ... for class 'Turtle'` | A command is misspelled or has wrong capital letters (`left` works, `Left` does not). |
| `CRASH!` | The robot drove into a wall. Fix your code and run the section again. |
