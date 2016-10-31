% DynKinect 0.2  Created by Tobias Augspurger 28.06.2014
% Measure deformation with Kinect 2 @ 424x512 30 fps
close all;clc; clear;

%% Camera Specifications
fps = 30; %Kinect takes 30 pictures per secound
row = 424;
column = 512;

% %%meanbox
% meanrowlow = 50;
% meanrowhigh = 350;
% 
% meancolumnlow = 100;
% meancolumnhigh = 450;


%% Central Mean Box
scaler = 0.2;
meanrowlow = row/2 - row*(scaler/2);
meanrowhigh = row/2 + row*(scaler/2);

meancolumnlow = column/2 - column*(scaler/2);
meancolumnhigh = column/2 + column*(scaler/2);

meanvariance=0;
k=0;
%%
iter = 20;
%%Allocate size and memory
VarMap=zeros(421,509);

%% Cutoff Distance
cutoffdistanceup=3300;
cutoffdistancelow=000;

%% Cutoff Variance
cutoffvariance=100;
% Capture ground truth data
ImageFolder=uigetdir('I:\Masterarbeit_Messdaten\LeinwandStatic','Folder of Static TIFF RAW Data');
tiffFilesS=dir(strcat(ImageFolder,'\*.tiff'));
L=length(tiffFilesS);

for g = 1:L
    Frame = double(imread(strcat(ImageFolder,'\',tiffFilesS(g).name)));
    %Frame = tv(double(imread(strcat(ImageFolder,'\',tiffFilesS(g).name))),iter,0.2,1);
    Framearray(:,:,g) = Frame;
   for a=1:row %%cutoff 3D Data
        for b=1:column
            if Framearray(a,b,g) > cutoffdistanceup || Framearray(a,b,g) < cutoffdistancelow
               Framearray(a,b,g) = NaN;
            end
        end
   end
end

for a = 1:row
    for b = 1:column
        for g= 1:L
            DynPixel(g)= Framearray(uint16(a),uint16(b),g);
        end
    V=var(DynPixel);
    if (a < meanrowhigh && a > meanrowlow) && ( b < meancolumnhigh && b > meancolumnlow )
        k=k+1;
        meanvariance = meanvariance + V;
    end
    if  V > cutoffvariance
        V=0;
    end
    VarMap(a,b) = V;
    end
end
RangeIma = mean(Framearray,3);

figure;
mesh(VarMap);
h = colorbar;
set(h,'fontsize',18);
set(gca,'FontSize',18)
y_label = get(h,'YTickLabel');
hz = repmat(' mm',size(y_label,1),1);
y_label = [y_label hz];
set(h,'YTickLabel',y_label);
zlabel('Variance [mm]')
ylim([0 424]);
xlim([0 512]);
set(gca,'yscale','log')

figure;
imagesc(VarMap);
h = colorbar;
set(h,'fontsize',18);
set(gca,'FontSize',18)
y_label = get(h,'YTickLabel');
hz = repmat(' mm',size(y_label,1),1);
y_label = [y_label hz];
set(h,'YTickLabel',y_label);
zlabel('Variance [mm]')
xlim([42 512]);
%caxis([0 cutoffvariance]);
% xlim([meancolumnlow meancolumnhigh]);
% ylim([meanrowlow meanrowhigh]);

figure;

mesh(RangeIma);
h = colorbar;
set(h,'fontsize',18);
set(gca,'FontSize',18)
y_label = get(h,'YTickLabel');
hz = repmat(' mm',size(y_label,1),1);
y_label = [y_label hz];
set(h,'YTickLabel',y_label);
zlabel('Distance [mm]')

figure;
imagesc(RangeIma);
h = colorbar;
set(h,'fontsize',18);
set(gca,'FontSize',18)
y_label = get(h,'YTickLabel');
hz = repmat(' mm',size(y_label,1),1);
y_label = [y_label hz];
set(h,'YTickLabel',y_label);

meanvariance=meanvariance/k