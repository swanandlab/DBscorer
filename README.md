![Visitors](https://api.visitorbadge.io/api/visitors?path=https%3A%2F%2Fgithub.com%2Fswanandlab%2FDBscorer&label=No%20of%20times%20visited&countColor=%2337d67a&style=flat-square)


Automatic Mobility Based Behavioral Quantification ( With Option for Manual Scoring ).

We've enhanced DBscorer's functionality and usability. We advise using **DBscorerV2**.

DBscorerV3 will come soon with few changes in GUI and outputs files. Soon, we will be releasing a program to analyse mouse behaviour in commonly used behaviour tests such as for anxiety and spatial memory.


# Validation Results of DBscorer V2

![alt text](https://github.com/swanandlab/DBscorer/blob/main/FST%20Correlation%20Plot.jpg?raw=true)

![alt text](https://github.com/swanandlab/DBscorer/blob/main/TST%20Correlation%20Plot.jpg?raw=true)


Installation:

Windows (Tested):

1. Install the MATLAB runtime [9.9](https://ssd.mathworks.com/supportfiles/downloads/R2020b/Release/8/deployment_files/installer/complete/win64/MATLAB_Runtime_R2020b_Update_8_win64.zip) first.

2. Click the [DBscorerV2](https://github.com/swanandlab/DBscorer/blob/main/DBscorerV2.exe) app to launch the GUI.

Mac (Need MATLAB):

Use DBscorerV2 exported.m file. 

# Notes
1. Mount the camera using a tripod.
2. The background should be free of glare and shadows. To prevent shadows and glares, use diffuse indirect light. Use a non-shiny background.
4. Crop a rectangular area so that all animal parts are contained within it while avoiding the surrounding area. View the demo video.
5. The size of the video imposes restrictions on DBscorer. In such cases, downsample or convert the video. (Issue is fixed in DBscorer V2).
6. Video should have a constant frame rate. If not, then convert with ffmpeg or any other program you prefer.
7. Do not use a video with very low or very high immobility for threshold generation, it might fail to compute threshold in such cases. Immobility between 30-70% works best. Check your file name after you generate the manual analysis; it should be in pairs, FST.mat and FST manual.mat.
8. Your video name or entered info should not contain full stop (.).


To prevent issues with detection, it is always a good idea to enhance video quality while recording. To test and get a sense of the recording conditions, kindly view the sample videos.

**Sample Videos**

[TST Sample Video](https://github.com/swanandlab/DBscorer/blob/main/TST%20Sample%20Video.mp4)

[FST Sample Video](https://github.com/swanandlab/DBscorer/blob/main/FST%20SAMPLE%20VIDEO.mp4)

**Video Pre-Processing** 

This can be easily done using [ffmpeg](https://www.gyan.dev/ffmpeg/builds/) software.
 
1. Create a folder and name it "_Convert_".

2. Place the convert.bat file, ffmpeg.exe and all videos in the same folder.

3. Create a subfolder in "_Convert_" and name it "_Output_".

4. Double click the "_Convert.bat_" file to start conversion. 

# DBscorerV2 

Convert the videos to a constant frame rate video in a MATLAB-supported video format (mp4, avi, mov). Use ffmpeg as described. You may downsample the video if needed. You can select one video file at a time for processing.
Please follow the steps below. 

# Steps:
1. Load Video: Use this button to load the video to be analyzed. Pressing this button would open a window for file selection. Click on your video file that is to be analyzed and click open. This will open a “figure window” showing the first frame.

2. Figure Window: Use this button to reopen the figure window if you have closed it.

3. Start (s) and End (s): Use this to define the start and end (seconds) of the video analysis. Figure window will help you to choose the start and end points appropriately.

4. Time: This shows the total duration of video to be analyzed. This field is not editable.

5. Label: You can use this field to add labels. Do not use any special characters or file extensions here (alphanumeric characters only). 

6. Create Background: You can create a clean background (without a mouse) for a selected part of the video using this. In most cases you will get a clean background. In case you do not get a clean background image,  you can change start and end such that you get a clean background. After getting a clean background, you should change the start and end points back to their original values for analysis.

7. Fix Background: If the background is not clean even after step no 7 then click fix background button to select the area covering artifact pixels as shown in the demo video.

8. Mark ROI: For TST and FST, select the area where the animal remains for the analysis period. The animal should not go outside the selected area throughout the analysis period. 

9. Process Video: You can use this button to perform the immobility analysis. This will create a .mat file for each animal which will be used for subsequent analysis. You can repeat the steps to process all the animals. 

Jump to step no 16 for automated analysis using the recommended threshold.

10. Manual Scoring: Do manual scoring either to determine an optimal threshold or you want to do manual analysis in a more detailed fashion than using a stopwatch. To perform manual scoring for obtaining the optimal threshold, you will have to perform all the previous steps in that order. We do not recommend performing manual scoring for threshold determination steps by non-experts. Because this will lead to erroneous threshold. Instead you can use the recommended threshold. Recommended threshold for FST is 1.6 , and TST is 0.6. 
For threshold determination, we recommend manually analyzing 3-4 randomly chosen videos (first and last 2 minutes of each video will result in better threshold determination).

11. Play and State: These buttons are used for manual scoring. They will be activated only when the manual scoring option is selected. Video will be paused at frame 1 of analysis by default and pressing “play” will start playing the video. Use the state button to switch between mobile (Green) and immobile(Magenta). You will also see a colored strip on top of the video corresponding to the state you have selected to aid in manual scoring. The default state is mobile.

12. Clip: Clip value removes periods of state switching. A clip value of 1 (recommended) will clip data from pre and post-transition while determining the optimal threshold. Doing this accounts for the delay in changing the toggle button.


14. Get Threshold: Once you manually score 3-4 videos, you can select all the .mat files to get an optimum threshold. It will generate a csv file with optimum threshold value and AUC, precision and recall for the threshold ( Higher the better). You can then use the threshold for rest of videos in the batch.

15. Time threshold is the minimum time required to say an animal is immobile or not. Let's say you consider that  an animal is immobile when it remains immobile  for at least 2 seconds. Doing so will remove any immobility period that is less than 2 seconds and it will reduce the total immobility %. 

0 0 0 1 0 0 0 1 1 0 1 1 0 0 1 0 1 0 . Before (7 second immobile, latency 4, 5 bouts)

0 0 0 0 0 0 0 1 1 0 1 1 0 0 0 0 0 0 . After(4 second immobile, latency 8, 2 bouts)

15. Compile Manual: This step is required only if you wish to do complete manual analysis and not required for threshold determination. Once you finish scoring all the videos manually, you can select all the .mat files by clicking the “compile manual button”. It will generate an excel sheet containing all the data together. It compiles only the .mat files generated from manual scoring. It will also generate a raster plot in order that is there in the excel sheet.

16. Compile: This button works in a similar manner as earlier except for automated analysis. Here, once you process all the videos, you can select all the .mat files generated from the “process video”(step 9). It will generate an excel sheet containing all the data together. It will also generate a raster plot in order that is there in the excel sheet.



# Published in [eNeuro](https://doi.org/10.1523/ENEURO.0305-21.2021)
Please cite the paper if you use the code.


# Detecting Animal Activity in Long Video

If you have a long video recorded, it is also possible to detect animal activity (not shown with data, but the concept is the same).



