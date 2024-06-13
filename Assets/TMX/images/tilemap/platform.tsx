<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.10" tiledversion="1.10.2" name="" tilewidth="64" tileheight="64" tilecount="42" columns="6">
 <properties>
  <property name="bool property" type="bool" value="false"/>
  <property name="float property" type="float" value="56.77"/>
  <property name="int property" type="int" value="12"/>
  <property name="string property" value="shoes"/>
 </properties>
 <image source="tileset.png" trans="ff00ff" width="384" height="448"/>
 <wangsets>
  <wangset name="地形" type="corner" tile="-1">
   <wangcolor name="brown" color="#ff0000" tile="-1" probability="1"/>
   <wangcolor name="green" color="#00ff00" tile="-1" probability="1"/>
   <wangtile tileid="0" wangid="0,1,0,1,0,0,0,0"/>
   <wangtile tileid="22" wangid="0,2,0,0,0,2,0,2"/>
   <wangtile tileid="25" wangid="0,2,0,2,0,0,0,0"/>
   <wangtile tileid="26" wangid="0,0,0,0,0,1,0,1"/>
  </wangset>
 </wangsets>
</tileset>
