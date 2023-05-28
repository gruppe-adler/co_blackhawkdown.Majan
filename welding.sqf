private _helmets = "rhs_altyn_visordown"; // "rhs_altyn";
private _weldingGung = "hgun_esd_01_F";
private _grinderType = "Land_Grinder_F";

grinder = _grinderType createVehicle [0,0,0];
grinder attachTo [player, [0,.1,0], "lefthand", true]; 
grinder setVectorDirAndUp  [[1,0,1], [1,0,0]];

arrow = "Sign_Arrow_F" createVehicle [0,0,0]; 

fnc_grindActivateLocal = {
    params ["_identifier"];

    private _data = missionNameSpace getVariable [_identifier, [[0,0,0], [0,0,0], objNull, [0,0,0]]];
    waitUntil {count _data > 0};

    [{
        params ["_args", "_handle"];
        _args params ["_identifier"];
        
        if (!isGameFocused) exitWith {};

        private _data = missionNameSpace getVariable [_identifier, [[0,0,0], [0,0,0], objNull, [0,0,0]]];
        _data params ["_posASL", "_surfaceNormal", "_intersectObject", "_finalPoint"]; 

        if (count _data < 1) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        if (isNull _intersectObject) exitWith {};

        [_posASL, _surfaceNormal, _intersectObject] spawn fnc_spark;
        [_posASL, _surfaceNormal, _intersectObject, _finalPoint] call fnc_light;
       
    }, 0, [_identifier]] call CBA_fnc_addPerFrameHandler;
};


fnc_grinderActivate = {
    player setVariable ["grad_grinder_active", true, true];

    private _identifier = format ["grad_grinder_%1_%2", position player, CBA_missionTime];
    [_identifier] remoteExec ["fnc_grindActivateLocal"];

    [{
        params ["_args", "_handle"];
        _args params ["_identifier"];
        
        if (!(player getVariable ["grad_grinder_active", false])) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
            missionNameSpace setVariable [_identifier, [], true]; // remove framehandler from clients
        };

        if (isNull (player getVariable ["grad_grinder_sound", objNull])) then {
            private _sound = player say3d "Spawn";
            player setVariable ["grad_grinder_sound", _sound];
        };
        

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

            private _healthPerFrame = 0.01;
            private _health = _intersectObject getVariable ["grad_grinder_tanktrap_health", 1];
            private _newHealth = _health - _healthPerFrame;
            systemChat str _newHealth;
            _intersectObject setVariable ["grad_grinder_tanktrap_health", _newHealth];

            if (_newHealth < 0.1) exitWith {
                
                [_intersectObject] call fnc_destroy;
                [_handle] call CBA_fnc_removePerFrameHandler;
                missionNameSpace setVariable [_identifier, [], true]; 
            };

            private _direction = _eyePos vectorDiff _posASL;
            _normalizedDirection = vectorNormalized _direction;

            private _distance = 0.1; // Adjust this value as needed
            private _finalPoint = _posASL vectorAdd (_normalizedDirection vectorMultiply _distance);

            missionNameSpace setVariable [_identifier, [_posASL, _surfaceNormal, _intersectObject, _finalPoint], true];
        } else {
            missionNameSpace setVariable [_identifier, [[0,0,0], [0,0,0], objNull, [0,0,0]], true];
        };
    }, 0, [_identifier]] call CBA_fnc_addPerFrameHandler;
};


addUserActionEventHandler ["DefaultAction", "Activate", { 
    if (currentWeapon player == "hgun_esd_01_F" && !(player getVariable ["grad_grinder_active", false])) then {
        call fnc_grinderActivate;
    };
}];

// deactivate grinder
addUserActionEventHandler ["DefaultAction", "Deactivate", { 
    if (player getVariable ["grad_grinder_active", false]) then {
        player setVariable ["grad_grinder_active", false, true];
    };    
}];

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
    
    private _yaw = getDir cursorObject + 100; private _pitch = 300; private _roll = 330;  
    private _vector = [  
     [sin _yaw * cos _pitch, cos _yaw * cos _pitch, sin _pitch],  
     [[sin _roll, -sin _pitch, cos _roll * cos _pitch], -_yaw] call BIS_fnc_rotateVector2D  
    ]; drop [[getMissionPath "tanktrap_bar2.p3d", 1, 0, 1], "", "SpaceObject", 1, 60,  
        [-.3, -.2, 1],  
        [0, 0, 1],  
        0.1, 20, 7.9, 0, [1,1],  
        [[0.5,0.5,0.5,0], [0.7,0.7,0.7,0.5], [0.9,0.9,0.9,0]],  
        [0,1,0,1,0,1],  
        0.2, 0.2, "", "", _intersectObject, 0, true, 0.2, [], _vector];

    private _yaw = getDir cursorObject + 220; private _pitch = -10; private _roll = 45;  
    private _vector = [  
     [sin _yaw * cos _pitch, cos _yaw * cos _pitch, sin _pitch],  
     [[sin _roll, -sin _pitch, cos _roll * cos _pitch], -_yaw] call BIS_fnc_rotateVector2D  
    ]; drop [[getMissionPath "tanktrap_bar2.p3d", 1, 0, 1], "", "SpaceObject", 1, 60,  
        [-.4, .5, .4],  
        [0, 0, 1],  
        0.1, 20, 7.9, 0, [1,1],  
        [[0.5,0.5,0.5,0], [0.7,0.7,0.7,0.5], [0.9,0.9,0.9,0]],  
        [0,1,0,1,0,1],  
        0.2, 0.2, "", "", _intersectObject, 0, true, 0.2, [], _vector];

    private _yaw = getDir cursorObject + 350; private _pitch = -10; private _roll = 45;  
    private _vector = [  
     [sin _yaw * cos _pitch, cos _yaw * cos _pitch, sin _pitch],  
     [[sin _roll, -sin _pitch, cos _roll * cos _pitch], -_yaw] call BIS_fnc_rotateVector2D  
    ]; drop [[getMissionPath "tanktrap_bar2.p3d", 1, 0, 1], "", "SpaceObject", 1, 60,  
        [.3, -.20, .25],  
        [0, 0, 1],  
        0.1, 20, 7.9, 0, [1,1],  
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
    _lightSource setLightIntensity (random 200 max 100); 
    _lightSource setLightDayLight true; // only for the light itself, not the flare 
    [{ deleteVehicle _this}, _lightSource, .1] call CBA_fnc_waitAndExecute; 
};

/*
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
*/