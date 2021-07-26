# DBscorer
Automatic Mobility Based Behavioral Quantification ( With Option for Manual Scoring )
DBScorer Executable

1. Prerequisites for Deployment 

Verify that version 9.9 (R2020b) of the MATLAB Runtime is installed.   
If not, you can run the MATLAB Runtime installer.
To find its location, enter
	>>mcrinstaller
at the MATLAB prompt.
NOTE: You will need administrator rights to run the MATLAB Runtime installer. 

2. Alternatively, download and install the Windows version 9.9 (R2020b) of the MATLAB Runtime for R2020b 
from the following link on the MathWorks website:
	https://www.mathworks.com/products/compiler/mcr/index.html

3. Run DBscorer.

For the video conversion you can use any converter which works for you. But if you want to use ffmpeg here is how we did it.
For Using ffmpeg

1. Download from the link.
	http://ffmpeg.org/

2. After installing check if below folder exists.
	C:\ffmpeg\ffmpeg

3. Create the following folder.
	C:\ffmpeg\Converted_Videos

4. Put the videos in a folder along with batch.bat file.

5. Double click to start conversion.

6.Alternatively you can drag and drop files on the batch file to start conversion.

7. You can edit the .bat file in notepad.

8. You can also create the .bat file by pasting the below line in notepad and saving it as .bat file.
	for %%a in ("*.*") do C:\ffmpeg\ffmpeg -i "%%a" -codec:v libx264 -crf 20 -vf scale=480:-1 -r 15 -an "C:\ffmpeg\Converted_Videos\%%~na.mp4
