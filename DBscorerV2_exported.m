classdef DBscorerV2_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Tool                 matlab.ui.Figure
        LoadVideo            matlab.ui.control.Button
        MarkROI              matlab.ui.control.Button
        StartsLabel          matlab.ui.control.Label
        ProcessVideoStart    matlab.ui.control.Spinner
        EndsLabel            matlab.ui.control.Label
        ProcessVideoEnd      matlab.ui.control.Spinner
        TimeEditFieldLabel   matlab.ui.control.Label
        Time                 matlab.ui.control.NumericEditField
        ProcessVideo         matlab.ui.control.Button
        FixBackground        matlab.ui.control.Button
        BinarizeLabel        matlab.ui.control.Label
        BinaryThreshold      matlab.ui.control.Spinner
        EnterInfo            matlab.ui.control.EditField
        CreateBackground     matlab.ui.control.Button
        ManualScoring        matlab.ui.control.Button
        Play                 matlab.ui.control.StateButton
        StateButton          matlab.ui.control.StateButton
        Cancel               matlab.ui.control.StateButton
        GetThresh            matlab.ui.control.Button
        AreaThresholdLabel   matlab.ui.control.Label
        AreaThreshold        matlab.ui.control.NumericEditField
        TimeThresholdsLabel  matlab.ui.control.Label
        TimeThresh           matlab.ui.control.NumericEditField
        CompileAuto          matlab.ui.control.Button
        CompileManual        matlab.ui.control.Button
        StartTimesLabel      matlab.ui.control.Label
        StartTime            matlab.ui.control.NumericEditField
        EndTimesLabel        matlab.ui.control.Label
        EndTime              matlab.ui.control.NumericEditField
        ClipLabel            matlab.ui.control.Label
        Clip                 matlab.ui.control.NumericEditField
        TimeBinsLabel        matlab.ui.control.Label
        TimeBin              matlab.ui.control.NumericEditField
        FigWindow            matlab.ui.control.Button
    end

    
    properties (Access = public)
        v % Video
        changingValue1 % Video analysis start time
        changingValue2 % Video analysis end time
        show1 % Video analysis first frame
        show2 % Video analysis end frame
        path3 % Video Path
        filename
        filename_3
        Background
        cr
        crop
        ClearOutsideMask
        hImage
        T
        video
        ar
        cord
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadVideo
        function LoadVideoPushed(app, event)
            % Close all the figures first
            figure
            close all
            % Imports selected video
            [filename_2, pathname_2] = uigetfile('*.mov;*.wmv;*.mp4;*.avi','Open Video File');
            if filename_2 == 0
                % If user clicked the Cancel button.
                return;
            end
            app.filename_3 = cellstr(filename_2);
            pathname_3 = cellstr(pathname_2);
            app.video = fullfile(pathname_3{1},app.filename_3{1});
            % Get the name video and create folder with video name
            [folder, baseFileNameNoExt, ~] = fileparts(app.video);
            fileName = fullfile(pathname_3{1});
            dotLocations = find(fileName == '.');
            if isempty(dotLocations)
                nameBeforeFirstDot = fileName;
            else
                nameBeforeFirstDot = fileName(1:dotLocations(1)-1);
            end
            cd(folder)
            app.path3=nameBeforeFirstDot;
            app.filename=baseFileNameNoExt;
            % creates video reader and shows firstframe from the video
            app.v = VideoReader(app.video);
            frame = read(app.v, 1);
            app.hImage=imshow(frame);
            xlabel(baseFileNameNoExt)
            app.changingValue1=1;
            app.changingValue2=floor(app.v.Duration);
            app.ProcessVideoStart.Value=1;
            app.ProcessVideoEnd.Value=round(app.v.Duration-1);
            app.Time.Value =floor(app.v.Duration);
            app.LoadVideo.BackgroundColor='g';
            app.CreateBackground.BackgroundColor='w';
            app.CreateBackground.Text='Create Background';
            app.FixBackground.Text='Fix Background';
            app.FixBackground.BackgroundColor='w';
            app.MarkROI.Text='Mark ROI';
            app.MarkROI.BackgroundColor='w';
        end

        % Button pushed function: MarkROI
        function MarkROIPushed(app, event)
            numrois=2;
            map=hsv(numrois);
            custommap = map;
            app.show1 = read(app.v,floor(app.changingValue1*app.v.FrameRate));
            imshow(app.show1)
            set(gcf, 'Position', get(0,'Screensize'));
            roi = drawpolygon('FaceAlpha',0,'Color',custommap(1,:));
            app.ClearOutsideMask=createMask(roi);
            croproi=roi.Position;
            app.cord=roi.Position;
            thisROI=[app.cord];
            close
            app.crop=[min(croproi(:,1)),min(croproi(:,2)),max(croproi(:,1))-min(croproi(:,1)),max(croproi(:,2))-min(croproi(:,2))];
            Ic=imcrop(app.show1,app.crop);
            app.hImage=imshow(Ic);
            [~,~,o]=size(Ic);
            medfilt=3;
            BackgroundCropped=imcrop(app.Background,app.crop);
            ClearOutsideMaskCropped=imcrop(app.ClearOutsideMask,app.crop);
            % Average
            fps=app.v.FrameRate;
            wanted_frames=floor(2*fps);
            a = app.changingValue1*app.v.FrameRate;
            b = app.changingValue2*app.v.FrameRate;
            x= floor((b-a).*rand(wanted_frames,1) + a);
            indices = sort(x);
            binarythresh=[];
            app.MarkROI.Text='Getting Binary Threshold';
            app.MarkROI.BackgroundColor='y';
            % if rgb then convert to grayscale
            if o==3
                for k=1:length(x)
                    frame=read(app.v,indices(k));
                    gray =rgb2gray(frame);
                    gray=imcrop(gray,app.crop);
                    MaskedImage = medfilt2(imabsdiff(BackgroundCropped,(gray)),[medfilt,medfilt]);
                    MaskedImage(~ClearOutsideMaskCropped) = 1;
                    level = graythresh(MaskedImage);
                    binarythresh=[binarythresh,level];
                end
            else
                for k=1:length(x)
                    gray=read(app.v,indices(k));
                    gray=imcrop(gray,app.crop);
                    MaskedImage = medfilt2(imabsdiff(BackgroundCropped,(gray)),[medfilt,medfilt]);
                    MaskedImage(~ClearOutsideMaskCropped) = 1;
                    level = graythresh(MaskedImage);
                    binarythresh=[binarythresh,level];
                end
            end
            MaskedImage = medfilt2(imabsdiff(BackgroundCropped,(gray)),[medfilt,medfilt]);
            MaskedImage(~ClearOutsideMaskCropped) = 1;
            bint = mean(binarythresh);
            app.BinaryThreshold.Value=round(bint*100);
            app.T=round(bint*100);
            MaskedBinary=imbinarize(MaskedImage,(app.T/100));
            B = labeloverlay(gray,MaskedBinary,'Colormap','winter','Transparency',0.10);
            set(app.hImage, 'CData',B)
            imshow(app.show1)
            Animal=drawpolygon('Position',thisROI,'LineWidth',.1,'FaceAlpha',.10,'Color','r','MarkerSize',.1);
            fig=gcf;
            exportgraphics(fig,[[app.EnterInfo.Value],' ',[app.filename],'.tif'],'Resolution',300)
            close
            app.hImage=imshow(Ic);
            set(app.hImage, 'CData',B)
            app.MarkROI.Text='Mark ROI';
            app.MarkROI.BackgroundColor='g';
            app.ProcessVideo.BackgroundColor='w';
        end

        % Value changing function: ProcessVideoStart
        function ProcessVideoStartValueChanging(app, event)
            app.changingValue1 = event.Value;
            if  app.changingValue1<app.v.Duration
                app.show1 = read(app.v,floor(app.changingValue1*app.v.FrameRate));
                set(app.hImage, 'CData', app.show1)
            end
            app.Time.Value =0;
            app.MarkROI.BackgroundColor='w';
            app.ProcessVideo.BackgroundColor='w';
            app.Play.BackgroundColor='w';
            app.StateButton.BackgroundColor='w';
        end

        % Value changing function: ProcessVideoEnd
        function ProcessVideoEndValueChanging(app, event)
            app.changingValue2 = event.Value;
            if  app.changingValue2<app.v.Duration
                app.show2 = read(app.v,floor(app.changingValue2*app.v.FrameRate));
                set(app.hImage, 'CData', app.show2)
            end
            app.Time.Value =app.changingValue2-app.changingValue1;
            app.MarkROI.BackgroundColor='w';
            app.ProcessVideo.BackgroundColor='w';
            app.Play.BackgroundColor='w';
            app.StateButton.BackgroundColor='w';
        end

        % Button pushed function: ProcessVideo
        function ProcessVideoButtonPushed(app, event)
            app.Cancel.Value=0;
            medfilt=3;
            app.T=app.BinaryThreshold.Value;
            app.ProcessVideo.BackgroundColor='Yellow';
            app.Play.BackgroundColor='w';
            app.StateButton.BackgroundColor='w';
            BackgroundCropped=imcrop(app.Background,app.crop);
            ClearOutsideMaskCropped=imcrop(app.ClearOutsideMask,app.crop);
            clear cr
            A=size(BackgroundCropped);
            app.cr = struct('cdata',zeros(A(1),A(2),1,'uint8'),...
                'colormap',[]);
            StartFrame=floor(app.changingValue1*app.v.FrameRate)+1;
            EndFrame=floor(app.changingValue2*app.v.FrameRate);
            app.ar=[];
            for k=StartFrame:1:EndFrame+1
                app.Time.Value=floor(k/app.v.FrameRate);
                %app.Time.Value=((endtime-floor(k/app.v.FrameRate))/totaltime)*100;
                pause(.0001)
                if app.Cancel.Value==1
                    break
                end
                frame=rgb2gray(read(app.v,k));
                RandomFrame = imcrop(frame,app.crop);
                MaskedImage = medfilt2(imabsdiff(BackgroundCropped,(RandomFrame)),[medfilt,medfilt]);
                MaskedImage(~ClearOutsideMaskCropped) = 1;
                MaskedBinary=imbinarize(MaskedImage,(app.T/100));
                All=sum(MaskedBinary,'all');%
                app.ar=[app.ar,All];%
            end
            BINTHRES=app.T;
            ar_score=app.ar;
            roicord=app.cord;
            fps=app.v.FrameRate;
            save([[app.EnterInfo.Value],' ',[app.filename]])
            app.ProcessVideo.BackgroundColor='g';
            app.hImage=imshow(app.Background);
        end

        % Button pushed function: FixBackground
        function FixBackgroundPushed(app, event)
            numrois=2;
            map=hsv(numrois);
            custommap = map;
            figure;
            imshow(app.Background);
            set(gcf, 'Position', get(0,'Screensize'));
            xlabel('Fill')
            RegionFill = drawpolygon('FaceAlpha',0,'Color',custommap(1,:));
            RegionFillMask = createMask(RegionFill);
            app.Background= regionfill(app.Background,RegionFillMask);
            delete(RegionFill);
            close
            app.hImage=imshow(app.Background);
            app.FixBackground.Text='Fix More Background';
            app.FixBackground.BackgroundColor='g';
            
        end

        % Value changing function: BinaryThreshold
        function BinaryThresholdValueChanging(app, event)
            changingValue3 = event.Value;
            medfilt=3;
            app.T=changingValue3;
            BackgroundCropped=imcrop(app.Background,app.crop);
            ClearOutsideMaskCropped=imcrop(app.ClearOutsideMask,app.crop);
            Ic=imcrop(app.show1,app.crop);
            app.hImage=imshow(Ic);
            [~,~,o]=size(Ic);
            % if rgb then convert to grayscale
            if o==3
                gray=rgb2gray(Ic);
            else
                gray=Ic;
            end            
                MaskedImage = medfilt2(imabsdiff(BackgroundCropped,(gray)),[medfilt,medfilt]);
                MaskedImage(~ClearOutsideMaskCropped) = 1;
                MaskedBinary=imbinarize(MaskedImage,(app.T/100));
            B = labeloverlay(Ic,MaskedBinary,'Colormap','winter','Transparency',0.10);
            set(app.hImage, 'CData',B)
        end

        % Button pushed function: CreateBackground
        function CreateBackgroundButtonPushed(app, event)
            app.v = VideoReader(app.video);
            fps=app.v.FrameRate;
            wanted_frames=floor(2*fps);
            a = app.changingValue1*app.v.FrameRate;
            b = app.changingValue2*app.v.FrameRate;
            x= floor((b-a).*rand(wanted_frames,1) + a);
            indices = sort(x);
            frame = read(app.v, wanted_frames(1));
            A=size(frame);
            app.cr= struct('cdata',zeros(A(1),A(2),1,'uint8'),...
                'colormap',[]);
            [m,n,o]=size(frame);
            Abkg = zeros(m,n,1,'uint8');
            % if rgb then convert to grayscale
            if o==3
                for k=1:length(x)
                    frame=read(app.v,indices(k));
                    frame =rgb2gray(frame);
                    Abkg(:,:,k) =uint8(app.cr(1).cdata);
                    app.cr(1).cdata = frame;
                end
            else
                for k=1:length(x)
                    frame=read(app.v,indices(k));
                    Abkg(:,:,k) =uint8(app.cr(1).cdata);
                    app.cr(1).cdata = frame;
                end
            end
            app.Background = uint8(median(double(Abkg),3));
            medfilt=3;
            app.Background=medfilt2(app.Background,[medfilt,medfilt]);
            app.hImage=imshow(app.Background);
            app.CreateBackground.BackgroundColor='g';
            app.CreateBackground.Text='Recreate Background';
            app.FixBackground.Text='Fix Background';
            app.FixBackground.BackgroundColor='w';
        end

        % Button pushed function: ManualScoring
        function ManualScoringButtonPushed(app, event)
            figure
            close all
            app.Play.Value=1;
            app.Cancel.Value=0;
            is=0;
            frame_by_frame_time_original = 1/app.v.FrameRate;
            StartFrame=floor(app.changingValue1*app.v.FrameRate)+1;
            EndFrame=floor(app.changingValue2*app.v.FrameRate);
            Full=EndFrame-StartFrame+2;
            im2 = zeros(Full,1);
            I=imcrop(app.show1,app.crop);
            app.hImage=imshow(I);
            app.StateButton.Value=0;
            app.StateButton.Text='Immobile';
            tic
            for k=StartFrame:1:EndFrame+1
                if app.Cancel.Value==1
                    break
                end
                while app.Play.Value==1
                    app.Play.Text='Play';
                    app.Play.BackgroundColor='y';
                    app.StateButton.BackgroundColor='y';
                    pause(.0001)
                    if app.Cancel.Value==1
                        break
                    end
                end
                app.Play.Text='Pause';
                app.Play.BackgroundColor='g';
                if app.StateButton.Value==1
                    app.StateButton.BackgroundColor='G';
                    app.StateButton.Text='Mobile';
                    is=is+1;
                    im2(k+1-StartFrame)=1;
                else
                    app.StateButton.BackgroundColor='M';
                    app.StateButton.Text='Immobile';
                    is=is+0;
                    im2(k+1-StartFrame)=0;
                end
                app.Time.Value=floor(k/app.v.FrameRate);
                frame=read(app.v,k);
                I=imcrop(frame,app.crop);
                set(app.hImage, 'CData', I)
                frame_normalization = toc;
                if frame_normalization < frame_by_frame_time_original
                    pause(frame_by_frame_time_original - frame_normalization);
                end
                tic
            end
            hold off
            app.StateButton.Text='State';
            app.StateButton.BackgroundColor='w';
            app.Play.Value=1;
            app.Time.Value=floor(sum(im2,'all')/app.v.FrameRate);
            fps=app.v.FrameRate;
            save([[app.EnterInfo.Value],' ',[app.filename],' ','Manual'])
            app.Cancel.Value=0;
            close all
            app.hImage=imshow(app.Background);
        end

        % Button pushed function: GetThresh
        function GetThreshButtonPushed(app, event)
            [filenames, pathname] = uigetfile('*.mat',...
                'Select One or More Files', ...
                'MultiSelect', 'on');
            if pathname == 0
                % If user clicked the Cancel button.
                return;
            end
            filenames=filenames';
            cd(pathname)
            %% Variables
            FileNames=[];
            AllData=[];
            clip=app.Clip.Value;
            kfold=7;
            %% Batch Processing
            FileNames=[];
            AllData=[];
            for name=1:length(filenames)
                file=filenames{name}(1:end-4);
                tf = strcmp(filenames{name}(end-9:end-4),'Manual');
                if tf==1
                    load(file)
                    auto=[file(1:end-7),'.mat'];
                    load(auto)
                    rc =length(im2)- rem(length(im2),fps);
                    Rc=im2(1:rc);
                    binc = reshape(Rc,fps,[]);
                    meanbinpercentage1c = mean(binc,1);
                    meanbinpercentage2c=meanbinpercentage1c<0.5;
                    GT=meanbinpercentage2c;
                    % area change %
                    AreaChange=abs(diff(ar_score(1:end-1)));
                    AreaPrevious=ar_score(1:end-2);
                    AreaChangePercent=(AreaChange./AreaPrevious)*100;
                    AreaChangePercent(AreaChangePercent>10)=10;
                    r_ar =length(AreaChangePercent)- rem(length(AreaChangePercent),fps);
                    R_ar=AreaChangePercent(1:r_ar);
                    bin_ar = reshape(R_ar,fps,[]);
                    Area_Change=mean(bin_ar,1);
                    % velocity %
                    FileNames=[FileNames;{file(1:end)}];
                    T1=table(GT(2:end)',Area_Change');
                    AllData=[AllData;T1];
                    %close all
                else
                    continue
                end
            end
            %% Clip data
            GT=AllData.Var1';
            Area_Change=AllData.Var2;
            Tillc=length(GT);
            transitionsc = diff([0,GT,0]); % find where the array goes from non-zero to zero and vice versa
            runstartsc = find(transitionsc == 1);
            runendsc = (find(transitionsc == -1)); %one past the end
            runlengthsc = abs(runendsc - runstartsc);
            GT=zeros(length(GT),1);
            for i=1:length(runstartsc)
                GT(runstartsc(i):runendsc(i))=1;
            end
            rasterc=sort([0,runstartsc,runendsc,Tillc]);
            %%
            clipped_Manual_score=GT;
            clipped_area_change=Area_Change;
            if clip>0
                for i=clip+1:length(rasterc)
                    if rasterc(i)-clip<=0
                        rasterc(i)=1;
                    else
                        clipped_Manual_score(rasterc(i)-clip:rasterc(i)+clip)=50;
                        clipped_area_change(rasterc(i)-clip:rasterc(i)+clip)=50;
                    end
                end
            end
            clipped_Manual_score(clipped_Manual_score==50)=[];
            clipped_area_change(clipped_area_change==50)=[];
            s=min(length(clipped_Manual_score),length(clipped_area_change));
            TrainData=[clipped_Manual_score(1:s),clipped_area_change(1:s)];
            % shuffle the data
            dp=s;
            idx= floor((s-1).*rand(dp,1) + 1);
            % k divide
            if  mod(s,kfold)>0
                blocksize=floor(s/kfold);
            else
                blocksize=floor(s/kfold)-1;
            end
            % create valset testset
            TrainSet=[];
            ValSet=[];
            AveragedThreshold=[];
            AveragedAUC=[];
            AveragedAccuracy=[];
            AveragedPrecision=[];
            AveragedRecall=[];
            for i=1: kfold-2
                ValSet=TrainData(idx(blocksize*i:blocksize*i+blocksize),:);
                TrainSet=TrainData;
                TrainSet(idx(blocksize*i:blocksize*i+blocksize),:)=[];
                % ROC based threshold determination
                %figure % 0 for immobility
                AreaChange=TrainSet(:,2);
                IM=AreaChange(TrainSet(:,1)==1);
                M=AreaChange(TrainSet(:,1)==0);
                [~,edges] = histcounts(AreaChange',1000);
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
                ThresholdPa=(edges(gmeansa==max(gmeansa)));
                CalibratedThresholdMin=min(ThresholdPa);
                CalibratedThresholdMax=max(ThresholdPa);
                AUCa=abs(trapz(NimPa,NmPa));
                %p4=plot(NimPa,NmPa,':k','LineWidth',2);
                % p4=area(NimPa,NmPa,'LineWidth',2,'LineStyle',':',FaceColor = '#87cefa');
                % hold on
                % p5=plot((NimPa(gmeansa==max(gmeansa))),(NmPa(gmeansa==max(gmeansa))),'k*','LineWidth',5);
                % hold off
                % pbaspect([1 1 1]);
                % ax = gca;
                % ax.Color = 'none';
                % ax.FontWeight='bold';
                % ax.FontSize = 12;
                % ax.TickLength = [.005 0.035];
                % ax.LineWidth=2;
                % xlabel('1-Specificity')
                % ylabel('Sensitivity')
                % title('ROC Curve')
                % %set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                % saveas(gcf,['ROC curve generated from Manual Quantification','.png'])
                CalibratedThresholdValue = max(ThresholdPa);
                % figure
                % bar(TrainSet(:,2))
                % hold on
                % bar(-TrainSet(:,1)*CalibratedThresholdValue,1,'k')
                % hold on
                % yline(CalibratedThresholdValue,'--k','Threshold');
                % ylabel('Area % Change')
                % xlabel('Time')
                AveragedThreshold=[AveragedThreshold,CalibratedThresholdValue];
                AveragedAUC=[AveragedAUC,AUCa];
                % here calculate true positive, false positive, true negative, false
                % negative
                trueval=ValSet(:,1);
                predicted=ValSet(:,2)<CalibratedThresholdValue;
                TP=sum(trueval==1 & predicted==1);
                FP=sum(trueval==0 & predicted==1);
                TN=sum(trueval==0 & predicted==0);
                FN=sum(trueval==1 & predicted==0);
                TPR=TP/(TP+FN);
                TNR=TN/(TN+FP);
                BalancedAccuracy=(TPR+TNR)/2;
                Precision=TP/(TP+FP);
                Recall=TP/(TP+FN);
                AveragedAccuracy=[AveragedAccuracy,BalancedAccuracy];
                AveragedPrecision=[AveragedPrecision,Precision];
                AveragedRecall=[AveragedRecall,Recall];
            end
            Rec_threshold=mean(AveragedThreshold,'all');
            AveragedAUC=mean(AUCa);
            AverageBalancedAccuracy=mean(AveragedAccuracy);
            AveragedPrecision=mean(AveragedPrecision);
            AveragedRecall=mean(AveragedRecall);
            T2=table(Rec_threshold,AveragedAUC,AverageBalancedAccuracy,AveragedPrecision,AveragedRecall);
            writetable(T2,'Threshold.csv');
%             %% Figure
%             figure
%             i=kfold-1;
%             ValSet=TrainData(idx(blocksize*i:blocksize*i+blocksize),:);
%             Data=ValSet;
%             bar(Data(:,2),1,'k')
%             %alpha(.5)
%             hold on
%             bar(-Data(:,1)*Rec_threshold,1,'b')
%             hold on
%             bar(-(Data(:,2)<Rec_threshold)*Rec_threshold,1,'r')
%             alpha(.5)
%             hold on
%             yline(Rec_threshold,'--k');
%             ylabel('Area % Change')
%             xlabel('Time')
%             set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
%             saveas(gcf,['Area % Change (Gray),Correct (Magenta) Manual (Blue), Auto (Red) Quantification','.png'])
        end

        % Button pushed function: CompileAuto
        function CompileAutoButtonPushed(app, event)
            [filenames, pathname] = uigetfile('*.mat',...
                'Select One or More Files', ...
                'MultiSelect', 'on');
            if pathname == 0
                % If user clicked the Cancel button.
                return;
            end
            cd(pathname)
            filenames=filenames';
            %% Variables
            FileNames=[];
            AllData=[];
            if isempty(app.StartTime.Value)
                startsec=0;
            else
                startsec=app.StartTime.Value;
            end
            
            if isempty(app.EndTime.Value)
                endsec=0;
            else
                endsec=app.EndTime.Value;
            end
            
            
            Threshold=app.AreaThreshold.Value;
            Minimumchange=app.TimeThresh.Value;
            Ylimit=5;
            Binsize=app.TimeBin.Value;
            %% Batch Processing
            FileNames=[];
            AllData=[];
            for name=1:length(filenames)
                file=filenames{name}(1:end-4);
                tf = strcmp(filenames{name}(end-9:end-4),'Manual');
                if tf==0
                load(file)
                startframe=( startsec*fps)+1;
                endframe=(endsec*fps)+1;
                if endframe<length(ar_score)
                Area=ar_score(startframe:endframe);
                else
                Area=ar_score(startframe:length(ar_score));
                endsec=(length(ar_score)-1)/fps;
                end
                AreaChange=abs(diff(Area));
                AreaPrevious=Area(1:end-1);
                AreaChangePercent=(AreaChange./AreaPrevious)*100;
                AreaChangePercent(AreaChangePercent>10)=10;
                r_ar =length(AreaChangePercent)- rem(length(AreaChangePercent),fps);
                R_ar=AreaChangePercent(1:r_ar);
                bin_ar = reshape(R_ar,fps,[]);
                Area_Change=mean(bin_ar,1);
                im=Area_Change<Threshold;
                A=im;
                Till=length(A);
                transitions = diff([0,A,0]); % find where the array goes from non-zero to zero and vice versa
                runstarts = find(transitions == 1);
                runends = (find(transitions == -1)-1); %one past the end
                runlengths = abs(runends - runstarts);
                runstarts(runlengths<= Minimumchange) = [];
                runends(runlengths<= Minimumchange) = [];
                Y=zeros(length(A),1);
                for i=1:length(runstarts)
                    Y(runstarts(i):runends(i))=1;
                end
                Immobility_Percentage=(sum(Y(1:Till))/Till)*100;
                Number_of_bouts=length(runends);
                if sum(runlengths,'all')==0
                    Longest_bout=0;
                else
                    Longest_bout=max(runlengths)+1;
                end
                if sum(runstarts,'all')==0
                    Immobility_latency=NaN;
                else
                    Immobility_latency=runstarts(1)-1;
                end

                % binned immobility

                if Binsize<length(Y)
                    bin =length(Y)- rem(length(Y),Binsize);
                    Rim=Y(1:bin);
                    if length(Y)>bin
                        Rim2=Y(bin+1:end);
                        Rimbin = reshape(Rim,Binsize,[]);
                        Bins = [sum(Rimbin,1)/Binsize,sum(Rim2)/length(Rim2)]*100;
                    else
                        Rimbin = reshape(Rim,Binsize,[]);
                        Bins = (sum(Rimbin,1)/Binsize)*100;
                    end
                else
                    Bins=sum(Y)/length(Y)*100;
                end
                % plot graphs
                bar(Y*Ylimit,1,'M','EdgeColor','none')
                hold on
                bar(double(Y==0)*Ylimit,1,'G','EdgeColor','none')
                alpha(.3) % sets transparency
                xticks(0:Binsize:Till)
                pbaspect([Till Till/10 1])
                xlim([0 Till])
                ylim([0 Ylimit])
                ax = gca;
                ax.Color ='none';
                ax.FontWeight='bold';
                ax.FontSize = 5;
                ax.TickLength = [.005 0.035];
                ax.LineWidth=2;
                box on
                saveas(gcf,[file,' Raster.png'])
                hold on
                p=bar(Area_Change,.5,'k','EdgeColor','none');
                alpha(.4)
                hold on
                xlabel('Time (Second)')
                ylabel('Δ Area % ')
                pbaspect([Till Till/10 1])
                hold on
                saveas(gcf,[file,' Raster Area Change.png'])
                hold off
                figure
                image(abs(100-Bins))
                colormap(gray(100))
                colorbar
                yticks([])
                xlabel('Binned Immobility (Darker)')
                pbaspect([length(Bins) length(Bins)/10 1])
                ax = gca;
                ax.Color = 'none';
                ax.FontWeight='bold';
                ax.FontSize = 5;
                ax.TickLength = [.005 0.035];
                ax.LineWidth=2;
                ax.XTick = 1:1:length(Y);
                saveas(gcf,[file,'Binned ','.png'])
                ExptStartTime=(StartFrame-1)/fps;
                ExptEndTime=(EndFrame/fps);
                T1=table(Immobility_Percentage,Immobility_latency,Longest_bout,Number_of_bouts,...
                    startsec,endsec,ExptStartTime,ExptEndTime,Minimumchange,Threshold,Binsize,Bins);
                writetable(T1,[file,' Results Auto.csv']);
                writematrix(Y,[file,' Auto .txt'])
                FileNames=[FileNames;{file(1:end)}];
                AllData=[AllData;T1];
                close all
                else
                    continue
                end
            end
            T2=table(FileNames);
            CombinedData=[T2,AllData];
            writetable(CombinedData,' Results Auto Compiled.csv');

        end

        % Button pushed function: CompileManual
        function CompileManualButtonPushed(app, event)
            [filenames, pathname] = uigetfile('*.mat',...
                'Select One or More Files', ...
                'MultiSelect', 'on');
            if pathname == 0
                % If user clicked the Cancel button.
                return;
            end
            cd(pathname)
            filenames=filenames';
            %% Variables
            FileNames=[];
            AllData=[];
            %fps=app.FPS.Value;
            if isempty(app.StartTime.Value)
                startsec=0;
            else
                startsec=app.StartTime.Value;
            end
            
            if isempty(app.EndTime.Value)
                endsec=0;
            else
                endsec=app.EndTime.Value;
            end
            Threshold=app.AreaThreshold.Value;
            Minimumchange=app.TimeThresh.Value;
            Ylimit=5;
            Binsize=app.TimeBin.Value;
            %% Batch Processing
            FileNames=[];
            AllData=[];
            for name=1:length(filenames)
                file=filenames{name}(1:end-4);
                tf = strcmp(filenames{name}(end-9:end-4),'Manual');
                if tf==1
                load(file)
                startframe=( startsec*fps)+1;
                endframe=(endsec*fps)+1;
                if endframe<length(im2)
                im2=im2(startframe:endframe);
                else
                im2=im2(startframe:length(im2));
                end
                rc =length(im2)- rem(length(im2),fps);
                Rc=im2(1:rc);
                binc = reshape(Rc,fps,[]);
                meanbinpercentage1c = mean(binc,1);
                meanbinpercentage2c=meanbinpercentage1c<0.5;
                A=meanbinpercentage2c;
                Till=length(A);
                transitions = diff([0,A,0]); % find where the array goes from non-zero to zero and vice versa
                runstarts = find(transitions == 1);
                runends = (find(transitions == -1)-1); %one past the end
                runlengths = abs(runends - runstarts);
                runstarts(runlengths<= Minimumchange) = [];
                runends(runlengths<= Minimumchange) = [];
                Y=zeros(length(A),1);
                for i=1:length(runstarts)
                    Y(runstarts(i):runends(i))=1;
                end
                Immobility_Percentage=(sum(Y(1:Till))/Till)*100;
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
                
                % binned immobility
                
                if Binsize<length(Y)
                    bin =length(Y)- rem(length(Y),Binsize);
                    Rim=Y(1:bin);
                    if length(Y)>bin
                        Rim2=Y(bin+1:end);
                        Rimbin = reshape(Rim,Binsize,[]);
                        Bins = [sum(Rimbin,1)/Binsize,sum(Rim2)/length(Rim2)]*100;
                    else
                        Rimbin = reshape(Rim,Binsize,[]);
                        Bins = (sum(Rimbin,1)/Binsize)*100;
                    end
                else
                    Bins=sum(Y)/length(Y)*100;
                end
                % plot graphs
                bar(Y*Ylimit,1,'M','EdgeColor','none')
                alpha(.3) % sets transparency
                hold on
                bar(double(Y==0)*Ylimit,1,'G','EdgeColor','none')
                alpha(.3)
                xticks(0:Binsize:Till)
                pbaspect([Till Till/10 1])
                xlim([0 Till])
                ylim([0 Ylimit])
                ax = gca;
                ax.Color ='none';
                ax.FontWeight='bold';
                ax.FontSize = 5;
                ax.TickLength = [.005 0.035];
                ax.LineWidth=2;
                hold on
                %set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
                xlabel('Time (second)')
                box on
                saveas(gcf,[file,' Raster Manual.png'])
                hold off
                figure
                image(abs(100-Bins))
                colormap(gray(100))
                colorbar
                yticks([])
                xlabel('Binned Immobility (Darker) Manual')
                pbaspect([length(Bins) length(Bins)/10 1])
                ax = gca;
                ax.Color = 'none';
                ax.FontWeight='bold';
                ax.FontSize = 5;
                ax.TickLength = [.005 0.035];
                ax.LineWidth=2;
                ax.XTick = 1:1:length(Y);
                saveas(gcf,[file,'Binned Manual','.png'])
                T1=table(Immobility_Percentage,Immobility_latency,Longest_bout,Number_of_bouts,...
                    startsec,endsec,Minimumchange,Threshold,Binsize,Bins);
                writetable(T1,[file,' Results Manual.csv']);
                FileNames=[FileNames;{file(1:end)}];
                writematrix(Y,[file,' Manual.txt'])
                AllData=[AllData;T1];
                close all
                else
                    continue
                end
            end
            T2=table(FileNames);
            CombinedData=[T2,AllData];
            writetable(CombinedData,' Results Manual Compiled.csv');

        end

        % Button pushed function: FigWindow
        function FigWindowButtonPushed(app, event)
            app.hImage=imshow(app.Background);
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
            app.Tool.Position = [100 100 360 480];
            app.Tool.Name = 'DBscorerV2';
            app.Tool.Resize = 'off';

            % Create LoadVideo
            app.LoadVideo = uibutton(app.Tool, 'push');
            app.LoadVideo.ButtonPushedFcn = createCallbackFcn(app, @LoadVideoPushed, true);
            app.LoadVideo.Interruptible = 'off';
            app.LoadVideo.FontName = 'Arial';
            app.LoadVideo.Position = [11 448 161 25];
            app.LoadVideo.Text = 'Load Video';

            % Create MarkROI
            app.MarkROI = uibutton(app.Tool, 'push');
            app.MarkROI.ButtonPushedFcn = createCallbackFcn(app, @MarkROIPushed, true);
            app.MarkROI.Interruptible = 'off';
            app.MarkROI.Tooltip = {''};
            app.MarkROI.Position = [11 179 161 25];
            app.MarkROI.Text = 'Mark ROI';

            % Create StartsLabel
            app.StartsLabel = uilabel(app.Tool);
            app.StartsLabel.HorizontalAlignment = 'right';
            app.StartsLabel.Position = [11 311 58 22];
            app.StartsLabel.Text = 'Start (s)';

            % Create ProcessVideoStart
            app.ProcessVideoStart = uispinner(app.Tool);
            app.ProcessVideoStart.ValueChangingFcn = createCallbackFcn(app, @ProcessVideoStartValueChanging, true);
            app.ProcessVideoStart.Limits = [1 Inf];
            app.ProcessVideoStart.Interruptible = 'off';
            app.ProcessVideoStart.Position = [89 311 81 22];
            app.ProcessVideoStart.Value = 1;

            % Create EndsLabel
            app.EndsLabel = uilabel(app.Tool);
            app.EndsLabel.HorizontalAlignment = 'right';
            app.EndsLabel.Position = [11 279 56 22];
            app.EndsLabel.Text = 'End (s)';

            % Create ProcessVideoEnd
            app.ProcessVideoEnd = uispinner(app.Tool);
            app.ProcessVideoEnd.ValueChangingFcn = createCallbackFcn(app, @ProcessVideoEndValueChanging, true);
            app.ProcessVideoEnd.Limits = [2 Inf];
            app.ProcessVideoEnd.Interruptible = 'off';
            app.ProcessVideoEnd.Position = [89 279 81 22];
            app.ProcessVideoEnd.Value = 2;

            % Create TimeEditFieldLabel
            app.TimeEditFieldLabel = uilabel(app.Tool);
            app.TimeEditFieldLabel.HorizontalAlignment = 'right';
            app.TimeEditFieldLabel.Position = [11 247 31 22];
            app.TimeEditFieldLabel.Text = 'Time';

            % Create Time
            app.Time = uieditfield(app.Tool, 'numeric');
            app.Time.Interruptible = 'off';
            app.Time.Editable = 'off';
            app.Time.Position = [89 247 81 22];

            % Create ProcessVideo
            app.ProcessVideo = uibutton(app.Tool, 'push');
            app.ProcessVideo.ButtonPushedFcn = createCallbackFcn(app, @ProcessVideoButtonPushed, true);
            app.ProcessVideo.Interruptible = 'off';
            app.ProcessVideo.Position = [11 114 161 25];
            app.ProcessVideo.Text = 'Process Video';

            % Create FixBackground
            app.FixBackground = uibutton(app.Tool, 'push');
            app.FixBackground.ButtonPushedFcn = createCallbackFcn(app, @FixBackgroundPushed, true);
            app.FixBackground.Interruptible = 'off';
            app.FixBackground.Tooltip = {''};
            app.FixBackground.Position = [11 378 161 25];
            app.FixBackground.Text = 'Fix Background';

            % Create BinarizeLabel
            app.BinarizeLabel = uilabel(app.Tool);
            app.BinarizeLabel.HorizontalAlignment = 'right';
            app.BinarizeLabel.Position = [11 148 67 22];
            app.BinarizeLabel.Text = 'Binarize';

            % Create BinaryThreshold
            app.BinaryThreshold = uispinner(app.Tool);
            app.BinaryThreshold.ValueChangingFcn = createCallbackFcn(app, @BinaryThresholdValueChanging, true);
            app.BinaryThreshold.Limits = [0 100];
            app.BinaryThreshold.Position = [89 148 81 22];

            % Create EnterInfo
            app.EnterInfo = uieditfield(app.Tool, 'text');
            app.EnterInfo.Position = [11 213 161 25];

            % Create CreateBackground
            app.CreateBackground = uibutton(app.Tool, 'push');
            app.CreateBackground.ButtonPushedFcn = createCallbackFcn(app, @CreateBackgroundButtonPushed, true);
            app.CreateBackground.Interruptible = 'off';
            app.CreateBackground.Tooltip = {''};
            app.CreateBackground.Position = [11 413 161 25];
            app.CreateBackground.Text = 'Create Background';

            % Create ManualScoring
            app.ManualScoring = uibutton(app.Tool, 'push');
            app.ManualScoring.ButtonPushedFcn = createCallbackFcn(app, @ManualScoringButtonPushed, true);
            app.ManualScoring.Tooltip = {''};
            app.ManualScoring.Position = [11 80 161 25];
            app.ManualScoring.Text = 'Manual Scoring';

            % Create Play
            app.Play = uibutton(app.Tool, 'state');
            app.Play.Tooltip = {''};
            app.Play.Text = 'Play';
            app.Play.Position = [11 46 161 25];

            % Create StateButton
            app.StateButton = uibutton(app.Tool, 'state');
            app.StateButton.Tooltip = {''};
            app.StateButton.Text = 'State';
            app.StateButton.Position = [12 12 161 25];

            % Create Cancel
            app.Cancel = uibutton(app.Tool, 'state');
            app.Cancel.Tooltip = {''};
            app.Cancel.Text = 'Cancel';
            app.Cancel.Position = [195 12 161 25];

            % Create GetThresh
            app.GetThresh = uibutton(app.Tool, 'push');
            app.GetThresh.ButtonPushedFcn = createCallbackFcn(app, @GetThreshButtonPushed, true);
            app.GetThresh.Interruptible = 'off';
            app.GetThresh.Tooltip = {''};
            app.GetThresh.Position = [195 350 161 25];
            app.GetThresh.Text = 'Get Threshold';

            % Create AreaThresholdLabel
            app.AreaThresholdLabel = uilabel(app.Tool);
            app.AreaThresholdLabel.HorizontalAlignment = 'right';
            app.AreaThresholdLabel.Position = [196 143 108 22];
            app.AreaThresholdLabel.Text = 'Δ Area Threshold';

            % Create AreaThreshold
            app.AreaThreshold = uieditfield(app.Tool, 'numeric');
            app.AreaThreshold.Limits = [0 Inf];
            app.AreaThreshold.Tooltip = {'Optional'};
            app.AreaThreshold.Position = [311 143 45 23];
            app.AreaThreshold.Value = 0.65;

            % Create TimeThresholdsLabel
            app.TimeThresholdsLabel = uilabel(app.Tool);
            app.TimeThresholdsLabel.HorizontalAlignment = 'right';
            app.TimeThresholdsLabel.Position = [187 225 116 22];
            app.TimeThresholdsLabel.Text = 'Time Threshold (s)';

            % Create TimeThresh
            app.TimeThresh = uieditfield(app.Tool, 'numeric');
            app.TimeThresh.Limits = [0 Inf];
            app.TimeThresh.RoundFractionalValues = 'on';
            app.TimeThresh.Tooltip = {'Optional'};
            app.TimeThresh.Position = [311 225 45 23];
            app.TimeThresh.Value = 1;

            % Create CompileAuto
            app.CompileAuto = uibutton(app.Tool, 'push');
            app.CompileAuto.ButtonPushedFcn = createCallbackFcn(app, @CompileAutoButtonPushed, true);
            app.CompileAuto.Interruptible = 'off';
            app.CompileAuto.Tooltip = {''};
            app.CompileAuto.Position = [194 99 162 26];
            app.CompileAuto.Text = 'Compile ';

            % Create CompileManual
            app.CompileManual = uibutton(app.Tool, 'push');
            app.CompileManual.ButtonPushedFcn = createCallbackFcn(app, @CompileManualButtonPushed, true);
            app.CompileManual.Interruptible = 'off';
            app.CompileManual.Tooltip = {''};
            app.CompileManual.Position = [194 55 162 26];
            app.CompileManual.Text = 'Compile Manual';

            % Create StartTimesLabel
            app.StartTimesLabel = uilabel(app.Tool);
            app.StartTimesLabel.HorizontalAlignment = 'right';
            app.StartTimesLabel.Position = [226 308 78 22];
            app.StartTimesLabel.Text = 'Start Time (s)';

            % Create StartTime
            app.StartTime = uieditfield(app.Tool, 'numeric');
            app.StartTime.Limits = [0 Inf];
            app.StartTime.RoundFractionalValues = 'on';
            app.StartTime.Tooltip = {'Optional'};
            app.StartTime.Position = [311 308 45 23];

            % Create EndTimesLabel
            app.EndTimesLabel = uilabel(app.Tool);
            app.EndTimesLabel.HorizontalAlignment = 'right';
            app.EndTimesLabel.Position = [233 267 74 22];
            app.EndTimesLabel.Text = 'End Time (s)';

            % Create EndTime
            app.EndTime = uieditfield(app.Tool, 'numeric');
            app.EndTime.Limits = [0 Inf];
            app.EndTime.RoundFractionalValues = 'on';
            app.EndTime.Tooltip = {'Optional'};
            app.EndTime.Position = [311 266 45 23];
            app.EndTime.Value = 300;

            % Create ClipLabel
            app.ClipLabel = uilabel(app.Tool);
            app.ClipLabel.HorizontalAlignment = 'right';
            app.ClipLabel.Position = [280 394 26 22];
            app.ClipLabel.Text = 'Clip';

            % Create Clip
            app.Clip = uieditfield(app.Tool, 'numeric');
            app.Clip.Limits = [0 Inf];
            app.Clip.RoundFractionalValues = 'on';
            app.Clip.Tooltip = {'Optional'};
            app.Clip.Position = [311 394 45 23];
            app.Clip.Value = 1;

            % Create TimeBinsLabel
            app.TimeBinsLabel = uilabel(app.Tool);
            app.TimeBinsLabel.HorizontalAlignment = 'right';
            app.TimeBinsLabel.Position = [225 184 80 22];
            app.TimeBinsLabel.Text = 'Time Bin (s)';

            % Create TimeBin
            app.TimeBin = uieditfield(app.Tool, 'numeric');
            app.TimeBin.Limits = [0 Inf];
            app.TimeBin.RoundFractionalValues = 'on';
            app.TimeBin.Tooltip = {'Optional'};
            app.TimeBin.Position = [311 184 45 23];
            app.TimeBin.Value = 60;

            % Create FigWindow
            app.FigWindow = uibutton(app.Tool, 'push');
            app.FigWindow.ButtonPushedFcn = createCallbackFcn(app, @FigWindowButtonPushed, true);
            app.FigWindow.Interruptible = 'off';
            app.FigWindow.Tooltip = {''};
            app.FigWindow.Position = [11 343 161 25];
            app.FigWindow.Text = 'Figure Window';

            % Show the figure after all components are created
            app.Tool.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DBscorerV2_exported

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