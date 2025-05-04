module utils;

import raylib;
import std.stdio;

void loadTextureFromGif(
    ref int fileCounter,
    ref int totalFrames,
    ref Image image,
    ref Texture texture,
    ref char* filePath,
    ref char* filePathString)
{
    fileCounter++;
    FilePathList droppedFile = LoadDroppedFiles();
    filePath = droppedFile.paths[0];
    TextCopy(filePathString, filePath);
    image = LoadImageAnim(filePath, &totalFrames);
    texture = LoadTextureFromImage(image);
    UnloadDroppedFiles(droppedFile);
}

void reverseGif(ref bool reverse, ref int currentAnimFrame, ref int totalFrames)
{
    if (reverse)
    {
        currentAnimFrame--;
        if (currentAnimFrame < 0)
        {
            currentAnimFrame = totalFrames - 1;
        }
    }
    else
    {
        currentAnimFrame++;
        if (currentAnimFrame >= totalFrames)
        {
            currentAnimFrame = 0;
        }
    }
}

void updateGifFrame(ref int frameCounter, ref int frameDelay, ref int currentAnimFrame, ref int totalFrames,
    ref bool reverse, ref uint nextFrameDataOffset, ref Image image, ref Texture texture)
{
    frameCounter++;
    if (frameCounter >= frameDelay)
    {
        reverseGif(reverse, currentAnimFrame, totalFrames);
        nextFrameDataOffset = image.width * image.height * 4 * currentAnimFrame;
        UpdateTexture(texture, (image.data) + nextFrameDataOffset);
        frameCounter = 0;
    }
}

void pauseGif(ref bool paused, ref bool updateTexture, ref int pauseTextFadeValue, ref int playTextFadeValue)
{
    if (IsKeyPressed(KeyboardKey.KEY_SPACE))
    {
        paused = !paused;
        updateTexture = !updateTexture;
        if (paused)
        {
            pauseTextFadeValue = 255;
            playTextFadeValue = 0;
        }
        else
        {
            pauseTextFadeValue = 0;
            playTextFadeValue = 255;
        }
    }
}

void drawInstructions()
{
    DrawText("Drag and drop a .gif file onto the screen", 100, 100, 20, Colors.RAYWHITE);
    DrawText("Play the gif faster / slower by hitting up / down", 100, 150, 20, Colors
            .RAYWHITE);
    DrawText("Play / pause by hitting the spacebar", 100, 200, 20, Colors
            .RAYWHITE);
    DrawText("Reverse the gif by hitting the R key", 100, 250, 20, Colors
            .RAYWHITE);
}

void changeGifSpeed(ref int frameDelay, const ref int MIN_FRAME_DELAY, const ref int MAX_FRAME_DELAY)
{
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

}
