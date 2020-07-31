%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This script describes the workflow to construct PCMs.  Separate
%functions are written to accomplish the different data manipulation and
%simulation tasks.  All low level functions should be contained in the
%folder.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

run matlab_setup.m
%%
%01_data_prep reads in data and creates
%labels used throughout the analysis.  The script saves .mat files with
%data so it doesn't need to be run repeatedly.
data_prep


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Contact Matrices.
%These scripts read in the MixingDataset_HH and calculate the corresponding
%contact matrix for use in the simulation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
varlist=[1]; %references the location of the variable elements in the labels matrix

contact_calc %script calling functions to calculate PCMs; open for options

process_pcm