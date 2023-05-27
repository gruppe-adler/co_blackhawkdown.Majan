init = "(_this select 0) setFlagTexture '\rhsgref\addons\rhsgref_main\data\flag_Insurgents_co.paa'";


_buildings = nearestObjects [[0,0,0], ["Land_jbad_House_c_5_v1","Land_jbad_House_c_1","Land_jbad_House_c_4","Land_jbad_House_c_5_v3","Land_jbad_House_c_12","Land_jbad_House_c_2","Land_jbad_House_c_11","Land_jbad_House_c_1_v2","Land_jbad_House_c_5","Land_jbad_House_c_5_v2","Land_jbad_House_c_3","Land_jbad_House_c_10","jbad_House_c_1", "jbad_House_c_1_v2", "jbad_House_c_10", "jbad_House_c_11", "jbad_House_c_12", "jbad_House_c_2", "jbad_House_c_3", "jbad_House_c_4", "jbad_House_c_5", "jbad_House_c_5_v1", "jbad_House_c_5_v2", "jbad_House_c_9"], 99999];
 
{[_x, "OFF"] remoteexec ["switchLight",0,true]} foreach _buildings;

private _buildings = nearestTerrainObjects [[worldsize/2, worldsize/2], ["house", "static"], worldsize]; 
  
{_x switchlight "OFF"; } foreach _buildings;



{  
 
private "_lamp"; 
_lamp = _x; 
 
{ _lamp setHit [ format [ "Light_%1_hitpoint", _x ], 1 ] } forEach [ 1, 2, 3, 4 ]; 
 
} foreach ( nearestObjects [ player, ["Lamps_base_F", "Land_PowerLine_01_pole_lamp_F"], 20000 ] );