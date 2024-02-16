# PLOS-BandwidthScaling

This repository contains the codes and demos for our paper in PLOS Computational Biology (2023): 

[Two stages of bandwidth scaling drives efficient neural coding of natural sounds](https://doi.org/10.1371/journal.pcbi.1005996)

Fengrong He, Ian H. Stevenson, Monty A. Escabi

## Setup 

This is a Matlab project, created in Matlab R2017b. 

Please add the folder "functions" and its subfolders to the path before using.

Please run the demo inside the folder containing: "Example.m".

## Brief Introduction

1. Example.m 

This is a demo code. It uses a speech sound as an example, calculating the modulation power spectrums for three models (Fourier Spectrogram MPS, Cochlear Spectrogram MPS and Midbrain Model MPS) and plotted in the same way as in the paper (Fig. 7). The program also generates and plots the time-varuing auditory midbrain model represenation (midbrainogram) described in the manuscript. 

2. The sounds folder

It has four sound representatives that we used in the paper: one for speech, one for fire sounds, one for water and one for noise. 

3. The functions folder

    **ripplespecstfft.m** calculates the Fourier Spectrogram MPS.

    **ripplespec.m** calculates the Cochlear Spectrogram MPS.

    **ripplespecmidbrain.m** calculates the Midbrain Model MPS.

    **plotMPSContour.m** requires a MPS as input and plots the figure as well as the contour of power concentration. 
    
## Expected Results
- Image for Fourier Spectrogram MPS:

![alt text](https://github.com/EscabiLab/PLOS-BandwidthScaling/blob/e49b42830315cb714a6f44f9705f074808cfc3dc/results/FourierMPS.png)

- Image for Cochlear Spectrogram MPS: 

![alt text](https://github.com/EscabiLab/PLOS-BandwidthScaling/blob/e49b42830315cb714a6f44f9705f074808cfc3dc/results/CochlearMPS.png)

- Image for Midbrain Model MPS:

![alt text](https://github.com/EscabiLab/PLOS-BandwidthScaling/blob/e49b42830315cb714a6f44f9705f074808cfc3dc/results/MidbrainMPS.png)

- Image for Midbrainogram model output:

![alt text](https://github.com/EscabiLab/PLOS-BandwidthScaling/blob/e49b42830315cb714a6f44f9705f074808cfc3dc/results/Midbrainogram.png)


