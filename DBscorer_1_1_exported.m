classdef DBscorer_1_1_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Tool                         matlab.ui.Figure
        LoadVideoButton              matlab.ui.control.Button
        MarkAreaButton               matlab.ui.control.Button
        StartsLabel                  matlab.ui.control.Label
        StartSpinner                 matlab.ui.control.Spinner
        EndsSpinnerLabel             matlab.ui.control.Label
        EndsSpinner                  matlab.ui.control.Spinner
        StateButton                  matlab.ui.control.StateButton
        TotalTimesEditFieldLabel     matlab.ui.control.Label
        TotalTimesEditField          matlab.ui.control.NumericEditField
        StatusEditField              matlab.ui.control.NumericEditField
        EnterInfoEditField           matlab.ui.control.EditField
        AutomaticScore               matlab.ui.control.Label
        GreenMobilityEditFieldLabel  matlab.ui.control.Label
        GreenMobilityEditField       matlab.ui.control.NumericEditField
        CalibratedThresholdLabel     matlab.ui.control.Label
        CalibratedThreshold          matlab.ui.control.NumericEditField
        AreaThresholdLabel           matlab.ui.control.Label
        EnterThreshold               matlab.ui.control.NumericEditField
        Analyse                      matlab.ui.control.Button
        Manual                       matlab.ui.control.Button
        Play                         matlab.ui.control.StateButton
        LatencyMagentaLabel          matlab.ui.control.Label
        Latency                      matlab.ui.control.NumericEditField
        LongestBoutMagentaLabel      matlab.ui.control.Label
        Largest_Bout                 matlab.ui.control.NumericEditField
        TimeThresholdsLabel          matlab.ui.control.Label
        MinIB                        matlab.ui.control.NumericEditField
        BinaryThresholdLabel         matlab.ui.control.Label
        BT                           matlab.ui.control.Spinner
        TimeBinsSpinnerLabel         matlab.ui.control.Label
        TimeBinsSpinner              matlab.ui.control.Spinner
        ResetButton                  matlab.ui.control.StateButton
        BackgroundFillButton         matlab.ui.control.Button
        BlurImageLabel               matlab.ui.control.Label
        Blur                         matlab.ui.control.Spinner
        UIAxes                       matlab.ui.control.UIAxes
    end

    
    properties (Access = public)
        v % Video
        changingValue1 % Video analysis start time
        changingValue2 % Video analysis end time
        show1 % Video analysis first frame
        show2 % Video analysis end frame
        meanbinpercentage_ar % Area Change Per Second wise
        leftColumn % For Cropping
        topLine % For Cropping
        width % For Cropping
        height % For Cropping
        ar % Raw area
        cr % Struc for image data frames
        T  % Binary threshold
        autoY %
        path3 % Video Path
        filename
        filename_3
        fbf % not paper
        fbfd % not paper
        J % Estimated and Refined Background
        Bkg % Median background
        G % Gaussian Blur value
        selectioncord
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadVideoButton
        function LoadVideoButtonPushed(app, event)
            
            % Changes Button Color and Values to initial state
            app.LoadVideoButton.Text='Load Video';
            app.MarkAreaButton.Text='Mark Area';
            app.MarkAreaButton.BackgroundColor='White';
            app.Analyse.Text='Automatic Analysis';
            app.Analyse.BackgroundColor='White';
            app.Play.Text='Play';
            app.Play.BackgroundColor='White';
            app.StateButton.BackgroundColor='White';
            app.Manual.Text='Manual Analysis';
            app.Manual.BackgroundColor='White';
            app.StatusEditField.Value = 0;
            app.TotalTimesEditField.Value =0;
            app.GreenMobilityEditField.Value =0;
            app.CalibratedThreshold.Value = 0;
            app.Play.Value=1;
            app.StateButton.Value=0;
            app.Largest_Bout.Value=0;
            app.Latency.Value = 0;
            %app.ResetButton.Value=0;
            %app.Blur.Value=.1;
            % Close all the figures first
            figure
            close all
            % Imports selected video
            [filename_2, pathname_2] = uigetfile('*.mov;*.wmv;*.mp4;*.avi','Open Video File');
            if filename_2 == 0
                % If user clicked the Cancel button.
                return;
            end
            app.LoadVideoButton.BackgroundColor='y';
            app.filename_3 = cellstr(filename_2);
            pathname_3 = cellstr(pathname_2);
            video = fullfile(pathname_3{1},app.filename_3{1});
            % Get the name video and create folder with video name
            [folder, baseFileNameNoExt, ~] = fileparts(video);
            fileName = fullfile(pathname_3{1});
            dotLocations = find(fileName == '.');
            if isempty(dotLocations)
                nameBeforeFirstDot = fileName;
            else
                nameBeforeFirstDot = fileName(1:dotLocations(1)-1);
            end
            cd(folder)
            if ~exist([folder,'\',baseFileNameNoExt],'dir')
                mkdir (baseFileNameNoExt)
            end
            cd(baseFileNameNoExt)
            app.path3=nameBeforeFirstDot;
            app.filename=baseFileNameNoExt;
            % creates video reader and shows firstframe from the video
            app.v = VideoReader(video);
            show = readFrame(app.v);
            imshow(show, 'Parent', app.UIAxes);
            app.StartSpinner.Value=1;
            app.EndsSpinner.Value=round(app.v.Duration)-1;
            app.LoadVideoButton.BackgroundColor='cyan';
        end

        % Button pushed function: MarkAreaButton
        function MarkAreaButtonPushed(app, event)
            % Clear old data that may interfere with new data
            clear app.cr
            figure
            close all
            textFontSize=10;
            % Changes Button Color and Values to initial state
            app.Analyse.Text='Automatic Analysis';
            app.Analyse.BackgroundColor='White';
            app.Play.Text='Play';
            app.Play.BackgroundColor='White';
            app.StateButton.BackgroundColor='White';
            app.Manual.Text='Manual Analysis';
            app.Manual.BackgroundColor='White';
            app.StatusEditField.Value = 0;
            app.TotalTimesEditField.Value =0;
            app.GreenMobilityEditField.Value =0;
            app.CalibratedThreshold.Value = 0;
            %app.Blur.Value=.1;
            % Show first frame within specified time period and
            % allows selection of region of interest using polygon tool
            if app.changingValue1 >0
                app.v.CurrentTime = app.changingValue1;
                app.show1 = readFrame(app.v);
            else
                app.v.CurrentTime = 1;
                app.show1 = readFrame(app.v);
            end
            imshow(app.show1);
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
            hFH = impoly();
            % Create a binary image ("mask") from the ROI object.
            binaryImage = hFH.createMask();
            xy = hFH.getPosition;
            app.selectioncord=xy;
            % Get coordinates of the boundary of the drawn region.
            structBoundaries = bwboundaries(binaryImage);
            xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
            x = xy(:, 2); % Columns.
            y = xy(:, 1); % Rows.
            app.MarkAreaButton.Text='Cropping...';
            app.MarkAreaButton.BackgroundColor='y';
            hold on;
            plot(x, y,'b', 'LineWidth', 2);
            drawnow;
            legend(['Start-',num2str(app.changingValue1),', End-',num2str(app.changingValue2),', ',[app.filename],',',[app.EnterInfoEditField.Value]])
            text(median(x), median(y), [app.EnterInfoEditField.Value], 'FontSize', textFontSize, 'FontWeight', 'Bold','Color', 'y');
            hold off
            figure
            imshow(app.show1);
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
            hold on;
            plot(x, y,'b', 'LineWidth', 2);
            drawnow;
            legend(['Start-',num2str(app.changingValue1),', End-',num2str(app.changingValue2),', ',[app.filename],',',[app.EnterInfoEditField.Value]])
            text(median(x), median(y), [app.EnterInfoEditField.Value], 'FontSize', textFontSize, 'FontWeight', 'Bold','Color', 'b');
            format shortg
            s = num2str(fix(clock));
            saveas(gcf,['Tag ',[app.EnterInfoEditField.Value],' ',s,'.png'])
            close all
            app.MarkAreaButton.Text='Cropping ...';
            % Now crop the image.
            app.leftColumn = min(x);
            rightColumn = max(x);
            app.topLine = min(y);
            bottomLine = max(y);
            app.width = rightColumn - app.leftColumn + 1;
            app.height = bottomLine - app.topLine + 1;
            I1 = imcrop(app.show1, [app.leftColumn, app.topLine, app.width, app.height]);
            % Create struct to store image data
            % Use 1 for single channel 3 for 3 channel
            % Read all the frames in the video from user defined start time
            A=size(I1);
            app.cr = struct('cdata',zeros(A(1),A(2),1,'uint8'),...
                'colormap',[]);
            app.v.CurrentTime = app.changingValue1;
            maxf=(app.changingValue2-app.changingValue1)*app.v.FrameRate;
            k = 1;
            scale=round(256/max(A),1); % Scaled for fast visualization
            while hasFrame(app.v)
                rgb = readFrame(app.v);
                gray1=rgb2gray(rgb);
                I = imcrop(gray1, [app.leftColumn, app.topLine, app.width, app.height]);
                %app.cr(k).cdata = I;
                rI = imresize(I, scale, 'nearest');
                app.cr(k).cdata = rI;
                k = k+1;
                if k>maxf+1
                    break
                end
            end
            % Automatic background estimation 
            K=app.cr(1).cdata;
            [m,n]=size(K);
            % 10 percent (.1) randomly choosen frame used to sample frames
            % for background estimation
            no_of_frames_to_sample=round(.1*(k-1));
            x = randsample(length(app.cr),no_of_frames_to_sample);
            indices = sort(x);
            A = zeros(m,n,1,'uint8');
            for i=1:length(indices)
                A(:,:,i) = uint8(app.cr(indices(i)).cdata);
            end
            % Median method for background estimation
            app.Bkg = uint8(median(double(A),3));
            app.J = app.Bkg;
            level = graythresh(gray1);
            app.BT.Value=level*100;
            app.T=level*100;
            K=app.cr(round(median(indices))).cdata;
            bkgsubi=imgaussfilt(imabsdiff(app.J,K),.1);
            blwh=imbinarize(bkgsubi);
            B = imoverlay(K,blwh,'m');
            imshowpair(B,K,'montage','Parent', app.UIAxes)
            %app.G=.1;
            app.MarkAreaButton.Text='Mark Area';
            app.MarkAreaButton.BackgroundColor='cyan';
            app.ResetButton.Value=1;
            app.ResetButton.BackgroundColor='m';
            app.ResetButton.Text='Auto';
            cd([app.path3,'\',app.filename])
        end

        % Value changing function: StartSpinner
        function StartSpinnerValueChanging(app, event)
            app.changingValue1 = event.Value;
            if  app.changingValue1<app.v.Duration
                app.v.CurrentTime = app.changingValue1;
                app.show1 = readFrame(app.v);
                imshow(app.show1, 'Parent', app.UIAxes);
            else
                app.v.CurrentTime = 0;
            end
            % Changes Button Color and Values
            app.MarkAreaButton.Text='Mark Area';
            app.MarkAreaButton.BackgroundColor='White';
            app.Analyse.Text='Automatic Analysis';
            app.Analyse.BackgroundColor='White';
            app.Play.Text='Play';
            app.Play.BackgroundColor='White';
            app.StateButton.BackgroundColor='White';
            app.Manual.Text='Manual Analysis';
            app.Manual.BackgroundColor='White';
            app.StatusEditField.Value = 0;
            app.TotalTimesEditField.Value =0;
            app.GreenMobilityEditField.Value =0;
            
        end

        % Value changing function: EndsSpinner
        function EndsSpinnerValueChanging(app, event)
            app.changingValue2 = event.Value;
            if  app.changingValue2<app.v.Duration
                app.v.CurrentTime = app.changingValue2;
                app.show2 = readFrame(app.v);
                imshow(app.show2, 'Parent', app.UIAxes);
            else
                app.v.CurrentTime = 0;
            end
            app.TotalTimesEditField.Value =app.changingValue2-app.changingValue1;
            % Changes Button Color and Values
            app.MarkAreaButton.Text='Mark Area';
            app.MarkAreaButton.BackgroundColor='White';
            app.Analyse.Text='Automatic Analysis';
            app.Analyse.BackgroundColor='White';
            app.Play.Text='Play';
            app.Play.BackgroundColor='White';
            app.StateButton.BackgroundColor='White';
            app.Manual.Text='Manual Analysis';
            app.Manual.BackgroundColor='White';
            app.StatusEditField.Value = 0;
            app.GreenMobilityEditField.Value =0;
        end

        % Button pushed function: Analyse
        function AnalyseButtonPushed(app, event)
            % Changes Button Color and Values
            app.Analyse.Text='Analysing';
            app.Play.Text='Play';
            app.Play.BackgroundColor='White';
            app.StateButton.BackgroundColor='White';
            app.Manual.Text='Manual Analysis';
            app.Manual.BackgroundColor='White';
            %% For storing data
            app.ar=[];
            %             app.fbf=[]; not paper
            %             app.fbfd=[0]; not paper
            numframes=length(app.cr);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for i=1:numframes
                K=app.cr(i).cdata;
                bkgsubi=imgaussfilt(imabsdiff(app.J,K),app.G);
                BW=imbinarize(bkgsubi,app.T/100);%
                All=sum(BW,'all');%
                app.ar=[app.ar,All];%
                %                 if i<numframes-1 % not paper
                %                     app.fbf=[app.fbf,sum(BW,'all')]; % not paper
                %                     K2=(app.cr(i+1).cdata); % not paper
                %                     bkgsubi2=imgaussfilt(imabsdiff(app.J,K2),app.G); % not paper
                %                     BW3=imbinarize(bkgsubi2,app.T/100); % not paper
                %                     app.fbfd=[app.fbfd,sum(abs(BW3-BW),'all')]; % not paper
                %                 end
            end
            %% Calculation for determining immobility
            ar_score=app.ar; % Raw Area data
            ar_abs=abs(diff(ar_score));
            b_ar=ar_score(1:length(ar_abs));
            percentage_ar=(bsxfun(@rdivide,ar_abs,b_ar))*100;
            r_ar =length(percentage_ar)- rem(length(percentage_ar),app.v.FrameRate);
            R_ar=percentage_ar(1:r_ar);
            bin_ar = reshape(R_ar,app.v.FrameRate,[]);
            Area_Change=mean(bin_ar,1);
            app.meanbinpercentage_ar = Area_Change;
            im=app.meanbinpercentage_ar<app.EnterThreshold.Value;
            framerate=app.v.FrameRate;
            %%same for manual from here
            A=im;
            minimumchange=app.MinIB.Value-1;
            Till=length(A);
            transitions = diff([0,A,0]); % find where the array goes from non-zero to zero and vice versa
            runstarts = find(transitions == 1);
            runends = (find(transitions == -1)-1); %one past the end
            runlengths = abs(runends - runstarts);
            runstarts(runlengths<= minimumchange) = [];
            runends(runlengths<= minimumchange) = [];
            Y=zeros(length(A),1);
            for i=1:length(runstarts)
                Y(runstarts(i):runends(i))=1;
            end
            % new raster code start
            bar(Y*app.EnterThreshold.Value,1,'M','EdgeColor','none')
            alpha(.4) % sets transparency
            hold on
            bar(double(Y==0)*app.EnterThreshold.Value,1,'G','EdgeColor','none')
            alpha(.4)
            yticks([])
            xticks(0:app.TimeBinsSpinner.Value:Till)
            pbaspect([Till Till/10 1])
            xlim([0 Till])
            %axis off
            %ylim([0 areathres])
            ax = gca;
            ax.Color ='none';
            ax.FontWeight='bold';
            ax.FontSize = 12;
            %ax.YTick = 1:1:100;
            ax.TickLength = [.005 0.035];
            ax.LineWidth=2;
            hold on
            %new raster code end
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            xlabel('Time (second)')
            ylabel([app.EnterInfoEditField.Value])
            format shortg
            s = num2str(fix(clock));
            box on
            saveas(gcf,['Raster ',[app.EnterInfoEditField.Value],' ',s,'.png'])
            app.meanbinpercentage_ar(app.meanbinpercentage_ar>10)=10; % cap max value to 20
            p=plot(app.meanbinpercentage_ar,'-k','LineWidth',2);
            hold on
            xlabel('Time (Second)')
            ylabel(['Percent Area Change of ',[app.EnterInfoEditField.Value]])
            pbaspect([Till Till/10 1])
            ax.YTick = 0:5:100;
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            box off
            ylim([0 max(app.meanbinpercentage_ar)])
            saveas(gcf,['Percent Area Change of ',[app.EnterInfoEditField.Value],' ',s,'.png'])
            app.CalibratedThreshold.Value = 0;
            app.autoY=Y;
            Immobility=(sum(Y(1:Till))/Till)*100;
            Number_of_bouts=length(runends);
            if sum(runlengths,'all')==0
                Longest_bout=0;
            else
                Longest_bout=max(runlengths)+1;
            end
            if sum(runstarts,'all')==0
                Immobility_latency=Till;
            else
                Immobility_latency=runstarts(1)-1;
            end
            app.Largest_Bout.Value=Longest_bout;
            app.Latency.Value = Immobility_latency;
            app.StatusEditField.Value = Immobility;
            app.TotalTimesEditField.Value = length(Y);
            app.GreenMobilityEditField.Value =length(Y)-sum(Y);
            AnalysisStart=app.changingValue1;
            AnalysisEnd=app.changingValue2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% binned interval
            binsize=app.TimeBinsSpinner.Value;
            if binsize<length(Y)
                bin =length(Y)- rem(length(Y),binsize);
                Rim=Y(1:bin);
                if length(Y)>bin
                    Rim2=Y(bin+1:end);
                    Rimbin = reshape(Rim,binsize,[]);
                    binnedim = [sum(Rimbin,1)/binsize,sum(Rim2)/length(Rim2)]*100;
                else
                    Rimbin = reshape(Rim,binsize,[]);
                    binnedim = (sum(Rimbin,1)/binsize)*100;
                end
            else
                binnedim=sum(Y)/length(Y)*100;
            end
            % Binned Immobility heatmap
            figure
            image(abs(100-binnedim))
            colormap(gray(100))
            colorbar
            yticks([])
            ylabel([app.EnterInfoEditField.Value])
            xlabel('Binned Immobility (Darker)')
            pbaspect([length(binnedim) length(binnedim)/10 1])
            ax = gca;
            ax.Color = 'none';
            ax.FontWeight='bold';
            ax.FontSize = 12;
            ax.TickLength = [.005 0.035];
            ax.LineWidth=2;
            ax.XTick = 1:1:length(Y);
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            saveas(gcf,['Binned ',[app.EnterInfoEditField.Value],' ',s,'.png'])
            AutoAnalysis = ['Auto ',[app.filename],' ',[app.EnterInfoEditField.Value],' ',s];
            Binary_Threshold=app.T;
            Blur_Value=app.G;
            Area_Threshold=app.EnterThreshold.Value;
            Time_Threshold=minimumchange+1;
            Bin_Size=binsize;
            app.Analyse.BackgroundColor='cyan';            
            app.Analyse.Text='Saving';
            close all
            save(AutoAnalysis)%remove this for paper??
            %% writes excel file start
            filenamexlsx = ['Auto ',[app.filename],' ',[app.EnterInfoEditField.Value],' ',s,'.xlsx'];
            A = {'Area'};
            B=[ar_score'];
            sheet = 1;
            xlsrange = 'A1';
            xlswrite(filenamexlsx,A,sheet,xlsrange)
            xlsrange = 'A2';
            xlswrite(filenamexlsx,B,sheet,xlsrange)
            C={'AreaChange/S'};
            D=[Area_Change'];
            sheet = 1;
            xlsrange = 'C1';
            xlswrite(filenamexlsx,C,sheet,xlsrange)
            xlsrange = 'C2';
            xlswrite(filenamexlsx,D,sheet,xlsrange)
            E={'Immobility','Latency','Longest Bout','Number of Bouts','FrameRate','Start', 'End',' Binary Threshold','Blur Value','Area Threshold','Time Threshold','Bin Size','Bins'};
            xlsrange = 'E1';
            xlswrite(filenamexlsx,E,sheet,xlsrange)
            F=[Immobility,Immobility_latency,Longest_bout,Number_of_bouts,framerate,AnalysisStart, AnalysisEnd, app.T,app.G,app.EnterThreshold.Value, minimumchange+1,binsize,binnedim];
            xlsrange = 'E2';
            xlswrite(filenamexlsx,F,sheet,xlsrange)
            %% writes excel file end
            app.Analyse.Text='Automatic Analysis';
            app.Analyse.BackgroundColor='cyan';
            close all
        end

        % Button pushed function: Manual
        function ManualButtonPushed(app, event)
            figure
            close all
            clear app.cr
            app.Play.Text='Play';
            app.Play.BackgroundColor='y';
            app.StatusEditField.Value = 0;
            app.TotalTimesEditField.Value =0;
            app.GreenMobilityEditField.Value =0;
            app.Largest_Bout.Value=0;
            app.Latency.Value = 0;
            app.Play.Value=1;
            is=0;
            t=0;
            frame_by_frame_time_original = 1/app.v.FrameRate;
            im2 = [];
            %imshow(app.cr(1).cdata,'Parent',app.UIAxes)
            imshow(app.cr(1).cdata)
            set(gca,'Units','pixels')
            posf = get(gca,'Position');
            widthf = posf(3);
            heightf = posf(4);
            drawnow
            %hold on
            %yl = yline(1,'LineWidth',3);
            %yl.Color = 'g';
            app.StateButton.Value=0;
            app.StateButton.Text='Mobility';
            xy=app.selectioncord
            % Get coordinates of the boundary of the drawn region.
            structBoundaries = bwboundaries(imbinarize(app.cr(1).cdata));
            xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
            x = xy(:, 2); % Columns.
            y = xy(:, 1); % Rows.
            tic
            for frame2=1:length(app.cr)
                while app.Play.Value==1
                    app.Play.Text='Play';
                    app.Play.BackgroundColor='y';
                    app.StateButton.BackgroundColor='y';
                    pause(.01)
                end
                app.Play.Text='Pause';
                app.Play.BackgroundColor='cyan';
               
                if app.StateButton.Value==1
                    app.StateButton.BackgroundColor='m';
                    app.StateButton.Text='Immobility';
                    is=is+1;
                    im2=[im2,1];
                    %yl.Color = 'm';
                    
                else
                    app.StateButton.BackgroundColor='green';
                    app.StateButton.Text='Mobility';
                    is=is+0;
                    im2=[im2,0];
                    %yl.Color = 'g';
                end
                app.TotalTimesEditField.Value =t/app.v.FrameRate;
                t=t+1;
                app.GreenMobilityEditField.Value =(t-is)/app.v.FrameRate;
                app.StatusEditField.Value = 100*(is/t);
                imshow(app.cr(frame2).cdata)
                %imshow(app.cr(frame2).cdata,'Parent',app.UIAxes)
                set(gca,'Units','pixels')
                posf = get(gca,'Position');
                widthf = posf(3);
                heightf = posf(4);
                drawnow
                frame_normalization = toc;
                if frame_normalization < frame_by_frame_time_original
                    pause(frame_by_frame_time_original - frame_normalization);
                end
                tic
            end
            hold off
            app.Play.Value=1;
            
            rc =length(im2)- rem(length(im2),app.v.FrameRate);
            Rc=im2(1:rc);
            binc = reshape(Rc,app.v.FrameRate,[]);
            meanbinpercentage1c = mean(binc,1);
            meanbinpercentage2c=meanbinpercentage1c>0.5; %manual
            %%same for manual from here
            Ac=meanbinpercentage2c;
            minimumchangec=app.MinIB.Value-1;
            Tillc=length(Ac);
            transitionsc = diff([0,Ac,0]); % find where the array goes from non-zero to zero and vice versa
            runstartsc = find(transitionsc == 1);
            runendsc = (find(transitionsc == -1)-1); %one past the end
            runlengthsc = abs(runendsc - runstartsc);
            runstartsc(runlengthsc<= minimumchangec) = [];
            runendsc(runlengthsc<= minimumchangec) = [];
            Yc=zeros(length(Ac),1);
            for i=1:length(runstartsc)
                Yc(runstartsc(i):runendsc(i))=1;
            end
            rasterc=sort([0,runstartsc,runendsc,Tillc]);
            figure
            % new raster code start
            bar(Yc*app.EnterThreshold.Value,1,'m','EdgeColor','none')
            alpha(.4) % sets transparency
            hold on
            bar(double(Yc==0)*app.EnterThreshold.Value,1,'g','EdgeColor','none')
            alpha(.4)
            yticks([])
            xticks(0:app.TimeBinsSpinner.Value:Tillc)
            pbaspect([Tillc Tillc/10 1])
            xlim([0 Tillc])
            %ylim([0 1])
            ax = gca;
            ax.Color ='none';
            ax.FontWeight='bold';
            ax.FontSize = 12;
            %ax.YTick = 1:1:100;
            ax.TickLength = [.005 0.035];
            ax.LineWidth=2;
            hold on
            %new raster code end
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            xlabel('Time (second)')
            ylabel([app.EnterInfoEditField.Value])
            format shortg
            s = num2str(fix(clock));
            box on
            saveas(gcf,['Manual Raster ',[app.EnterInfoEditField.Value],' ',s,'.png'])
            box off
            pc=plot(app.meanbinpercentage_ar,'-k','LineWidth',2);
            xlabel('Time (Second)')
            ylabel(['Manual Percent Change of ',[app.EnterInfoEditField.Value]])
            pbaspect([Tillc Tillc/10 1])
            ax.YTick = 0:5:100;
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            ylim([0 max(app.meanbinpercentage_ar)])
            saveas(gcf,['Manual Percent Change of ',[app.EnterInfoEditField.Value],' ',s,'.png'])
            app.CalibratedThreshold.Value = 0;
            Immobilityc=(sum(Yc(1:Tillc))/Tillc)*100;
            Number_of_boutsc=length(runendsc);
            if sum(runlengthsc,'all')==0
                Longest_boutc=0;
            else
                Longest_boutc=max(runlengthsc)+1;
            end
            if sum(runstartsc,'all')==0
                Immobility_latencyc=Tillc;
            else
                Immobility_latencyc=runstartsc(1)-1;
            end
            app.Largest_Bout.Value=Longest_boutc;
            app.Latency.Value = Immobility_latencyc;
            app.StatusEditField.Value = Immobilityc;
            app.TotalTimesEditField.Value = length(Yc);
            app.GreenMobilityEditField.Value =length(Yc)-sum(Yc);
            AnalysisStartc=app.changingValue1;
            AnalysisEndc=app.changingValue2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% binned interval
            binsizec=app.TimeBinsSpinner.Value;
            if binsizec<length(Yc)
                binc =length(Yc)- rem(length(Yc),binsizec);
                Rimc=Yc(1:binc);
                if length(Yc)>binc
                    Rim2c=Yc(binc+1:end);
                    Rimbinc = reshape(Rimc,binsizec,[]);
                    binnedimc = [sum(Rimbinc,1)/binsizec,sum(Rim2c)/length(Rim2c)]*100;
                else
                    Rimbinc = reshape(Rimc,binsizec,[]);
                    binnedimc = (sum(Rimbinc,1)/binsizec)*100;
                end
            else
                binnedimc=sum(Yc)/length(Yc)*100;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Binned Immobility heatmap
            figure
            image(abs(100-binnedimc))
            colormap(gray(100))
            colorbar
            yticks([])
            ylabel([app.EnterInfoEditField.Value])
            xlabel('Manual Binned Immobility')
            pbaspect([length(binnedimc) length(binnedimc)/10 1])
            ax = gca;
            ax.Color = 'none';
            ax.FontWeight='bold';
            ax.FontSize = 12;
            ax.TickLength = [.005 0.035];
            ax.LineWidth=2;
            ax.XTick = 1:1:length(Yc);
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            saveas(gcf,['Manual Binned ',[app.EnterInfoEditField.Value],' ',s,'.png'])
            %%same for manual from here
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            clip=3;
            clipped_Manual_score=Yc;
            clipped_area_change=app.meanbinpercentage_ar;
            for i=clip+2:length(rasterc)-1
                if rasterc(i)+clip<length(Yc)-clip
                    if rasterc(i)-clip<=0
                       rasterc(i)=clip+1;
                    clipped_Manual_score(rasterc(i)-clip:rasterc(i)+clip)=100;
                    clipped_area_change(rasterc(i)-clip:rasterc(i)+clip)=100;
                    end
                end
            end
            clipped_Manual_score(clipped_Manual_score==100)=[];
            clipped_area_change(clipped_area_change==100)=[];
            IM=clipped_area_change(clipped_Manual_score==1);
            M=clipped_area_change(clipped_Manual_score==0);
            [~,edges] = histcounts(clipped_area_change',1000);
            Nim = histcounts(IM,edges);
            Nm = histcounts(M,edges);
            NmPa=[]; % tpr
            for i=1:length(Nm)
                Pm=(sum(Nm(i:length(Nm)))/sum(Nm));
                NmPa=[NmPa,Pm];
            end
            NimPa=[]; % fpr
            for i=1:length(Nim)
                Pim=sum(Nim(i:length(Nim)))/sum(Nim);
                NimPa=[NimPa,Pim];
            end
            %CZ
            gmeansa=(NmPa.*(1-NimPa));
            ThresholdPa=(edges(gmeansa==max(gmeansa))); % fix things here
            CalibratedThresholdMin=min(ThresholdPa);
            CalibratedThresholdMax=max(ThresholdPa);
            AUCa=abs(trapz(NimPa,NmPa));
            p4=plot(NimPa,NmPa,'-m','LineWidth',4);
            hold on
            p5=plot((NimPa(gmeansa==max(gmeansa))),(NmPa(gmeansa==max(gmeansa))),'g*','LineWidth',5);
            hold off
            pbaspect([1 1 1]);
            ax = gca;
            ax.Color = 'none';
            ax.FontWeight='bold';
            ax.FontSize = 12;
            ax.TickLength = [.005 0.035];
            ax.LineWidth=2;
            xlabel('1-Specificity')
            ylabel('Sensitivity')
            title('ROC Curve')
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            saveas(gcf,['ROC curve generated from Manual Quantification',[app.EnterInfoEditField.Value],' ',s,'.png'])
            app.CalibratedThreshold.Value = max(ThresholdPa);
            close all
            format shortg
            s = num2str(fix(clock));
            ManualAnalysis = ['Manual ',[app.filename],' ',[app.EnterInfoEditField.Value],' ',s];
            %remove this for paper
            %fbfdiff=app.fbfd;%remove this for paper
            Data=app.cr;
            framerate=app.v.FrameRate;
            Area_Change=app.meanbinpercentage_ar ;
            rawarea=app.ar;
            framerate=app.v.FrameRate;
            AnalysisStart=app.changingValue1;
            AnalysisEnd=app.changingValue2;
            Selection_Coordinates=app.selectioncord;
            Binary_Threshold=app.T;
            Blur_Value=app.G;
            Area_Threshold=app.EnterThreshold.Value;
            Time_Threshold=minimumchangec+1;
            Bin_Size=binsizec;
            save(ManualAnalysis)
            %remove this for paper
            %% writes excel file
            filenamexlsx = ['Manual ',[app.filename],' ',[app.EnterInfoEditField.Value],' ',s,'.xlsx'];
            A = {'Area','Manual'};
            B=[rawarea', im2'];
            sheet = 1;
            xlsrange = 'A1';
            xlswrite(filenamexlsx,A,sheet,xlsrange)
            xlsrange = 'A2';
            xlswrite(filenamexlsx,B,sheet,xlsrange)
            C={'AreaChange/S','Manual/S'};
            D=[Area_Change',Yc];
            sheet = 1;
            xlsrange = 'C1';
            xlswrite(filenamexlsx,C,sheet,xlsrange)
            xlsrange = 'C2';
            xlswrite(filenamexlsx,D,sheet,xlsrange)
            E={'Immobility','Latency','Longest Bout','Number of Bouts','FrameRate','Start', 'End',' Binary Threshold','Blur Value','Area Threshold','Time Threshold','Bin Size','Bins'};
            xlsrange = 'E1';
            xlswrite(filenamexlsx,E,sheet,xlsrange)
            F=[Immobilityc,Immobility_latencyc,Longest_boutc,Number_of_boutsc,framerate,AnalysisStart, AnalysisEnd,app.T,app.G,app.EnterThreshold.Value, minimumchangec+1,binsizec,binnedimc];
            xlsrange = 'E2';
            xlswrite(filenamexlsx,F,sheet,xlsrange)          
            imshow(app.show1,'Parent', app.UIAxes)
            app.StateButton.BackgroundColor='cyan';
            app.StateButton.Text='Done!';
            app.Manual.Text='Manual Analysis';
            app.Manual.BackgroundColor='cyan';
            app.Analyse.BackgroundColor='cyan';
            app.Manual.BackgroundColor='cyan';
            cd(app.path3)
            cd(app.filename)
            close all
        end

        % Value changing function: BT
        function BTValueChanging(app, event)
            changingValue3 = event.Value;
            app.T=changingValue3;
            K =app.cr(1).cdata;
            bkgsubi=imgaussfilt(imabsdiff(app.J,K),app.G);
            blwh1=imbinarize(bkgsubi,app.T/100);
            B1 = imoverlay(K,blwh1,'g');
            imshowpair(B1,K,'montage','Parent', app.UIAxes)
            app.ResetButton.BackgroundColor='g';
            app.ResetButton.Text='Custom';
        end

        % Value changed function: ResetButton
        function ResetButtonValueChanged(app, event)
            value = app.ResetButton.Value;
            K=app.cr(1).cdata;
            app.G=.1;
            app.Blur.Value=.1;
            bkgsubi=imgaussfilt(imabsdiff(app.J,K),app.G);
            ot=graythresh(bkgsubi);
            blwh=imbinarize(bkgsubi);
            B = imoverlay(K,blwh,'m');
            imshowpair(B,K,'montage','Parent', app.UIAxes)
            app.BT.Value=round(ot*100);
            app.T=round(ot*100);
            
            app.ResetButton.BackgroundColor='m';
            app.ResetButton.Text='Auto';
        end

        % Button pushed function: BackgroundFillButton
        function BackgroundFillButtonPushed(app, event)
            figure;
            imshow(app.J);
            set(gcf, 'Position', get(0,'Screensize'));
            hold on
            h = impoly;
            mask = h.createMask();
            bw = regionfill(app.J,mask);
            app.J=bw;
            delete(h);
            %             cla
            imshow(app.J)
            pause(3)
            app.G=.1;
            app.Blur.Value=.1;
            close all
        end

        % Value changing function: Blur
        function BlurValueChanging(app, event)
            changingValue4 = event.Value;
            app.G=changingValue4;
            K =app.cr(1).cdata;
            bkgsubi=imgaussfilt(imabsdiff(app.J,K),app.G);
            blwh1=imbinarize(bkgsubi,app.T/100);
            B1 = imoverlay(K,blwh1,'g');
            imshowpair(B1,K,'montage','Parent', app.UIAxes)
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Tool and hide until all components are created
            app.Tool = uifigure('Visible', 'off');
            app.Tool.AutoResizeChildren = 'off';
            app.Tool.Color = [1 1 1];
            app.Tool.Position = [100 100 640 480];
            app.Tool.Name = 'DBScorer';
            app.Tool.Resize = 'off';

            % Create LoadVideoButton
            app.LoadVideoButton = uibutton(app.Tool, 'push');
            app.LoadVideoButton.ButtonPushedFcn = createCallbackFcn(app, @LoadVideoButtonPushed, true);
            app.LoadVideoButton.Position = [10 442 224 22];
            app.LoadVideoButton.Text = 'Load Video';

            % Create MarkAreaButton
            app.MarkAreaButton = uibutton(app.Tool, 'push');
            app.MarkAreaButton.ButtonPushedFcn = createCallbackFcn(app, @MarkAreaButtonPushed, true);
            app.MarkAreaButton.Tooltip = {'Select Only Area Containing the animal'};
            app.MarkAreaButton.Position = [11 285 223 37];
            app.MarkAreaButton.Text = 'Mark Area';

            % Create StartsLabel
            app.StartsLabel = uilabel(app.Tool);
            app.StartsLabel.HorizontalAlignment = 'right';
            app.StartsLabel.Position = [11 405 55 22];
            app.StartsLabel.Text = 'Start (s)';

            % Create StartSpinner
            app.StartSpinner = uispinner(app.Tool);
            app.StartSpinner.ValueChangingFcn = createCallbackFcn(app, @StartSpinnerValueChanging, true);
            app.StartSpinner.Limits = [1 Inf];
            app.StartSpinner.Position = [69 405 53 22];
            app.StartSpinner.Value = 1;

            % Create EndsSpinnerLabel
            app.EndsSpinnerLabel = uilabel(app.Tool);
            app.EndsSpinnerLabel.HorizontalAlignment = 'right';
            app.EndsSpinnerLabel.Position = [136 405 44 22];
            app.EndsSpinnerLabel.Text = 'End (s)';

            % Create EndsSpinner
            app.EndsSpinner = uispinner(app.Tool);
            app.EndsSpinner.ValueChangingFcn = createCallbackFcn(app, @EndsSpinnerValueChanging, true);
            app.EndsSpinner.Limits = [2 Inf];
            app.EndsSpinner.Position = [181 405 53 22];
            app.EndsSpinner.Value = 2;

            % Create StateButton
            app.StateButton = uibutton(app.Tool, 'state');
            app.StateButton.Tooltip = {''};
            app.StateButton.Text = 'State';
            app.StateButton.Position = [426 5 204 38];

            % Create TotalTimesEditFieldLabel
            app.TotalTimesEditFieldLabel = uilabel(app.Tool);
            app.TotalTimesEditFieldLabel.HorizontalAlignment = 'right';
            app.TotalTimesEditFieldLabel.Position = [276 405 78 22];
            app.TotalTimesEditFieldLabel.Text = 'Total Time (s)';

            % Create TotalTimesEditField
            app.TotalTimesEditField = uieditfield(app.Tool, 'numeric');
            app.TotalTimesEditField.Editable = 'off';
            app.TotalTimesEditField.Position = [365 405 54 22];

            % Create StatusEditField
            app.StatusEditField = uieditfield(app.Tool, 'numeric');
            app.StatusEditField.Editable = 'off';
            app.StatusEditField.Position = [365 370 54 22];

            % Create EnterInfoEditField
            app.EnterInfoEditField = uieditfield(app.Tool, 'text');
            app.EnterInfoEditField.Tooltip = {'Input Animal ID'};
            app.EnterInfoEditField.Position = [11 332 223 22];

            % Create AutomaticScore
            app.AutomaticScore = uilabel(app.Tool);
            app.AutomaticScore.HorizontalAlignment = 'right';
            app.AutomaticScore.Position = [245 370 109 22];
            app.AutomaticScore.Text = 'Score (% Magenta)';

            % Create GreenMobilityEditFieldLabel
            app.GreenMobilityEditFieldLabel = uilabel(app.Tool);
            app.GreenMobilityEditFieldLabel.HorizontalAlignment = 'right';
            app.GreenMobilityEditFieldLabel.Position = [469 405 91 22];
            app.GreenMobilityEditFieldLabel.Text = 'Green (Mobility)';

            % Create GreenMobilityEditField
            app.GreenMobilityEditField = uieditfield(app.Tool, 'numeric');
            app.GreenMobilityEditField.Limits = [0 Inf];
            app.GreenMobilityEditField.Editable = 'off';
            app.GreenMobilityEditField.Position = [572 405 52 22];

            % Create CalibratedThresholdLabel
            app.CalibratedThresholdLabel = uilabel(app.Tool);
            app.CalibratedThresholdLabel.HorizontalAlignment = 'right';
            app.CalibratedThresholdLabel.Position = [448 369 112 22];
            app.CalibratedThresholdLabel.Text = 'Calibrated Threshold';

            % Create CalibratedThreshold
            app.CalibratedThreshold = uieditfield(app.Tool, 'numeric');
            app.CalibratedThreshold.Limits = [0 Inf];
            app.CalibratedThreshold.Editable = 'off';
            app.CalibratedThreshold.Position = [572 370 56 22];

            % Create AreaThresholdLabel
            app.AreaThresholdLabel = uilabel(app.Tool);
            app.AreaThresholdLabel.HorizontalAlignment = 'right';
            app.AreaThresholdLabel.Position = [23 129 121 22];
            app.AreaThresholdLabel.Text = '? Area Threshold (%)';

            % Create EnterThreshold
            app.EnterThreshold = uieditfield(app.Tool, 'numeric');
            app.EnterThreshold.Limits = [0 Inf];
            app.EnterThreshold.Tooltip = {'Optional'};
            app.EnterThreshold.Position = [156 129 78 23];
            app.EnterThreshold.Value = 1;

            % Create Analyse
            app.Analyse = uibutton(app.Tool, 'push');
            app.Analyse.ButtonPushedFcn = createCallbackFcn(app, @AnalyseButtonPushed, true);
            app.Analyse.Position = [10 5 224 38];
            app.Analyse.Text = 'Automatic Analysis';

            % Create Manual
            app.Manual = uibutton(app.Tool, 'push');
            app.Manual.ButtonPushedFcn = createCallbackFcn(app, @ManualButtonPushed, true);
            app.Manual.Tooltip = {'For getting optimum threshold based on user input or'; 'Manually analysing Video'};
            app.Manual.Position = [248 5 106 38];
            app.Manual.Text = 'Manual Analysis';

            % Create Play
            app.Play = uibutton(app.Tool, 'state');
            app.Play.Tooltip = {'Start or Pause Scoring Manually'};
            app.Play.Text = 'Play';
            app.Play.Position = [365 5 54 38];

            % Create LatencyMagentaLabel
            app.LatencyMagentaLabel = uilabel(app.Tool);
            app.LatencyMagentaLabel.HorizontalAlignment = 'right';
            app.LatencyMagentaLabel.Position = [248 442 106 22];
            app.LatencyMagentaLabel.Text = 'Latency (Magenta)';

            % Create Latency
            app.Latency = uieditfield(app.Tool, 'numeric');
            app.Latency.Limits = [0 Inf];
            app.Latency.Editable = 'off';
            app.Latency.Position = [365 442 54 22];

            % Create LongestBoutMagentaLabel
            app.LongestBoutMagentaLabel = uilabel(app.Tool);
            app.LongestBoutMagentaLabel.HorizontalAlignment = 'right';
            app.LongestBoutMagentaLabel.Position = [426 442 134 22];
            app.LongestBoutMagentaLabel.Text = 'Longest Bout (Magenta)';

            % Create Largest_Bout
            app.Largest_Bout = uieditfield(app.Tool, 'numeric');
            app.Largest_Bout.Limits = [0 Inf];
            app.Largest_Bout.Editable = 'off';
            app.Largest_Bout.Position = [572 442 56 22];

            % Create TimeThresholdsLabel
            app.TimeThresholdsLabel = uilabel(app.Tool);
            app.TimeThresholdsLabel.HorizontalAlignment = 'right';
            app.TimeThresholdsLabel.Position = [38 94 106 22];
            app.TimeThresholdsLabel.Text = 'Time Threshold (s)';

            % Create MinIB
            app.MinIB = uieditfield(app.Tool, 'numeric');
            app.MinIB.Limits = [0 Inf];
            app.MinIB.RoundFractionalValues = 'on';
            app.MinIB.Tooltip = {'Optional'};
            app.MinIB.Position = [156 94 78 23];

            % Create BinaryThresholdLabel
            app.BinaryThresholdLabel = uilabel(app.Tool);
            app.BinaryThresholdLabel.HorizontalAlignment = 'right';
            app.BinaryThresholdLabel.Position = [46 191 98 22];
            app.BinaryThresholdLabel.Text = 'Binary Threshold';

            % Create BT
            app.BT = uispinner(app.Tool);
            app.BT.ValueChangingFcn = createCallbackFcn(app, @BTValueChanging, true);
            app.BT.Limits = [0 100];
            app.BT.Tooltip = {'Optional'};
            app.BT.Position = [156 191 78 22];

            % Create TimeBinsSpinnerLabel
            app.TimeBinsSpinnerLabel = uilabel(app.Tool);
            app.TimeBinsSpinnerLabel.HorizontalAlignment = 'right';
            app.TimeBinsSpinnerLabel.Position = [75 59 70 22];
            app.TimeBinsSpinnerLabel.Text = 'Time Bin (s)';

            % Create TimeBinsSpinner
            app.TimeBinsSpinner = uispinner(app.Tool);
            app.TimeBinsSpinner.Limits = [0 Inf];
            app.TimeBinsSpinner.Tooltip = {'Optional'};
            app.TimeBinsSpinner.Position = [156 59 78 22];
            app.TimeBinsSpinner.Value = 60;

            % Create ResetButton
            app.ResetButton = uibutton(app.Tool, 'state');
            app.ResetButton.ValueChangedFcn = createCallbackFcn(app, @ResetButtonValueChanged, true);
            app.ResetButton.Tooltip = {'Use Auto Thresholding'};
            app.ResetButton.Text = 'Reset';
            app.ResetButton.Position = [11 232 57 38];

            % Create BackgroundFillButton
            app.BackgroundFillButton = uibutton(app.Tool, 'push');
            app.BackgroundFillButton.ButtonPushedFcn = createCallbackFcn(app, @BackgroundFillButtonPushed, true);
            app.BackgroundFillButton.Tooltip = {'Select Only Area Containing the animal'};
            app.BackgroundFillButton.Position = [75 232 159 38];
            app.BackgroundFillButton.Text = 'Background Fill';

            % Create BlurImageLabel
            app.BlurImageLabel = uilabel(app.Tool);
            app.BlurImageLabel.HorizontalAlignment = 'right';
            app.BlurImageLabel.Position = [46 162 99 22];
            app.BlurImageLabel.Text = 'Blur Image';

            % Create Blur
            app.Blur = uispinner(app.Tool);
            app.Blur.Step = 0.1;
            app.Blur.ValueChangingFcn = createCallbackFcn(app, @BlurValueChanging, true);
            app.Blur.Limits = [0.1 10];
            app.Blur.Tooltip = {'Optional'};
            app.Blur.Position = [156 162 78 22];
            app.Blur.Value = 0.1;

            % Create UIAxes
            app.UIAxes = uiaxes(app.Tool);
            app.UIAxes.XColor = 'none';
            app.UIAxes.XTick = [];
            app.UIAxes.YColor = 'none';
            app.UIAxes.YTick = [];
            app.UIAxes.ZColor = 'none';
            app.UIAxes.GridColor = 'none';
            app.UIAxes.MinorGridColor = 'none';
            app.UIAxes.HandleVisibility = 'off';
            app.UIAxes.Position = [248 50 382 304];

            % Show the figure after all components are created
            app.Tool.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DBscorer_1_1_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Tool)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Tool)
        end
    end
end