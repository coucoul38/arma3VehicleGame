fnc_g_findClassname = {
/*
Note: Feel free to add more classes to watch out for following the pattern

Usage:
(_displayName) call fnc_g_findClassname; //returns className as a string

Example:
"RGO Grenade" call fnc_g_findClassname; //returns "HandGrenade"
*/
private "_findClassname";

_findClassname = "getText (_x >> 'displayName') == _this" configClasses (configFile >> "cfgWeapons");
if (count _findClassname > 0) exitWith {configName (_findClassname select 0)};

_findClassname = "getText (_x >> 'displayName') == _this" configClasses (configFile >> "cfgMagazines");
if (count _findClassname > 0) exitWith {configName (_findClassname select 0)};

_findClassname = "getText (_x >> 'displayName') == _this" configClasses (configFile >> "cfgVehicles");
if (count _findClassname > 0) exitWith {configName (_findClassname select 1)};

_findClassname = format ["Item %1 not found",_this];
_findClassname

};


fnc_c38_changePlayerVehicle = {

	_player = _this;
	_turret = (vehicle _player) unitTurret _player;
	_posTurret = screenToWorld [0.5, 0.5];
	_playerUnits = units player;
	_bot = _playerUnits select 1;
	_bot allowDamage false;
	private _veh = Null;
	
	deleteVehicle vehicle _player;
	
	//CREATE new vehicle
	_vehicleDisplayName = vehiclesList select _playerKills;
	
	//Check if the className is given
	if(isClass (configFile >> "cfgVehicles" >> _vehicleDisplayName)) then 
	{
		_vehicleClassName = _vehicleDisplayName;
		_veh = _vehicleClassName createVehicle position _player;
	} else {
		_vehicleClassName = _vehicleDisplayName call fnc_g_findClassname;
		_veh = _vehicleClassName createVehicle position _player;
	};

	_veh lock true;
	
	//MOVE units in vehicle
	_x moveInGunner _veh;
	_bot moveInDriver _veh;
	_veh allowCrewInImmobile true;
	{
		_x disableAI "FSM";
		_x setBehaviour "CARELESS";
	} forEach crew _veh;
	
	//ROTATE turret
	//_veh lockCameraTo [_posTurret, _veh unitTurret _player, true];
};

if(isServer) then {
	//Sparky_JSDF_Overhaul_gac_JGSDF_AAV
	vehiclesList = ["AAVP7A1","PRACS_FV107","BTR-80","BTR-80A","rhs_bmp1_vdv","Sparky_JSDF_Overhaul_JSDF_JGSDF_Type61","rhsusf_stryker_m1134_d","PRACS_M60A3","Sparky_JSDF_Overhaul_JSDF_JGSDF_Type74","RHS_M2A3","rhs_t72ba_tv","AMF_VBCI_CE_01_F","Type89IFV", "Type87RCV","Sparky_JSDF_Overhaul_JSDF_JGSDF_Type61","B_AMF_TANK_01","M1A1AIM"]; //if a vehicle is not spawning, put its configName instead of its displayName
	activeControls = [];
	control = 2000;
	west setFriend [west, 0];
	west setFriend [resistance, 0];

	
	//spawn 1st vehicle
	{
		_playerUnits = units player;
		_bot = _playerUnits select 1;
		
		//CREATE the vehicle
		_vehicleDisplayName = vehiclesList select 0;
		_vehicleClassName = _vehicleDisplayName call fnc_g_findClassname;
		hint _vehicleClassName;
		_veh = _vehicleClassName createVehicle position _x;
		_veh lock true;
		
		//MOVE units in the vehicle
		_x moveInGunner _veh;
		_bot moveInDriver _veh;
	} forEach allPlayers;
	
	unitKilled = {
		{
			//get the DIRECTION the player is aiming at
			_turretAimPos = eyePos vehicle _x;
			//hint format["%1, %2, %3", _turretAimPos select 0, _turretAimPos select 1, _turretAimPos select 2];
			_vehPosition = position vehicle _x;
			
			//Kill all other crew
			{
				_x setDamage 1;
				vehicle _x setDamage 1;
			} forEach units(vehicle(_this select 0));
			
			//_x addPlayerScores [2,0,0,0,0]; //Add 1 kill to the player (2 because killing a friendly is -1 (this is deathmatch, everybody is on the same side))
			_playerKills = getPlayerScores _x select 0;
			if (_playerKills == 20) then 
			{ 
				"endDM" setDebriefingText ["End of match", name _x + " got 20 kills.", "Winner: " + name _x]; // overwrites the debriefing text
				"endDM" call BIS_fnc_endMission;
			} else {
				_x call fnc_c38_changePlayerVehicle;
			};
		} forEach allPlayers;
	};
	
	{
		
		
		_x addEventHandler ["killed", 
		{		
			if (_this select 0 != _this select 1) then {
				//hint typeOf(vehicle (_this select 1));
				[control, _this select 0, name(_this select 1), typeOf(vehicle (_this select 1)), (_this select 0)distance(_this select 1)] execVM "killFeed.sqf";};
				call unitKilled;
		}];
		
		//_x addEventHandler ["killed", unitKilled];
	} forEach allUnits;
};

/*onEachFrame {
	{
		_beg = ASLToAGL eyePos vehicle _x;
		_endE = (_beg vectorAdd (eyeDirection vehicle _x vectorMultiply 100));
		drawLine3D [ _beg, _endE, [0,1,0,1]];
	}forEach allPlayers;
};*/