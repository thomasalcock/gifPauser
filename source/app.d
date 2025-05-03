import std.stdio;
import std.conv;
import raylib;

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
	int frameDelay = 8;
	int frameCounter = 0;
	bool updateTexture = true;
	bool reverse = false;
	char* filePath;
	int textFadeValue = 0;

	InitWindow(screenWidth, screenHeight, "gifPauser");
	SetTargetFPS(60);

	while (!WindowShouldClose())
	{
		fileDropped = IsFileDropped();
		if (fileDropped)
		{
			writeln("reset text fade value");
			textFadeValue = 255;
			loadTextureFromGif(fileCounter, totalFrames, image, texture, filePath);
		}

		if (IsKeyPressed(KeyboardKey.KEY_SPACE))
		{
			updateTexture = !updateTexture;
		}
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
		Rectangle source = Rectangle(0, 0, cast(float) texture.width, cast(float) texture.height);
		Rectangle dest = Rectangle(0, 0, cast(float) GetScreenWidth(), cast(float) GetScreenHeight());

		if (fileCounter > 0)
		{
			DrawTexturePro(texture, source, dest, Vector2(0, 0), 0.0f, Colors.WHITE);
			// TODO: store magic numbers in variables
			if (frameCounter >= 7)
			{
				textFadeValue -= 25;
			}
			if (textFadeValue <= 10)
			{
				textFadeValue = 0;
			}
			writeln(textFadeValue);
			DrawTextPro(GetFontDefault(), TextFormat("Loaded file %s", filePath),
				Vector2(100, 100),
				Vector2(0, 0),
				0.0f, 50, 1, Color(0, 0, 0, cast(ubyte) textFadeValue)); //TODO: do arithmetic on ubyte to avoid cast
		}
		else
		{
			drawInstructions();
		}
		EndDrawing();
	}
	UnloadTexture(texture);
	UnloadImage(image);
	CloseWindow();
}
