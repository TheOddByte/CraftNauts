--[[
	Store information about character.
	Calculate collision volumes.
	Check for abilities.
	Check for actions: Jumping, Crouching, etc.
	
	Example for a character:

	local characters = {}

	characters['clunk'] = {
		["name"] = "Clunk";
		["skin"] = {
			["left"] = {
					"Ascii image of Clunk pointing to the left"
				};
			["right"] = {
					"Ascii image of Clunk pointing to the right"
				};
			["stand"] = {
					"Ascii image of Clunk standing"
				};
		};
		["stats"] = {
			["health"] = 100;
			["mana"]   = 100;
			["jump"]   = 3
		};
		["abilities"] = {
			[1] = {
				["name"] = "Ability1";
				["desc"] = "Does stuff";
				["exec"] = "functionname";
				["price"] = 100;
				["upgrades"] = {
					[1] = {
						["desc"] = "Does more stuff";
						["price"] = 150;
						["exec"] = "functionname"
					}
					[2] = {
						["desc"] = "Does more stuff";
						["price"] = 200;
						["exec"] = "functionname"
					}
					[3] = {
						["desc"] = "Does more stuff";
						["price"] = 250;
						["exec"] = "functionname"
					}
				}
			}
			[2] = {
				["name"] = "Ability2";
				["desc"] = "Does stuff";
				["exec"] = "functionname";
				["price"] = 100;
				["upgrades"] = {
					[1] = {
						["desc"] = "Does more stuff";
						["price"] = 150;
						["exec"] = "functionname"
					}
					[2] = {
						["desc"] = "Does more stuff";
						["price"] = 200;
						["exec"] = "functionname"
					}
					[3] = {
						["desc"] = "Does more stuff";
						["price"] = 250;
						["exec"] = "functionname"
					}
				}
			}
			[3] = {
				["name"] = "Ability3";
				["desc"] = "Does stuff";
				["exec"] = "functionname";
				["price"] = 100;
				["upgrades"] = {
					[1] = {
						["desc"] = "Does more stuff";
						["price"] = 150;
						["exec"] = "functionname"
					}
					[2] = {
						["desc"] = "Does more stuff";
						["price"] = 200;
						["exec"] = "functionname"
					}
					[3] = {
						["desc"] = "Does more stuff";
						["price"] = 250;
						["exec"] = "functionname"
					}
				}
			}
		};
		["powerups"] = {
			[1] = {
				["name"] = "Strenght";
				["desc"] = "Makes you stronger";
				["exec"] = "functionname"
			}
			[2] = {
				["name"] = "Health";
				["desc"] = "Gives you more health";
				["exec"] = "functionname"
			}
			[3] = {
				["name"] = "Speed";
				["desc"] = "Makes you faster";
				["exec"] = "functionname"
			}
			[4] = {
				["name"] = "Mana";
				["desc"] = "Gives you more mana";
				["exec"] = "functionname"
			}
		}
	}
]]