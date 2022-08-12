%
%function [CochData]=cochleogram(data,Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT,FiltType,BWType,NLType,ModFiltType)
%	
%	FILE NAME 	: COCHLEOGRAN
%	DESCRIPTION : Spectro-temporal signal representation obtained 
%                 by applying a octave spaced filterbank and
%                 extracting envelope modulation signal. Uses critical
%                 bandwidth Gamma tone filters for the auditory
%                 model decomposition.
%
%   data        : Input data
%   Fs          : Sampling Rate
%   dX          : Spectral separation betwen adjacent filters in octaves
%                 Usually a fraction of an octave ~ 1/8 would allow 
%                 for a spectral envelope resolution of up to 4 
%                 cycles per octave
%                 Note that X=log2(f/f1) as defined for the ripple 
%                 representation 
%   f1          : Lower frequency to compute spectral decomposition
%   fN          : Upper freqeuncy to compute spectral decomposition
%   Fm          : Maximum Modulation frequency allowed for temporal
%                 envelope at each band. If Fm==inf full range of Fm is used.
%   OF          : Oversampling Factor for temporal envelope
%                 Since the maximum frequency of the envelope is 
%                 Fm, the Nyquist Frequency is 2*Fm
%                 The Frequency used to sample the envelope is 
%                 2*Fm*OF
%   Norm        : Amplitude normalization (Optional)
%                 En:  Equal Energy 
%                 Amp: Equal Amplitude (Default)
%   dis         : display (optional): 'log' or 'lin' or 'n'
%                 Default == 'n'
%   ATT         : Attenution / Sidelobe error in dB (Optional) for modulation
%                 lowpass filter. Also used for BSpline filters when using
%                 BSpline option below
%                 Default == 60 dB
%   FiltType    : Type of filter to use (Optional): 'GammaTone' or 'BSpline'
%                 Default == 'GammaTone'
%   BWType      : Bandwidth option - either critical band ('cb') or
%                 Equivalent Rectangular Bandwidth ('erb')
%                 Defaul == 'erb'
%   NLType      : Nonlinearity type - either Hilbert transform ('hil') or
%                 linear rectification ('rect') - Default = 'hil'
%   ModFiltType : Modualtion lowpass filter type - either a transitional
%                 windowed filter ('win', Roark and Escabi 1999) or a time-domain
%                 b-spline filter ('bspline') - Default=='win'
%
%RETURNED VARIABLES
%
%   CochData : Data structure containing cochleogram results
%             .taxis        : Time axis
%             .faxis        : Frequency axis
%             .S            : Cochleogram
%             .SdB          : Cochleogram in dB - normalized for zero mean 
%             .Sc           : Cochleogram corrected for group delays. Filter 
%                             group delays are removed from the filterbank.
%             .ScdB         : Cochleogram corrected for group delays in dB. 
%                             Filter group delays are removed from the 
%                             filterbank. Normalized for zero mean.
%             .Sf           : Spectral Envelope Distribution
%             .NormGain     : Power gain between Energy and Amplitude
%                             normalization. This allows you convert 
%                             between either output by simply multiplying
%                             by the gain. Note that:
%
%                             Norm Gain = 'Amp' Normalization Power / 'En' 
%                             Normalization Power
%
%             .Filter.H     : Data structure array containing the impulse
%                             responses (.H) of the gamma tone filters used 
%                             for the filterbank decomposition.
%             .GroupDelay   : Estimated group delays for each filter. Used 
%                             to correct the cochleogram by removing the 
%                             filter delays.
%             .BW           : Bandwidths for filterbank
%             .Param        : Contains all of the input parameters
%
% (C) Monty A. Escabi, January 2008 (Edit June 2009, May/Sept 2016 , 2019 MAE/FH)
%
function [CochData]=cochleogram(data,Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT,FiltType,BWType,NLType,ModFiltType)

%Input Parameters
if nargin<8 | isempty(Norm)
    Norm='Amp';         %MAE, May 2018
end
if nargin<9 | isempty(dis)
	dis='n';
end
if nargin<10 | isempty(ATT)
	ATT=60;
end
if nargin<11 | isempty(FiltType)
   FiltType='GammaTone'; 
end
if nargin<12 | isempty(BWType)  %Added ERB as default, March 2019
    BWType='erb';
end
if nargin<13 | isempty(NLType)
    NLType='hil';               %Added linear rectification option - Aug 31, 2021, MAE
end
if nargin<14 | isempty(ModFiltType)
    ModFiltType='win';          %Added modulation bspline filter option - Aug 31, 2021, MAE
end

%Finding frequency axis for chromatically spaced filter bank
%Note that chromatic spacing requires : f(k) = f(k+1) * 2^dX
X1=0;
XN=log2(fN/f1);
L=floor(XN/dX);
Xc=(.5:L-.5)/L*XN;
fc=f1*2.^Xc;

%Finding filter characterisitic frequencies according to Greenwood
%[fc]=greenwoodfc(20,20000,.1);

%Finding filter bandwidhts assuming 1 critical band or ERB scale
if strcmp(BWType,'erb')
    BW=erb(fc);
else
    BW=criticalbandwidth(fc);
end

%Temporal Down Sampling Factor
DF=max(ceil(Fs/2/Fm/OF),1);

