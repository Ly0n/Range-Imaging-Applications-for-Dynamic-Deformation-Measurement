
%x=Angle;
%x=Angle;
y1=Amp_Kinect;
y2=Amp_laser;
x=[1 2 3 4 5 6 7 8 9 10]
%y1=Freq_laser;
%y2=Freq_Kinect;
% y1=Amp_Kinect_left
% y2=Amp_Kinect_right
% y3=Amp_Kinect
% y4=Amp_laser
%%Plot Relativ Error
figure
%plot(x,y1,'b-o',x,y2,'g-o',x,y3,'c-o',x,y4,'r-o')
plot(x,y1,'b-o',x,y2,'g-o')
set(gca,'FontSize',18)
%xlim([0.6 2.4])
ylabel('Amplitude [mm]');
xlabel('Frequency f_{ref} [Hz]') % label left y-axis
legend('ToF Left','ToF Right','ToF Middle','LDV')
