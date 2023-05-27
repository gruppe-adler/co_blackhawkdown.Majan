private _helmets = "rhs_altyn_visordown"; // "rhs_altyn";


private _weldingGung = "hgun_esd_01_F";

arrow = "Sign_Arrow_F" createVehicle [0,0,0]; 


fnc_spark = {

    params ["_posASL", "_surfaceNormal", "_intersectObject"];
    private _duration = 0.01 + random 0.1;
    private _amount = 0.001 + random 0.01;
    private _spark = "#particlesource" createVehicleLocal ASLtoAGL _posASL;
    private _lifetime = 1+(random 0.5);


    _spark setParticleCircle [0, [0, 0, 0]];
    _spark setParticleRandom [1, [0, 0, 0], [0.4, 0.4, -0.3], 0, 0.0025, [0, 0, 0, 0], 0, 0];
    _spark setParticleParams [
        ["\A3\data_f\proxies\muzzle_flash\muzzle_flash_silencer.p3d", 1, 0, 1], "", "SpaceObject",
        1, _lifetime, [0, 0, 0], [0, 0, -0.1], 0, 20, 7.9, 0, 
        [0.3,0.3,0.05], [[1, 1, 1, 1], [1, 0.5, 0.5, 1], [0.5, 0, 0, 0]], [0.08], 1, 0, "", "", _spark,0,true,0.2,[[10,5,5,1]]
    ];
    _spark setDropInterval _amount; 
    sleep _duration;
    deleteVehicle _spark;

};

fnc_destroy = {

    params ["_intersectObject"];

    private _position = getPos _intersectObject;
    
    private _yaw = 0; private _pitch = 45; private _roll = 45; 
    private _vector = [ 
     [sin _yaw * cos _pitch, cos _yaw * cos _pitch, sin _pitch], 
     [[sin _roll, -sin _pitch, cos _roll * cos _pitch], -_yaw] call BIS_fnc_rotateVector2D 
    ]; drop [[getMissionPath "tanktrap_bar2.p3d", 1, 0, 1], "", "SpaceObject", 1, 60, 
        [0, 0, 1], 
        [1, 1, 1], 
        0, 20, 7.9, 0, [1,1], 
        [[0.5,0.5,0.5,0], [0.7,0.7,0.7,0.5], [0.9,0.9,0.9,0]], 
        [0,1,0,1,0,1], 
        0.2, 0.2, "", "", _intersectObject, 0, true, 0.2, [], _vector];

    private _yaw = 45; private _pitch = 135; private _roll = 135; 
    private _vector = [ 
     [sin _yaw * cos _pitch, cos _yaw * cos _pitch, sin _pitch], 
     [[sin _roll, -sin _pitch, cos _roll * cos _pitch], -_yaw] call BIS_fnc_rotateVector2D 
    ]; drop [[getMissionPath "tanktrap_bar2.p3d", 1, 0, 1], "", "SpaceObject", 1, 60, 
        [0, 0, 1], 
        [1, 1, 1], 
        0, 20, 7.9, 0, [1,1], 
        [[0.5,0.5,0.5,0], [0.7,0.7,0.7,0.5], [0.9,0.9,0.9,0]], 
        [0,1,0,1,0,1], 
        0.2, 0.2, "", "", _intersectObject, 0, true, 0.2, [], _vector];

    private _yaw = 90; private _pitch = 270; private _roll = 270; 
    private _vector = [ 
     [sin _yaw * cos _pitch, cos _yaw * cos _pitch, sin _pitch], 
     [[sin _roll, -sin _pitch, cos _roll * cos _pitch], -_yaw] call BIS_fnc_rotateVector2D 
    ]; drop [[getMissionPath "tanktrap_bar2.p3d", 1, 0, 1], "", "SpaceObject", 1, 60, 
        [0, 0, 1], 
        [1, 1, 1], 
        0, 20, 7.9, 0, [1,1], 
        [[0.5,0.5,0.5,0], [0.7,0.7,0.7,0.5], [0.9,0.9,0.9,0]], 
        [0,1,0,1,0,1], 
        0.2, 0.2, "", "", _intersectObject, 0, true, 0.2, [], _vector];

    deleteVehicle _intersectObject;

};

fnc_light = { 
    params ["_posASL", "_surfaceNormal", "_intersectObject", "_finalPoint"]; 
     
    private _lightSource = "#lightpoint" createVehicleLocal ASLtoAGL (_finalPoint); 

    _lightSource setLightColor [1, .5, .8];  
    _lightSource setLightAmbient [1, .8, .9];  
    _lightSource setLightUseFlare true; 
    _lightSource setLightFlareSize (random 1 max 0.5); // in meter 
    _lightSource setLightFlareMaxDistance 100; // in meter 
    _lightSource setLightIntensity (random 10 max 5); 
    _lightSource setLightDayLight true; // only for the light itself, not the flare 
    [{ deleteVehicle _this}, _lightSource, .1] call CBA_fnc_waitAndExecute; 
};


onEachFrame { 

private _eyePos = AGLToASL positionCameraToWorld [0,0,0];
private _endPos = AGLToASL positionCameraToWorld [0,0,2];
 _ins = lineIntersectsSurfaces [ 
  _eyePos, 
  _endPos, 
  player, 
  objNull, 
  true, 
  1, 
  "VIEW", 
  "NONE" 
 ]; 

 if (!isGameFocused) exitWith {};
 if (count _ins == 0) exitWith {}; 
 _ins#0 params ["_posASL", "_surfaceNormal", "_intersectObject"];
 


 if (typeOf _intersectObject == "land_gm_tanktrap_02") then {

     private _direction = _eyePos vectorDiff _posASL;
     _normalizedDirection = vectorNormalized _direction;

     private _distance = 0.1; // Adjust this value as needed
     private _finalPoint = _posASL vectorAdd (_normalizedDirection vectorMultiply _distance);

    [_posASL, _surfaceNormal, _intersectObject] spawn fnc_spark;
    [_posASL, _surfaceNormal, _intersectObject, _finalPoint] call fnc_light;
 };
};