import std.stdio;
import std.conv;
import raylib;

// TODO: resize gifs
// TODO: dark mode
void main()
{
	const int screenWidth = 1024;
	const int screenHeight = 768;
	const int MAX_FRAME_DELAY = 20;
	const int MIN_FRAME_DELAY = 1;
	// const int MAX_FILEPATH_RECORDED = 4096;
	//const int MAX_FILEPATH_SIZE = 2048;
	//char*[MAX_FILEPATH_SIZE] filePath;
	Image imScarfyAnim;
	Texture2D texture;

	bool fileDropped = false;
	int fileCounter = 0;
	int animFrames = 0;
	uint nextFrameDataOffset = 0;
	int currentAnimFrame = 0;
	int frameDelay = 8;
	int frameCounter = 0;
	bool updateTexture = true;

	InitWindow(screenWidth, screenHeight, "gifPlayer");
	SetTargetFPS(60);

	while (!WindowShouldClose())
	{
		fileDropped = IsFileDropped();
		if (fileDropped)
		{
			fileCounter++;
			FilePathList droppedFile = LoadDroppedFiles();
			char* filePath = droppedFile.paths[0];
			imScarfyAnim = LoadImageAnim(filePath, &animFrames);
			texture = LoadTextureFromImage(imScarfyAnim);
			UnloadDroppedFiles(droppedFile);
		}

		if (IsKeyPressed(KeyboardKey.KEY_SPACE))
		{
			updateTexture = !updateTexture;
		}

		if (updateTexture && fileCounter > 0)
		{
			frameCounter++;
			if (frameCounter >= frameDelay)
			{
				currentAnimFrame++;
				if (currentAnimFrame >= animFrames)
				{
					currentAnimFrame = 0;
				}
				nextFrameDataOffset = imScarfyAnim.width * imScarfyAnim.height * 4 * currentAnimFrame;
				UpdateTexture(texture, (imScarfyAnim.data) + nextFrameDataOffset);
				frameCounter = 0;
			}
		}

		if (IsKeyPressed(KeyboardKey.KEY_RIGHT))
		{
			frameDelay++;
		}
		else if (IsKeyPressed(KeyboardKey.KEY_LEFT))
		{
			frameDelay--;
		}

		if (frameDelay > MAX_FRAME_DELAY)
		{
			frameDelay = MAX_FRAME_DELAY;
		}
		else if (frameDelay < MIN_FRAME_DELAY)
		{
			frameDelay = MIN_FRAME_DELAY;
		}

		BeginDrawing();

		ClearBackground(Colors.RAYWHITE);

		if (fileCounter > 0)
		{
			// DrawText(TextFormat("TOTAL GIF FRAMES:  %02i", animFrames), 50, 30, 20, Colors.GRAY);
			// DrawText(TextFormat("CURRENT FRAME: %02i", currentAnimFrame), 50, 60, 20, Colors.GRAY);
			// DrawText(TextFormat("CURRENT FRAME IMAGE.DATA OFFSET: %02i",
			// 		nextFrameDataOffset), 50, 90, 20, Colors.GRAY);
			DrawText("FRAMES DELAY: ", 100, 500, 10, Colors.DARKGRAY);
			DrawText(TextFormat("%02i frames", frameDelay), 620, 450, 10, Colors.DARKGRAY);
			DrawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 500, 10, Colors.DARKGRAY);

			{
				DrawTexture(texture, GetScreenWidth() / 2 - texture.width / 2, 140, Colors.WHITE);
			}

		}
		else
		{
			DrawText("Drag and drop a .gif file onto the screen!", 100, 100, 30, Colors.GRAY);
		}
		EndDrawing();
	}
	UnloadTexture(texture);
	UnloadImage(imScarfyAnim);
	CloseWindow();
}
