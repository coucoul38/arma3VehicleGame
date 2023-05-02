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
	
	_playerUnits = units player;
	_bot = _playerUnits select 1;
	
	deleteVehicle vehicle _player;
	
	//CREATE new vehicle
	_vehicleDisplayName = vehiclesList select _playerScore;
	_vehicleClassName = _vehicleDisplayName call fnc_g_findClassname;
	_veh = _vehicleClassName createVehicle _vehPosition;
	_veh lock true;
	
	//MOVE units in vehicle
	_x moveInGunner _veh;
	_bot moveInDriver _veh;
	_veh allowCrewInImmobile true;
	{
		_x disableAI "FSM";
		_x setBehaviour "CARELESS";
	} forEach crew _veh;
};

if(isServer) then {
	vehiclesList = ["M2A3","M1134"];
	activeControls = [];
	control = 2000;
	west setFriend [west, 0];

	
	//spawn 1st vehicle
	{
		_playerUnits = units player;
		_bot = _playerUnits select 1;
		
		//CREATE the vehicle
		_vehicleDisplayName = vehiclesList select 0;
		_vehicleClassName = _vehicleDisplayName call fnc_g_findClassname;
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
			_playerScore = score _x;
			if (_playerScore == 20) then 
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
				hint typeOf(vehicle (_this select 1));
				[control, _this select 0, name(_this select 1), typeOf(vehicle (_this select 1)), (_this select 0)distance(_this select 1)] execVM "killFeed.sqf";};
				call unitKilled;
		}];
		
		//_x addEventHandler ["killed", unitKilled];
	} forEach allUnits;
};
