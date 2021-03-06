"
@author: Zsofia Koma, UvA
Aim: Create Fig.1. in Bakx et al., 2018 
-- a.) data structure representation of features (area, voxel, object)
-- b.) schematic overview of the integration of LiDAR into SDM workflow (based on Guisan et al.,2017 book page 43)

Input: 
Output: 

Function:

Example usage (from command line):   

ToDo: 
1. 3D plotting rasters and voxels -- the solution is still ugly...

Question:


"
# Run install packages
install.packages(c("sp","rgdal","raster","spatialEco","rgeos","dplyr","XML","maptools","dismo","ggmap","ggplot2","biomod2","rgl","rasterVis","plot3D"))

# Import required libraries
library("sp")
library("rgdal")
library("raster")
library("spatialEco")
library("rgeos")
library("dplyr")
library("XML")

library("maptools")
library("dismo")
library("ggmap")
library("ggplot2")
library("biomod2")

library("lidR")
library("rgl")
library("rasterVis")
library("plot3D")
library("ggspatial")
library("ggsn")

# Set global variables
Rpath=getwd() # set relative path based on github repository
setwd(paste(Rpath,"/birddata2/",sep="")) # set working directory

##################################################################################################################
# A.) Data structure representation of features (area, voxel, object)                                            #
##################################################################################################################

# Import data
las = readLAS("g32hz1rect2.las")

####### Pre-process #######

# ground classification
lasground(las, "pmf", 1, 1)
dtm = grid_terrain(las, method = "knnidw", k = 10L)

plot(dtm,colorPalette = terrain.colors(100),xaxt='n',yaxt='n', ann=FALSE,legend=FALSE)

dtm_r <- rasterFromXYZ(dtm)
writeRaster(dtm_r, filename="dtm_test.tif", format="GTiff", overwrite=TRUE)
plot3D(dtm_r)

# normalization
lasnormalize(las, method = "knnidw", k = 10L)
plot(las,bg="white",size=1.8)
grid3d("x",at = list(x=pretty(seq(min(las@data$X)-1, max(las@data$X)+1, length = 100), n = 10)),col = "black",lwd = 2)
grid3d("y",at = list(y=pretty(seq(min(las@data$Y)-1, max(las@data$Y)+1, length = 100), n = 10)),col = "black",lwd = 2)
grid3d("z",at = list(z=pretty(seq(min(las@data$Z)-1, max(las@data$Z)+1, length = 100), n = 10)),col = "black",lwd = 2)


####### Raster #######

hmax = grid_metrics(las, max(Z),res=1)
plot(hmax,xaxt='n',yaxt='n', ann=FALSE,legend=FALSE)
grid (15,15,lty = 1, col = "black",lwd=3)

hmax_r <- rasterFromXYZ(hmax)
plot3D(hmax_r)

projection(hmax_r) <- "+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.417,50.3319,465.552,-0.398957,0.343988,-1.8774,4.0725 +units=m +no_defs"
writeRaster(hmax_r, filename="hmax_test.tif", format="GTiff", overwrite=TRUE)

####### Voxel #######

hmax_v = grid_metrics3d(las, max(Z),res=1)
plot3d(hmax_v)

####### Object #######

# Watershed

chm = grid_canopy(las, res = 1, subcircle = 2, na.fill = "knnidw", k = 1)
chm = as.raster(chm)
plot(chm)

crowns = lastrees(las, "watershed", chm, th = 0.2, extra = TRUE)
contour = rasterToPolygons(crowns, dissolve = TRUE)

plot(hmax)
plot(contour, add = T,lwd=2)

ttops = tree_detection(hmax, 8, 1)
lastrees_dalponte(las, hmax, ttops)
col = pastel.colors(200)
plot(las, color = "treeID",colorPalette = col)

# Point cloud based

lastrees_li(las)

col = pastel.colors(200)
plot(las, color = "treeID", colorPalette = col,bg="white",size=3)

##################################################################################################################
# B.) schematic overview of the integration of LiDAR into SDM workflow (based on Guisan et al.,2017 book page 43)#
##################################################################################################################

# Create presence only data (coming from digitalization based on exported maximum height layer)

