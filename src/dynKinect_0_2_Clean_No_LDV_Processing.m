% DynKinect 0.2  Created by Tobias Augspurger 28.06.2014
% Measure deformation with Kinect 2 @ 424x512 30 fps
close all;clc;
clearvars -except FramearrayDyn FramearrayStatic L;

%% Camera Specifications
fps=30; %Kinect takes 30 pictures per secound
row=424;
column=512;

%% Cutoff Distance
cutoffdistance=8000;

%% Cutoff Amplitude of AmpMap and FreqMap
maxamplitude=33;
minamplitude=0;

% Total Variation Denosing Parameter
iter=20; 
dt=0.2; 
eps=1;
lam=5;

%% Cursor start points
v=2;
h=2;

%Number of pixels in the window edge % Must be even
windowedge=4;

%% Construct a questdlg with three options

choice = questdlg('Would you like to load new raw data or already filtered data from workspace?', ...
	'Data Source', ...
	'Load new data','Data from workspace','Load new data');
% Handle response
switch choice
    case 'Load new data'
        clearvars FramearrayDyn FramearrayGT L;
        

        %% Capture dynamic data
        ImageFolder=uigetdir('C:\Users\cY\Desktop\Masterarbeit\Kinect\DynKinect','Folder of Dynamic TIFF RAW Data');
        tiffFilesS=dir(strcat(ImageFolder,'\*.tiff'));
        L=length(tiffFilesS);
        
    case 'Data from Workspace'
end

%%Allocate size and memory
FreqMap=zeros(421,509);
AmpMap=zeros(421,509);
VarMap=zeros(421,509);
ppMap=zeros(421,509);

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


%% Create Videodata and denoise with TVD
if(~(exist ('FramearrayDyn','var') || exist ('FramearrayGT','var')))
FramearrayDyn=zeros(424,512,L);
for g = 1:L
    Frame=tv(double(imread(strcat(ImageFolder,'\',tiffFilesS(g).name))),iter,dt,eps,lam);
%     Frame=double(imread(strcat(ImageFolder,'\',tiffFilesS(g).name)));
%     FrameGroundtruth=double(imread(strcat(ImageFolderGroundtruth,'\',tiffFilesSGroundtruth(g).name)));
    
    Frame=fliplr(Frame);
    FramearrayDyn(:,:,g) = Frame;
    
   for a=1:424 %%cutoff 3D Data
        for b=1:512
            if FramearrayDyn(a,b,g) > cutoffdistance
               FramearrayDyn(a,b,g) = 0;
            end
        end
   end
end
end
%% FFT on every pixel
for row = 1:424
    for column = 1:512
        for g= 1:L
            DynPixel(g)= FramearrayDyn(uint16(row),uint16(column),g);
        end
        DynPixel=DynPixel-mean(DynPixel);
        z_dyn=DynPixel;
        
        %% Apply Lowpass filter
%        zf = filter(Hd,z_dyn);
%         %%Apply no low pass
          zf=z_dyn;
%         z_staticf=z_static;
        
        %% Draw splines 
%%      zf = interp1(t,zf,tnew,'spline');
        
        %% FFT
        Y = fft(zf,NFFT)/(L);
        Y_AmpsDyn = abs(Y(1:NFFT/2+1));
        Y_AmpsNoiseFree = Y_AmpsDyn; %%- Y_AmpsStatic; %%Filter with noise from static measurement
        Y_AmpsNoiseFree(Y_AmpsNoiseFree<0)=0;
        f = Fs/2*linspace(0,1,NFFT/2+1);
        [peakamplitude, peakindex]= max(4*Y_AmpsNoiseFree);
        freq=f(peakindex);
        y = rmswindow(DynPixel,5,0,0);
        rmsmean = mean(y);
        pp = rmsmean*sqrt(2)*2;
        
        %% Clean Up the Data
        if(peakamplitude>maxamplitude || peakamplitude<minamplitude || freq>Fs/2 || pp>maxamplitude) 
            freq=0;
            peakamplitude=0;
            pp=0;
        end 
        FreqMap(row,column) = freq;
        AmpMap(row,column) = peakamplitude;
        ppMap(row,column) = pp;
    
    end
end

%% Plot FreqMap and AmpMap
figure;
imagesc(FreqMap)
titelstring = sprintf('1D FFT for every Pixel - Dominating Frequency after %g seconds',L*(1/fps));
title(titelstring)
colorbar;

figure;
imagesc(AmpMap)
titelstring = sprintf('1D FFT for every Pixel - Dominating Amplitude after %g seconds',L*(1/fps));
title(titelstring)
colorbar;

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

% figure;
% mesh(AmpMap); 
% h = findobj('Type','surface');
% set(h,'CData',FreqMap,'FaceColor','texturemap')
% title('4D plot of FFT of Total variation and low passed Videodata')
% titelstring = sprintf('FFT for every Pixel - Dominating Amplitude (color) and Frequency (z) after %g seconds',L*(1/fps));
% title(titelstring)
% axis equal;
% view([150 30]);
% h = colorbar;
% ylabel = get(h,'YTickLabel');
% Hz = repmat(' Hz',size(ylabel,1),1);
% ylabel = [ylabel Hz];
% set(h,'YTickLabel',ylabel);
% zlabel('Frequency [Hz]')
% zlim([0 maxamplitude]);

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
    
    %% Create Dynamic Pixelarray
    for g = 1:L
        DynPixel(g)= (FramearrayDyn(uint16(v),uint16(h),g));
    end
    DynPixel=DynPixel-mean(DynPixel); %% SURFACE fibration
    zf=DynPixel;
    
    %Apply Low Pass Filter
    zf = filter(Hd,zf);
   
    %% Plot Time Domain with linear interpolation
    subplot(2,2,2);
    plot(t,zf);
    title('z(t) lowpass & total variation denoising');
    xlabel('Time [s]');
    ylabel('Amplitude [mm]');
    axis([0,L*(1/fps),min(zf(30:L)),max(zf(30:L))]);

    %% Plot single-sided amplitude spectrum.
    subplot(2,2,3);
    
    %% FFT
    Y = fft(zf,NFFT)/(L);
    Y_AmpsDyn = abs(Y(1:NFFT/2+1));
    Y_AmpsNoiseFree = Y_AmpsDyn;
    Y_AmpsNoiseFree(Y_AmpsNoiseFree<0)=0;
    plot(f,4*Y_AmpsNoiseFree)
    [peakamplitude, peakindex]= max(4*abs(Y(1:NFFT/2+1)));
    freq=f(peakindex);
    title('Frequency Domain after total variation denoising ');
    xlabel('Frequency [Hz]');
    ylabel('Amplitude [mm]');
    subplot(2,2,4);
    
    %% Mean pp in square windows arround marker
    starth = uint16(h) - windowedge/2;
    startv = uint16(v) - windowedge/2;
    %% Horizontal lines    
    %% Reset the window
    k=0;
    ppwindow=0;
    for hrunner = 0 : (windowedge-1) 
          for vrunner = 0 : (windowedge-1)
          k=k+1;
          ppwindow(k) = ppMap(startv + vrunner, starth + hrunner);
          end
    end
    ppwindowmedian = median(ppwindow)
    ppwindowmean = mean(ppwindow)
    %% Plot time domain splines instead of straight lines
    vq1 = interp1(t,zf,tnew,'spline');
    plot(tnew,vq1);
    %%plot(t,z)
    title('z(t) Total Variation Denoising, Low Pass and Spline Interpolation');
    xlabel('Time [s]');
    ylabel('Amplitude [mm]');
end