% DynKinect 0.3a  Created by Tobias Augspurger 25.11.2014
% Measure deformation with Kinect 2 @ 512x424 30 fps and compare it with
% scope data from LDV or other reference devices
close all;clc;
clearvars -except FramearrayDyn FramearrayStatic L;

%% Camera Specifications
fps=30; %Kinect takes 30 pictures per secound
row=424;
column=512;


%% Cutoff Amplitude of AmpMap and FreqMap
maxamplitude=100
minamplitude=0

% Total Variation Denosing Parameter
iter=20
dt=0.2; 
eps=1;
lam=2

% Scope and Laser Doppler Vibrometer Data
sensitivity = 125 %%(mm/s)/V
samples = 1001; % zero based
TimePerDIV = 1%s
sampingrate_scope = (samples-1)/(TimePerDIV*10) %% Hz %%Scope with 10 DIV cross screen 200ms/div and 1000 samples are taken: samplingrate = 10DIV*200ms/div *1/1000
% Pixelsector
v_windowlength = 4
h_windowlength = 4

%% Cursor start points
v=2;
h=2;

%% Construct a questdlg with three options

choice = questdlg('Would you like to load new raw data or already filtered data from workspace?', ...
	'Data Source', ...
	'Load new data','Data from workspace','Load new data');
% Handle response
switch choice
    case 'Load new data'
        clearvars FramearrayDyn FramearrayGT L;
        
        %% Capture dynamic data
        ImageFolder=uigetdir('I:\Masterarbeit_Messdaten','Folder of Dynamic TIFF RAW Data');
        tiffFilesS=dir(strcat(ImageFolder,'\*.tiff'));
        L=length(tiffFilesS);
        
    case 'Data from Workspace'
end

%%Allocate size and memory
FreqMap=zeros(421,509);
AmpMap=zeros(421,509);
VarMap=zeros(421,509);
ppMap=zeros(421,509);

AmpMap_raw=zeros(421,509);
ppMap_raw=zeros(421,509);
%% Configure FFT
Fs = fps; % Sampling frequency %% FPS
%Fspline=fps*10;
T = 1/Fs;     
NFFT = 2^nextpow2(L); % Next power of 2 from length of y 

%% Define time stream
t=0:1/fps:L*(1/fps)-1/fps;

%% Spline Time
tnew=0:1/(fps*10):L*(1/fps)-1/fps;

%% Define Lowpass filter paramter
d = fdesign.lowpass('Fp,Fst,Ap,Ast',3,15,0.5,40,30);
Hd = design(d,'equiripple');

