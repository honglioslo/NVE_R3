#!/bin/bash
# download data at monthly step by web
# download data at daily timestep
mkdir Processed
mkdir Norge
mkdir Done

for i in {1948..2017}
do
   echo "year $i "
   # used in D.A. SACHINDRA et al
   wget "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/shum.2m.gauss."$i".nc"
   wget "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/air.2m.gauss."$i".nc"
   wget "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface/air.sig995."$i".nc"
   wget "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/skt.sfc.gauss."$i".nc"
   wget "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/soilw.0-10cm.gauss."$i".nc"
   wget "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/soilw.10-200cm.gauss."$i".nc"

   # new parameters
   wget "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/prate.sfc.gauss."$i".nc"
   wget "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/pevpr.sfc.gauss."$i".nc"
   wget "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.dailyavgs/surface_gauss/runof.sfc.gauss."$i".nc"
done

## calculate monthly of these daily data

temp=$(ls *2000*.nc)
variables=$(echo $temp | sed -r "s/.2000.nc//g")
for iV in $variables
do
  echo $iV
  file_list=$(ls *$iV*)
  for ifile in $file_list
  do
    cdo sellonlatbox,2,34,55,74 $ifile Norge_$ifile
    if [ "$?" -eq 0 ]; then
      mv Norge_$ifile Norge
      mv $ifile processed
    fi
  done
done

# data from 2015 to 2017 has generic grid due to another variable time_band, select used variable and merge
fileN="air.2m.gauss."
varN="air"

fileN="air.sig995."
varN="air"

fileN="shum.2m.gauss."
varN="shum"

fileN="skt.sfc.gauss."
varN="skt"

fileN="soilw.0-10cm.gauss."
varN="soilw"

fileN="soilw.10-200cm.gauss."
varN="soilw"

fileN="pevpr.sfc.gauss."
varN="pevpr"

fileN="prate.sfc.gauss."
varN="prate"

fileN="runof.sfc.gauss."
varN="runof"


for i in {2014..2017}
do
cdo selvar,$varN $fileN$i".nc" selvar.nc
mv $fileN$i".nc" processed
cdo sellonlatbox,2,34,55,74 selvar.nc "Norge_"$fileN$i".nc"
mv "Norge_"$fileN$i".nc" Norge
rm selvar.nc
done
# merge time series
cd Norge
temp=$(ls *2000*.nc)
variables=$(echo $temp | sed -r "s/.2000.nc//g")
variables=$(echo $variables | sed -r "s/Norge_//g")
#variables="pevpr.sfc.gauss prate.sfc.gauss runof.sfc.gauss"
for iV in $variables
do
  echo $iV
  file_list=$(ls *$iV*)
  export SKIP_SAME_TIME=1
  cdo mergetime $file_list $iV".nc"
done

# get monthly mean and move to Done
temp=$(ls *2000*.nc)
variables=$(echo $temp | sed -r "s/.2000.nc//g")
variables=$(echo $variables | sed -r "s/Norge_//g")
for iV in $variables
do
  echo $iV
  cdo monmean $iV".nc" $iV".mon.mean.nc"
  if [ "$?" -eq 0 ]; then
     mv $iV".mon.mean.nc" ../Done
  fi
done

# select the monthly timestep data at the Norge region
fileN="hgt.mon.mean.nc rhum.mon.mean.nc shum.mon.mean.nc air.mon.mean.nc pres.mon.mean.nc slp.mon.mean.nc"
for ifile in $fileN
do
   cdo sellonlatbox,2,34,55,74 $ifile Norge_$ifile
   if [ "$?" -eq 0 ]; then
      cp Norge_$ifile Norge
      mv $ifile processed
      mv Norge_$ifile Done/$ifile
   fi
done



