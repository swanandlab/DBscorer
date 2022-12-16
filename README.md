# DBscorer

Automatic Mobility Based Behavioral Quantification ( With Option for Manual Scoring )

Forced swim test and Tail suspension test automation

We have improved the performance and ease of use for DBscorer. Read the github [Wiki](https://github.com/swanandlab/DBscorer/wiki) for DBscorerV2 use. This version is more user friendly. Contact us if you face any problem in using it. 


![No of Visits](https://visitor-badge.laobi.icu/badge?page_id=swanandlab/DBscorer)


**Installation and Video Conversion**

https://user-images.githubusercontent.com/50400250/208101760-f8a40a08-d0d4-4bca-9ee2-a7c7877ef733.mp4

**DBscorer V2 use **

https://user-images.githubusercontent.com/50400250/208101966-779e9dae-dc6b-413d-85fa-4e3f4e038780.mp4


[TST Sample Video](https://github.com/swanandlab/DBscorer/blob/main/TST%20Sample%20Video.mp4)

[FST Sample Video](https://github.com/swanandlab/DBscorer/blob/main/FST%20SAMPLE%20VIDEO.mp4)


# Notes
1. Camera should be stationary. Use a tripod to mount the camera.
2. Background should be glare and shadow free. Use diffuse indirect light to avoid shadow and glares. Do not use reflective background.
3. Fill background carefully. You need to fill only the part which is from animal.
4. Crop a rectangular area such that all parts of animal will inside the the selected region while avoiding unnessesary surrounding. See the demo video.
5. DBscorer is limited by size of the video. Please convert or downsample the video in such cases. (Fixed in DBscorer V2) 
6. Video should be in constant frame rate. If not then convert using ffmpeg or any software that you like.

It is always good to improve video quality during recording to avoid problems in detection.

**Video Conversion and Downsampling**

1. Download from the [ffmpeg](http://ffmpeg.org/) website.
2. After installing check if below folder exists.
C:\ffmpeg\ffmpeg
3. Create the following folder.
C:\ffmpeg\Converted_Videos
4. Put the videos in a folder along with ffmpeg_convert.bat file.
5. Double click to start conversion.

# DBscorer Use
**DBscorer use**

https://user-images.githubusercontent.com/50400250/162684979-b73db491-5611-4084-90a7-02341f676408.mp4

**Instructions**

1. Download and install the Windows version 9.9 ([R2020b](https://ssd.mathworks.com/supportfiles/downloads/R2020b/Release/5/deployment_files/installer/complete/win64/MATLAB_Runtime_R2020b_Update_5_win64.zip)) of the MATLAB Runtime for R2020b  from the following link on the [MathWorks website](https://www.mathworks.com/products/compiler/mcr/index.html)
NOTE: You will need administrator rights to run the MATLAB Runtime installer. 

2. Run DBscorer.exe.

Please check the sample videos to test and get an idea of the recording condition.

# Published in [eNeuro](https://doi.org/10.1523/ENEURO.0305-21.2021)
Please cite the paper if you use the code for analysis.
Email us in case if you need any help.

Validation Results of DBscorer V2


![alt text](https://github.com/swanandlab/DBscorer/blob/main/FST%20Correlation%20Plot.jpg?raw=true)

![alt text](https://github.com/swanandlab/DBscorer/blob/main/FST%20BA%20Plot.jpg?raw=true)

![alt text](https://github.com/swanandlab/DBscorer/blob/main/TST%20Correlation%20Plot.jpg?raw=true)

![alt text](https://github.com/swanandlab/DBscorer/blob/main/TST%20BA%20Plot.jpg?raw=true)

It is also possible to detect activity of single housed rodent if you have recorded long video (Not shown with data but in principle its the same). 



