# [DBscorer](https://doi.org/10.1523/ENEURO.0305-21.2021)
Automatic Mobility Based Behavioral Quantification ( With Option for Manual Scoring )

Forces swim test and Tail suspension test automation

DBScorer Executable

Prerequisites for Deployment 

Verify that version 9.9 (R2020b) of the MATLAB Runtime is installed.   
If not, you can run the MATLAB Runtime installer.
To find its location, enter
	>>mcrinstaller
at the MATLAB prompt.
NOTE: You will need administrator rights to run the MATLAB Runtime installer. 

Alternatively, download and install the Windows version 9.9 ([R2020b](https://ssd.mathworks.com/supportfiles/downloads/R2020b/Release/5/deployment_files/installer/complete/win64/MATLAB_Runtime_R2020b_Update_5_win64.zip)) of the MATLAB Runtime for R2020b  from the following link on the [MathWorks website](https://www.mathworks.com/products/compiler/mcr/index.html)

Run DBscorer.exe.

For the video conversion you can use any converter which works for you. But if you want to use ffmpeg here is how we did it.
**For Using ffmpeg

Download from the [ffmpeg](http://ffmpeg.org/) website.

After installing check if below folder exists.
C:\ffmpeg\ffmpeg

Create the following folder.
C:\ffmpeg\Converted_Videos

Put the videos in a folder along with ffmpeg_convert.bat file.

Double click to start conversion.

Alternatively you can drag and drop files on the batch file to start conversion.

You can edit the .bat file in notepad.

You can also create the .bat file by pasting the below line in notepad and saving it as .bat file.


for %%a in ("*.*") do C:\ffmpeg\ffmpeg -i "%%a" -codec:v libx264 -crf 20 -vf scale=480:-1 -r 15 -an "C:\ffmpeg\Converted_Videos\%%~na.mp4