presence=readShapeSpatial("Sim_Birds.shp")
plot(presence,type = 'p', col = 'red', pch=18, cex=3, add=TRUE)

proj4string(presence) <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.417,50.3319,465.552,-0.398957,0.343988,-1.8774,4.0725 +units=m +no_defs")
presense_wgs84 <- spTransform(presence, CRS("+proj=longlat +datum=WGS84"))

ggplot() + geom_osm(type = "osm") + ggspatial::geom_spatial(data=presense_wgs84,col="blue",pch=18, cex=6) + coord_map()
ggplot() + ggspatial::geom_spatial(data=presense_wgs84,col="blue",pch=18, cex=6) + coord_map() + theme(panel.background = element_rect(fill = "grey80", colour = "black", size=2),axis.title.y = element_blank(),
                                                                                                       axis.title.x=element_blank(),axis.text.x=element_blank(),axis.text.y=element_blank())+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) 

# Create layers

hmax = grid_metrics(las, max(Z),res=1)
plot(hmax,xaxt='n',yaxt='n', ann=FALSE,legend=FALSE)

hmax_r <- rasterFromXYZ(hmax)

hsd = grid_metrics(las, sd(Z),res=1)
plot(hsd,xaxt='n',yaxt='n', ann=FALSE,legend=FALSE)

hsd_r <- rasterFromXYZ(hsd)

hmean = grid_metrics(las, mean(Z),res=1)
plot(hmean)

hmean_r <- rasterFromXYZ(hmean)

# stack layers

rasters_stacked <- stack(hmax_r,hsd_r,hmean_r)
plot(rasters_stacked)

pts = extract(rasters_stacked, presence)
pts_dataframe= data.frame(cbind(coordinates(presence),pts,presence@data))
pts_dataframe[is.na(pts_dataframe)] <- 0

# Create prediction

glm_model=glm(id~V1.1+V1.2+V1.3,family="binomial",data=pts_dataframe)
map=predict(rasters_stacked,glm_model,type="response")
plot(map,col=topo.colors(50),xaxt='n',yaxt='n', ann=FALSE,legend=TRUE)

# Create response curves

rp=response.plot2(model=c('glm_model'),Data=pts_dataframe[,c('V1.1','V1.2','V1.3')],show.variables=c('V1.1','V1.2','V1.3'),fixed.var.metric="mean",plot=TRUE,use.formal.names=TRUE)

# Simulate response curves

response_df <- data.frame(data=seq(0,30,1),probability=1/(1+exp(-.5*(seq(0,30,1)-15))))

ggplot(data=response_df , aes(x=data, y=probability)) + geom_line(color="blue", size=3) + scale_color_brewer(palette="Paired") + theme_minimal() + theme(panel.background = element_rect(fill = "white", colour = "white", size=1), axis.title.y = element_blank(),
                                                                                                                                                            axis.title.x=element_blank(),axis.text.x=element_blank(),axis.text.y=element_blank()) + theme(axis.line = element_line(arrow=arrow(),size = 1.5, colour = "black"))

response2_df <- data.frame(data=seq(-4,4,length=200),probability=1/sqrt(2*pi)*exp(-seq(-4,4,length=200)^2/2))

ggplot(data=response2_df , aes(x=data, y=probability)) + geom_line(color="blue", size=3) + scale_color_brewer(palette="Paired") + theme_minimal() + theme(panel.background = element_rect(fill = "white", colour = "white", size=1), axis.title.y = element_blank(),
                                                                                                                                                            axis.title.x=element_blank(),axis.text.x=element_blank(),axis.text.y=element_blank()) + theme(axis.line = element_line(arrow=arrow(),size = 1.5, colour = "black"))

response3_df <- data.frame(data=seq(0,30,1),probability=4*seq(0,30,1)+1)

ggplot(data=response3_df , aes(x=data, y=probability)) + geom_line(color="blue", size=3) + scale_color_brewer(palette="Paired") + theme_minimal() + theme(panel.background = element_rect(fill = "white", colour = "white", size=1), axis.title.y = element_blank(),
                                                                                                                                                           axis.title.x=element_blank(),axis.text.x=element_blank(),axis.text.y=element_blank()) + theme(axis.line = element_line(arrow=arrow(),size = 1.5, colour = "black"))
