% Introduction:
%   This is an example for how to use the codes
%   - ripplespecstfft.m for Fourier spectrogram MPS
%   - ripplespec.m for cochlear spectrogram MPS 
%   - ripplespecmidbrain.m for midbrain model MPS
%   - plotMPSContour.m plots the image as well as the contour for a certain power level
%   
%   Some of the parameters used here gives lower resolutions than the paper for fast computation. 
% 
%   Parameters used in the paper: 
%   For ripplespecstfft     : df = 50; dFm = 1; f1 = 100; fN = 10000; UT = 5;
%   For ripplespec          : dX = 0.01; dFm = 0.5; f1 = 100; fN = 10000; Fm = 750; OF = 4;
%   For ripplespecmidbrain  : Qt = 1; Qs = 1; Fml = 1; Fmu = 512; RDl = 0.1; RDu = 4; Dt = 0.25; Ds = 0.1; f1 = 100; fN = 10000; Fm = 512;

%% load data
% This is an example for how to use the functions 
duration = 10; % take 10 seconds sound for example
[Y,Fs] = audioread('sounds/Alan-Davis-Drake.mp3');
data = Y(1:duration*Fs,1);

%% Fourier Spectrogram MPS
df = 50;
dFm = 1;
f1 = 100;
fN = 10000;
UT = 5;
% UT = 5;% FmAxis will be extended to 195 Hz, compatible to RipSpecCochlear
% UT = 15;% FmAxis will be extended to 585 Hz, compatible to RipSpecMidbrain
% UT = 1; % FmAxis goes to 40Hz.
[RipSpecFourier]=ripplespecstfft(data,Fs,df,dFm,f1,fN,UT);
figure;plotMPSContour('RipSpecFourier',RipSpecFourier);
title('Fourier Spectrogram MPS');xlabel('Temporal Modulation (Hz)');ylabel('Spectral Modulation (cyc/kHz)');

%% Cochlear Spectrogram MPS
dX = 0.01;
dFm = 0.5;
f1 = 100;
fN = 10000;
Fm = 750;
OF = 4; % oversampling rate - higher number means higher resolution for FmAxis
[RipSpecCochlear]=ripplespec(data,Fs,dX,dFm,f1,fN,Fm,OF);
figure;plotMPSContour('RipSpecCochlear',RipSpecCochlear);
title('Cochlear Spectrogram MPS');xlabel('Temporal Modulation (Hz)');ylabel('Spectral Modulation (cyc/oct)');

%% Midbrain Model MPS
Qt = 1;
Qs = 1;
Fml = 1;
Fmu = 512;
RDl = 1;
RDu = 4;
Dt = 1;
Ds = 0.5;
f1 = 100;
fN = 8000;
Fm = 750;
[RipSpecMidbrain]=ripplespecmidbrain(data,Qt,Qs,Fml,Fmu,RDl,RDu,Dt,Ds,Fs,f1,fN,Fm);
figure;plotMPSContour('RipSpecMidbrain',RipSpecMidbrain);
title('Midbrain Model MPS');xlabel('Temporal Modulation (Hz)');ylabel('Spectral Modulation (cyc/oct)');
