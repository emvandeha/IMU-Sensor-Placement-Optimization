# IMU-Sensor-Placement-Optimization
Data and code for analysis presented in Sensors journal manuscript titled "Optimization of IMU Sensor Placement for the Measurement of Lower Limb Joint Kinematics" by W. Niswander, W. Wang, and K. Kontson.

IMU Placement Study Data Processing Workflow
Wesley Niswander


# Step 1: Set up subject information .mat file (P_xxx_Info.mat)
The subject information files are very important because they define how the data is imported from raw text files and how a variety of scripts handle this data. Subject information files are found in the ‘Subject Information’ folder. For each subject there is a .m file and a .mat file. The .m file is where the variables needed to define how the trial was set up are defined. The .m file, when run, saves these variables into a .mat file for later reference. These files have three sections defining sensor locations, tasks performed, and text file format. There is an additional section at the end where these variables are saved into the .mat file.

**Section 1, Sensor indexes:**  The sensors are numbered based on the order they will appear in the imported data cell array. Files are listed in this structure in alphanumeric order based on file name so that all the sensors appear in the same order for every task. The sensor files are named by the Mtw Station Manager as such: 
Station Serial Number/Time Stamp/Sensor serial Number example) 'MT_0120064B-2019-06-28_09h58_00B4276E.txt'
In this manner the data is organized in the cell array based on the time each task was performed and sensor serial number. If there are 11 sensors, then every 11 files correspond to a single task with the sensors appearing in the same order for each task.

*(Example) Say sensor 00B4276E which is on the subjects heel always appears as the seventh sensor out of 11 for a given task.  This means that row 7 of the structure* *corresponds to the heel sensor for the first task, row 11+7=18 corresponds to the heel sensor for the second task, row 2x11+7=29 corresponds to the heel sensor for* *the third task, et cetera.*
*Matlab orders the sensors alphanumerically so that higher digits come before lower digits, A comes before B, and numbers come before letters.*
*The sensors are ordered in the subject information file from 0 to 10 based on the order of their appearance. If the L4-L5 sensor’s serial number is 5th, for* *instance, then num.L4L5 = 4.*
*The total number of sensors (which is 11 in this study) is also given.*

The task and sensor specific data is later referenced using the following equation: index = NumberSensors*(num.sensor-1)+1 

