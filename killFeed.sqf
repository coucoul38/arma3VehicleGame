
disableSerialization;

private _escapeXML = // replaces special characters in player names by their XML counterpart to not break the code
{
	_this
	regexReplace ["&", "&amp;"]
	regexReplace ["<", "&lt;"]
	regexReplace [">", "&gt;"]
	regexReplace ['"', "&quot;"]
	regexReplace ["'", "&apos;"]
};


_control = _this select 0;
_unit = _this select 1;
_unitName = name _unit call _escapeXML;
_killerName = (_this select 2) call _escapeXML;
_vehicle = _this select 3;
_vehicleName = getText(configFile >> "CfgVehicles" >> _vehicle >> "displayName");
_distance = _this select 4;

{
	_ctrl = (findDisplay 46) displayCtrl _x;
	
	_pos = ctrlPosition _ctrl;
	_pos set [1, (_pos select 1) + 0.045];
	
	_ctrl ctrlSetPosition _pos;
	
	_ctrl ctrlCommit 0.25;
} forEach activeControls;

UISleep 0.25;

_ctrl =  (findDisplay 46) ctrlCreate ["RscStructuredText", _control];

_ctrl ctrlSetPosition [-0.7, -0.4, 1, 0.1];
_ctrl ctrlSetTextColor [1,1,1,1];

_ctrl ctrlSetStructuredText parseText format ["<a color='#23B500'>%1</a> killed <a color='#B50000'>%2</a> with <a color='#008EB5'>%3</a> from <a color='#B50097'>%4m</a>", _killerName, _unitName, _vehicleName, str(round _distance)];
_ctrl ctrlCommit 0;

_ctrl ctrlSetFade 1;
_ctrl ctrlCommit 10;

0 = (_control) spawn {
	disableSerialization;
	_ctrl = (findDisplay 46) displayCtrl _this;
	
	UISleep 10;
	
	ctrlDelete _ctrl;
	activeControls = activeControls - [_this];
};

activeControls = [_control] + activeControls;
control = control +1;