function ins_G1500_ant ( fid , dx_dy_dz , ant_orig )
% Insert GprMax3D input file description of GSSI 1.5 GHz antenna
% ant_orig is x,y,z coordinates where antenna should be inserted
% Craig Warren , 04/06/2009
global casedims tx
% Antenna material properties
abs_Er =1.58;
abs_cond =0.428;
f = 1710E6;
Tx_res =4;
Rx_res =925;
% Antenna geometry
casethick =0.002;
shieldthick =0.002;
pcbthick =0.002;
foamsurroundthick =0.003;
skidthick =0.004;
bowtie_base =0.022;
bowtie_height =0.014;
bowtie_thick =0.001;
if dx_dy_dz > 0.001
    bowtie_thick = dx_dy_dz (1);
end
patch_height =0.015;
tx =[ ant_orig (1) +0.114 ant_orig (2) +0.053 ant_orig (3) + skidthick ]; % Coordinates of transmitter
sig_rx =(1/ Rx_res ) *( dx_dy_dz (2) /( dx_dy_dz (1) * dx_dy_dz (3) ) );
% Material definitions
fprintf ( fid ,  '\ n % s \ n \ n ' , ' ****** START GSSI 1.5 GHz antenna model ****** ');
fprintf ( fid , '% s \ n ' , ' --- Antenna materials --- ');
fprintf ( fid , '% s % s \ n ' , '# medium : ' , ' 1.0 0.0 0.0 59.6 E6 1.0 0.0 copper ');
fprintf ( fid , '% s % s % s % s % s \ n ' , '# medium : ' ,sprintf ( ' %3.1 f ' ,abs_Er ) , ' 0.0 0.0 ' ,sprintf ( ' %3.3 f ' , abs_cond ) , ' 1.0 0.0 absorber ');
fprintf ( fid , '% s % s \ n ' , '# medium : ' , ' 3.0 0.0 0.0 0.0 1.0 0.0 foam_surround ');
fprintf ( fid , '% s % s \ n ' , '# medium : ' , ' 3.0 0.0 0.0 0.0 1.0 0.0 pcb ');
fprintf ( fid , '% s % s \ n ' , '# medium : ' , ' 2.35 0.0 0.0 0.0 1.0 0.0 hdpe ');
fprintf ( fid , '% s % s \ n ' , '# medium : ' , ' 2.35 0.0 0.0 0.0 1.0 0.0 case ');
fprintf ( fid , '% s % s % s \ n ' , '# medium : 3.0 0.0 0.0 ' ,num2str ( sig_rx ) , ' 1.0 0.0 res_rx ');
% Antenna geometry
fprintf ( fid , '\ n % s \ n ' , ' --- Antenna geometry --- ');
% Plastic case
fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '# box : ' , num2str ( ant_orig (1) ) , ' ' ,num2str ( ant_orig (2) ) , ' ' , num2str ( ant_orig (3) + skidthick ) , ' ' , ...
    num2str ( ant_orig (1) + casedims (1) ) , ' ' ,num2str ( ant_orig(2) + casedims (2) ) , ' ' ,num2str ( ant_orig (3) + skidthick + casedims (3) ) , ' case ');
fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '#geometry_vtk : ' ,num2str ( ant_orig (1) - dx_dy_dz (1) ) , ' ' ,num2str ( ant_orig (2) - dx_dy_dz (2) ) , ' ' , ...
    num2str ( ant_orig (3) - dx_dy_dz (3) ) , ' ' ,num2str ( ant_orig(1) + casedims (1) + dx_dy_dz (1) ) , ' ' , num2str ( ant_orig(2) + casedims (2) + dx_dy_dz (2) ) , ' ' , ...
    num2str ( ant_orig (3) + skidthick + casedims (3) + dx_dy_dz (3) ), ' ' ,num2str ( dx_dy_dz (1) ) , ' ' ,num2str ( dx_dy_dz (2) ) , ' ' ,num2str ( dx_dy_dz (3) ) , ' G1500_ant n ');
fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '# box : ' , num2str ( ant_orig (1) + casethick ) , ' ' ,num2str ( ant_orig (2) + casethick ) , ' ' ,num2str ( ant_orig (3) + skidthick ) , ...
    ' ' ,num2str ( ant_orig (1) + casedims (1) - casethick ) , ' ' , num2str ( ant_orig (2) + casedims (2) - casethick ) , ' ' , num2str ( ant_orig (3) + skidthick + casedims (3) - casethick) , ...
    ' free_space ') ;
