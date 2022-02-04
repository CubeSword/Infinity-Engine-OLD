# ♾️ Infinity Engine
-----
![](https://media.discordapp.net/attachments/782707705792954388/931918337989029948/Untitled108_20220115083034.png)
-----
Made by 4 people literally out of pure boredom, Aiming to rewrite Friday Night Funkin' to include
easier modding, cool features, and little quality of life shits
-----
# ℹ️ Preparing Libraries for Compiling
If you want to compile Infinity Engine from source, Here's what you need to do:

- Install [Haxe](https://haxe.org/download/)
- Install [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/)
- Install [Git](https://git-scm.com/)

***MAKE SURE TO USE THE LATEST VERSION OF HAXE!! OTHERWISE COMPILING MAY NOT WORK.***

If you're too lazy to read the HaxeFlixel install docs then here's the fuckin commands:

**Installing the basics**
--
```
haxelib install lime
haxelib install openfl
haxelib install flixel
```

**Setup**
--
```
haxelib run lime setup flixel
haxelib run lime setup (IF THIS ASKS TO MAKE LIME A COMMAND, TYPE Y)
haxelib install flixel-tools
haxelib run flixel-tools setup
```

**Updating**
--
In order to update a library (which you should try to do somewhat often)

You just do:
`haxelib update [library]`

Example:
`haxelib update flixel`

**Libraries**
--
These are libraries you need for the game to correctly compile:
(Copy the commands to install them)

```
haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git linc_luajit https://github.com/AndreiRudenko/linc_luajit
haxelib install flixel-ui
haxelib install hscript
```

-----
# 💻 Compiling
**If you see ANY deprecated warnings, Don't worry, They won't affect compiling.**
--
## HTML5 Compiling
All you need to do here is run `lime test html5` in the root folder of the source code. (or wherever project.xml is)

## Windows Compiling
Once you have all of the library shits installed, You must install [Visual Studio 2019](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=community&rel=16&utm_medium=microsoft&utm_source=docs.microsoft.com&utm_campaign=download+from+relnotes&utm_content=vs2019ga+button).
If that link downloads VS 2022 instead, Please let one of the Infinity Engine team know so we can correct the link!

While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:

- MSVC v142 - VS 2019 C++ x64/x86 build tools
- Windows SDK (10.0.17763.0)

This will install like 5GB of bullshit, but it is needed to compile.
After all of that shit's done run `lime test windows`.

## Mac Compiling
--
I (swordcube) do not own a Mac myself and can't confirm this but this might work:
Open a terminal in the root source code folder and run `lime test mac`.

There should be tutorials on how to compile for Mac if that doesn't work, surely.

## Linux Compiling
Open a terminal in the root source code folder and run `lime test linux`.

Executable file will be in `export/release/linux/bin`.

**NOTE:** Compiling is going to take a long time for the first time, and maybe even in general.
The compiling speed depends on your hardware.
-----
# ℹ️ What we have planned / What we're working on
- Easy Modding (Working on it)
- Modcharts/Lua Scripting
- Custom Notes (Using LUA or smth, could have a json for storing shit like "act like death note or use lua file")
- Extra Keys (1k to 9k, Could change eventually)
- Replays
- Achievements (Unhardcoded too!!!)

# ✅ Finished/Almost Finished
- Basic Gameplay (Characters, Health, Score/Accuracy/Misses, Notes)
- Stages/Backgrounds (Only Week 1 - 3 stages exist at the moment)
- Menus

## 📖 Credits
- Raf - Project Owner, Coder and Artist ([GitHub](https://github.com/RafaelGiacom)) ([GameJolt](https://gamejolt.com/@RafaelGiacom)) ([GameBanana](https://gamebanana.com/members/1739332))
- SwordCube - mega dumbass (True Facts), Coder, Artist ([GitHub](https://github.com/swordcube)) ([GameJolt](https://gamejolt.com/@swordcube)) ([Twitter](https://twitter.com/swordcube))
- ZonianDX - Coder, Gamer 😎, Artist ([GitHub](https://github.com/timeless13GH)) ([Twitter](https://twitter.com/ZonianDX)) ([GameBanana](https://gamebanana.com/members/2029461))
- Leather128 - Coder but the best out of the coders ([GitHub](https://github.com/Leather128)) ([GameBanana](https://gamebanana.com/members/1799813)) ([Itch.io](https://leather128.itch.io/)) ([YouTube](https://www.youtube.com/channel/UCbCtO-ghipZessWaOBx8u1g))
