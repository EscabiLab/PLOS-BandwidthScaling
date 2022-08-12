# PLOS-BandwidthScaling

This repository contains the codes and demos for our paper: 

[Two stages of bandwidth scaling drives efficient neural coding of natural sounds](https://www.biorxiv.org/content/10.1101/2022.04.12.488076v1)

Fengrong He, Ian H. Stevenson, Monty A. Escabi

## Setup 

This is a Matlab based project, tested in Matlab R2017b and higher. 

All necessary codes are included, please add the folder "functions" and its subfolders to the path before use.

Please run the demo in the folder containing: "Example.m".

## Brief Introduction

1. Example.m 

This is a demo code. It uses a speech sound as an example, calculating the modulation power spectrum for three models (Fourier Spectrogram MPS, Cochlear Spectrogram MPS and Midbrain Model MPS) and plotted in the same way as in the paper (Fig. 7) 

2. The sounds folder

It has four sound representatives that we used in the paper: one for speech, one for fire sounds, one for water and one for noise. 

3. The functions folder

    **ripplespecstfft.m** calculates the Fourier Spectrogram MPS.

    **ripplespec.m** calculates the Cochlear Spectrogram MPS.

    **ripplespecmidbrain.m** calculates the Midbrain Model MPS.

    **plotMPSContour.m** requires a MPS as input and plots the figure as well as the contour of power concentration. 
    
## Expected Results