**Section 2, Task List:** The ‘TaskList’ variable is a character array that lists the tasks performed in a given trial. This variable is used later for reference by the user and to correctly name tasks in the imported data cell array. It is important to separate tasks with newline characters (10 is ascii for newline) for the data structure naming scheme to work correctly. This can be done using the strcat function as such:	TaskList = strcat(‘Task 1’,10,’Task 2’,10,’Task 3’,10, et cetera

**Section 3, Medial Lateral Guesses:** The functional calibration performed later requires initial rough approximations of unit vectors aligned along the positive medial-lateral axis. This is based on the sensors default coordinate system as defined by Xsens.

**Section 4, Text File Format:** This section is used to define where things are in the IMU text files. The output format of these files can be changed in the Mtw Station Manager, so it is convenient to be able to define their structure here. Four things are defined as follows:
1.	Acceleration Columns: The variable ‘AccColumns’ defines the columns where the sensor acceleration data is found. These three columns should be labeled Acc_X, Acc_Y, and Acc_Z.
2.	Rotational Velocity Columns: The variable ‘RVelColumns’ defines the columns where the sensor rotational velocity is found. These three columns should be labeled Gyr_X, Gyr_Y, and Gyr_Z.
3.	Quaternion Column One: The variable ‘QuatColumnOne’ defines the first of four columns containing quaternions. Make sure that the files are indeed outputting quaternions instead of rotational matrices or Euler angles. These columns should be labeled  Quat_q0, Quat_q1, Quat_q2, and Quat_q3. Enter the number corresponding to Quat_q0 only.
4.	Starting Row: The variable ‘RowStart’ defines the first row of the text file which contains data. This may change based on what is displayed in the header.
Note: It is easier to define these variables if you open these text files and actually look at them. Notepad or a similar application may not display the text files in a tabular manner and I suggest either opening them in Matlab or copying and pasting the data into Excel.

**Section 5, Save:** This section calls Matlab’s save function. The user should be sure to enter in the correct name they want to save the .mat file as before running the script. I have been saving them as “P_xxx_Info.”


# Step 2: Import Subject Data (Data_Import.m)
The Data_Import.m script is responsible for importing the subject data from IMU text files into a cell array. The cell array contains five columns. The first contains the file name, the second contains the file’s data table, the third contains a nx4 double of quaternion values, the fourth contains the task name, and the fifth contains the sensor location.
To import the data the user will be prompted to do three things
1.	The user will be prompted to open a subject information .mat file (Example: P_xxx_Info.mat in the ‘Subject Information’ folder). These files, set up in Step 1, contain information necessary to import the IMU text files correctly.
2.	The user will be prompted to select a folder containing the IMU text files (these should be in a folder titled ‘Subject Data Text Files’)
3.	The user will be prompted to save the data cell array as a .mat file. The name should be entered into the Command Window. The .mat file will be saved in the folder titled ‘Imported Subject Data.’

# Step 3: Calibration (Calibration.m)
The Calibration.m function allows the user to calibrate the IMU sensor axes to the body segments they reside on. Two independent methods are used in this study to align three vectors from the sensors to their respective body segment. Both methods use data from the same calibration task, subsequently described. First the subject is instructed to stand still in an upright posture. The subject is then instructed to sit on a stool in a pose that involves the subject extending their legs with their heels remaining on the ground and their toes pointed up so that the long axes of their thighs and shanks are not perpendicular to the ground but are still parallel to the sagittal plane. The subject also leans their torso back, again so that the long axis is not perpendicular to the floor and lies in the sagittal plane. The subject is then asked to walk across the room in a straight line, turn around, and walk back.  

1.	Functional Calibration
- Superior-Inferior (SI) vector: The SI vector is determined from the acceleration vector when the subject is standing. It is assumed that gravitational acceleration points in the SI direction for all body segments and that this is the only mode of acceleration when the subject is standing still. 
- Medial-Lateral (ML) vector: The ML vector is determined when the subject is walking at steady state. It is assumed that the ML axis is the primary axis of rotation for non-torso sensors when the subject is walking at steady state, so the first component obtained through Principal Component Analysis (PCA) of the rotational velocity is used to define the ML vector when the subject is walking at steady state. For torso sensors, this vector is assumed to lye along the “[0 1 0]” axis of the sensor. 
- Anterior-Posterior (AP) vector: The AP vector can be obtained by taking the cross product of the SI and ML vectors. Further cross products are performed between all three vectors to ensure the coordinate system they define is orthogonal.

2.	Static Calibration
- Superior-Inferior (SI) vector: The SI vector is determined from the acceleration vector when the subject is standing. It is assumed that gravitational acceleration points in the SI direction for all body segments and that this is the only mode of acceleration when the subject is standing still. This is the same as in the functional calibration.
- Medial-Lateral (ML) vector: The ML vector is determined by the cross product of the SI vector and vector co-planer to the SI vector in the sagittal plane. The co-planer vector is obtained when the subject is seated still with their legs extended and their torso leaned back. Like with the SI vector, the co-planer vector is obtained when the subject is seated in this pose based on gravitational acceleration.
- Anterior-Posterior (AP) vector: The AP vector can be obtained by taking the cross product of the SI and ML vectors. Further cross products are performed between all three vectors to ensure the coordinate system they define is orthogonal.

The Calibration.m function utilizes a user interface to obtain information from the user to define the subject, calibration task, and phases of calibration. These phases include when the subject is standing, when the subject is seated, and when the subject is walking at steady state. 
The function contains six sections:
1.	Set up workspace: This section uses the uigetfile function so that the user can pick the subject data .mat file (“P_xxx.mat” in the ‘Imported Subject Data’ folder) they want to use, then loads that file. If a .mat file titled ‘data’ is already present, the user will be given the option to “use the same trial data.” These files are a bit larger, so this can save time versus re-loading the same file multiple times.
2.	Select Task: This section also uses the uigetfile function so that the user can pick the correct subject information file (“P_xxx_Info.mat” in the ‘Subject Information’ folder). Again, if this information is already loaded, the user will have the chance to re-use it. The user will then be presented the trial task list in the Command Window and asked the number of the task they want to use. Only Calibration tasks should be chosen.
3.	Create acceleration and rotational velocity variables: The user does not need to do anything for this section. This section uses information provided by the subject information file to pull the acceleration and rotational velocity data for each sensor out of the cell array ‘data.’ The sum of the magnitudes of acceleration and rotational velocity are also found and will be used later.
4. Defining ranges of still standing, still sitting, and steady state gait: This section uses four interactive functions to define the times when the subject is standing, sitting, and walking at steady state. These functions use ‘input’ to obtain information from the user in the Command Window, and ‘ginput’ so that the user can scope out values from plots. The four functions used in this section are as follows:
   - StationaryCalibrationRanges: This function is used to determine the range of time when the subject is standing, and the range of time when the subject is seated. 
     - The user is prompted to click on the starting and ending points where still standing occurs using the heel acceleration plot.
     - The user is prompted to click on the starting and ending points where still sitting occurs using the heel acceleration plot. The user has the option to skip this part is no sitting calibration was performed
    - ZeroVelocityFinder: This function is used to find where overall motion of the subject is minimal. To accomplish this the minima of bulk acceleration and bulk rotational velocity of all sensors (defined as the sum of the magnitudes of each sensor) are found. The times when these minima are coincident are assumed to occur approximately during flatfoot. These flatfoot points will be used in conjunction with integrated rotational velocity to estimate sensor drift and produce an estimate of heel angle.
      - The user is asked for input to define the minima of a bulk rotational velocity plot. The user is prompted to click on a point below which they want the function to look for minima. The user is prompted to enter a minimum distance (in frames) between detected minima. The user will be prompted to continue or try again.
      - The user will go through the same procedure for a plot of bulk acceleration.
      - The user will be shown a plot of the times of the bulk rotational velocity and bulk acceleration minima and be prompted to enter a threshold (in frames) by which to treat these points as coincident. After entering this threshold, the plot will be updated to show these coincident points. The user should look for relatively equal spacing between points for each pass of level straight line walking. The user will be prompted to “try again” afterwards. Several attempts may be necessary to get the desired result.
   - Angle_Corrected: This function generates an estimate of the three components of heel angle using integrated rotational velocity and the flatfoot points defined in the previous function. This function then obtains input from the user which it uses to further refine this estimate. This function assumes that the angle is approximately zero for all components during flatfoot and that drift is linear. Using these assumptions, a linear drift correction can be applied between flatfoot points so that every subsequent flatfoot point is zero and every point in between is shifted proportionally. These flatfoot points are further refined by finding the points on the heel angle plot near the initial guesses where slope is minimal. The estimated angle is then recalculated, and the plot is updated. Note: This angle correction is only valid during steady state gait.
       - A plot of the three components of heel angle will be shown along with a legend labeling the components as one, two, and three. The user will be prompted to enter the number corresponding to the primary axis of rotation. The function will look at where the slope of this component is minimal near the initial flatfoot guesses.
    - DefiningSteadState: This function uses the heel angle plot generated by the ‘Angle_Corrected’ function to allow the user to define regions of steady state gait in terms of the flatfoot points.
       - A plot showing the corrected heel angle will be displayed along with the refined flatfoot points. These points will be labeled 1, 2, 3, 4, 5 et cetera from first to last. The user will be prompted to select how many steady state regions there are (for instance if two passes were made across the mat, there are two steady state regions).
       - The user will be prompted to enter the numbers of the first and last flatfoot points encompassing each steady state region. These will be entered in the form of a 1x2 vector (for instance if the steady state region starts on the flatfoot point labeled “2” and ends on the flatfoot point labeled “7” then the input will be “[2 7]”). It is generally good practice to omit the first and last steps of a pass in order to avoid confounding effects related to stopping, starting, or turning.

5.	Perform estimations of anatomical axes: Method 1, functional calibration: This section performs calibrations for all of the sensors using the functional calibration method. Coordinate systems are defined for each sensor using this method as a set of three orthogonal unit vectors  aligned with the superior-inferior, medial-lateral, and anterior-posterior anatomical directions. The superior-inferior unit vector is defined by the direction of gravitational acceleration during the still standing time span defined earlier. For non-torso sensors, the medial-lateral unit vector is defined as lying along the principal component found using principal component analysis (PCA) of the rotational velocity data during the steady state gait times defined previously. For torso sensors this vector is assumed to lye along the “[0 1 0]” axis of the sensor which is most closely aligned with medial-lateral. PCA analysis cannot be used to define the medial-lateral axis for torso sensors since they rotate around this axis very little. The anterior-posterior unit vector is defined as the normalized cross product of the medial-lateral and superior-inferior unit vectors. To ensure all vectors are orthogonal, the medial-lateral unit vector is re-defined as the normalized cross product between the superior-inferior and anterior-posterior unit vectors, and then the anterior-posterior unit vector is re-defined as the normalized cross product of the medial-lateral and superior-inferior unit vectors. The superior-inferior vector is not redefined since this is the most reliably estimated axis of the three. When this section is run the user will be asked whether they want to perform functional calibrations (1 for yes, enter for no). If they answer yes, the calibrations will be performed, then the user will be asked to save the functional calibration file using the ‘uisave’ function. 

6.	Perform estimations of anatomical axes: Method 2, static calibration: This section performs calibrations for all of the sensors using the static calibration method. Coordinate systems are defined for each sensor using this method as a set of three orthogonal unit vectors aligned with the superior-inferior, medial-lateral, and anterior-posterior anatomical directions. Like with the functional method, the superior-inferior unit vector is defined by the direction of gravitational acceleration during the still standing time span defined earlier. The medial-lateral unit vector is defined as the normalized cross product of the superior-inferior unit vector and a vector co-planer to the superior-inferior unit vector in the sagittal plane. This co-planer vector is defined when the subject is seated with their legs extended and torso leaned back and when all of their body segments are parallel to the sagittal plane. The anterior-posterior unit vector is defined as the normalized cross product of the medial-lateral and superior-inferior unit vectors. Further cross products are done to ensure the coordinate system is orthoganol like with the functional calibration method. When this section is run the user will be asked whether they want to perform static calibrations (1 for yes, enter for no). If they answer yes, the calibrations will be performed, then the user will be asked to save the static calibration file using the ‘uisave’ function. 

# Step 4: Generating Plots (Angle_Plot_Generator.m)
This script is used to generate Euler angle plots for different joints using different sensor combinations. In all cases the Euler angles are generated in a YXZ rotation order. To generate the three Euler angles about a joint two sensors, one above and one below the joint must be used. This function is useful because it allows for easy and direct comparisons between different sensor combinations on calculated joint angles. This function will guide the user through several steps to select the appropriate trial data, joints, and sensor combinations they wish to look at.
  1. The user will first be prompted to open the correct data file using the uigetfile function. This is the data imported beforehand in step 2 and should be in the ‘Imported Subject Data’ folder.
  2. The user will then be prompted to load the subject information file for the subject. This was created in step 1 and should be found as a .mat file in the ‘Subject Information’ folder.
  3. The user will be prompted to open a calibration file. These were created in step 3 and should be found in a subject folder (named P_xxx) in the ‘Calibrations’ folder. For convenience the subject’s task list is displayed in the Command Window so that it is easy to find which calibration came before which task. The calibrations have been named based on subject id, calibration number, and calibration type. The calibration type is either functional or static with functional calibration files ending with a ‘f’ and static calibration files ending with a ‘s.’ For example, P003_7f is a functional calibration based on the data gathered in the calibration 7 task for subject P003.
  4. The user is then presented with the task list in the Command Window and asked to select a task. The user needs to enter in the number corresponding to the task they wish to view in the Command Window and hit enter. 
  5. The user is then prompted to select the joint(s) they want to look at. To do this they must enter numbers into the command prompt corresponding to the joint of interest (ie 1=hip, 2=knee, 3=ankle). Multiple joints can be analyzed, but the entered number must be in the form of a vector closed by brackets. The user also has the option to skip this step and automatically generate plots for every joint using every sensor combination (option 4).
  6. The user is then asked to enter the sensors they want to examine for each relevant body segment (ie torso, thigh, shank, and foot). This process is very similar to the process used in the previous bullet point. The code will then generate all of the possible angles it can for the sensors selected and generate plots for each chosen joint.
 	
# Step 5: Comparing the IMU angles to the reference optical motion capture system (Comparisons_Tool.m)
The Comparisons_Tool.m script walks the user through selecting the correct data for both the IMU angles and the optical motion capture angles. This script then plots the IMU and optical angles on the same plots.
  1. The ‘Load Optical Motion Capture Data’ section prompts the user to load the optical data using the uigetfile function.  If the relevant data is already loaded the user is asked if they want to load new data.
  2. The user is then prompted to select the task they want to look at from the optical data.
  3. The user is then prompted to load the IMU angle data. This process is identical to the loading of the optical data.
  4. The user is prompted to enter the frame rates of each system as two inputs in the command prompt. The frame rates for each subject in the study are listed here for reference. 
     - P004: IMU: 60 FPS, Optical: 100FPS
     - P005: IMU: 60 FPS, Optical: 120FPS
     - P006: IMU: 60 FPS, Optical: 120FPS
     - P007: IMU: 60 FPS, Optical: 100FPS
     - P008: IMU: 60 FPS, Optical: 100FPS
     - P009: IMU: 60 FPS, Optical: 100FPS
     - P010: IMU: 60 FPS, Optical: 100FPS
   5. The user is then asked whether they want to offset the IMU data to match the optical data on frame 1. If the user opts to do this then the IMU angle plots will be shifted so that their angles at frame one are equal to the frame 1 angle of the reference system. 
   6. The plots for the hip, knee, and ankle joints are then generated for the three Euler angles.
