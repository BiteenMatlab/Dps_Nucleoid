The folder needs to be organized in this way for proper loading
--Strain_1
    --Condition_1
        --rep1
            --re1_movie1            # make sure phase and fluorescence channel from 'rep1_movie1' in same subfolder
                --StrainName_condition_rep1_movie1_GFP.nd2               # movie from fluorescence chanel
                --StrainName_condition_rep1_movie1_phase.tif             # movie from phase contrast chanel
            --rep1_movie2

1) Run ImageProcess.mlx     --> get 'Tracks_all'    
    (all  all video in the main folder will be analyzed)
    Correct drift by cross correlation of selected region from phase contrast image
    Cell segmentation by Omnipose (configurate python environment 'omnipose' first)
    Seperate movies into smaller regions (solves RAM bottleneck for large ROIs, for exmaple 2048X2048)
    Tracking analysis by SMALL-LABS
    
2) Run Filter_and_TrajOrg.mlx
    (input folder by Rep, it will analyze each movie from input folder)
    Filter by cell morphology
    Filter by locus number, locus position and locus circularity
    Convert units (frame -> s; pixel -> um)
    Remove outliers (steps with unreasonable displacement, frame indexes not countinuesly increase)

3) Run MSD.mlx      --> get diffusion coefficient and anomalous diffusion exponent
    (input folder by Rep, it will perform MSD analysis for trajactories from selected replicate)
    We used A MATLAB class for Mean Square Displacement analysis from the paper below (alos cited in our manuscript)
        ''Nadine Tarantino, Jean-Yves Tinevez, Elizabeth Faris Crowell, Bertrand Boisson, Ricardo Henriques, 
        Musa Mhlanga, Fabrice Agou, Alain Israël, and Emmanuel Laplantine. TNF and IL-1 exhibit distinct 
        ubiquitin requirements for inducing NEMO-IKK supramolecular structures. J Cell Biol (2014) vol. 204 (2) pp. 231-45''
    You can find the discription of this class from this link:
        ''https://tinevez.github.io/msdanalyzer/'
    Plot single and ensemble MSD curve
    Calculate diffusion coefficient and anomalous diffusion exponent from each trajectory
    Get the distributions and plot the histograms

4) Run Confine_measure.mlx      --> Measure the confinement of locus trajectory
    Calcualte 'Radius of Gyration', 'Confined Area', 'Confine Index', and 'First Passage Time'
    