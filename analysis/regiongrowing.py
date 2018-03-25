"""
Aim: 
1. Read the point cloud along with extracted features
2. Make a region growing segmentation (in 2D space)
3. Extract boundaries of the segments

Example of usage:

"""

import sys
import argparse

import numpy as np
import pandas as pd
import geopandas as gpd

import matplotlib.pyplot as plt
import seaborn as sns

#parser = argparse.ArgumentParser()
#parser.add_argument('path', help='where the files are located')
#parser.add_argument('features', help='point cloud with features')
#args = parser.parse_args()

#import sys
#sys.path.insert(0, 'D:/GitHub/eEcoLiDAR/develop-branch/eEcoLiDAR/')
#from laserchicken import read_ply
#pc_wfea = read_ply.read('D:/Results/Geobia/Work/02gz2_merged_kiv1_kivtest._ground_height._cylinder2.5.ply')

#pc_wfea = pd.read_csv(args.path+args.features,sep=' ',names=['X','Y','Z','coeff_var_z','density_absolute_mean','kurto_z','max_z','mean_z',
#'median_z','min_z','perc_20','perc_40','perc_60','perc_80','pulse_penetration_ratio','range','sigma_z','skew_z','std_z','var_z'],skiprows=41)
#print(pc_wfea.dtypes)

"""Use simulation to develop the algorithm"""

from scipy.spatial import cKDTree

df = pd.DataFrame(np.random.randn(50, 3), columns=list('XYD'))
#print(df.head())

points=df.as_matrix(columns=['X','Y'])

seed=df.sample(n=1)
#print(seed)
seed=seed.as_matrix(columns=['X','Y'])

tree = cKDTree(points)
print(tree.query(seed))


	



