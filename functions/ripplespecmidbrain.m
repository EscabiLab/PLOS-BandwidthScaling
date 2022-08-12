%
%function [RipSpec]=ripplespecmidbrain(data,Qt,Qs,Fml,Fmu,RDl,RDu,Dt,Ds,Fs,f1,fN,Fm)
%	
%	FILE NAME 	: ripplespec midbrain
%	DESCRIPTION : Computes the ripple spectrum of a sound for the midbrain model
%                 which contains two steps: a cochleogram of a sound wave and 
%                 the midbrain decomposition of this cochleogram.
%
%	data    : Input data. If data is an array it simply corresponds to the
%             sound waveform samples. If data is a data structure, then the
%             structure is the cochleogram.
%   Qt      : Quality factor for temporal modulation filter bank
%   Qs      : Quality factor for spectral modulation filter bank
%   Fml     : Lowest temporal modulation frequency (Hz)
%   Fmu     : Highest temporal modulation frequency (Hz)
%   RDl     : Lowest spectral modulation frequency (cyc/oct)
%   RDu     : Highest spectral modulation frequency (cyc/oct)
%   Dt      : Resolution of temporal modulation filter bank
%   Ds      : Resolution of spectral modulation filter bank
%
%PARAMETERS FOR COCHLEOGRAM
%
%	Fs		: Sampling Rate
%	f1		: Lower frequency to compute spectral decomposition
%	fN		: Upper freqeuncy to compute spectral decomposition
%	Fm		: Maximum Modulation frequency allowed for temporal
%			  envelope at each band. If Fm==inf full range of Fm is used.
%
%RETURNED VARIABLES
%
%   RipSpec : Output data structure
%               .En         : Modulation Power Spectrum
%               .FmAxis     : Temporal Modulation Frequency Axis
%               .RDAxis     : Ripple Density Axis   
%               .LogFmAxis  : Temporal Modulation Frequency Axis in Log Scale
%               .LogRDAxis  : Ripple Density Axis in Log Scale
%
% (C) Monty A. Escabi, 2022

function [RipSpec]=ripplespecmidbrain(data,Qt,Qs,Fml,Fmu,RDl,RDu,Dt,Ds,Fs,f1,fN,Fm)
%Choosing RipSpecCochlear Parameters
dX=1/2/RDu/4;       %Guarantess that the upper filter satisfies Nyquist
dFm=Fml/4;          %Needed to assure modulation resolution is sufficient for lowest filter
OF = 4;             

%Convert sound to ripplespec Loglinear 
if ~ isstruct(data)
    [RipSpecCochlear]=ripplespec(data,Fs,dX,dFm,f1,fN,Fm,OF);
else
    RipSpecCochlear = data;
end
RSL = RipSpecCochlear.P3;
[ModFiltBank] = ModFiltBankParamGaborAlpha1ns([Qt Qs Fml Fmu RDl RDu Dt Ds]); 

%Convert filter bank to frequency domain (Power!)
[n1,n2] = size(ModFiltBank.F);
En = zeros(n1,n2);
input.RDAxis = RipSpecCochlear.RDAxis;
input.FmAxis = RipSpecCochlear.FmAxis;

for i = 1:n1
    for j = 1:(n2-1)/2+1
        H = mtfgaboralpha1modelns(ModFiltBank.F(i,j).Beta,input);
        En(i,j) =sum(sum(H.^2.*RSL));%1/NFFT1/NFFT2*sum(sum(H.^2.*RSL));
        if ModFiltBank.F(i,j).Beta(2) ~= 0
            En(i,n2+1-j) = sum(sum(fliplr(H).^2.*RSL));%1/NFFT1/NFFT2*sum(sum(fliplr(H).^2.*RSL));
        end
        %Parseval's theorem: sum(sum(x(n).^2))=1/N * sum(sum(x(k).^2))
        clear H;
    end
end

%Saving Results to Data Structure
RipSpec.En = En;
RipSpec.FmAxis=ModFiltBank.Param.FmAxis;
RipSpec.RDAxis=ModFiltBank.Param.RDAxis;
RipSpec.LogFmAxis = ModFiltBank.Param.LogFmAxis;
RipSpec.LogRDAxis = ModFiltBank.Param.LogRDAxis;
