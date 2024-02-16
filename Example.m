% Introduction:
%   This is an example for how to use the codes
%   - ripplespecstfft.m for Fourier spectrogram MPS
%   - ripplespec.m for cochlear spectrogram MPS 
%   - ripplespecmidbrain.m for midbrain model MPS
%   - plotMPSContour.m plots the image as well as the contour for a certain power level
%   - midbrainogram.m - generates a time varying midbrainogram represenation   
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

%% Computing Example Midbrainogram - time varying waveforms

%Take 5-sec sound sample segment 
[Y,Fs] = audioread('sounds/Alan-Davis-Drake.mp3');
Y=Y(5*Fs+1:10*Fs);

%First generate cochleogram - use lower spectral resolution (dX=0.1) since it would
%take too long to compute for dX=0.01
dX=0.1;
f1=100;
fN=10000;
Fm=750;
OF=2;
Norm='Amp';
dis='n';
ATT=60;
FiltType='GammaTone';
NLType='rect';
[CochData]=cochleogram(Y,Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT,FiltType,NLType);

%Decompose into modualtion bands and Generate Midbrainogram
beta=[1 1 4 512 0.25 4 1 1];
Sflag='dB';
OF=2;
fc=50;
[MidData]=midbrainogram(CochData,beta,Sflag);
[MidRateData]=midbrainrateogram(MidData,fc,OF);

%% Plotting Midbrainogram - only plotting a select subset of the modulation bands. 
Max=max(max(max(max(MidData.Sm))));
count=1;
faxis=MidData.faxis;
taxis=MidData.taxis;
for k=[10 11 13 15]     %Selected temporal modulation bands to plot
    for l=[1 3 6]       %Selected spectral modualtion bands to plot

        subplot(4,3,count)
        imagesc(log2(faxis/faxis(1)),taxis,MidData.Sm(:,:,l,k))
        caxis([-Max Max]*.25)
        set(gca,'Ydir','normal')
        count=count+1;

    end
end
subplot(4,3,10)
xlabel('Time (s)')
subplot(4,3,7)
ylabel('Freq. (octave above 100 Hz)')

subplot(4,3,1)
title(['RD=' num2str(MidData.RDaxis(1)) ' cycles/oct'])
subplot(4,3,2)
title(['RD=' num2str(MidData.RDaxis(3)) ' cycles/oct'])
subplot(4,3,3)
title(['RD=' num2str(MidData.RDaxis(6)) ' cycles/oct'])

subplot(4,3,1)
ylabel(['Fm=' num2str(MidData.Fmaxis(9)) ' Hz'])
subplot(4,3,4)
ylabel(['Fm=' num2str(MidData.Fmaxis(11)) ' Hz'])
subplot(4,3,7)
ylabel(['Fm=' num2str(MidData.Fmaxis(13)) ' Hz'])
subplot(4,3,10)
ylabel(['Fm=' num2str(MidData.Fmaxis(15)) ' Hz'])


%% Plotting Midbrainrateogram 

% Similar to midbrainogram but contains only the slow rate fluctuations
% limited up to a frquency Fc (50 Hz for example below)
% The detailed temporal fluctuations are removed
Max=max(max(max(max(MidRateData.Sm))));
count=1;
faxis=MidData.faxis;
taxis=MidData.taxis;
for k=[10 11 13 15]  %Selected temporal modulation bands to plot
    for l=[1 3 6]    %Selected spectral modulation bands to plot
    
        subplot(4,3,count)
        imagesc(log2(faxis/faxis(1)),taxis,MidRateData.Sm(:,:,l,k))
        caxis([-Max Max]*.25)
        set(gca,'Ydir','normal')
        count=count+1;

    end
end
subplot(4,3,10)
xlabel('Time (s)')
subplot(4,3,7)
ylabel('Freq. (octave above 100 Hz)')

subplot(4,3,1)
title(['RD=' num2str(MidRateData.RDaxis(1)) ' cycles/oct'])
subplot(4,3,2)
title(['RD=' num2str(MidRateData.RDaxis(3)) ' cycles/oct'])
subplot(4,3,3)
title(['RD=' num2str(MidRateData.RDaxis(6)) ' cycles/oct'])

subplot(4,3,1)
ylabel(['Fm=' num2str(MidRateData.Fmaxis(9)) ' Hz'])
subplot(4,3,4)
ylabel(['Fm=' num2str(MidRateData.Fmaxis(11)) ' Hz'])
subplot(4,3,7)
ylabel(['Fm=' num2str(MidRateData.Fmaxis(13)) ' Hz'])
subplot(4,3,10)
ylabel(['Fm=' num2str(MidRateData.Fmaxis(15)) ' Hz'])




