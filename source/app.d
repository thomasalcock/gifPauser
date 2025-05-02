import std.stdio;
import std.conv;
import raylib;

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

	InitWindow(screenWidth, screenHeight, "gifPauser");
	SetTargetFPS(60);

	while (!WindowShouldClose())
	{
		fileDropped = IsFileDropped();
		if (fileDropped)
		{
			fileCounter++;
			FilePathList droppedFile = LoadDroppedFiles();
			char* filePath = droppedFile.paths[0];
			image = LoadImageAnim(filePath, &totalFrames);
			texture = LoadTextureFromImage(image);
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
				if (currentAnimFrame >= totalFrames)
				{
					currentAnimFrame = 0;
				}
				nextFrameDataOffset = image.width * image.height * 4 * currentAnimFrame;
				UpdateTexture(texture, (image.data) + nextFrameDataOffset);
				frameCounter = 0;
			}
		}

		if (IsKeyPressed(KeyboardKey.KEY_DOWN))
		{
			frameDelay++;
		}
		else if (IsKeyPressed(KeyboardKey.KEY_UP))
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
		Rectangle source = Rectangle(0, 0, cast(float) texture.width, cast(float) texture.height);
		Rectangle dest = Rectangle(0, 0, cast(float) screenWidth, cast(float) screenHeight);

		if (fileCounter > 0)
		{
			DrawTexturePro(texture, source, dest, Vector2(0, 0), 0.0f, Colors.WHITE);
		}
		else
		{

			DrawText("Drag and drop a .gif file onto the screen!", 100, 100, 20, Colors.GRAY);
			DrawText("Play the gif faster / slower by hitting up / down!", 100, 150, 20, Colors
					.GRAY);
			DrawText("Play / pause by hitting the spacebar!", 100, 200, 20, Colors
					.GRAY);
		}
		EndDrawing();
	}
	UnloadTexture(texture);
	UnloadImage(image);
	CloseWindow();
}
