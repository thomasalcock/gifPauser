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

void updateTextTransparency(
    ref int someFrameCounter,
    ref int textFadeValue,
    const ref int frameDelay,
    const ref int textFadeDelta,
    const ref int textFadeThreshold
)
{
    someFrameCounter++;
    if (someFrameCounter >= frameDelay - 1)
    {
        textFadeValue -= textFadeDelta;
    }
    if (textFadeValue <= textFadeThreshold)
    {
        textFadeValue = 0;
    }
}

void pauseGif(ref bool paused,
    ref bool play,
    ref bool updateTexture,
    ref int pauseTextFadeValue,
    ref int playTextFadeValue)
{
    if (IsKeyPressed(KeyboardKey.KEY_SPACE))
    {
        paused = !paused;
        updateTexture = !updateTexture;
        if (paused)
        {
            pauseTextFadeValue = 255;
            playTextFadeValue = 0;
            play = false;
        }
        else
        {
            play = true;
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

void changeGifSpeed(ref int frameDelay,
    ref bool increaseSpeed,
    ref bool decreaseSpeed,
    ref int increaseSpeedTextFadeValue,
    ref int decreaseSpeedTextFadeValue,
    const ref int MIN_FRAME_DELAY,
    const ref int MAX_FRAME_DELAY)
{
    if (IsKeyPressed(KeyboardKey.KEY_DOWN))
    {
        frameDelay++;
        decreaseSpeed = true;
        increaseSpeed = false;
        decreaseSpeedTextFadeValue = 255;
        increaseSpeedTextFadeValue = 0;
    }
    else if (IsKeyPressed(KeyboardKey.KEY_UP))
    {
        frameDelay--;
        decreaseSpeed = false;
        increaseSpeed = true;
        decreaseSpeedTextFadeValue = 0;
        increaseSpeedTextFadeValue = 255;
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

void showFadingText(
    const char* text,
    ref bool buttonActivation,
    ref int frameCountSinceButtonPress,
    ref int speedTextFadeValue,
    ref int frameDelay,
    const ref int textFadeDelta,
    const ref int textFadeThreshold)
{
    if (buttonActivation)
    {
        updateTextTransparency(frameCountSinceButtonPress,
            speedTextFadeValue, frameDelay,
            textFadeDelta, textFadeThreshold);

        if (speedTextFadeValue > 0)
        {
            DrawTextPro(GetFontDefault(), text,
                Vector2(GetScreenWidth() - 100, 10),
                Vector2(0, 0),
                0.0f, 20, 1, Color(255, 255, 255, cast(ubyte) speedTextFadeValue));
        }
    }
}
