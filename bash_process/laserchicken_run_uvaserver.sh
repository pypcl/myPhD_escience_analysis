# download the data from WebDAV derive neighborhood based features

passw="$(<D:/Koma/GitHub/passw.txt)"
path_of_laserchicken="D:/Koma/GitHub/eEcoLiDAR/"
path_of_pythonscripts="D:/Koma/GitHub/myPhD_escience_analysis/test_laserchicken/"

localinput="D:/Koma/GitHub/myPhD_escience_analysis/test_data/"

filename=$1
radius=$2
volume=$3

curl --insecure --fail --location --user $passw https://webdav.grid.sara.nl/pnfs/grid.sara.nl/data/projects.nl/eecolidar/01_Work/zsofia/geobia/Results/Data/$filename.las --output $localinput$filename.las 

# kd-tree

python $path_of_pythonscripts/kdtree_geobia_$volume.py $path_of_laserchicken $localinput$filename.las $localinput$filename._$volume$radius.pkl $radius

# feature calculation

python $path_of_pythonscripts/computefea_geobia_$volume.py $path_of_laserchicken $localinput$filename.las $localinput$filename._$volume$radius.pkl $localinput$filename._$volume$radius.ply $radius

echo "--------Upload is started--------"

curl --insecure --fail --location --user $passw --upload-file $localinput$filename._$volume$radius.pkl https://webdav.grid.sara.nl/pnfs/grid.sara.nl/data/projects.nl/eecolidar/01_Work/zsofia/geobia/Results/KdTree/
curl --insecure --fail --location --user $passw --upload-file $localinput$filename._$volume$radius.ply https://webdav.grid.sara.nl/pnfs/grid.sara.nl/data/projects.nl/eecolidar/01_Work/zsofia/geobia/Results/Features/

echo "--------Remove unnecessary files--------"

#rm $localinput*.pkl
#rm $localinput*.las
#rm $localinput*.ply

echo "--------Script is finished--------"
