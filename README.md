# MIT-BIH ECG Analysis with MATLAB

This repository contains a set of **MATLAB** scripts and functions for loading,
visualizing, and analyzing ECG signals from the  
**MIT-BIH Arrhythmia Database**, with support for:

- reading ECG signals and annotations via the **WFDB Toolbox**;
- record selection (e.g., `100`, `101`, …);
- analysis using **sample-based windows**;
- counting total peaks and normal peaks (`N`);
- serving as a baseline for validating QRS/R-peak detection algorithms
  (e.g., Pan–Tompkins, wavelet-based methods, and custom architectures).

The main goals of this project are **reproducibility**, **independence from the
current working directory**, and easy integration with signal-processing and
research pipelines.

---

## Project Structure

```
mitbih-original-read/
├── src/
│ └── load_mitbih_record.m
│ ├── main.m 
│ ├── plot_mitbih_window.m
│ ├── project_root.m
│ └── test.m
├── database/
│ └── (arquivos MIT-BIH: 100.hea, 100.dat, 100.atr, ...)
├── projectVersion
├── requirements.m
└── README.md

```
- `database/`  
  Contains the MIT-BIH dataset (directly or organized in subfolders).
- `src/utils/`  
  Utility functions independent of the MATLAB *Current Folder*.
- `scripts/`  
  Example scripts and experimental code.

---

## Requirements

- MATLAB (R2020b or newer recommended)
- WFDB Toolbox for MATLAB  
  https://github.com/MIT-LCP/wfdb-app-toolbox
- MIT-BIH Arrhythmia Database (PhysioNet)

---

## Loading a Record

Records are loaded directly from the `database/` folder, regardless of the
MATLAB working directory.

```matlab
S = load_mitbih_record('100', 1);   % record 100, channel 1

```

The returned structure contains:

- S.ecg – ECG signal

- S.fs – sampling frequency

- S.annSample – annotated peak sample indices

- S.annType – annotation symbols (N, V, etc.)

- S.record – record identifier

## Sample-Based Window Plotting

Visualization is performed using sample-index windows, which facilitates
localized inspection and algorithm validation.

```
n0 = 1;
n1 = 2000;

plot_mitbih_window_samples(S, n0, n1);
```

## Example Output

``` 
=== MIT-BIH Record 100 ===
Total annotated peaks          : 2274
Total normal peaks (N)         : 2239
---------------------------------
Analyzed window (samples)      : [1 , 2000]
Peaks in window                : 8
Normal peaks in window (N)     : 7

```