%Designing Low Pass Filter for Extracting Envelope
if strcmp(ModFiltType,'win')
    He=lowpass(Fm,.25*Fm,Fs,ATT,'n');    %b-spline transitional windowed filter - in frequency domain - similar to kaiser (Roark and Escabi 1999)
else
    He=bsplinelowpass(Fm,20,Fs);         %20-th order b-spline filter - i.e., b-spline in time domain - Added August 2021 - MAE
    He=He/sum(He);
end
Ne=(length(He)-1)/2;

%Generating Filters 
if strcmp(FiltType,'BSpline')       %Added B-Spline filter option
    for k=1:length(fc)
        Disp='n';
        f1b=fc(k)-BW(k)/2;          %Corrected f1 so that it does not get overwritten - MAE Feb. 2022
        f2b=fc(k)+BW(k)/2;          
        TW=BW(k)*.10;    %Choose 10% of BW for TW
        [Filter(k).H] = bandpass(f1b,f2b,TW,Fs,ATT,Disp);
        N(k)=(length(Filter(k).H)-1)/2;
    end
else    %Default filtertype option, Gamma Tone filters
    for k=1:length(fc)
        [Filter(k).H]=gammatonefilter(3,BW(k),fc(k),Fs);
        N(k)=(length(Filter(k).H)-1)/2;
    end
end

%Finding Group Delays
for k=1:length(Filter)   
    P=(Filter(k).H).^2/sum((Filter(k).H).^2);
    t=(1:length(Filter(k).H))/Fs;
    GroupDelay(k)=sum(P.*t);
end

%FFT Size
NFFT=2 ^ nextpow2( length(data) + max(N)*2+1 +Ne*2+1);

%Filtering data, Extracting Envelope, and Down-Sampling
Ndata=length(data);
for k=1:length(fc)

	%Output Display
	clc,disp(['Filtering band ' int2str(k) ' of ' int2str(length(fc))]) 

    %Filter
    H=Filter(k).H;
    Hen=H/sqrt(sum(H.^2));
    NormGain(k)=sqrt(sum(H.^2))/sqrt(sum(Hen.^2));
    if strcmp(Norm,'En')        %Edit Nov 2008, Escabi
        H=Hen;                  %Equal Energy
    end
        
	%Filtering at kth Scale
	Y=convfft(data',H,0,NFFT,'y');      %Changed delayed from N(k) to zero
     
    %Spectral Amplitude Distribution
    %Sf(k)=std(Y);
    
	%Finding Envelope Using the Hilbert Transform or Linear rectification
    if strcmp(NLType,'hil')
        Y=abs(hilbert(Y));  %Hilbert Envelope
    else
        Y=max(0,Y);         %Linear rectification
    end

	%Filtering The Envelope and Downsampling
    if Fm~=inf
        Y=max(0,convfft(Y,He,Ne));      %Remove (-) values which are due to filtering
    end
    
	%Downsampling Envelope
    S(k,:)=Y(1:DF:Ndata);
    
    %Downsampling Envelope and Correcting for Group Delay
    NMax=round(max(GroupDelay*Fs));
    Ndelay=round(GroupDelay(k)*Fs)+1;
    Sc(k,:)=Y(Ndelay:DF:Ndata-NMax+Ndelay-1);
    
    %Spectral Envelope Distribution
    %Sf(k)=sqrt(mean(Y.^2));
    Sf(k)=mean(S(k,:));
    
end
taxis=(0:size(S,2)-1)/(Fs/DF);
faxis=fc;

%dB Cochleograms
SdB=20*log10(S);
i=find(~isinf(SdB));
MindB=min(SdB(i));
i=find(isinf(SdB));
SdB(i)=MindB*ones(size(SdB(i)));                %Remove values with -Inf - i.e., note that when S == 0 -> SdB=-Inf
SdB=SdB-mean(mean(SdB));                        %Subtract Mean Value

%dB Cochleogram - corrected for group delay
ScdB=20*log10(Sc);
i=find(~isinf(ScdB));
MindB=min(ScdB(i));
i=find(isinf(ScdB));
ScdB(i)=MindB*ones(size(ScdB(i)));                %Remove values with -Inf - i.e., note that when S == 0 -> SdB=-Inf

%Storing as data structure
CochData.S=S;
CochData.SdB=SdB;
CochData.Sc=Sc;
CochData.ScdB=ScdB;
CochData.Sf=Sf;
CochData.taxis=taxis;
CochData.faxis=faxis;
CochData.Norm=Norm;
CochData.NormGain=NormGain;
CochData.Filter=Filter;
CochData.GroupDelay=GroupDelay;
CochData.BW=BW;                  %MAE, May 2016

%Storing Input Paramaters
CochData.Param.Fs=Fs;
CochData.Param.dX=dX;
CochData.Param.f1=f1;
CochData.Param.fN=fN;
CochData.Param.Fm=Fm;
CochData.Param.OF=OF;
CochData.Param.DF=DF;
CochData.Param.Norm=Norm;
CochData.Param.ATT=ATT;
CochData.Param.FiltType=FiltType;
CochData.Param.BWType=BWType;
CochData.Param.NLType=NLType;
CochData.Param.ModFiltType=ModFiltType;