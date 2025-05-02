import std.stdio;
import std.conv;
import raylib;

void main()
{
	const int screenWidth = 800;
	const int screenHeight = 600;
	const int MAX_FRAME_DELAY = 20;
	const int MIN_FRAME_DELAY = 1;
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

		// BeginTextureMode(renderTexture);
		// ClearBackground(Colors.RAYWHITE);
		// EndTextureMode();

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
			DrawText("Drag and drop a .gif file onto the screen!", 100, 100, 30, Colors.GRAY);
		}
		EndDrawing();
	}
	UnloadTexture(texture);
	UnloadImage(imScarfyAnim);
	CloseWindow();
}
