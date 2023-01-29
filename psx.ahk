#Requires AutoHotkey v2.0

global is_connected := false
global Url := "https://web.roblox.com/games/6284583030"
global LoadedImagePath := A_ScriptDir . "\img\loaded.png"
SendMode "Event"
IsConnected()
{
    ; there is no reason chrome should need to steal focus from the user - fix your problematic "feature", Google
    If WinActive("ahk_exe chrome.exe") && WinExist("ahk_exe RobloxPlayerBeta.exe")
        WinActivate "ahk_exe RobloxPlayerBeta.exe"

    ImageFound := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*40 " . LoadedImagePath)
    Return ImageFound

}

ClickWarp()
{
    SendEvent "{Click 79 502}"

}

ScrollToBottom() {

    MouseMove 957, 483
    Sleep 200
    SendMode "Input"
    Send "{WheelDown 10000}"
    SendMode "Event"
    Sleep 500

}

ScrollToTop() {

    MouseMove 957, 483
    Sleep 200
    SendMode "Input"
    Send "{WheelUp 10000}"
    SendMode "Event"
    Sleep 500

}

FindAndClick(ImageName)
{
    ImageFound := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth , A_ScreenHeight, A_ScriptDir . "\img\" . ImageName)
    if (ImageFound) {
        SendEvent Format("{Click {1}, {2}}", FoundX, FoundY)

    }
    return ImageFound
}

CloseTeleport() {
    FindAndClick("teleport_x.png")
    FindAndClick("teleport_x_hover.png")
}

ClickDestination() {
    SendEvent "{Click 868, 633}"

}

Walk(KeyName, Length:=5)
{
    SendEvent "{" . KeyName . " down}"
    Sleep Length
    Send "{" . KeyName " up}"
}

IsHome()
{
    ImageFound := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth , A_ScreenHeight, A_ScriptDir . "\img\home.png")
    Return ImageFound
}

LaunchLastGame()
{
    if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\img\home.png") > 0) {
        MouseMove 153, 544
        Sleep 200
        SendEvent "{Click 170, 626}"
        Loop {
            FindAndClick("skip.png")
            if(IsConnected()) {
                Sleep 1000
                Break
            }
        }
    }
}

IsInteractable() {
    ImageFound := CheckImageInScales("Interactable.png", 20, 90, 1)
    Return ImageFound
}

LeaveExperience()
{

    SendEvent "{esc}"
    Sleep 100
    SendEvent "{l}"
    Sleep 100
    SendEvent "{enter}"
    Sleep 100
}

MoveCamera(X, Y)
{
    MouseMove A_ScreenWidth // 2, A_ScreenHeight // 2
    MouseGetPos &CurrX, &CurrY
    NewX := CurrX + X
    NewY := CurrY + Y
    MouseClickDrag "right", CurrX, CurrY, NewX, NewY
}

MoveToBarn()
{
    CloseTeleport()
    MoveCamera(-50, 0)
    Walk("w", 6500)
    Walk("s", 300)
    Walk("d", 1500)
    Walk("w", 1600)
    Tries := 0
    Loop {
        SendEvent "{space down}"
        Walk("w", 300)
        SendEvent "{space up}"
        if(IsInteractable()) {
            ;Hit the barn door, load in
            SendEvent "{e}"
            Sleep 5000
            return 1
        }

        Tries := Tries + 1
        if(Tries > 20)
            return 0

    }
}

ClickOnChest() {
    MouseMove 1100, 120
    Click "down"
    Sleep 500
    Click "up"
}

CheckReconnect() {
    LeaveClicked := FindAndClick("leave.png")
    if(LeaveClicked) {
        Sleep 2000
    }
    return LeaveClicked

}

ControlLoop() {

    CloseTeleport()
    ClickNoIfPresent()
    if (CheckReconnect())
        return 1
    ClickOnChest()
    Sleep 5000
    return 0

}

ClickNoIfPresent()
{
    ImageFound := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\img\no.png")
    if (ImageFound) {
        SendEvent "{Click " . FoundX . " " . FoundY . "}"
        Sleep 100
    }
}

CheckImageInScales(ImageName, FromScale, ToScale, Increment:=5)
{
    CurrentWidth := ToScale
    Loop {
        ImagePath := "*50 *w" . CurrentWidth . " *h-1 " . A_ScriptDir . "\img\" . ImageName
        ImageFound := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, ImagePath)
        if(ImageFound)
            Return 1

        CurrentWidth := CurrentWidth - Increment

        if(CurrentWidth < FromScale)
            Return 0
    }
}

WarpToDoodleFarm()
{
    CloseTeleport()
    Sleep 1000
    ClickWarp()
    ScrollToBottom()
    ClickDestination()
    Sleep 1000
    Loop {
        if(IsConnected()) {
            Sleep 1000
            Break
        }
    }
    CloseTeleport()
    Sleep 1000
}

FixCamera() {
    ScrollToBottom()
}

WarpToSomewhere()
{
    CloseTeleport()
    Sleep 1000
    ClickWarp()
    ScrollToTop()
    ClickDestination()
    Sleep 1000
    Loop {
        if(IsConnected()) {
            Sleep 1000
            Break
        }
    }
    CloseTeleport()
    Sleep 1000
}

PrepForGrind() {
    WinActivate "ahk_exe RobloxPlayerBeta.exe"
    if(IsConnected())
        LeaveExperience()
    LaunchLastGame()
    Sleep 1000
    WarpToDoodleFarm()
    Sleep 1000
    CloseTeleport()
}

GrindPrep()
{
    Tries := 0
    Loop {
        PrepForGrind()
        GotToBarn := MoveToBarn()
        if(GotToBarn) {
            MoveCamera(-50, 0)
            Break
        }
        Tries := Tries + 1
        if(Tries > 5)
            ExitApp
    }
}

GrindLoop()
{
    Loop {

        LoopResultFailed := ControlLoop()
        if(LoopResultFailed)
            GrindPrep()
    }
}

GrindBarn() {
    GrindPrep()
    GrindLoop()
}

F4::
    {
        GrindBarn()
    }

F5::
    {
        GrindLoop()
    }

F7::
    {
        Walk("w", 300)
    }

F8::
    {
        MoveCamera(50, 0)
    }

F9::
    {
        MsgBox IsInteractable()
    }

F3::
    {
        Keys := ["a", "s", "d", "w"]
        For K in Keys
            Send Format("{{1} up}", K)

        Click "up"
        Click "up right"
        Reload
    }