%% Scope Data Processing

    csvFilesS=dir(strcat(ImageFolder,'\*.csv'));
        if ~isempty(csvFilesS)
                second=csvread(strcat(ImageFolder,'\',csvFilesS.name),2,0,[2,0,samples,0]);
                Volt=csvread(strcat(ImageFolder,'\',csvFilesS.name),2,1,[2,1,samples,1]);
                %Remove Offset
                speed =(Volt-mean(Volt))*sensitivity;

                %Integrate the Speed to get the displacement
                displacement=cumtrapz(speed)/sampingrate_scope;

                %Remove Offset
                displacement = displacement-mean(displacement);
%                 y = rmswindow(displacement,5,0,0);
%                 rmsmean = mean(y);
%                 pp_scope = rmsmean*sqrt(2)*2

                %Add time offset
                second=second+max(second);

                figure; 
                subplot(2,2,1:2);
                plot(second,displacement);
                title('Time Domain of Scope Data');
                xlabel('Time [s]');
                ylabel('Displacement [mm]');
                xlim([min(second) max(second)]);

                subplot(2,2,3:4);
                Lscope = length(displacement);
                NFFT_scope = 2^nextpow2(Lscope); % Next power of 2 from length of y 
                Y = fft(displacement,NFFT_scope)/(Lscope);
                f_scope = sampingrate_scope/2*linspace(0,1,NFFT_scope/2+1);
                Y_Laser = abs(Y(1:NFFT_scope/2+1));
                plot(f_scope,2*Y_Laser);
                title('Frequency Domain of Scope Data');
                xlabel('Frequency [Hz]');
                ylabel('Amplitude [mm]');
                xlim([0 15]);
            end


    %% Create Videodata and denoise with TVD
    if(~(exist ('FramearrayDyn','var') || exist ('FramearrayGT','var')))
    FramearrayDyn=zeros(424,512,L);
    for g = 1:L
    %   FrameRaw=tv(double(imread(strcat(ImageFolder,'\',tiffFilesS(g).name))),iter,dt,eps,lam);
       FrameRaw=double(imread(strcat(ImageFolder,'\',tiffFilesS(g).name)));
    %     FrameGroundtruth=double(imread(strcat(ImageFolderGroundtruth,'\',tiffFilesSGroundtruth(g).name)));
        FrameRaw=fliplr(FrameRaw);
        FramearrayDyn_Raw(:,:,g) = FrameRaw;

%        for a=1:424 %%cutoff 3D Data
%             for b=1:512
%                 if FramearrayDyn_Raw(a,b,g) > cutoffdistancemax
%                    FramearrayDyn_Raw(a,b,g) = 0;
%                 end
%             end
%        end
    end
end
%% FFT on every pixel
for row = 1:424
    for column = 1:512
        for g= 1:L
            DynPixel_raw(g) = FramearrayDyn_Raw(uint16(row),uint16(column),g);
        end
        DynPixel_raw=DynPixel_raw-mean(DynPixel_raw);
        
        %% Apply Lowpass filter
%       DynPixel = filter(Hd,DynPixel);
%       %%Apply no low pass
%       z_staticf=z_static;

        %% Draw splines 
%       zf = interp1(t,zf,tnew,'spline');
           
        %% FFT Raw
        Y = fft(DynPixel_raw,NFFT)/(L);
        Y_AmpsDyn = abs(Y(1:NFFT/2+1));
        f = Fs/2*linspace(0,1,NFFT/2+1);
        amps=2*Y_AmpsDyn;
        [peakamplitude_raw_first, peakindex_first]=max(amps);
        peakamplitude_raw_proc = amps;
        peakamplitude_raw_proc(1:peakindex_first + round(peakindex_first*0.7)) = 0;
        [peakamplitude_raw, peakindex]=max(peakamplitude_raw_proc);
%         [max_val, max_idx] = max(amps)
%         [max2_val, max2_idx] = max(amps(amps(~=max_idx)))
%         [peakamplitude_raw, peakindex] = max(amps(amps~=max_val))
%         %[peakamplitude_raw, peakindex]= max(amps(amps~=max(amps)));
        %[sortedValues,sortIndex] = sort(amps(:),'descend');
        freq_raw=f(peakindex);
        
%         %% Calcualte RMS
%         y = rmswindow(DynPixel_raw,5,0,0);
%         rmsmean = mean(y);
%         pp_raw = rmsmean*sqrt(2)*2;
        
        % Clean Up the Data
        if(peakamplitude_raw > maxamplitude || peakamplitude_raw < minamplitude || freq_raw > Fs/2 )%|| pp_raw > maxamplitude) 
            freq_raw=0;
            peakamplitude_raw=0;
 %           pp_raw=0;
        end 
        FreqMap(row,column) = freq_raw;
        AmpMap(row,column) = peakamplitude_raw;
        ppMap(row,column) = peakamplitude_raw;
        end
end

%% Plot FreqMap and AmpMap
figure;
imagesc(FreqMap)
%titelstring = sprintf('1D FFT for every Pixel - Dominating Frequency after %g seconds',L*(1/fps));
%title(titelstring)
colorbar;
h = colorbar;
y_label = get(h,'YTickLabel');
mm = repmat(' Hz',size(y_label,1),1);
y_label = [y_label mm];
set(h,'YTickLabel',y_label);
set(h,'fontsize',18);
set(gca,'FontSize',18)


figure;
imagesc(AmpMap)
titelstring = sprintf('1D FFT for every Pixel - Dominating Amplitude after %g seconds',L*(1/fps));
title(titelstring)
h = colorbar;
y_label = get(h,'YTickLabel');
mm = repmat(' mm',size(y_label,1),1);
y_label = [y_label mm];
set(h,'YTickLabel',y_label);


figure;
mesh(FreqMap); 
h = findobj('Type','surface');
set(h,'CData',AmpMap,'FaceColor','texturemap')
title('4D plot of FFT of Total variation and low passed Videodata')
titelstring = sprintf('FFT for every Pixel - Dominating Amplitude (color) and Frequency (z) after %g seconds',L*(1/fps));
title(titelstring)
axis equal;
view([150 30]);
h = colorbar;
y_label = get(h,'YTickLabel');
mm = repmat(' mm',size(y_label,1),1);
y_label = [y_label mm];
set(h,'YTickLabel',y_label);
zlabel('Frequency [Hz]')
zlim([0 fps/2]);

figure;
mesh(AmpMap); 
h = findobj('Type','surface');
titelstring = sprintf('1D FFT for every Pixel - Dominating Amplitude after %g seconds',L*(1/fps));
title(titelstring)
axis equal;
view([150 30]);
h = colorbar;
y_label = get(h,'YTickLabel');
mm = repmat(' mm',size(y_label,1),1);
y_label = [y_label mm];
set(h,'YTickLabel',y_label);
zlabel('Amplitude [mm]')
zlim([0 maxamplitude]);

figure;
mesh(FreqMap); 
titelstring = sprintf('1D FFT for every Pixel - Dominating Frequency after %g seconds',L*(1/fps));
title(titelstring)
axis equal;
view([150 30]);
h = colorbar;
y_label = get(h,'YTickLabel');
hz = repmat(' Hz',size(y_label,1),1);
y_label = [y_label hz];
set(h,'YTickLabel',y_label);
zlabel('Frequency [Hz]')
zlim([0 fps/2]);

figure;
mesh(ppMap); 
titelstring = sprintf('Peak to Peak Value after %g seconds',L*(1/fps));
title(titelstring)
axis equal;
view([150 30]);
h = colorbar;
y_label = get(h,'YTickLabel');
hz = repmat(' mm',size(y_label,1),1);
y_label = [y_label hz];
set(h,'YTickLabel',y_label);
zlabel('Peak to Peak [mm]')
zlim([0 maxamplitude]);

% %% Mean pp in square windows arround marker
% starth = uint16(h_windowmiddle) - windowedge/2;
% startv = uint16(v_windowmiddle) - windowedge/2;

% %% Reset the window
% k=0;
% Ampwindow=0;
% for hrunner = 0 : (windowedge-1) 
%       for vrunner = 0 : (windowedge-1)
%       k=k+1;
%       Ampwindow(k) = AmpMap(startv + vrunner, starth + hrunner);
%       end
% end
% Ampwindowmedian = median(Ampwindow)
% Ampwindowmean = mean(Ampwindow)

figure;
while(1);
    %% User with data cursor input
    subplot(2,2,1);
    datacursormode on;
    imagesc(AmpMap);
    combinedStr = strcat('Vertical: ',num2str(uint16(v)),' Horizontal: ',num2str(uint16(h)));
    title(combinedStr);
    axis on;
    grid on;
    set(gca, 'XColor', 'b');
    set(gca, 'YColor', 'b');
    xlabel('Horizontal');
    ylabel('Vertical');
    [h,v] = ginput(1);
    v=uint16(v)
    h=uint16(h)
    %% Create Dynamic Pixelarray
    for g = 1:L
        k=0;
        for a=1:v_windowlength
            for b=1:h_windowlength
                k=k+1;
                Pixelsector(k) = FramearrayDyn_Raw(v+a,h+b,g) ;                
            end
        end
        DynPixelMean(g)= mean(Pixelsector); 
    end
    DynPixelMean=DynPixelMean-mean(DynPixelMean); %% SURFACE vibrations
%     %% Apply TVD Filter on 1D data
%     zf=TVD_mm(zf,1,20);
   
        %% Apply Lowpass filter
    %%DynPixelMean = filter(Hd,DynPixelMean);

    %% Plot Time Domain with linear interpolation
    subplot(2,2,2);
    plot(t,DynPixelMean);
    title('z(t) of Raw Data');
    xlabel('Time [s]','FontSize',18);
    ylabel('Displacement [mm]','FontSize',18);
    %%axis([0,L*(1/fps),min(DynPixelMean(30:L)),max(DynPixelMean(30:L))]);
    set(gca,'FontSize',18)
    

    subplot(2,2,3);
    %% FFT of pixel sector
    Y = fft(DynPixelMean,NFFT)/(L);
    Y_AmpsDyn = abs(Y(1:NFFT/2+1));
    plot(f,2*Y_AmpsDyn)
    [peakamplitude_pixel, peakindex]= max(2*abs(Y(1:NFFT/2+1)));
    freq_pixelsector = f(peakindex);
    %combinedStr= strcat('Frequency Domain of  ',num2str(h_windowlength),'x',num2str(v_windowlength),' Pixel Sector');
    %title(combinedStr,'FontSize',18);
    xlabel('Frequency [Hz]','FontSize',18);
    ylabel('Amplitude [mm]','FontSize',18);
    set(gca,'FontSize',18) 
    
    %% Plot single-sided amplitude spectrum.
    subplot(2,2,4);
    %% FFT of scope
    plot(f_scope,2*Y_Laser);
    [peakamplitude_scope, peakindex]= max(2*abs(Y_Laser(1:NFFT_scope/2+1)));
    freq_laser = f_scope(peakindex);
    xlim([0 15]);
    title('Frequency Domain of Scope Data');
    xlabel('Frequency [Hz]','FontSize',18);
    ylabel('Amplitude [mm]','FontSize',18);
    set(gca,'FontSize',18) 
    delta_amplitude =  peakamplitude_pixel - peakamplitude_scope
    relative_error = delta_amplitude / peakamplitude_scope
    
    %% Output
    freq_laser
    peakamplitude_scope
    freq_pixelsector
    peakamplitude_pixel

end