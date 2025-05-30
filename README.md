# Dps_Nucleoid

[![License: GPL-3.0-or-later](https://img.shields.io/badge/License-GPL%20v3%2B-blue.svg)](./LICENSE)

Matlab / Live Script notebooks, Python utilities, and helper functions used to produce the quantitative microscopy analyses described in  
**McCarthy, Way & Dai *et al.* — “Dps binds and protects DNA in starved *Escherichia coli* with minimal effect on chromosome accessibility, dynamics and organisation.”**

> If you use this code, please cite the paper above **and** link back to this repository.

---

## Repository layout

```text
Dps_Nucleoid/
├── Drift_Correction/                  # Drift correction via fiducial beads
├── Locus_Tracking/                    # DNA-locus tracking & mean-squared-displacement analysis
├── PALM/                              # PALM-based nucleoid reconstruction and occupancy calculations
├── steve's feret diameter/            # Third-party Feret-diameter tools by Steve Eddins (MathWorks) —
│                                       archived here because the original File-Exchange link is no longer accessible
├── Cell_morphology.mlx                # Cell-morphology analysis
├── ExclusionFractionAnalysis.mlx      # Normalized exclusion fraction of probes relative to the nucleoid
├── HeatmapRegionExtraction.mlx        # Extract high-occurrence regions in heatmaps
├── LocalizationHeatMap.mlx            # 2-D localization histogram (heatmap)
├── NucleoidOccupancyAnalysis.mlx      # Nucleoid-occupancy calculations from bulk-staining data
├── Movie2mat.m                        # Convert ND2 movies → .mat files (adapted from SMALL-LABS)
├── anglevec.m                         # Utility: angle between two 2-D vectors
└── LICENSE                            # GPL-3.0-or-later