% Copper coated PCB enclosure and absorbers
fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '# box : ' , num2str ( ant_orig (1) +0.025) , ' ' ,num2str ( ant_orig (2) + casethick ) , ' ' ,num2str ( ant_orig (3) + skidthick ) , ...
    ' ' ,num2str ( ant_orig (1) + casedims (1) -0.025) , ' ' ,num2str( ant_orig (2) + casedims (2) - casethick ) , ' ' ,num2str (ant_orig (3) + skidthick +0.027) , ' pec ') ;
fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '# box : ' ,num2str ( ant_orig (1) +0.025+ shieldthick ) , ' ' ,num2str (ant_orig (2) + casethick + shieldthick ) , ' ' , ...
    num2str ( ant_orig (3) + skidthick ) , ' ' ,num2str ( ant_orig (1)+0.025+ shieldthick +0.057) , ' ' ,num2str ( ant_orig (2) + casedims (2) - casethick - shieldthick ) , ' ' , ...
    num2str ( ant_orig (3) + skidthick +0.027 - shieldthick -0.001), ' foam_surround ') ; % Modelling foam around edge of absorber as similar material to pcb
fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '# box : ' , num2str ( ant_orig (1) +0.025+ shieldthick + foamsurroundthick) , ' ' , ...
    num2str ( ant_orig (2) + casethick + shieldthick +foamsurroundthick ) , ' ' ,num2str ( ant_orig (3) + skidthick ) , ' ' ,num2str ( ant_orig (1) +0.025+shieldthick +0.057 - foamsurroundthick ) , ...
    ' ' ,num2str ( ant_orig (2) + casedims (2) - casethick - shieldthick - foamsurroundthick ) , ' ' ,num2str ( ant_orig(3) + skidthick +0.027 - shieldthick ) , ' absorber ') ;
fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '# box : ' ,num2str ( ant_orig (1) +0.086) , ' ' ,num2str ( ant_orig (2) +casethick + shieldthick ) , ' ' , ...
    num2str ( ant_orig (3) + skidthick ) , ' ' ,num2str ( ant_orig (1)+0.086+0.057) , ' ' ,num2str ( ant_orig (2) + casedims (2) -casethick - shieldthick ) , ' ' , ...
    num2str ( ant_orig (3) + skidthick +0.027 - shieldthick -0.001), ' foam_surround ') ; % Modelling foam around edge of absorber as similar material to pcb
fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '# box : ' , num2str ( ant_orig (1) +0.086+ foamsurroundthick ) , ' ' , num2str ( ant_orig (2) + casethick + shieldthick + foamsurroundthick ) , ' ' , ...
    num2str ( ant_orig (3) + skidthick ) , ' ' ,num2str ( ant_orig (1)+0.086+0.057 - foamsurroundthick ) , ' ' ,num2str ( ant_orig (2) + casedims (2) - casethick - shieldthick -foamsurroundthick ) , ...
' ' ,num2str ( ant_orig (3) + skidthick +0.027 - shieldthick ) , ' absorber ') ;
% PCB
fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '# box : ' , num2str ( ant_orig (1) +0.025+ shieldthick + foamsurroundthick) , ' ' , ...
num2str ( ant_orig (2) + casethick + shieldthick +foamsurroundthick ) , ' ' ,num2str ( ant_orig (3) + skidthick ) , ' ' ,num2str ( ant_orig (1) +0.086 - shieldthick - foamsurroundthick ) , ' ' , ...
num2str ( ant_orig (2) + casedims (2) - casethick - shieldthick - foamsurroundthick ) , ' ' ,num2str ( ant_orig (3) +skidthick + pcbthick ) , ' pcb ') ;

fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '# box : ' , ...
num2str ( ant_orig (1) +0.086+ foamsurroundthick ) , ' ' , ...
num2str ( ant_orig (2) + casethick + shieldthick + foamsurroundthick ) , ...
' ' ,num2str ( ant_orig (3) + skidthick ) , ' ' ,num2str (ant_orig (1) +0.086+0.057 - foamsurroundthick ) , ' ' , ...
num2str ( ant_orig (2) + casedims (2) - casethick - shieldthick - foamsurroundthick ) , ' ' ,num2str ( ant_orig (3) + skidthick + pcbthick ) , ' pcb ') ;
% PCB components
% Bowtie Rx
fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '# box : ' , num2str ( ant_orig (1) +0.044) , ' ' ,num2str ( ant_orig (2) +0.024) , ' ' ,num2str ( ant_orig (3) + skidthick ) , ' ' , ...
num2str ( ant_orig (1) +0.044+ bowtie_base ) , ' ' ,num2str (ant_orig (2) +0.024+ patch_height ) , ' ' ,num2str (ant_orig (3) + skidthick + bowtie_thick ) , ' copper ') ;
fprintf ( fid , '% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ' , '# box : ' , num2str ( ant_orig (1) +0.044) , ' ' ,num2str ( ant_orig (2)+0.068) , ' ' , ...
num2str ( ant_orig (3) + skidthick ) , ' ' ,num2str ( ant_orig (1)+0.044+ bowtie_base ) , ' ' ,num2str ( ant_orig (2) +0.068+patch_height ) , ...
' ' ,num2str ( ant_orig (3) + skidthick + bowtie_thick ) , 'copper ') ;
fprintf ( fid , ’% s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s \ n ’
, ’# wedge : ’ ,num2str ( tx (1) -0.059) , ’ ’ ,num2str ( tx (2) ) , ’ ’
,num2str ( tx (3) ) , ’ ’ , ...
num2str ( tx (1) -0.059 - bowtie_base /2) , ’ ’ ,num2str ( tx (2) -
bowtie_height -0.001) , ’ ’ ,num2str ( tx (3) ) , ’ ’ ,num2str
( tx (1) -0.059+ bowtie_base /2) , ’ ’ , ...
num2str ( tx (2) - bowtie_height -0.001) , ’ ’ ,num2str ( tx (3) ) ,
’ ’ ,num2str ( bowtie_thick ) , ’ copper ’) ;
fprintf ( fid , ’% s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s % s \ n ’
, ’# wedge : ’ ,num2str ( tx (1) -0.059) , ’ ’ ,num2str ( tx (2)
+0.001) , ’ ’ ,num2str ( tx (3) ) , ’ ’ , ...
num2str ( tx (1) -0.059 - bowtie_base /2) , ’ ’ ,num2str ( tx (2) +
bowtie_height +0.002) , ’ ’ ,num2str ( tx (3) ) , ’ ’ ,num2str
( tx (1) -0.059+ bowtie_base /2) , ’ ’ , ...
num2str ( tx (2) + bowtie_height +0.002) , ’ ’ ,num2str ( tx (3) ) ,
’ ’ ,num2str ( bowtie_thick ) , ’ copper ’) ;
fprintf ( fid , ’% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ’ , ’# edge : ’ ,
num2str ( tx (1) -0.059) , ’ ’ ,num2str ( tx (2) -0.001) , ’ ’ ,
num2str ( tx (3) ) , ’ ’ , ...
num2str ( tx (1) -0.059) , ’ ’ ,num2str ( tx (2) ) , ’ ’ ,num2str ( tx
(3) ) , ’ copper ’) ;
fprintf ( fid , ’% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ’ , ’# edge : ’ ,
num2str ( tx (1) -0.059) , ’ ’ ,num2str ( tx (2) +0.001) , ’ ’ ,
num2str ( tx (3) ) , ’ ’ , ...
num2str ( tx (1) -0.059) , ’ ’ ,num2str ( tx (2) +0.002) , ’ ’ ,
num2str ( tx (3) ) , ’ copper ’) ;
% Bowtie Tx
fprintf ( fid , ’% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ’ , ’# box : ’ ,
num2str ( ant_orig (1) +0.103) , ’ ’ ,num2str ( ant_orig (2)
+0.024) , ’ ’ ,num2str ( ant_orig (3) + skidthick ) , ’ ’ , ...
num2str ( ant_orig (1) +0.103+ bowtie_base ) , ’ ’ ,num2str (
ant_orig (2) +0.024+ patch_height ) , ’ ’ ,num2str (
ant_orig (3) + skidthick + bowtie_thick ) , ’ copper ’) ;
fprintf ( fid , ’% s % s % s % s % s % s % s % s % s % s % s % s % s \ n ’ , ’# box : ’ ,
num2str ( ant_orig (1) +0.103) , ’ ’ ,num2str ( ant_orig (2)
+0.068) , ’ ’ , ...
num2str ( ant_orig (3) + skidthick ) , ’ ’ ,num2str ( ant_orig (1)
+0.103+ bowtie_base ) , ’ ’ ,num2str ( ant_orig (2) +0.068+
patch_height ) , ...
’ ’ ,num2str ( ant_orig (3) + skidthick + bowtie_thick ) , ’
copper ’) ;



