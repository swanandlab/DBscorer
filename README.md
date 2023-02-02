# DBscorer

![No of Visits](https://visitor-badge.laobi.icu/badge?page_id=swanandlab/DBscorer)

![alt text](https://github.com/swanandlab/DBscorer/blob/main/DBscorerV2UI.png?raw=true)

Automatic Mobility Based Behavioral Quantification ( With Option for Manual Scoring ). Forced swim test and Tail suspension test automation. 

We have improved the performance and ease of use for DBscorer. DBscorerV2 is more user friendly. We recommend the use of **DBscorerV2**.  Contact us if you face any problem in using it. 


# Validation Results of DBscorer V2

![alt text](https://github.com/swanandlab/DBscorer/blob/main/FST%20Correlation%20Plot.jpg?raw=true)

![alt text](https://github.com/swanandlab/DBscorer/blob/main/FST%20BA%20Plot.jpg?raw=true)

![alt text](https://github.com/swanandlab/DBscorer/blob/main/TST%20Correlation%20Plot.jpg?raw=true)

![alt text](https://github.com/swanandlab/DBscorer/blob/main/TST%20BA%20Plot.jpg?raw=true)

Installation:

Windows (Tested):

1. Install the MATLAB runtime [9.10](https://ssd.mathworks.com/supportfiles/downloads/R2021a/Release/7/deployment_files/installer/complete/win64/MATLAB_Runtime_R2021a_Update_7_win64.zip) first.

2. Click the [DBscorerV2](https://github.com/swanandlab/DBscorer/blob/main/DBscorerV2.exe) app to launch the GUI.

Mac (Not tested):

Use DBscorerV2 exported. You will probably need MATLAB2020b.


**DBscorer V2: Installation and Video Conversion**

https://user-images.githubusercontent.com/50400250/208101760-f8a40a08-d0d4-4bca-9ee2-a7c7877ef733.mp4

**DBscorer V2:  Use**

https://user-images.githubusercontent.com/50400250/208101966-779e9dae-dc6b-413d-85fa-4e3f4e038780.mp4


# Notes
1. Camera should be stationary. Use a tripod to mount the camera.
2. Background should be glare and shadow free. Use diffuse indirect light to avoid shadow and glares. Do not use reflective background.
3. Fill background carefully. You need to fill only the part which is from animal.
4. Crop a rectangular area such that all parts of animal will inside the the selected region while avoiding unnessesary surrounding. See the demo video.
5. DBscorer is limited by size of the video. Please convert or downsample the video in such cases. (Fixed in DBscorer V2) 
6. Video should be in constant frame rate. If not then convert using ffmpeg or any software that you like.

It is always good to improve video quality during recording to avoid problems in detection. Please check the sample videos to test and get an idea of the recording condition.

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

Load Video: Convert the videos to a constant frame rate video in a MATLAB-supported video format. Use ffmpeg as described. You may downsample the video if needed. You can select one video file at a time for processing.

Create Background: You can create a background for the video using this. In most cases, the background will include pixels from animals.

Fix Background: To fix the background, select the area generated from animal pixels, as shown in the demo video.

Figure Window: This button creates a window showing an image of a video frame. If you accidentally close the figure window, changing the start(s) won't show any video frame. In this case, use the figure window to create the window where the video frame will be shown and then change the start(s).

Start (s) and End (s): Use this to define the start and End of the video analysis and show the frame.

Info: Before marking your ROI, you can enter the information here about the animal.

Mark ROI: For TST and FST, select the area where the animal remains for the analysis period. The animal should not get outside. After selection, you will get suggestions for a binary threshold value.

Process Video: Process video using this. You can repeat the steps to process all the videos. Then compile data later by selecting all the files together. You can use the cancel button to stop processing it.

Manual Scoring: Do manual scoring either to determine an optimal threshold or you want to do manual analysis in a more detailed fashion than using a stopwatch. Do the manual scoring as shown for 3-4 min video for 3-4 min to get an optimum threshold value for the whole batch of similarly recorded videos. The setup remains the same for all the recordings (light, background, etc.)

Clip: Clip value removes periods of state switching. A clip value of 1  will clip data from pre and post-transition while determining the optimal threshold. Doing this accounts for the delay in changing the toggle button.

Get Threshold: Once you manually score 3-4 videos, you can select all the .mat files to get an optimum threshold. It will generate a data file with optimum threshold value and accuracy for the data.

Compile: Once you process all the videos, you can select all the .mat files generated from the process video. It will generate an excel sheet containing all the data together. It ignores the mat file from the manual analysis and compiles only the .mat files generated from the process video.

Compile Manual: Once you finish scoring all the videos manually, you can select all the .mat files ending with the manual. It will generate an excel sheet containing all the data together. It compiles only the .mat files generated from manual scoring.






# Published in [eNeuro](https://doi.org/10.1523/ENEURO.0305-21.2021)
Please cite the paper if you use the code for analysis.
Email us in case if you need any help.



# Old DBscorer Use
**Old DBscorer use**

https://user-images.githubusercontent.com/50400250/162684979-b73db491-5611-4084-90a7-02341f676408.mp4

**Instructions**

**Video Conversion and Downsampling**

1. Download from the [ffmpeg](http://ffmpeg.org/) website.
2. After installing check if below folder exists.
C:\ffmpeg\ffmpeg
3. Create the following folder.
C:\ffmpeg\Converted_Videos
4. Put the videos in a folder along with ffmpeg_convert.bat file.
5. Double click to start conversion.

1. Download and install the Windows version 9.9 ([R2020b](https://ssd.mathworks.com/supportfiles/downloads/R2020b/Release/5/deployment_files/installer/complete/win64/MATLAB_Runtime_R2020b_Update_5_win64.zip)) of the MATLAB Runtime for R2020b  from the following link on the [MathWorks website](https://www.mathworks.com/products/compiler/mcr/index.html)
NOTE: You will need administrator rights to run the MATLAB Runtime installer. 

2. Run DBscorer.exe.




It is also possible to detect activity of single housed rodent if you have recorded long video (Not shown with data but in principle its the same). 



