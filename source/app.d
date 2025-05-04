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
	int frameDelay = 8;
	int frameCounter = 0;
	bool updateTexture = true;
	bool reverse = false;
	char* filePath;
	char* filePathString = cast(char*) GC.calloc(char.sizeof * 200);
	int textFadeValue = 0;
	const int textFadeDelta = 15;
	const int textFadeThreshold = 10;

	InitWindow(screenWidth, screenHeight, "gifPauser");
	SetTargetFPS(60);
	while (!WindowShouldClose())
	{
		fileDropped = IsFileDropped();
		if (fileDropped)
		{
			textFadeValue = 255;
			loadTextureFromGif(fileCounter, totalFrames, image,
				texture, filePath, filePathString);
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
		Rectangle source = Rectangle(0, 0, cast(float) texture.width, cast(
				float) texture.height);
		Rectangle dest = Rectangle(0, 0, cast(
				float) GetScreenWidth(), cast(float) GetScreenHeight());

		if (fileCounter > 0)
		{
			DrawTexturePro(texture, source, dest, Vector2(0, 0), 0.0f, Colors.WHITE);
			if (frameCounter >= frameDelay - 1)
			{
				textFadeValue -= textFadeDelta;
			}
			if (textFadeValue <= textFadeThreshold)
			{
				textFadeValue = 0;
			}
			if (textFadeValue > 0)
			{
				DrawTextPro(GetFontDefault(), TextFormat("Loaded file %s", filePathString),
					Vector2(10, 10),
					Vector2(0, 0),
					0.0f, 20, 1, Color(255, 255, 255, cast(ubyte) textFadeValue));
				//TODO: do arithmetic on ubyte to avoid cast
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
