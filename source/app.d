import std.stdio;
import std.conv;
import raylib;
import core.memory;
import utils;

// TODO: allow user to save single file as 
// TODO: allow user to iterate through single frames
// TODO: display and fade out text / state when user changes input
void main()
{
	const int screenWidth = 800;
	const int screenHeight = 600;
	const int MAX_FRAME_DELAY = 20;
	const int MIN_FRAME_DELAY = 1;
	Image image;
	Texture2D texture;
	bool fileDropped = false;
	int fileCounter = 0;
	int totalFrames = 0;
	uint nextFrameDataOffset = 0;
	int currentAnimFrame = 0;
	int frameDelay = 11;
	bool increaseSpeed = false;
	bool decreaseSpeed = false;
	int frameCounter = 0;
	bool updateTexture = true;
	bool reverse = false;
	bool pause = false;
	char* filePath;
	char* filePathString = cast(char*) GC.calloc(char.sizeof * 200);

	int reverseFrameCount = 0;
	int reverseTextFadeValue = 0;
	int increaseSpeedFrameCount = 0;
	int increaseSpeedTextFadeValue = 0;
	int decreaseSpeedFrameCount = 0;
	int decreaseSpeedTextFadeValue = 0;
	int playFrameCounter = 0;
	int playTextFadeValue = 0;
	int pauseTextFadeValue = 0;
	int pauseFrameCounter = 0;
	int fileTextFadeValue = 0;

	const int textFadeDelta = 20;
	const int textFadeThreshold = 10;

	InitWindow(screenWidth, screenHeight, "gifPauser");
	SetTargetFPS(60);
	SetWindowState(ConfigFlags.FLAG_WINDOW_RESIZABLE);

	while (!WindowShouldClose())
	{
		fileDropped = IsFileDropped();
		if (fileDropped)
		{
			fileTextFadeValue = 255;
			loadTextureFromGif(fileCounter, totalFrames, image,
				texture, filePath, filePathString);
		}

		pauseGif(pause, updateTexture, pauseTextFadeValue, playTextFadeValue);

		if (IsKeyPressed(KeyboardKey.KEY_R))
		{
			reverse = !reverse;
			reverseTextFadeValue = 255;
		}

		if (updateTexture && fileCounter > 0)
		{
			updateGifFrame(frameCounter, frameDelay, currentAnimFrame, totalFrames,
				reverse, nextFrameDataOffset, image, texture);
		}

		changeGifSpeed(frameDelay, increaseSpeed, decreaseSpeed,
			increaseSpeedTextFadeValue, decreaseSpeedTextFadeValue,
			MIN_FRAME_DELAY, MAX_FRAME_DELAY);

		BeginDrawing();
		ClearBackground(Colors.DARKGRAY);
		Rectangle source = Rectangle(0, 0, cast(float) texture.width, cast(float) texture.height);
		Rectangle dest = Rectangle(0, 0, cast(float) GetScreenWidth(), cast(float) GetScreenHeight());

		if (fileCounter > 0)
		{
			DrawTexturePro(texture, source, dest, Vector2(0, 0), 0.0f, Colors.WHITE);
			updateTextTransparency(frameCounter, fileTextFadeValue, frameDelay, textFadeDelta, textFadeThreshold);
			if (fileTextFadeValue > 0)
			{
				DrawTextPro(GetFontDefault(), TextFormat("Loaded file %s", filePathString),
					Vector2(10, 10),
					Vector2(0, 0),
					0.0f, 20, 1, Color(255, 255, 255, cast(ubyte) fileTextFadeValue));
				//TODO: do arithmetic on ubyte to avoid cast
			}

			if (increaseSpeed)
			{
				updateTextTransparency(increaseSpeedFrameCount, increaseSpeedTextFadeValue, frameDelay,
					textFadeDelta, textFadeThreshold);

				if (increaseSpeedTextFadeValue > 0)
				{
					DrawTextPro(GetFontDefault(), "Faster!",
						Vector2(GetScreenWidth() - 100, 10),
						Vector2(0, 0),
						0.0f, 20, 1, Color(255, 255, 255, cast(ubyte) increaseSpeedTextFadeValue));
				}
			}

			if (decreaseSpeed)
			{
				updateTextTransparency(decreaseSpeedFrameCount, decreaseSpeedTextFadeValue, frameDelay,
					textFadeDelta, textFadeThreshold);
				if (decreaseSpeedTextFadeValue > 0)
				{
					DrawTextPro(GetFontDefault(), "Slower!",
						Vector2(GetScreenWidth() - 100, 10),
						Vector2(0, 0),
						0.0f, 20, 1, Color(255, 255, 255, cast(ubyte) decreaseSpeedTextFadeValue));
				}
			}

			if (pause)
			{
				updateTextTransparency(pauseFrameCounter, pauseTextFadeValue, frameDelay, textFadeDelta, textFadeThreshold);
				if (pauseTextFadeValue > 0)
				{
					DrawTextPro(GetFontDefault(), "Paused",
						Vector2(GetScreenWidth() - 100, 10),
						Vector2(0, 0),
						0.0f, 20, 1, Color(255, 255, 255, cast(ubyte) pauseTextFadeValue));
				}
			}
			else
			{
				updateTextTransparency(playFrameCounter, playTextFadeValue, frameDelay, textFadeDelta, textFadeThreshold);
				if (playTextFadeValue > 0)
				{
					DrawTextPro(GetFontDefault(), "Play",
						Vector2(GetScreenWidth() - 100, 10),
						Vector2(0, 0),
						0.0f, 20, 1, Color(255, 255, 255, cast(ubyte) playTextFadeValue));
				}
			}

			if (reverse)
			{
				updateTextTransparency(reverseFrameCount, reverseTextFadeValue, frameDelay, textFadeDelta, textFadeThreshold);
				if (reverseTextFadeValue > 0)
				{
					DrawTextPro(GetFontDefault(), "Reverse",
						Vector2(GetScreenWidth() - 100, 10),
						Vector2(0, 0),
						0.0f, 20, 1, Color(255, 255, 255, cast(ubyte) reverseTextFadeValue));
				}
			}

		}
		else
		{
			drawInstructions();
		}
		EndDrawing();
	}
	GC.free(filePathString);
	UnloadTexture(texture);
	UnloadImage(image);
	CloseWindow();
}
