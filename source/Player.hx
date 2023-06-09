package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	/* NEW: to give footsteps to player. We don't want to create and destroy a new sound 
		object every time we want to play the same sound, so we will create a FlxSound object 
		to be used over and over */
	var stepSound:FlxSound;

	static inline var SPEED:Float = 100;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		// add footstep to constructor:
		// stepSound = FlxG.sound.load(AssetPaths.steps__wav);
		stepSound = FlxG.sound.load("assets/sounds/steps.wav");

		loadGraphic(AssetPaths.player__png, true, 16, 16);
		drag.x = drag.y = 800;

		setSize(8, 8);
		offset.set(4, 4);

		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);

		animation.add("d_idle", [0]);
		animation.add("lr_idle", [3]);
		animation.add("u_idle", [6]);
		animation.add("d_walk", [0, 1, 0, 2], 6);
		animation.add("lr_walk", [3, 4, 3, 5], 6);
		animation.add("u_walk", [6, 7, 6, 8], 6);
	}

	function updateMovement()
	{
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;

		// update our keys to accomodate for mobile. How? making these exist only if there's a keyboard.
		#if FLX_KEYBOARD
		up = FlxG.keys.anyPressed([UP, W]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);
		#end

		// FOR MOBILE. Looks a little stiff...
		#if mobile
		var virtualPad = PlayState.virtualPad;
		up = up || virtualPad.buttonUp.pressed;
		down = down || virtualPad.buttonDown.pressed;
		left = left || virtualPad.buttonLeft.pressed;
		right = right || virtualPad.buttonRight.pressed;
		#end

		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		if (up || down || left || right)
		{
			var newAngle:Float = 0;
			if (up)
			{
				newAngle = -90;
				if (left)
					newAngle -= 45;
				else if (right)
					newAngle += 45;

				facing = UP;
			}
			else if (down)
			{
				newAngle = 90;
				if (left)
					newAngle += 45;
				else if (right)
					newAngle -= 45;

				facing = DOWN;
			}
			else if (left)
			{
				newAngle = 180;
				facing = LEFT;
			}
			else if (right)
			{
				newAngle = 0;
				facing = RIGHT;
			}

			velocity.setPolarDegrees(SPEED, newAngle);
		}

		var action = "idle";

		if ((velocity.x != 0 || velocity.y != 0) && touching == NONE)
		{
			action = "walk";
			stepSound.play(); // if player is walking, play the sound.
		}

		switch (facing)
		{
			case LEFT, RIGHT:
				animation.play("lr_" + action); // this could be lr_idle or lr_walk
			case UP:
				animation.play("u_" + action);
			case DOWN:
				animation.play("d_" + action);
			case _:
		}
	}

	override function update(elapsed:Float)
	{
		updateMovement();
		super.update(elapsed);
	}
}
