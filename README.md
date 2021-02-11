# Cycloop

`Cycloop` is the repository containing the MATLAB code that supports the findings of the study 'Automatic synchronisation of the cell cycle in budding yeast through closed-loop feedback control.'


# Repo contents
+ [Computational_Analysis](./Computational_Analysis)
+ [Illustrative_Platform_Code](./Illustrative_Platform_Code)
+ [Simulator](./Simulator)
+ [Supplementary_Data_1](./Supplementary_Data_1)

# System requirements**
## Hardware requirements
`Cycloop` requires only a standard computer with enough RAM to run the code in the MATLAB environment.

## OS requirements
This package is supported for macOS and Windows 10. The package has been tested on the following systems:
+ macOS Catalina
+ Windows 10


## Software dependencies
+ MATLAB R2019a
+ Additional MATLAB toolboxes (e.g. Signal Processing Toolbox, Image Processing Toolbox, etc.)

# Installation guide
1. Download the repository from https://github.com/dibbelab/Cycloop .
2. Unpack the files.
3. Start MATLAB and navigate to the `Cycloop` folder.


# Demo
See the [Instructions for use](#instructions-for-use) section.

# Instructions for use
## Simulator
Set the working directory to `./Simulator/`. 

+ Run the script `main_code.m` to generate the simulations shown in Fig. 3b-e and Fig. 4b-e.
+ Run the script `make_SFIG2_bd.m` to generate the analysis shown in Supplementary Fig. 2b-d.
+ Run the script `make_SFIG2_ce.m` to generate the analysis shown in Supplementary Fig. 2c-e.


## Computational analysis
### Non-cycling strain
Set the working directory to `./Computationa_Analysis/NonCycling/`.

+ Run the script `Main.m` to generate the outputs related to the microfluidics experiments shown in Fig. 2, Fig. 3f-t, Supplementary Fig. 3, Supplementary Fig. 5, and Supplementary Fig. 6.
+ Run the script `make_SuppFig1_abc.m` to generate the outputs related to the microfluidics experiment shown in Fig. 1a-c.
+ Run the script `make_SuppFig1_def.m` to generate the single-cell traces shown in Fig. 1d-f.
+ Run the script `make_SuppFig4.m` to generate the analysis shown in Supplementary Fig. 4.

### Cycling strain
Set the working directory to `./Computationa_Analysis/Cycling/`.
+ Run the script `main_script.m` to generate the outputs related to the microfluidics experiments shown in Supplementary Fig. 7, Fig. 4f-t and Supplementary Fig. 8.
+ Run the script `make_SFIG4.m` to generate the analysis shown in Supplementary Fig. 4.


# License
This code is licensed under the **GNU General Public License v3.0**