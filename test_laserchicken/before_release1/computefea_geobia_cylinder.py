import argparse
import pickle

import numpy as np
import pandas as pd
import time

parser = argparse.ArgumentParser()
parser.add_argument('path_of_laserchicken', help='The path of laserchicken')
parser.add_argument('input', help='absolute path of input point cloud')
parser.add_argument('kdtree', help='absolute path of pkl (pickled kdtree)')
parser.add_argument('output', help='absolute path of output point cloud')
parser.add_argument('radius', help='radius of the volume')
args = parser.parse_args()

import sys
sys.path.insert(0, args.path_of_laserchicken)

from laserchicken import read_las
from laserchicken.keys import point
from laserchicken.volume_specification import InfiniteCylinder
from laserchicken.feature_extractor import compute_features
from laserchicken.write_ply import write

print("------ Feature calculation is started ------")

# Import
pc = read_las.read(args.input)

f = open(args.kdtree, 'rb')
kdtree= pickle.load(f)
f.close()

start1 = time.time()

compute_features(pc, kdtree, 0, pc, ['max_z','min_z','mean_z','median_z','std_z','var_z','range','coeff_var_z','skew_z','kurto_z',
'sigma_z','perc_20','perc_40','perc_60','perc_80','echo_ratio','pulse_penetration_ratio','density_absolute_mean'], InfiniteCylinder(np.float(args.radius)))

"""											   
feadataframe=pd.DataFrame({'_x':pc[point]['x']['data'],'_y':pc[point]['y']['data'],'_z':pc[point]['z']['data'],
                           'max_z':pc[point]['max_z']['data'],'min_z':pc[point]['min_z']['data'], 'mean_z':pc[point]['mean_z']['data'],
                           'median_z':pc[point]['median_z']['data'],'std_z':pc[point]['std_z']['data'], 'var_z':pc[point]['var_z']['data'],
                           'range':pc[point]['range']['data'],'coeff_var_z':pc[point]['coeff_var_z']['data'], 'skew_z':pc[point]['skew_z']['data'],'kurto_z':pc[point]['kurto_z']['data'],
						   'echo_ratio':pc[point]['echo_ratio']['data'],
						   'pulse_penetration_ratio':pc[point]['pulse_penetration_ratio']['data'],'density_absolute_mean':pc[point]['density_absolute_mean']['data'],
                           'sigma_z':pc[point]['sigma_z']['data'], 'perc_20':pc[point]['perc_20']['data'],
                           'perc_40':pc[point]['perc_40']['data'],'perc_60':pc[point]['perc_60']['data'], 'perc_80':pc[point]['perc_80']['data']})

feadataframe.to_csv(args.output,sep=";",index=False)
"""	

end1 = time.time()
difftime1=end1 - start1
print(("feature calc: %f sec") % (difftime1))

write(pc,args.output)




