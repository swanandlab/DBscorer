# DBscorer
Automatic Mobility Based Behavioral Quantification ( With Option for Manual Scoring )

Forces swim test and Tail suspension test automation

![No of Visits](https://visitor-badge.laobi.icu/badge?page_id=swanandlab/DBscorer)

**Demo**

https://user-images.githubusercontent.com/50400250/162684979-b73db491-5611-4084-90a7-02341f676408.mp4

**Instructions**

1. Download and install the Windows version 9.9 ([R2020b](https://ssd.mathworks.com/supportfiles/downloads/R2020b/Release/5/deployment_files/installer/complete/win64/MATLAB_Runtime_R2020b_Update_5_win64.zip)) of the MATLAB Runtime for R2020b  from the following link on the [MathWorks website](https://www.mathworks.com/products/compiler/mcr/index.html)
NOTE: You will need administrator rights to run the MATLAB Runtime installer. 

2. Run DBscorer.exe.

Please check the sample videos to test and get an idea of the recording condition.

[TST Sample Video](https://github.com/swanandlab/DBscorer/blob/main/TST%20Sample%20Video.mp4)

[FST Sample Video](https://github.com/swanandlab/DBscorer/blob/main/FST%20SAMPLE%20VIDEO.mp4)


# Notes
1. Camera should be stationary. Use a tripod to mount the camera.
2. Background should be glare and shadow free. Use diffuse indirect light to avoid shadow and glares. Do not use reflective background.
3. Fill background carefully. You need to fill only the part which is from animal.
4. Mark the area such that all parts of animal will inside the the selected region while avoiding unnessesary surrounding.
5. Video should be in constant frame rate. If not then convert using ffmpeg or any software that you like.

**Video Conversion**

1. Download from the [ffmpeg](http://ffmpeg.org/) website.
2. After installing check if below folder exists.
C:\ffmpeg\ffmpeg
3. Create the following folder.
C:\ffmpeg\Converted_Videos
4. Put the videos in a folder along with ffmpeg_convert.bat file.
5. Double click to start conversion.

Alternatively you can drag and drop files on the batch file to start conversion.
You can edit the .bat file in notepad.
You can also create the .bat file by pasting the below line in notepad and saving it as .bat file.

for %%a in ("*.*") do C:\ffmpeg\ffmpeg -i "%%a" -codec:v libx264 -crf 20 -vf scale=480:-1 -r 15 -an "C:\ffmpeg\Converted_Videos\%%~na.mp4



# Published in [eNeuro](https://doi.org/10.1523/ENEURO.0305-21.2021)
Please cite the paper if you use the code for analysis.
Raise a issue or email in case if you need any help.

Version 2 will be released soon!



