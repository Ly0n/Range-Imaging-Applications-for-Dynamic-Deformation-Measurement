# Range Imaging Applications for Dynamic Deformation Measurement
Tobias Augspurger
---   
Thanks to all constributors at FH Aachen Aerospace Engineering and FH Düsseldorf.
26. January 2015
---

![alt text](/doc/pictures/PointCloud.png)

---   

![alt text](/doc/pictures/Amp_dis_3D_0_7m.png)
Membrane Surface Amplitude Distribution
## Abstract

Three-dimensional Time-of-Flight (ToF) range cameras improved significantly in accuracy,
speed, price and size over the last years. By delivering the range from the scene to the
image sensor in every pixel, static and dynamic scenes can be reconstructed into a three-
dimensional model contactless from a single point of view. The observed area is illuminated
by infrared diodes and a IR CMOS camera measures the time delay of the returning light .
Out of it the range is acquired parallel with no time delay between the pixels . This offers
the potential for various close to medium range applications. One of this is the measurement
of vibrations and structural deformations under dynamic loads. In contrast to other present
measurement methods, complete surface movements can be acquired in parallel without
a movable laser beam or a complex stereo triangulation between multiple cameras . The
Kinect 2 range camera is used to show the performance of vibration measurements and to
analyze how the range images can be filtered and processed. It is the first ToF camera on
the consumer market and at the time of release the one with the highest number of pixels
(512x424 at 30 frames per seconds). It delivers 3D informations from 0.6 m to 8.0 m at a
depth resolution of 1 mm. A Laser Doppler Vibrometer is used, as high precision reference
measurement device, delivering the highest standard in deformation measurement on a
single surface point. This thesis will prove, that vibrations of a body can be reconstructed
at amplitudes of 4 mm with an accuracy below 1 mm. The performance depends on the
distance to the camera, angle of view, surface material, number of investigated pixels and
the measurement time. At the ideal distance of 1.3 m to 1.5 m, the error to the reference is
reduced down to 0.05 mm after 8 seconds of measurement at a frequency of 3 Hz. Even
the first and second harmonics are visible in the frequency domain on white paper, offering
a high reflectivity for the infrared light of the ToF measurement principle. The influence
on the accuracy of different angles to the surface normal is another topic. A vibration of
3 Hz can be reconstructed correctly in frequency up to an angle of 45 ◦ . The amplitude
is overestimated with higher angles. Since every pixel delivers a range information, the
complete video stream can be processed by a Fast-Fourier Transform to derive the dynamic
behavior of the whole field of view. The vibration can be illustrated in images, representing
the amplitude and frequency distribution in the complete field of view over a certain time span.

Thanks senfi for your latex template:
https://github.com/senfi/Abschlussarbeit-Vorlage

**Please contact me for furher details**
