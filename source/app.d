import std.stdio;
import std.conv;
import raylib;
import core.memory;
import utils;

// TODO: make window resizeable
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
	int frameDelay = 5;
	int frameCounter = 0;
	bool updateTexture = true;
	bool reverse = false;
	bool pause = false;
	char* filePath;
	char* filePathString = cast(char*) GC.calloc(char.sizeof * 200);

	int pauseTextFadeValue = 0;
	int pauseFrameCounter = 0;
	int fileTextFadeValue = 0;
	const int textFadeDelta = 15;
	const int textFadeThreshold = 10;

	InitWindow(screenWidth, screenHeight, "gifPauser");
	SetTargetFPS(60);
	while (!WindowShouldClose())
	{
		fileDropped = IsFileDropped();
		if (fileDropped)
		{
			fileTextFadeValue = 255;
			loadTextureFromGif(fileCounter, totalFrames, image,
				texture, filePath, filePathString);
		}

		pauseGif(pause, updateTexture, pauseTextFadeValue);

		if (IsKeyPressed(KeyboardKey.KEY_R))
		{
			reverse = !reverse;
		}

		if (updateTexture && fileCounter > 0)
		{
			updateGifFrame(frameCounter, frameDelay, currentAnimFrame, totalFrames,
				reverse, nextFrameDataOffset, image, texture);
		}

		changeGifSpeed(frameDelay, MIN_FRAME_DELAY, MAX_FRAME_DELAY);

		BeginDrawing();
		ClearBackground(Colors.DARKGRAY);
		Rectangle source = Rectangle(0, 0, cast(float) texture.width, cast(
				float) texture.height);
		Rectangle dest = Rectangle(0, 0, cast(
				float) GetScreenWidth(), cast(float) GetScreenHeight());

		if (fileCounter > 0)
		{
			DrawTexturePro(texture, source, dest, Vector2(0, 0), 0.0f, Colors.WHITE);
			if (frameCounter >= frameDelay - 1)
			{
				fileTextFadeValue -= textFadeDelta;
			}
			if (fileTextFadeValue <= textFadeThreshold)
			{
				fileTextFadeValue = 0;
			}
			if (fileTextFadeValue > 0)
			{
				DrawTextPro(GetFontDefault(), TextFormat("Loaded file %s", filePathString),
					Vector2(10, 10),
					Vector2(0, 0),
					0.0f, 20, 1, Color(255, 255, 255, cast(ubyte) fileTextFadeValue));
				//TODO: do arithmetic on ubyte to avoid cast
			}
			if (pause)
			{
				pauseFrameCounter++;
				if (pauseFrameCounter >= frameDelay - 1)
				{
					pauseTextFadeValue -= textFadeDelta;
				}
				if (pauseTextFadeValue <= textFadeThreshold)
				{
					pauseTextFadeValue = 0;
				}
				if (pauseTextFadeValue > 0)
				{
					DrawTextPro(GetFontDefault(), "Paused",
						Vector2(GetScreenWidth() - 100, 10),
						Vector2(0, 0),
						0.0f, 20, 1, Color(255, 255, 255, cast(ubyte) pauseTextFadeValue));
				}
			}

			if (reverse)
			{
				DrawTextPro(GetFontDefault(), "Reverse",
					Vector2(GetScreenWidth() - 100, 50),
					Vector2(0, 0),
					0.0f, 20, 1, Color(255, 255, 255, 255));

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
