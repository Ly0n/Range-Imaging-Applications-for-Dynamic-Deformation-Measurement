%plot(Distance,Amp_Kinect,'b--o',Distance,Amp_laser,'g--o',Distance,Freq_Kinect,'b--*',Distance,Freq_laser,'g--*')
%[hAx,hLine1,hLine2] = plotyy(Distance,Amp_Kinect-Amp_laser,Distance, Amp_laser)
%calc relative and absolute error
%x=distance
x=Angle;
%x=Frequency;
% y1=Amp_Kinect;
% y2=Amp_laser;
%y1=Freq_laser;
%y2=Freq_Kinect;
y1=Amp_Kinect_left
y2=Amp_Kinect_right
y3=Amp_Kinect
y4=Amp_laser
%%Plot Relativ Error
figure
%%ab_error_frq=Freq_Kinect - Freq_laser;
%%rel_eroor_frq=ab_error_frq./Freq_laser
%rabs=Amp_Kinect-Amp_laser;
%%rrel=rabs./Amp_laser;
%plot(x,y1,'b--o',x,y2,'g--o')
plot(x,y1,'b-o',x,y2,'g-o',x,y3,'c-o',x,y4,'r-o')
%plot(x,y1,'b--o');
set(gca,'FontSize',22)
%xlim([0.6 2.4])
%title('Mean Raw Filterd Variance over Distance in a 20% Sector in the middle of the image');
%title('Amplitude versus Angle after 3 Seconds');
ylabel('A_p Amplitude [mm]');
xlabel('Angle \alpha [DEG]') % label left y-axis
legend('ToF Left','ToF Right','ToF Middle','LDV')
%figure
%%plot(x,Freq_Kinect,'b--o',x,Freq_laser,'g--o')