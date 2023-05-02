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
	_units = units group _player;
	_bot = _units select 1;
	
	//DELETE old vehicle
	deleteVehicle vehicle _player;
	//CREATE new vehicle
	_vehicleDisplayName = vehiclesList select (score _player);
	_vehicleClassName = _vehicleDisplayName call fnc_g_findClassname;
	hint _vehicleDisplayName;
	
	_newVehicle = _vehicleClassName createVehicle position _player;
	_newVehicle lock true;
	
	//ENTER new vehicle
	_player moveInGunner _newVehicle;
	_bot moveInDriver _newVehicle;
};



if(isServer) then {
	vehiclesList = ["M2A3","M1134"];
	activeControls = [];
	control = 2000;
	west setFriend [west, 0];
	{
		_x call fnc_c38_changePlayerVehicle;
	}forEach allPlayers;
	
	
	unitKilled = {
			//get the DIRECTION the player is aiming at
			_turretAimPos = eyePos vehicle(_this select 1);
			//hint format["%1, %2, %3", _turretAimPos select 0, _turretAimPos select 1, _turretAimPos select 2];
			
			//Kill all other crew
			{
				_x setDamage 1;
				vehicle _x setDamage 1;
			} forEach units(vehicle(_this select 0));
			
			//_x addPlayerScores [2,0,0,0,0]; //Add 1 kill to the player (2 because killing a friendly is -1 (this is deathmatch, everybody is on the same side))
			_playerScore = score (_this select 1);
			if (_playerScore == 20) then 
			{ 
				"endDM" setDebriefingText ["End of match", name (_this select 1) + " got 20 kills.", "Winner: " + name (_this select 1)]; // overwrites the debriefing text
				"endDM" call BIS_fnc_endMission;
			} else {
				[control, _this select 0, _this select 1] execVM "killFeed.sqf";
				(_this select 1) call fnc_c38_changePlayerVehicle;
			};
	};
	
	{
		
		
		_x addEventHandler ["killed", 
		{		
			if (_this select 0 != _this select 1) then {
				_this call unitKilled;
			};
		}];
		
		//_x addEventHandler ["killed", unitKilled];
	} forEach allUnits;
};
