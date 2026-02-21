# Selecting Multiple Options Experiment

Collaborators: Sumedha Goyal, Kiantè Fernandez, Ian Krajbich

Krajbich Lab - Neuroeconomics and Decision Neuroscience at UCLA

## Overview

This repository contains MATLAB/Psychtoolbox code for a value-based decision-making experiment examining how choice selection size affects decisions, response times, and eye movements. The experiment replicates https://select-multi-options.herokuapp.com/ in a lab setting with EyeLink eye tracking.

Participants complete two phases:

**Phase 1 — Exposure & Rating:** Participants passively view 60 food images (750ms each), then rate each food on a 1–100 scale ("how much would you like this as a daily snack"). Slider initial position is randomized to reduce anchoring.

**Phase 2 — Choice Task:** Participants choose 1, 2, or 3 foods from sets of 4 items arranged in a cross formation. Three blocks of 100 trials each (one per selection size), with block order randomized across participants. The same 4 food items appear on a given trial across all blocks, but spatial positions are shuffled per block. Eye movements are recorded via EyeLink during this phase.

## Requirements

- MATLAB with [Psychtoolbox](http://psychtoolbox.org/) installed
- `images/60foods/` folder containing 60 food stimulus images (item__.jpeg)
- Optional: SR Research EyeLink eye tracker (set `trackEye = 1` in the script to enable)

## Running the Experiment

1. Clone the repository
2. Ensure the `images/60foods/` folder is present with all 60 images
3. Open MATLAB and run `select_multi_options.m`
4. Enter the subject number when prompted

## Data Output

- `Subject_N_Data.mat` — Behavioral data containing:
  - `dataTable`: Food ratings (1–100) and rating response times for all 60 items
  - `choose1Data`: Choose-1 block trials (4 presented image IDs, chosen food, RT)
  - `choose2Data`: Choose-2 block trials (4 presented image IDs, 2 chosen foods, RTs)
  - `choose3Data`: Choose-3 block trials (4 presented image IDs, 3 chosen foods, RTs)
- `SN.edf` — EyeLink data file with raw gaze data and event markers (when eye tracking enabled)
- `eyeData_N.txt` — Tab-separated fixation summary by ROI per trial (when eye tracking enabled)

## Files

- `select_multi_options.m` — Main experiment script
- `images/60foods/` — 60 food stimulus images (item__.jpeg)
