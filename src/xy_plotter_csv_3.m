%x=Deflection
%x=Angle;
x=Frequency;
% y1=Amp_Kinect;
% y2=Amp_laser;
%y1=Freq_laser;
%y2=Freq_Kinect;
y1=Freq_Kinect
y2=Freq_laser
%y2=Amp_Kinect_left

%%Plot Relativ Error
figure
%plot(x,y1,'b-o',x,y2,'g-o',x,y3,'r-o')
plot(x,y1,'b-o',x,y2,'r-o')
set(gca,'FontSize',18)
%xlim([0.6 2.4])
ylabel('Dominating Frequency f_p [mm]');
xlabel('Frequency Waveform Generator f_{ref}') % label left y-axis
legend('ToF','LDV')
